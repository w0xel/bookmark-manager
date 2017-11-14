include (Translations)
    add_translations_directory(${GETTEXT_PACKAGE})
    add_translations_catalog(${GETTEXT_PACKAGE}
    ../src/
    ../src/Components
    ../src/DesktopFileManager
    ../src/Dialogs
    ../src/Polkit
    ../src/Tests
    ../src/Views
    ../data/com.github.bartzaalberg.bookmark-manager.desktop.in
    ../data/com.github.bartzaalberg.bookmark-manager.appdata.xml.in
)
