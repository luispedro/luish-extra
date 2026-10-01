// Desktop tools: xrandr (1.5.2), gsettings (GLib 2.80.0), dconf (0.40.0), notify-send (libnotify 0.8.3), wmctrl
// (1.07, Debian's git snapshot of 2024-02-28), xdotool (4.20260303.1, and 3.20160805.1, which lacks `search --role`),
// swaymsg (sway 1.12) and hyprctl (Hyprland 0.56.2).
import "@std/completion/lib" as lib;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

// xrandr [OPTIONS]: the options after `--output NAME` apply to that output. Values are the next word only.
fn xrandr() {
    let outputs = k("xrandr_outputs");
    #{
        opts: `
            -d, --display DISPLAY       the X display
            --help                      show the help
            -o, --orientation ORIENTATION  the screen's orientation
            -q, --query                 show the screens, outputs and modes
            -s, --size SIZE             the screen size (index, or WIDTHxHEIGHT)
            -r, --rate, --refresh RATE  the refresh rate
            -v, --version               show the version
            -x                          reflect in x
            -y                          reflect in y
            --screen SCREEN             the screen
            --verbose                   more verbose output
            --current                   show the current state without polling
            --dryrun                    show what would be done, without doing it
            --nograb                    don't grab the screen while changing it
            --prop, --properties        show the outputs' properties
            --fb WxH                    the screen size, in pixels
            --fbmm WxH                  the screen size, in millimetres
            --dpi DPI/OUTPUT            the DPI (a number, or that of an output)
            --output OUTPUT             the output that the following options change
            --auto                      the preferred mode (or off, if disconnected)
            --mode MODE                 the mode
            --preferred                 the preferred mode
            --pos XxY                   the position
            --reflect REFLECTION        reflect the output
            --rotate ROTATION           rotate the output
            --left-of OUTPUT            place left of an output
            --right-of OUTPUT           place right of an output
            --above OUTPUT              place above an output
            --below OUTPUT              place below an output
            --same-as OUTPUT            place at the position of an output
            --set PROPERTY VALUE        set an output property
            --scale X[xY]               scale the output
            --scale-from WxH            scale the output to show this size
            --transform A,B,C,D,E,F,G,H,I  the transformation matrix
            --filter FILTER             the scaling filter
            --off                       disable the output
            --crtc CRTC                 the CRTC
            --panning WxH[+X+Y[/...]]   panning
            --gamma R[:G:B]             the gamma correction
            --brightness VALUE          the brightness (a software factor)
            --primary                   make the output the primary one
            --noprimary                 no primary output
            --newmode NAME CLOCK HDISP HSYNC-START HSYNC-END HTOTAL VDISP VSYNC-START VSYNC-END VTOTAL [FLAGS]  add a mode
            --rmmode NAME               remove a mode
            --addmode OUTPUT NAME       add a mode to an output
            --delmode OUTPUT NAME       remove a mode from an output
            --listproviders             list the providers
            --setprovideroutputsource PROVIDER SOURCE  set a provider's output source
            --setprovideroffloadsink PROVIDER SINK  set a provider's offload sink
            --listmonitors              list the monitors
            --listactivemonitors        list the active monitors
            --setmonitor NAME GEOMETRY OUTPUTS  add a monitor
            --delmonitor NAME           remove a monitor
        `,
        values: #{
            "--display": "none",
            "--orientation": ["normal", "inverted", "left", "right"],
            "--size": "none",
            "--rate": "none",
            "--screen": "none",
            "--fb": "none",
            "--fbmm": "none",
            "--dpi": "none",
            "--output": outputs,
            "--mode": k("xrandr_modes"),
            "--pos": "none",
            "--reflect": ["normal", "x", "y", "xy"],
            "--rotate": ["normal", "inverted", "left", "right"],
            "--left-of": outputs,
            "--right-of": outputs,
            "--above": outputs,
            "--below": outputs,
            "--same-as": outputs,
            "--set": "none",
            "--scale": "none",
            "--scale-from": "none",
            "--transform": "none",
            "--filter": ["nearest", "bilinear"],
            "--crtc": "none",
            "--panning": "none",
            "--gamma": "none",
            "--brightness": "none",
            "--newmode": "none",
            "--rmmode": "none",
            "--addmode": outputs,
            "--delmode": outputs,
            "--setprovideroutputsource": "none",
            "--setprovideroffloadsink": "none",
            "--setmonitor": "none",
            "--delmonitor": "none",
        },
        args: ["none"],
        strict_eq: true,
    }
}

