using Granite.Widgets;

namespace BookmarkManager {
public class ListBoxRow : Gtk.ListBoxRow {

    StackManager stackManager = StackManager.get_instance();

    private const int PROGRESS_BAR_HEIGHT = 5;
    private Settings settings = new Settings ("com.github.bartzaalberg.bookmark-manager");

    private Gtk.Image start_image = new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
    private Gtk.Image stop_image = new Gtk.Image.from_icon_name ("media-playback-stop-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
    private Gtk.Image loading_image = new Gtk.Image.from_icon_name ("content-loading-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
    private Gtk.Image cur_image;
    private Gtk.Image edit_image = new Gtk.Image.from_icon_name ("document-properties-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
    private Gtk.Image delete_image = new Gtk.Image.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

    private Gtk.Image icon = new Gtk.Image.from_icon_name ("terminal", Gtk.IconSize.DND);
    private Gtk.Box vertical_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
    private Gtk.EventBox start_button;
    private Bookmark bookmark;

    public ListBoxRow (Bookmark bookmark){

        this.bookmark = bookmark;
        var sshCommand = generateSSHCommand(bookmark);
        var name_label = generateNameLabel(bookmark);
        var summary_label = generateSummaryLabel(sshCommand);
        this.start_button = generateStartButton(sshCommand, bookmark.getRunInBackground());
        var edit_button = generateEditButton(bookmark);
        var delete_button = generateDeleteButton();

        vertical_box.add (name_label);
        vertical_box.add (summary_label);

        var bookmark_row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        bookmark_row.margin = 12;
        bookmark_row.add(icon);
        bookmark_row.add (vertical_box);
        bookmark_row.pack_end (start_button, false, false);
        bookmark_row.pack_end (edit_button, false, false);
        bookmark_row.pack_end (delete_button, false, false);

        this.add (bookmark_row);
    }

    public Gtk.Label generateNameLabel(Bookmark bookmark){
        var name = bookmark.getName();
        if(bookmark.getNickname() != null){
            name = bookmark.getNickname();
        }
        var name_label = new Gtk.Label ("<b>%s</b>".printf (name));
        name_label.use_markup = true;
        name_label.halign = Gtk.Align.START;

        return name_label;
    }

    public Gtk.Label generateSummaryLabel(string sshCommand){
        var summary_label = new Gtk.Label (sshCommand);
        summary_label.halign = Gtk.Align.START;

        return summary_label;
    }

    public string generateSSHCommand(Bookmark bookmark){
        var username = settings.get_string("sshname");
        if(bookmark.getUser() != null && bookmark.getUser() != ""){
            username = bookmark.getUser();
        }

        return "ssh " + username + "@" + bookmark.getName();
    }

    public Gtk.EventBox generateStartButton(string sshCommand, bool runInBackground){
        var start_button = new Gtk.EventBox();

        if (SSHManager.get_instance().isRunning(this.bookmark.getNickname())) {
            start_button.add(stop_image);
            cur_image = stop_image;
            SSHManager.get_instance().setListener(this.bookmark.getNickname(), this);
        } else {
            start_button.add(start_image);
            cur_image = start_image;
        }

        start_button.set_tooltip_text(_("Start an SSH session in a terminal"));
        start_button.destroy.connect(() => {
            SSHManager.get_instance().unsetListener(this.bookmark.getNickname());
        });
        start_button.button_press_event.connect (() => {

            string result;
	        string error = null;
	        int status;

            if(SSHManager.get_instance().stop(this.bookmark.getNickname())) {
                return true;
            }

            if(settings.get_boolean("use-terminal")){

                stackManager.addATerminal();

                try {
                    stackManager.terminal.run_command(sshCommand);

                } catch (SpawnError e) {
	                new Alert("An error occured", e.message);
                }
                return true;
            }

            try {
                var terminalName = settings.get_string("terminalname");
                if (runInBackground) {
                    start_button.remove(cur_image);
                    start_button.add(loading_image);
                    cur_image = loading_image;
                    cur_image.show();
                    SSHManager.get_instance().spawnBackground(sshCommand, this.bookmark.getNickname(), this);
                } else {
                    Process.spawn_command_line_sync (terminalName + " --execute='" + sshCommand + "'",
									        out result,
									        out error,
									        out status);
                }

                if(error != null && error != ""){
                    new Alert("An error occured",error);
                }

            } catch (SpawnError e) {
	            new Alert("An error occured", e.message);
            }
            return true;
        });

        return start_button;
    }

    public void sshStopped() {
        this.start_button.remove(cur_image);
        this.start_button.add(start_image);
        this.cur_image = start_image;
        this.start_image.show();
    }

    public void sshConnected() {
        if (this.cur_image == this.stop_image)
            return;
        this.start_button.remove(cur_image);
        this.start_button.add(stop_image);
        this.cur_image = stop_image;
        this.stop_image.show();
    }

    public void sshLoading() {
        this.start_button.remove(cur_image);
        this.start_button.add(loading_image);
        this.cur_image = loading_image;
        this.cur_image.show();
    }

    public Gtk.EventBox generateDeleteButton(){
        var delete_button = new Gtk.EventBox();
        delete_button.add(delete_image);
        delete_button.set_tooltip_text(_("Remote this bookmark"));
        delete_button.button_press_event.connect (() => {
            new DeleteConfirm(bookmark);

            SSHManager.get_instance().stop(this.bookmark.getNickname());
            return true;
        });

        return delete_button;
    }

    public Gtk.EventBox generateEditButton(Bookmark bookmark){
        var edit_button = new Gtk.EventBox();
        edit_button.add(edit_image);
        edit_button.set_tooltip_text(_("Edit this bookmark"));
        edit_button.button_press_event.connect (() => {
            stackManager.setEditBookmark(bookmark);
            stackManager.getStack().visible_child_name = "edit-bookmark-view";
            return true;
        });

        return edit_button;
    }
}
}
