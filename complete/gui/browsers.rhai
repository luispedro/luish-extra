// Browsers and mail: firefox (156.0.1) and thunderbird (156.0.1), which take the options of Mozilla's toolkit, and
// chromium and google-chrome (154), whose switches are many and undocumented: those of its manual page and the stable
// ones that are used most.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

// The options that Firefox and Thunderbird share (their `--help`). Mozilla takes each option with one dash or two,
// and its value as the next word or after `=`, so the optional values are written `[=VALUE]`.
fn mozilla_opts() {
    `
        --display=DISPLAY           X display to use
        --sync                      make X calls synchronous
        --g-fatal-warnings          make all warnings fatal
        -h, --help                  show the help
        -v, --version               show the version
        --full-version              show the version, build and platform build ids
        -P PROFILE                  start with a profile (the profile manager without one)
        --profile PATH              start with the profile at PATH
        --migration                 start with the migration wizard
        --ProfileManager            start with the profile manager
        --origin-to-force-quic-on ORIGIN  force QUIC for an origin
        --new-instance              open a new instance, not a window of the running one
        --safe-mode                 disable extensions and themes for this session
        --allow-downgrade           allow downgrading a profile
        --MOZ_LOG=MODULES           log modules, as $MOZ_LOG
        --MOZ_LOG_FILE=FILE         log to a file, as $MOZ_LOG_FILE
        --headless                  run without a GUI
        --dbus-service LAUNCHER     run as a D-Bus service, with a launcher script
        --jsconsole                 open the Browser Console
        --devtools                  open DevTools on initial load
        --jsdebugger[=PATH]         open the Browser Toolbox (of another firefox at PATH)
        --wait-for-jsdebugger       wait for the JS debugger to connect (with --jsdebugger)
        --start-debugger-server[=PORT]  start the devtools server on a TCP port (6000), ws:PORT or a socket path
        --marionette                enable the remote control server
        --remote-debugging-port[=PORT]  start the Remote Agent for WebDriver BiDi (9222)
        --remote-allow-hosts HOSTS  values of the Host header to allow
        --remote-allow-origins ORIGINS  values of the Origin header to allow
        --remote-allow-system-access  give the Remote Agent privileged access to the parent process
    `
}

fn mozilla(own, extra) {
    let v = #{
        "--display": "none",
        "-P": k("mozilla_profiles"),
        "--profile": "dirs",
        "--origin-to-force-quic-on": "none",
        "--MOZ_LOG": "none",
        "--dbus-service": "files",
        "--start-debugger-server": "none",
        "--remote-debugging-port": "none",
        "--remote-allow-hosts": "none",
        "--remote-allow-origins": "none",
    };
    v.mixin(extra);
    #{opts: mozilla_opts() + own, values: v, args: ["files"]}
}

// firefox [OPTIONS] [URL|FILE]...
fn firefox() {
    mozilla(`
        --browser                   open a browser window
        --new-window URL            open a URL in a new window
        --new-tab URL               open a URL in a new tab
        --private-window[=URL]      open a new private window (with a URL)
        --preferences               open the preferences
        --screenshot[=PATH]         save a screenshot of the page (to PATH, or screenshot.png)
        --window-size WIDTH[,HEIGHT]  the size of the screenshot
        --search TERM               search with the default search engine
        --setDefaultBrowser         set Firefox as the default browser
        --first-startup             run the post-install actions before opening a window
        --kiosk                     start in kiosk mode
        --kiosk-monitor NUM         the monitor of the kiosk window
        --disable-pinch             disable pinch gestures
    `, #{
        "--new-window": "none",
        "--new-tab": "none",
        "--window-size": "none",
        "--search": "none",
        "--kiosk-monitor": "none",
    })
}