// gsettings [--schemadir DIR] COMMAND [ARGS]: schemas, keys and values are those of the installed schemas.
fn gsettings() {
    let schema = k("gsettings_schemas");
    let key = k("gsettings_keys");
    #{
        opts: `
            --version                   show the version
            --schemadir SCHEMADIR       a directory of extra schemas
        `,
        values: #{"--schemadir": "dirs"},
        commands: `
            help                        show the help (of a command)
            list-schemas                list the installed schemas
            list-relocatable-schemas    list the relocatable schemas
            list-keys                   list the keys of a schema
            list-children               list the children of a schema
            list-recursively            list the keys and values, recursively
            range                       show the range of a key's values
            describe                    show the description of a key
            get                         get the value of a key
            set                         set the value of a key
            reset                       reset a key to its default
            reset-recursively           reset all the keys of a schema
            writable                    check whether a key is writable
            monitor                     watch for changes
        `,
        subs: #{
            "help": #{args: [["list-schemas", "list-relocatable-schemas", "list-keys", "list-children",
                              "list-recursively", "range", "describe", "get", "set", "reset", "reset-recursively",
                              "writable", "monitor"], "none"]},
            "list-schemas": #{opts: "--print-paths  show the paths of the schemas", args: ["none"]},
            "list-relocatable-schemas": #{args: ["none"]},
            "list-keys": #{args: [schema, "none"]},
            "list-children": #{args: [schema, "none"]},
            "list-recursively": #{args: [schema, "none"]},
            "range": #{args: [schema, key, "none"]},
            "describe": #{args: [schema, key, "none"]},
            "get": #{args: [schema, key, "none"]},
            "set": #{args: [schema, key, k("gsettings_values"), "none"]},
            "reset": #{args: [schema, key, "none"]},
            "reset-recursively": #{args: [schema, "none"]},
            "writable": #{args: [schema, key, "none"]},
            "monitor": #{args: [schema, key, "none"]},
        },
    }
}

// dconf COMMAND [ARGS]: paths in the database, read with `dconf list`.
fn dconf() {
    let keys = k("dconf_paths");
    let dirs = k("dconf_dirs");
    #{
        commands: `
            help                        show the help (of a command)
            read                        read the value of a key
            list                        list the contents of a directory
            write                       write the value of a key
            reset                       reset a key or directory
            compile                     compile a binary database from key files
            update                      update the system databases
            watch                       watch a path for changes
            dump                        dump a directory to standard output
            load                        load a directory from standard input
        `,
        subs: #{
            "help": #{args: [["read", "list", "write", "reset", "compile", "update", "watch", "dump", "load"], "none"]},
            "read": #{opts: "-d  read the default value", args: [keys, "none"]},
            "list": #{args: [dirs, "none"]},
            "write": #{args: [keys, k("dconf_value"), "none"]},
            "reset": #{opts: "-f  reset a directory", args: [keys, "none"]},
            "compile": #{args: ["files", "dirs", "none"]},
            "update": #{args: ["dirs", "none"]},
            "watch": #{args: [keys, "none"]},
            "dump": #{args: [dirs, "none"]},
            "load": #{opts: "-f  ignore locked keys", args: [dirs, "none"]},
        },
    }
}

