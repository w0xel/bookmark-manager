install (FILES com.github.bartzaalberg.bookmark-manager.desktop DESTINATION share/applications)
install (FILES com.github.bartzaalberg.bookmark-manager.appdata.xml DESTINATION share/metainfo/)

install (FILES icons/16/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/16x16/apps)
install (FILES icons/24/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/24x24/apps)
install (FILES icons/32/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/32x32/apps)
install (FILES icons/48/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/48x48/apps)
install (FILES icons/32/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/32x32/apps)
install (FILES icons/64/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/64x64/apps)
install (FILES icons/128/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/128x128/apps)

install (FILES icons/64/com.github.bartzaalberg.bookmark-manager.svg DESTINATION share/icons/hicolor/scalable/apps)

include(FindGettext)
set (XDG_APPS_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/applications)

# Translate and install the desktop file
set (GETTEXT_REQUIRED_VERSION 0.19)
if(GETTEXT_VERSION_STRING VERSION_EQUAL GETTEXT_REQUIRED_VERSION OR GETTEXT_VERSION_STRING VERSION_GREATER GETTEXT_REQUIRED_VERSION)
  add_custom_command(
      OUTPUT com.github.bartzaalberg.bookmark-manager.desktop
      COMMAND ${GETTEXT_MSGFMT_EXECUTABLE}
        --desktop
        --template=data/com.github.bartzaalberg.bookmark-manager.desktop.in
        -d po
        -o ${CMAKE_BINARY_DIR}/data/com.github.bartzaalberg.bookmark-manager.desktop
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  add_custom_target(build-desktop-file ALL DEPENDS com.github.bartzaalberg.bookmark-manager.desktop)
  install(
    FILES ${CMAKE_BINARY_DIR}/data/com.github.bartzaalberg.bookmark-manager.desktop
    DESTINATION ${XDG_APPS_INSTALL_DIR})
else()
  message(WARNING "Gettext >= ${GETTEXT_REQUIRED_VERSION} required for .desktop file translation")
  install(
    FILES com.github.bartzaalberg.bookmark-manager.desktop.in
    DESTINATION ${XDG_APPS_INSTALL_DIR}
    RENAME com.github.bartzaalberg.bookmark-manager.desktop)
endif()

# Translate and install AppData file
set (GETTEXT_REQUIRED_VERSION 0.19.7)
if(GETTEXT_VERSION_STRING VERSION_EQUAL GETTEXT_REQUIRED_VERSION OR GETTEXT_VERSION_STRING VERSION_GREATER GETTEXT_REQUIRED_VERSION)
  add_custom_command(
      OUTPUT com.github.bartzaalberg.bookmark-manager.appdata.xml
      COMMAND ${GETTEXT_MSGFMT_EXECUTABLE}
        --xml
        --template=data/com.github.bartzaalberg.bookmark-manager.appdata.xml.in
        -d po
        -o ${CMAKE_BINARY_DIR}/data/com.github.bartzaalberg.bookmark-manager.appdata.xml
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )
  add_custom_target(build-appdata-file ALL DEPENDS com.github.bartzaalberg.bookmark-manager.appdata.xml)
  install(
    FILES ${CMAKE_BINARY_DIR}/data/com.github.bartzaalberg.bookmark-manager.appdata.xml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo)
else()
  message(WARNING "Gettext >= ${GETTEXT_REQUIRED_VERSION} required for AppData file translation")
  install(
    FILES com.github.bartzaalberg.bookmark-manager.appdata.xml.in
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo
  RENAME com.github.bartzaalberg.bookmark-manager.appdata.xml)
endif()
