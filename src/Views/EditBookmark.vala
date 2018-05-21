namespace BookmarkManager {
public class EditBookmark : BookmarkForm{
 
    private ListBox listBox = ListBox.get_instance();

    public EditBookmark(){ 

        general_header.set_text(_("Edit a bookmark"));

        hostEntry.set_sensitive(false);

        var edit_button = new Gtk.Button.with_label (_("Edit"));
        edit_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        edit_button.clicked.connect (() => {
           EditBookmarkInFile();
        });

        button_box.pack_end (edit_button);
    }

    public void loadBookmark(Bookmark bookmark){
               
        nicknameEntry.text = "";
        hostEntry.text = "";
        hostNameEntry.text = "";
        portEntry.text = "";
        userNameEntry.text = "";
        agentForwardCheckButton.active = false;
        proxyCommandEntry.text = "";
        localForwardEntry.text = "";
        backgroundCheckButton.active = false;
        
        if(bookmark.getNickname() != null){
            nicknameEntry.text = bookmark.getNickname();
        }

        if(bookmark.getName() != null){
            hostEntry.text = bookmark.getName();
        }
        if(bookmark.getIp() != null){ 
            hostNameEntry.text = bookmark.getIp();
        }

        if(bookmark.getPort() != 0){ 
            portEntry.text = bookmark.getPort().to_string();  
        }

        if(bookmark.getUser() != null){ 
            userNameEntry.text = bookmark.getUser();
        }

        if(bookmark.getForwardAgent() != null){ 
            agentForwardCheckButton.active = true;
        }

        if(bookmark.getProxyCommand() != null){ 
            proxyCommandEntry.text = bookmark.getProxyCommand();
        }

        if(bookmark.getLocalForward() != null){ 
            localForwardEntry.text = bookmark.getLocalForward();
        }

        if(bookmark.getRunInBackground() == true){
            backgroundCheckButton.active = true;
        }
    }

    public void EditBookmarkInFile(){
        
        var bookmarkName = hostEntry.text;

        var ConfigFileReader = new ConfigFileReader(); 
        var bookmarks = ConfigFileReader.getBookmarks(); 

        var bookmark = getCorrectBookmarkByName(bookmarkName, bookmarks);
        bookmark.setNickname(nicknameEntry.text);        
        bookmark.setName(hostEntry.text);
        bookmark.setIp(hostNameEntry.text);  
        bookmark.setUser(userNameEntry.text);  
        bookmark.setPort(int.parse(portEntry.text));
        bookmark.setLocalForward(localForwardEntry.text);

        if(agentForwardCheckButton.active == true) {
            bookmark.setForwardAgent("yes");
        }

        if(backgroundCheckButton.active == true) {
            bookmark.setRunInBackground(true);
        } else {
            bookmark.setRunInBackground(false);
        }
         
        bookmark.setProxyCommand(proxyCommandEntry.text);  

        if(isNotValid(bookmark)){
            new Alert(_("Fields are invalid"), _("Please correctly fill in all the required fields"));
            return;
        }

        var index = getCorrectBookmarkIndex(bookmark, bookmarks);
        
        bookmarks[index] = bookmark;

        ConfigFileReader.writeToFile(bookmarks);

        listBox.getBookmarks("");    
    }

    public int getCorrectBookmarkIndex(Bookmark editedBookmark, Bookmark[] bookmarks){
        var index = 0;           
        foreach (Bookmark bookmark in bookmarks) {
            if(bookmark.getName() == editedBookmark.getName()) {
                return index;
            }
            index++;
        }
        return index;
    }

    public Bookmark getCorrectBookmarkByName(string bookmarkName, Bookmark[] bookmarks){           
        foreach (Bookmark bookmark in bookmarks) {
            if(bookmark.getName() == bookmarkName) {
                return bookmark;
            }
        }
        return new Bookmark();
    }
}
}