// notify-send [OPTIONS] SUMMARY [BODY]
fn notify_send() {
    #{
        opts: `
            -?, --help                  show the help
            -u, --urgency=LEVEL         the urgency
            -t, --expire-time=TIME      the timeout, in milliseconds
            -a, --app-name=APP_NAME     the application's name
            -i, --icon=ICON             an icon file or the name of a stock icon
            -c, --category=TYPE[,TYPE...]  the categories of the notification
            -e, --transient             a transient notification
            -h, --hint=TYPE:NAME:VALUE  extra data (TYPE: boolean, int, double, string, byte or variant)
            -p, --print-id              print the notification's ID
            -r, --replace-id=REPLACE_ID  the ID of the notification to replace
            -w, --wait                  wait for the notification to be closed
            -A, --action=[NAME=]TEXT    an action to show (implies --wait; its name is printed)
            -v, --version               show the version
        `,
        values: #{
            "--urgency": ["low", "normal", "critical"],
            "--expire-time": "none",
            "--app-name": "none",
            "--icon": "files",
            "--category": k("notify_categories"),
            "--hint": [#{value: "boolean:", suffix: ""}, #{value: "int:", suffix: ""}, #{value: "double:", suffix: ""},
                       #{value: "string:", suffix: ""}, #{value: "byte:", suffix: ""}, #{value: "variant:", suffix: ""}],
            "--replace-id": "none",
            "--action": "none",
        },
        args: ["none"],
    }
}

// wmctrl [OPTIONS]: an action (-a, -c, -R, -Y, -r with what it does to the window, ...) and its options.
fn wmctrl() {
    let win = k("wmctrl_windows");
    #{
        opts: `
            -m                          show information about the window manager
            -l                          list the windows
            -d                          list the desktops
            -j                          show the current desktop
            -s DESK                     switch to a desktop
            -a WIN                      activate a window (switching to its desktop)
            -c WIN                      close a window gracefully
            -R WIN                      move a window to the current desktop and activate it
            -Y WIN                      iconify (minimize) a window
            -r WIN                      the window that -t, -e, -y, -b, -N, -I, -M, -T and -L act on
            -t DESK                     move the window to a desktop
            -e MVARG                    resize and move the window (GRAVITY,X,Y,W,H)
            -y MVARG                    resize and move the window, then reactivate it
            -b STARG                    change the state of the window ((remove|add|toggle),PROP1[,PROP2])
            -N STR                      set the window's name (long title)
            -I STR                      set the window's icon name (short title)
            -M PATH                     set the window's mini-icon (an XPM file)
            -T STR                      set both the name and the icon name
            -L                          show information about the window
            -k MODE                     the window manager's "showing the desktop" mode
            -o X,Y                      the viewport of the current desktop
            -n NUM                      the number of desktops
            -g W,H                      the size of all desktops
            -h                          show the help
            -S                          list the windows in stacking order
            -i                          WIN is a numerical window ID
            -p                          show the PIDs in the window list
            -G                          show the geometry in the window list
            -x                          show WM_CLASS in the window list, or WIN is a WM_CLASS
            -u                          force UTF-8 mode
            -F                          match the whole window title, case-sensitively
            -v                          be verbose
            -w WA                       use a workaround
        `,
        values: #{
            "-s": "none", "-a": win, "-c": win, "-R": win, "-Y": win, "-r": win, "-t": "none", "-e": "none",
            "-y": "none", "-b": k("wmctrl_states"), "-N": "none", "-I": "none", "-T": "none",
            "-k": ["on", "off", "toggle"], "-o": "none", "-n": "none", "-g": "none",
            "-w": ["DESKTOP_TITLES_INVALID_UTF8"],
        },
        args: ["none"],
    }
}

