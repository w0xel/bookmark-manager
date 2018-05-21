namespace BookmarkManager {
public class TimeoutThread {
    private string nickname;

    public TimeoutThread(string nickname) {
        this.nickname = nickname;
    }
    
    public void* timeout() {
        while (true) {
            if (SSHManager.get_instance().checkTimeout(this.nickname)) {
                return null;
            }

            Thread.usleep(5000000);
        }
        return null;
    }
}
public class SSHManager {
    private static SSHManager instance = null;

    private Gee.HashMap<string, ListBoxRow> rowMap;
    private Gee.HashMap<string, Pid> pidMap;
    private Gee.HashMap<string, int64?> timeMap;
    private Gee.HashMap<string, TimeoutThread> threadMap;
    
    
    SSHManager() {
        rowMap = new Gee.HashMap<string, ListBoxRow>();
        pidMap = new Gee.HashMap<string, Pid>();
        timeMap = new Gee.HashMap<string, int64?>();
        threadMap = new Gee.HashMap<string, TimeoutThread>();
    }

    private bool process_line (IOChannel channel, IOCondition condition, int stream, string nickname) {
	    try {
		    string line;
	    	channel.read_line (out line, null, null);
            if (line == null) {
                stdout.printf("Line not there!\n");
                return false;
            }
            if (stream == 1) {
                Notify.Notification notification = new Notify.Notification ("SSH Error", line, "dialog-warning");
		        notification.show ();
            }
            if (line.contains("connected")) {
                if (rowMap.has_key(nickname))
                    rowMap[nickname].sshConnected();
            } else if (line.contains("still alive")) {
                timeMap[nickname] = GLib.get_real_time () / 1000;
                if (rowMap.has_key(nickname))
                    rowMap[nickname].sshConnected();
            } else if (stream == 0) {
                new Alert("Unexpected output from ssh", line);
            }
	    } catch (IOChannelError e) {
	    	return false;
	    } catch (ConvertError e) {
		    return false;
	    }

	    return true;
    }

    public bool checkTimeout(string nickname) {
        if (!pidMap.has_key(nickname))
            return true;

        var now = GLib.get_real_time () / 1000;;
        if (timeMap[nickname] + 30000 < now) {
            this.stop(nickname);
            
            Notify.Notification notification = new Notify.Notification ("SSH Timeout", nickname, "dialog-warning");
		    notification.show ();
            return true;
        } else if (timeMap[nickname] + 7000 < now) {
            this.loading(nickname);
            return false;
        }
        return false;
    }

    public bool getIsAnyRunning() {
        if (pidMap.size > 0)
            return true;
        else
            return false;
    }

    public void quit_all() {
        foreach (var pid in pidMap.entries) {
            Posix.kill(pid.value, Posix.SIGTERM);
        }
    }

    public void spawnBackground(string sshCommand, string nickname, ListBoxRow boxRow){
        try {
            string sshCmd = sshCommand + " placeholder placeholder placeholder";
		    string[] spawn_args = sshCmd.split(" ");
            spawn_args[spawn_args.length - 1] = "echo 'connected'; while sleep 5; do echo 'still alive: "+ nickname + "'; done";
            spawn_args[spawn_args.length - 3] = "-o";
            spawn_args[spawn_args.length - 2] = "PasswordAuthentication no";
		    string[] spawn_env = Environ.get ();
		    Pid child_pid;

		    int standard_input;
		    int standard_output;
		    int standard_error;

		    Process.spawn_async_with_pipes ("/",
		    	spawn_args,
			    spawn_env,
		    	SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
		    	null,
		    	out child_pid,
                out standard_input,
                out standard_output,
                out standard_error);

            rowMap[nickname] = boxRow;
            pidMap[nickname] = child_pid;
            timeMap[nickname] = GLib.get_real_time () / 1000;;

            // stdout:
		    IOChannel output = new IOChannel.unix_new (standard_output);
		    output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
			    return process_line (channel, condition, 0, nickname);
		    });

		    // stderr:
		    IOChannel error = new IOChannel.unix_new (standard_error);
		    error.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) => {
			    return this.process_line (channel, condition, 1, nickname);
		    });

            threadMap[nickname] = new TimeoutThread(nickname);
            Thread.create<void*>(threadMap[nickname].timeout, true);

		    ChildWatch.add(child_pid, (pid, status) => {
                if (rowMap.has_key(nickname)) {
                    rowMap[nickname].sshStopped();
                    rowMap.unset(nickname);
                }
                print("Disconnected\n");
                pidMap.unset(nickname);
                timeMap.unset(nickname);
                threadMap.unset(nickname);
                error.shutdown(true);
                output.shutdown(true);
		    	Process.close_pid (pid);
		    });
	    } catch (SpawnError e) {
		    stdout.printf ("Error: %s\n", e.message);
	    }
    }

    public void setListener(string nickname, ListBoxRow listener) {
        rowMap[nickname] = listener;
    }

    public void unsetListener(string nickname) { 
        if (rowMap.has_key(nickname))
            rowMap.unset(nickname);
    }

    public bool stop(string nickname) {
        if (pidMap.has_key(nickname)) {
            Posix.kill(pidMap[nickname], Posix.SIGTERM);
            return true;
        }
        return false;
    }

    public bool loading(string nickname) {
        if (rowMap.has_key(nickname)) {
            rowMap[nickname].sshLoading();
            return true;
        }
        return false;
    }

    public bool isRunning(string nickname) {
        return pidMap.has_key(nickname);
    }

    public static SSHManager get_instance() {
        if (instance == null)
            instance = new SSHManager();

        return instance;
    }
}
}