// thunderbird [OPTIONS] [URL|FILE]...: its own options are written with one dash.
fn thunderbird() {
    mozilla(`
        -mail, --mail               go to the mail tab
        -addressbook, --addressbook  go to the address book tab
        -calendar, --calendar       go to the calendar tab
        -options, --options         go to the settings tab
        -compose[=OPTIONS], --compose[=OPTIONS]  compose a message (to='a@b.org',subject='...',attachment=FILE,...)
        -file, --file               open the email or ICS calendar files
        -setDefaultMail, --setDefaultMail  set Thunderbird as the default mail client
        -keymanager, --keymanager   open the OpenPGP key manager
    `, #{})
}

// chromium, google-chrome [OPTIONS] [URL|FILE]...: a switch takes its value after `=` only.
fn chrome() {
    #{
        opts: `
            --version                   show the version
            --product-version           show the version number only
            --user-data-dir=DIR         the directory of the user data (~/.config/google-chrome)
            --profile-directory=DIR     the profile in the user data directory (Default, Profile 1, ...)
            --incognito                 open in incognito mode
            --guest                     open in guest mode
            --new-window                open the URLs in a new window
            --app=URL                   open a URL as an app, without the browser's UI
            --kiosk                     start in kiosk mode
            --start-maximized           start maximized
            --start-fullscreen          start in full screen
            --window-size=W,H           the size of the first window
            --window-position=X,Y       the position of the first window
            --window-name=NAME          the title of the first window
            --class=CLASS               the window class (WM_CLASS)
            --proxy-server=PROXY        the proxy ([SCHEME://]HOST:PORT, or URL-SCHEME=PROXY;...)
            --no-proxy-server           use no proxy
            --proxy-auto-detect         detect the proxy configuration
            --proxy-pac-url=URL         the proxy autoconfiguration URL
            --proxy-bypass-list=HOSTS   hosts to reach without the proxy (;-separated)
            --host-resolver-rules=RULES  rules for resolving host names (MAP * 127.0.0.1)
            --password-store=STORE      the password store
            --headless                  run without a GUI
            --dump-dom                  print the DOM of the page (headless)
            --print-to-pdf[=FILE]       print the page to a PDF file (headless; output.pdf)
            --no-pdf-header-footer      leave out the header and footer of --print-to-pdf
            --screenshot[=FILE]         save a screenshot of the page (headless; screenshot.png)
            --virtual-time-budget=MS    wait this long, in virtual time, before --dump-dom or --screenshot
            --remote-debugging-port=PORT  listen for DevTools on a port
            --remote-debugging-pipe     talk DevTools over file descriptors 3 and 4
            --remote-allow-origins=ORIGINS  origins allowed to connect to DevTools (* for any)
            --auto-open-devtools-for-tabs  open DevTools in each tab
            --disable-extensions        disable extensions
            --load-extension=DIRS       load unpacked extensions (,-separated)
            --disable-extensions-except=DIRS  disable extensions but these unpacked ones
            --enable-features=FEATURES  enable features (,-separated)
            --disable-features=FEATURES  disable features (,-separated)
            --enable-blink-features=FEATURES  enable Blink features (,-separated)
            --disable-blink-features=FEATURES  disable Blink features (,-separated)
            --js-flags=FLAGS            flags for V8
            --ozone-platform=PLATFORM   the Ozone platform
            --ozone-platform-hint=PLATFORM  the Ozone platform, if it is available
            --gtk-version=VERSION       the GTK version
            --enable-wayland-ime        use the Wayland input method
            --force-device-scale-factor=FACTOR  the scale of the UI
            --force-dark-mode           use dark mode for the UI and the pages
            --lang=LANG                 the UI's language (en-US)
            --user-agent=STRING         the User-Agent of requests
            --disable-gpu               disable GPU acceleration
            --no-sandbox                disable the sandbox
            --disable-dev-shm-usage     write shared memory files to /tmp, not /dev/shm
            --disable-web-security      disable the same-origin policy (with --user-data-dir)
            --allow-file-access-from-files  let file:// pages read other file:// URLs
            --ignore-certificate-errors  ignore TLS certificate errors
            --disable-background-networking  disable background network requests
            --mute-audio                mute all audio
            --no-first-run              skip the first-run tasks
            --no-default-browser-check  don't check whether it is the default browser
            --enable-logging[=stderr]   log to stderr (or to chrome_debug.log in the user data directory)
            --log-file=FILE             log to a file (with --enable-logging)
            --log-level=LEVEL           the lowest level logged (0 info to 3 fatal)
            --v=LEVEL                   the verbosity of VLOG
            --vmodule=PATTERNS          the verbosity of VLOG by source file (PATTERN=N,...)
        `,
        values: #{
            "--user-data-dir": "dirs",
            "--profile-directory": k("chrome_profiles"),
            "--app": "none",
            "--window-size": "none",
            "--window-position": "none",
            "--window-name": "none",
            "--class": "none",
            "--proxy-server": "none",
            "--proxy-pac-url": "none",
            "--proxy-bypass-list": "none",
            "--host-resolver-rules": "none",
            "--password-store": ["basic", "gnome-libsecret", "kwallet", "kwallet5", "kwallet6"],
            "--virtual-time-budget": "none",
            "--remote-debugging-port": "none",
            "--remote-allow-origins": "none",
            "--load-extension": "dirs",
            "--disable-extensions-except": "dirs",
            "--enable-features": "none",
            "--disable-features": "none",
            "--enable-blink-features": "none",
            "--disable-blink-features": "none",
            "--js-flags": "none",
            "--ozone-platform": ["x11", "wayland", "headless"],
            "--ozone-platform-hint": ["auto", "x11", "wayland"],
            "--gtk-version": ["3", "4"],
            "--force-device-scale-factor": "none",
            "--lang": "none",
            "--user-agent": "none",
            "--enable-logging": ["stderr"],
            "--log-level": ["0", "1", "2", "3"],
            "--v": "none",
            "--vmodule": "none",
        },
        strict_eq: true,
        args: ["files"],
    }
}

fn spec(cmd) {
    switch cmd {
        "firefox" => firefox(),
        "thunderbird" => thunderbird(),
        "chromium" | "chromium-browser" | "google-chrome" | "google-chrome-stable" => chrome(),
        _ => #{},
    }
}