// The commands of xdotool, which can be chained (`xdotool search --name x windowactivate`).
fn xdotool_commands() {
    [
        #{value: "getactivewindow", desc: "the active window"},
        #{value: "getwindowfocus", desc: "the focused window"},
        #{value: "getwindowname", desc: "the name of a window"},
        #{value: "getwindowclassname", desc: "the class name of a window"},
        #{value: "getwindowpid", desc: "the pid of a window"},
        #{value: "getwindowgeometry", desc: "the geometry of a window"},
        #{value: "getdisplaygeometry", desc: "the size of the display"},
        #{value: "search", desc: "search for windows"},
        #{value: "selectwindow", desc: "select a window with the mouse"},
        #{value: "help", desc: "list the commands"},
        #{value: "version", desc: "show the version"},
        #{value: "behave", desc: "run a command on a window event"},
        #{value: "behave_screen_edge", desc: "run a command when the mouse reaches a screen edge"},
        #{value: "click", desc: "click a mouse button"},
        #{value: "getmouselocation", desc: "the mouse location"},
        #{value: "key", desc: "type keystrokes"},
        #{value: "keydown", desc: "press keys"},
        #{value: "keyup", desc: "release keys"},
        #{value: "mousedown", desc: "press a mouse button"},
        #{value: "mousemove", desc: "move the mouse"},
        #{value: "mousemove_relative", desc: "move the mouse relative to its position"},
        #{value: "mouseup", desc: "release a mouse button"},
        #{value: "set_window", desc: "set properties of a window"},
        #{value: "type", desc: "type text"},
        #{value: "windowactivate", desc: "activate a window"},
        #{value: "windowfocus", desc: "focus a window"},
        #{value: "windowkill", desc: "kill the client of a window"},
        #{value: "windowclose", desc: "destroy a window"},
        #{value: "windowquit", desc: "ask a window to close"},
        #{value: "windowmap", desc: "map a window"},
        #{value: "windowminimize", desc: "minimize a window"},
        #{value: "windowmove", desc: "move a window"},
        #{value: "windowraise", desc: "raise a window"},
        #{value: "windowlower", desc: "lower a window"},
        #{value: "windowreparent", desc: "reparent a window"},
        #{value: "windowsize", desc: "resize a window"},
        #{value: "windowstate", desc: "change the state of a window"},
        #{value: "windowunmap", desc: "unmap a window"},
        #{value: "set_num_desktops", desc: "set the number of desktops"},
        #{value: "get_num_desktops", desc: "the number of desktops"},
        #{value: "set_desktop", desc: "switch to a desktop"},
        #{value: "get_desktop", desc: "the current desktop"},
        #{value: "set_desktop_for_window", desc: "move a window to a desktop"},
        #{value: "get_desktop_for_window", desc: "the desktop of a window"},
        #{value: "get_desktop_viewport", desc: "the viewport"},
        #{value: "set_desktop_viewport", desc: "move the viewport"},
        #{value: "exec", desc: "run a command"},
        #{value: "sleep", desc: "sleep for some seconds"},
    ]
}

