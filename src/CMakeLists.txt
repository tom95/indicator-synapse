find_package (PkgConfig)

# Add all your dependencies to the list below
pkg_check_modules (DEPS REQUIRED zeitgeist-2.0 json-glib-1.0 rest-0.7 glib-2.0 gobject-2.0 gtk+-3.0 gio-2.0 gio-unix-2.0 wingpanel-2.0 libnotify)

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.22.0" MINIMUM)

include (ValaPrecompile)
# Add all your vala files and requires packages to the List below to include them in the build
vala_precompile (VALA_C ${CMAKE_PROJECT_NAME}
    indicator/main.vala
    indicator/menu.vala
    indicator/match-item.vala
    indicator/selectable-list.vala

    core/common-actions.vala
    core/config-service.vala
    core/data-sink.vala
    core/dbus-service.vala
    core/desktop-file-service.vala
    core/match.vala
    core/plugin.vala
    core/query.vala
    core/relevancy-backend-zg.vala
    core/relevancy-service.vala
    core/result-set.vala
    core/utils.vala
    core/volume-service.vala

    plugins/banshee-plugin.vala
    plugins/calculator-plugin.vala
    plugins/chat-actions-plugin.vala
    plugins/chromium-plugin.vala
    plugins/command-plugin.vala
    plugins/desktop-file-plugin.vala
    plugins/devhelp-search.vala
    plugins/dictionary.vala
    plugins/directory-plugin.vala
    plugins/file-op-plugin.vala
    plugins/filezilla-plugin.vala
    plugins/gnome-screensaver-plugin.vala
    plugins/gnome-session-plugin.vala
    plugins/hello-world-plugin.vala
    plugins/hybrid-search-plugin.vala
    plugins/imgur-plugin.vala
    plugins/launchpad-plugin.vala
    plugins/locate-plugin.vala
    plugins/opensearch.vala
    plugins/pastebin-plugin.vala
    plugins/pidgin-plugin.vala
    plugins/rhythmbox-plugin.vala
    plugins/selection-plugin.vala
    plugins/ssh-plugin.vala
    plugins/system-management.vala
    plugins/test-slow-plugin.vala
    plugins/wolframalpha-plugin.vala
    plugins/xnoise-media-player-plugin.vala
    plugins/zeitgeist-plugin.vala
    plugins/zeitgeist-related.vala

PACKAGES
    zeitgeist-2.0 json-glib-1.0 rest-0.7 glib-2.0 gobject-2.0 gtk+-3.0 gio-2.0 gio-unix-2.0 wingpanel-2.0 libnotify
OPTIONS
  --thread
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
)

add_library (${CMAKE_PROJECT_NAME} MODULE ${VALA_C})
target_link_libraries(${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} DESTINATION ${PKGDATADIR})
