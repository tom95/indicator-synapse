project('synapse', 'vala', 'c')

gettext_name = meson.project_name() + '-indicator'
gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(gettext_name), language:'c')

#asresources = gnome.compile_resources(
    #'as-resources', 'data/de.tombeckmann.password-indicator.gresource.xml',
    #source_dir: 'data',
    #c_name: 'as'
#)

wingpanel_dep = dependency('wingpanel-2.0')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

shared_module(
    meson.project_name(),
    'src/indicator/main.vala',
    'src/indicator/menu.vala',
    'src/indicator/match-item.vala',
    'src/indicator/selectable-list.vala',

    'src/core/common-actions.vala',
    'src/core/config-service.vala',
    'src/core/data-sink.vala',
    'src/core/dbus-service.vala',
    'src/core/desktop-file-service.vala',
    'src/core/match.vala',
    'src/core/plugin.vala',
    'src/core/query.vala',
    'src/core/relevancy-backend-zg.vala',
    'src/core/relevancy-service.vala',
    'src/core/result-set.vala',
    'src/core/utils.vala',
    'src/core/volume-service.vala',


    'src/plugins/banshee-plugin.vala',
    'src/plugins/calculator-plugin.vala',
    'src/plugins/chat-actions-plugin.vala',
    'src/plugins/chromium-plugin.vala',
    'src/plugins/command-plugin.vala',
    'src/plugins/desktop-file-plugin.vala',
    'src/plugins/devhelp-search.vala',
    'src/plugins/dictionary.vala',
    'src/plugins/directory-plugin.vala',
    'src/plugins/file-op-plugin.vala',
    'src/plugins/filezilla-plugin.vala',
    'src/plugins/gnome-screensaver-plugin.vala',
    'src/plugins/gnome-session-plugin.vala',
    'src/plugins/hello-world-plugin.vala',
    'src/plugins/hybrid-search-plugin.vala',
    'src/plugins/imgur-plugin.vala',
    'src/plugins/launchpad-plugin.vala',
    'src/plugins/locate-plugin.vala',
    'src/plugins/opensearch.vala',
    'src/plugins/pastebin-plugin.vala',
    'src/plugins/pidgin-plugin.vala',
    'src/plugins/rhythmbox-plugin.vala',
    'src/plugins/selection-plugin.vala',
    'src/plugins/ssh-plugin.vala',
    'src/plugins/system-management.vala',
    'src/plugins/test-slow-plugin.vala',
    'src/plugins/wolframalpha-plugin.vala',
    'src/plugins/xnoise-media-player-plugin.vala',
    'src/plugins/zeitgeist-plugin.vala',
    'src/plugins/zeitgeist-related.vala',

    #asresources,
    dependencies: [
        dependency('zeitgeist-2.0'),
        dependency('json-glib-1.0'),
        dependency('rest-0.7'),
        dependency('libnotify'),
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('gio-2.0'),
        dependency('gio-unix-2.0'),
        wingpanel_dep
    ],
    install: true,
    install_dir : get_option('libdir') + '/wingpanel' #'/usr/lib/x86_64-linux-gnu/wingpanel' #wingpanel_dep.get_pkgconfig_variable('indicatorsdir')
)