// The spec of an xdotool command, whose last argument may be the next command (`next`). A window is an ID or one of
// the window stack (%1, %@) that search puts there.
fn xdotool_sub(name, next) {
    let win = [#{value: "%1", desc: "the first window of the stack"}, #{value: "%@", desc: "all the windows of the stack"}];
    let win_or_next = win + next;
    let shell = `
        --shell                     print shell variables
        --prefix STR                the prefix of the variables' names
    `;
    let keys = `
        --clearmodifiers            clear the active modifiers during the keystrokes
        --delay DELAY               milliseconds between keystrokes
        --repeat TIMES              repeat the keys
        --repeat-delay DELAY        milliseconds between repetitions
        --window WINDOW             send the keystrokes to a window
    `;
    let sync_opt = "--sync  wait until it is done";
    let s = switch name {
        "getwindowfocus" => #{opts: "-f  the focused window, even if it isn't a top-level one", args: [next]},
        "getwindowname" | "getwindowclassname" | "getwindowpid" | "windowkill" | "windowclose" | "windowquit"
            | "windowraise" | "windowlower" | "get_desktop_for_window" => #{args: [win_or_next, next]},
        "getwindowgeometry" => #{opts: shell, args: [win_or_next, next]},
        "getmouselocation" => #{opts: shell, args: [next]},
        "search" => #{
            opts: `
                --class                 match the window class
                --classname             match the window class name
                --role                  match the window role
                --maxdepth N            the depth of the search (-1: infinite)
                --onlyvisible           only visible windows
                --pid PID               only the windows of a process
                --screen N              only a screen
                --desktop N             only a desktop
                --limit N               stop after N results
                --name                  match the window name
                --shell                 print the results as a shell array WINDOWS=( ... )
                --prefix STR            the prefix of the array's name
                --title                 the same as --name (deprecated)
                --all                   all conditions must match
                --any                   any condition may match
                --sync                  wait until a window is found
                -h, --help              show the help
            `,
            values: #{"--maxdepth": "none", "--pid": "pids", "--screen": "none", "--desktop": "none",
                      "--limit": "none", "--prefix": "none"},
            args: ["none", next],
        },
        "behave" => #{args: [win, ["mouse-enter", "mouse-leave", "mouse-click", "focus", "blur"], next]},
        "behave_screen_edge" => #{
            opts: `
                --delay MILLISECONDS    how long the mouse must stay there
                --quiesce MILLISECONDS  how long after activating before another activation
            `,
            values: #{"--delay": "none", "--quiesce": "none"},
            args: [["left", "top", "right", "bottom", "top-left", "top-right", "bottom-left", "bottom-right"], next],
        },
        "click" | "mousedown" | "mouseup" => #{
            opts: `
                --clearmodifiers        clear the active modifiers
                --window WINDOW         send the click to a window
                --repeat REPEATS        click this many times
                --delay MILLISECONDS    milliseconds between clicks (100)
            `,
            values: #{"--window": win, "--repeat": "none", "--delay": "none"},
            args: [[#{value: "1", desc: "left"}, #{value: "2", desc: "middle"}, #{value: "3", desc: "right"},
                    #{value: "4", desc: "wheel up"}, #{value: "5", desc: "wheel down"}], next],
        },
        "key" | "keydown" | "keyup" => #{
            opts: keys,
            values: #{"--delay": "none", "--repeat": "none", "--repeat-delay": "none", "--window": win},
            args: [k("xdotool_keys")],
        },
        "mousemove" => #{
            opts: `
                -c, --clearmodifiers    clear the active modifiers
                --screen SCREEN         the screen to move on
                --sync                  wait until the mouse has moved
                -w, --window WINDOW     move relative to a window
            `,
            values: #{"--screen": "none", "--window": win},
            args: [["restore"], "none", next],
        },
        "mousemove_relative" => #{
            opts: `
                -c, --clearmodifiers    clear the active modifiers
                -p, --polar             polar coordinates (X an angle, Y a distance)
                --sync                  wait until the mouse has moved
            `,
            args: ["none", "none", next],
        },
        "set_window" => #{
            opts: `
                --name NAME             the window's name (title)
                --icon-name NAME        the window's name while minimized
                --role ROLE             the window's role
                --class CLASS           the window's class
                --classname CLASSNAME   the window's class name
                --overrideredirect OVERRIDE  override_redirect (1: unmanaged by the window manager)
                --urgency URGENT        the urgency hint (1 or 0)
            `,
            values: #{"--name": "none", "--icon-name": "none", "--role": "none", "--class": "none",
                      "--classname": "none", "--overrideredirect": ["0", "1"], "--urgency": ["0", "1"]},
            args: [win_or_next, next],
        },
        "type" => #{
            opts: `
                --window WINDOW         send the keystrokes to a window
                --delay MILLISECONDS    milliseconds between keystrokes
                --clearmodifiers        clear the active modifiers
                --args N                the number of arguments to type
                --terminator TERM       the word that ends the arguments to type
                --file FILE             type the contents of a file (- for standard input)
                -h, --help              show the help
            `,
            values: #{"--window": win, "--delay": "none", "--args": "none", "--terminator": "none"},
            args: ["none"],
        },
        "windowactivate" | "windowfocus" | "windowmap" | "windowminimize" | "windowunmap" =>
            #{opts: sync_opt, args: [win_or_next, next]},
        "windowmove" => #{
            opts: sync_opt + "\n--relative  move relative to the window's position",
            args: [win, "none", "none", next],
        },
        "windowsize" => #{
            opts: sync_opt + "\n--usehints  use the window's sizing hints (in characters, for terminals)",
            args: [win, "none", "none", next],
        },
        "windowreparent" => #{args: [win, win, next]},
        "windowstate" => #{
            opts: `
                --add PROPERTY          add a property
                --remove PROPERTY       remove a property
                --toggle PROPERTY       toggle a property
            `,
            values: #{"--add": k("xdotool_states"), "--remove": k("xdotool_states"),
                      "--toggle": k("xdotool_states")},
            args: [win_or_next, next],
        },
        "set_num_desktops" | "sleep" => #{args: ["none", next]},
        "set_desktop" => #{opts: "--relative  relative to the current desktop", args: ["none", next]},
        "set_desktop_for_window" => #{args: [win, "none", next]},
        "set_desktop_viewport" => #{args: ["none", "none", next]},
        "exec" => #{
            opts: `
                --sync                  wait for the command to finish
                --args N                the number of arguments of the command
                --terminator TERM       the word that ends the command
            `,
            values: #{"--args": "none", "--terminator": "none"},
            args: ["commands", "files"],
        },
        "help" | "version" => #{args: ["none"]},
        _ => #{args: [next]},
    };
    s
}

