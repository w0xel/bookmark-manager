using Granite.Widgets;

namespace BookmarkManager {
public class App:Granite.Application{

    public MainWindow window = null;
    private bool windowDestroyed = false;
    private AppIndicator.Indicator indicator = null;
   
    construct {
        application_id = Constants.APPLICATION_ID;
        program_name = Constants.APP_NAME;
        app_years = Constants.APP_YEARS;
        exec_name = Constants.EXEC_NAME;
        app_launcher = Constants.DESKTOP_NAME;
        build_version = Constants.VERSION;
        app_icon = Constants.ICON;
        main_url = Constants.MAIN_URL;
        bug_url = Constants.BUG_URL;
        flags = ApplicationFlags.HANDLES_OPEN;

    }

    public void windowCreate() {
        this.window = new MainWindow();
        this.windowDestroyed = false;
        this.window.show_all();
        this.window.destroy.connect (this.windowDestruct);

        this.indicator.set_status(AppIndicator.IndicatorStatus.PASSIVE);
    }

    public void windowDestruct() {
        print("Window destroyed...\n");
        this.windowDestroyed = true;
        window = null;
        StackManager.del_instance();
        HeaderBar.del_instance();
        ListBox.del_instance();
        if (!SSHManager.get_instance().getIsAnyRunning()) {
            this.release();
            Gtk.main_quit();
            Process.exit(0);
        }

        this.indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
    }

    public override void activate() {
        this.hold();

        SimpleAction show_window = new SimpleAction ("show_window", null);
		show_window.activate.connect (() => {
            this.hold();

            if (this.windowDestroyed == true) {
                this.windowCreate();
            }
            this.release();
		});

		this.add_action (show_window);
        Notify.init ("com.github.bartzaalberg.bookmark-manager");

        this.indicator = new AppIndicator.Indicator("com.github.bartzaalberg.bookmark-manager", "applications-internet",
                                      AppIndicator.IndicatorCategory.APPLICATION_STATUS);
        if (!(indicator is AppIndicator.Indicator)) return;

        this.indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
        this.indicator.set_attention_icon("network-vpn");

        var menu = new Gtk.Menu();

        var item = new Gtk.MenuItem.with_label("Show window");
        item.activate.connect(() => {
            this.windowCreate();
        });
        item.show();
        menu.append(item);

        var bar = item = new Gtk.MenuItem.with_label("Quit");
        item.show();
        item.activate.connect(() => {
            this.release();
            SSHManager.get_instance().quit_all();
            Gtk.main_quit();
        });
        menu.append(item);

        this.indicator.set_menu(menu);
        this.indicator.set_secondary_activate_target(bar);
        this.indicator.set_status(AppIndicator.IndicatorStatus.PASSIVE);

        windowCreate();
        Gtk.main();
        //this.release();
    }

    public static int main(string[] args) {
        
        var app = new App();
        app.register(null);

        bool remote = false;
        if (app.get_is_remote()) {
            remote = true;
            print("Second instance\n");
            app.activate_action("show_window", null);
            Thread.usleep(1000000);
        } else {

            app.run(args);
        }
        return 0;
    }
 
}
}

