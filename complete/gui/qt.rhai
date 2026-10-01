// The options that every KDE program has, from Qt's QCommandLineParser and QGuiApplication (`--help-all` of okular
// and kate 23.08.5, Qt 5.15). Qt also takes its own options with a single `-` (`-platform offscreen`).

// The options that QCommandLineParser adds and those of KDE's KAboutData.
fn kde_opts() {
    `
        -h, --help                  show the help
        --help-all                  show the help, with Qt's options
        -v, --version               show the version
        --author                    show the authors
        --license                   show the license
        --desktopfile FILE_NAME     the base name of the program's desktop entry
    `
}

// Qt's options (`--help-all`).
fn qt_opts() {
    `
        --qmljsdebugger VALUE       activate the QML/JS debugger (port:1234[,block])
        --platform NAME             the QPA plugin (NAME[:OPTIONS])
        --platformpluginpath PATH   path to the platform plugins
        --platformtheme THEME       platform theme
        --plugin PLUGIN             additional plugin to load
        --qwindowgeometry GEOMETRY  geometry of the main window (100x100+50+50)
        --geometry GEOMETRY         geometry of the main window (100x100+50+50)
        --qwindowicon ICON          default window icon
        --icon ICON                 default window icon
        --qwindowtitle TITLE        title of the first window
        --title TITLE               title of the first window
        --reverse                   lay out right to left
        --session SESSION           restore the program from an earlier session
        --display DISPLAY           the X display, instead of $DISPLAY
        --name NAME                 instance name (ICCCM 4.1.2.5)
        --nograb                    never grab the mouse
        --dograb                    grab the mouse, even in a debugger
        --visual ID                 ID of the X11 visual to use
    `
}

fn values() {
    #{
        "--desktopfile": "none",
        "--qmljsdebugger": [#{value: "port:", suffix: "", desc: "the port to listen on"}],
        "--platform": ["xcb", "wayland", "wayland-egl", "offscreen", "minimal", "eglfs", "linuxfb", "vnc",
                       "vkkhrdisplay"],
        "--platformpluginpath": "dirs",
        "--platformtheme": "none",
        "--plugin": "none",
        "--qwindowgeometry": "none",
        "--geometry": "none",
        "--qwindowicon": "files",
        "--icon": "files",
        "--qwindowtitle": "none",
        "--title": "none",
        "--session": "none",
        "--display": "none",
        "--name": "none",
        "--visual": "none",
    }
}

// A spec with the KDE and Qt options added to `s`.
fn with_kde(s) {
    s.opts = kde_opts() + s.opts + qt_opts();
    let v = values();
    v.mixin(s.values ?? #{});
    s.values = v;
    s
}