// xdotool [COMMAND [OPTIONS] [ARGS]]... | xdotool SCRIPT: the line is completed with the spec of the last command
// on it (key, type and exec take the rest of the line).
fn complete_xdotool(words, i) {
    let names = xdotool_commands().map(|c| c.value);
    let j = 0;
    for w in 1..i {
        if ["key", "keydown", "keyup", "type", "exec"].contains(words[j]) {
            break;
        }
        if names.contains(words[w]) {
            j = w;
        }
    }
    if j == 0 {
        return lib::complete(#{args: [xdotool_commands(), "none"]}, words, i);
    }
    let s = xdotool_sub(words[j], xdotool_commands());
    s.line = words;
    lib::complete(s, words.extract(j), i - j)
}

// swaymsg [OPTIONS] [MESSAGE]: a message of type command (the default) is a sway command.
fn swaymsg() {
    #{
        opts: `
            -h, --help                  show the help
            -m, --monitor               monitor until killed (-t subscribe)
            -p, --pretty                pretty output, even when not on a terminal
            -q, --quiet                 be quiet
            -r, --raw                   raw output, even on a terminal
            -s, --socket SOCKET         the socket
            -t, --type TYPE             the type of the message
            -v, --version               show the version
        `,
        values: #{
            "--socket": "files",
            "--type": ["command", "get_workspaces", "get_seats", "get_inputs", "get_outputs", "get_tree",
                       "get_marks", "get_bar_config", "get_version", "get_binding_modes", "get_binding_state",
                       "get_config", "send_tick", "subscribe"],
        },
        args: [k("sway_commands"), "none"],
    }
}

// The dispatchers of `hyprctl dispatch`.
fn hypr_dispatchers() {
    ["exec", "execr", "pass", "sendshortcut", "sendkeystate", "killactive", "closewindow", "workspace",
     "movetoworkspace", "movetoworkspacesilent", "togglefloating", "setfloating", "settiled", "fullscreen",
     "fakefullscreen", "fullscreenstate", "dpms", "pin", "movefocus", "movewindow", "swapwindow", "centerwindow",
     "resizeactive", "moveactive", "resizewindowpixel", "movewindowpixel", "cyclenext", "swapnext", "tagwindow",
     "focuswindow", "focusmonitor", "splitratio", "toggleopaque", "movecursortocorner", "movecursor",
     "renameworkspace", "exit", "forcerendererreload", "movecurrentworkspacetomonitor",
     "focusworkspaceoncurrentmonitor", "moveworkspacetomonitor", "swapactiveworkspaces", "alterzorder",
     "togglespecialworkspace", "focusurgentorlast", "togglegroup", "changegroupactive", "focuscurrentorlast",
     "lockgroups", "lockactivegroup", "moveintogroup", "moveoutofgroup", "movewindoworgroup", "movegroupwindow",
     "denywindowfromgroup", "global", "submap", "event"]
}

// hyprctl [FLAGS] COMMAND [ARGS]
fn hyprctl() {
    #{
        opts: `
            -j                          output JSON
            -r                          refresh the state after the command
            --batch                     run commands separated by ;
            -i, --instance INSTANCE     the instance (its signature, or its index in hyprctl instances)
            -q, --quiet                 no output
            -h, --help                  show the help
        `,
        values: #{"--instance": "none"},
        commands: `
            activewindow                the active window and its properties
            activeworkspace             the active workspace and its properties
            animations                  the configured animations and beziers
            binds                       list the binds
            clients                     list the windows and their properties
            configerrors                list the configuration's parsing errors
            cursorpos                   the cursor position, in global layout coordinates
            decorations                 list the decorations of a window
            devices                     list the keyboards and mice
            dismissnotify               dismiss all notifications, or this many
            dispatch                    call a dispatcher
            eval                        run Lua code
            getoption                   the value of a configuration option
            globalshortcuts             list the global shortcuts
            hyprpaper                   send a hyprpaper request
            hyprsunset                  send a hyprsunset request
            instances                   list the running instances
            keyword                     set a configuration keyword
            kill                        kill the window clicked on (Escape to exit)
            layers                      list the surface layers
            layouts                     list the layouts
            monitors                    list the active outputs (all: and the inactive ones)
            notify                      send a notification
            output                      add or remove a fake output
            plugin                      send a plugin request
            reload                      reload the configuration
            repl                        an interactive Lua REPL, or the result of Lua code
            rollinglog                  the tail of the log
            setcursor                   set the cursor theme and size
            seterror                    set the error string
            setprop                     set a window property
            getprop                     get a window property
            splash                      the current splash
            status                      internal status information
            switchxkblayout             set the xkb layout of a keyboard
            systeminfo                  system information
            version                     the version, flags, commit and branch
            workspacerules              list the workspace rules
            workspaces                  list the workspaces and their properties
        `,
        subs: #{
            "dispatch": #{args: [hypr_dispatchers(), "none"]},
            "monitors": #{args: [["all"], "none"]},
            "reload": #{args: [["config-only"], "none"]},
            "rollinglog": #{opts: "-f, --follow  follow the log", args: ["none"]},
            "output": #{args: [["create", "remove"], ["wayland", "x11", "headless", "auto"], "none"]},
            "notify": #{args: [[#{value: "-1", desc: "no icon"}, #{value: "0", desc: "warning"},
                                #{value: "1", desc: "info"}, #{value: "2", desc: "hint"},
                                #{value: "3", desc: "error"}, #{value: "4", desc: "confused"},
                                #{value: "5", desc: "ok"}], "none"]},
            "seterror": #{args: [["disable"], "none"]},
            "switchxkblayout": #{args: ["none", ["next", "prev"], "none"]},
            "plugin": #{args: [["load", "unload", "list"], "files", "none"]},
        },
    }
}

fn spec(cmd) {
    switch cmd {
        "xrandr" => xrandr(),
        "gsettings" => gsettings(),
        "dconf" => dconf(),
        "notify-send" => notify_send(),
        "wmctrl" => wmctrl(),
        "swaymsg" => swaymsg(),
        "hyprctl" => hyprctl(),
        _ => #{},
    }
}
