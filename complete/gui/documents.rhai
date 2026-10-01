// Documents: libreoffice and soffice (LibreOffice 24.2.7.2; soffice is the same program), evince (46.3.1), okular
// (23.08.5), zathura (2026.07.18) and xdg-open (xdg-utils 1.1.3).
import "qt" as qt;

fn k(name) { "@extra-complete/gui/kinds:" + name }

// soffice [OPTIONS] [FILES]: the options of its `--help`. `-n`, `-o`, `-p`, `--pt`, `--view` and `--show` say how the
// files after them are opened, and `-env:VAR=VALUE` sets a bootstrap variable. `--nstemporarydirectory` (macOS
// sandbox only) and the ignored switches (`-psn`, `-Embedding`, `--nofirststartwizard`, `--protector`) are left out.
fn libreoffice() {
    #{
        opts: `
            -h, -?, --help                show this help and quit
            --helpwriter                  open the help on Writer
            --helpcalc                    open the help on Calc
            --helpdraw                    open the help on Draw
            --helpimpress                 open the help on Impress
            --helpbase                    open the help on Base
            --helpbasic                   open the help on Basic scripting
            --helpmath                    open the help on Math
            --version                     show the version and quit
            --quickstart[=no]             activate (deactivate) the quickstarter service
            --nolockcheck                 disable the check for remote instances using the installation
            --infilter=FILTER             force an input filter type
            --pidfile=FILE                store the pid of soffice.bin in FILE
            --display DISPLAY             set the DISPLAY environment variable
            --nologo                      disable the splash screen
            --minimized                   start minimized
            --nodefault                   start without displaying anything except the splash screen
            --invisible                   start in invisible mode
            --headless                    start without a GUI
            --norestore                   disable restart and file recovery after a crash
            --safe-mode                   start with a fresh user profile, temporarily
            --accept=CONNECT              create a UNO acceptor
            --unaccept=CONNECT            close a UNO acceptor (all: all of them)
            --language=LANG               the UI's language (an IETF language tag)
            --terminate_after_init        exit after initialization (no documents loaded)
            --eventtesting                exit after loading documents
            --writer                      create an empty Writer document
            --calc                        create an empty Calc document
            --draw                        create an empty Draw document
            --impress                     create an empty Impress document
            --base                        create a new database
            --global                      create an empty Writer master document
            --math                        create an empty Math document
            --web                         create an empty HTML document
            -n                            treat the following files as templates for new documents
            -o                            open the following files for editing
            --pt PRINTER                  print the following files to PRINTER
            -p                            print the following files to the default printer
            --view                        open the following files read-only
            --show                        open and start the following presentations
            --convert-to EXT[:FILTER]     convert files (implies --headless)
            --outdir DIR                  output directory (--convert-to, --print-to-file)
            --convert-images-to FORMAT    filter format for all images written (--convert-to)
            --print-to-file               print files to files
            --printer-name PRINTER        printer (--print-to-file)
            --cat                         dump the text content of the files (implies --headless)
            --script-cat                  dump the text content of the files' scripts (implies --headless)
        `,
        values: #{
            "--infilter": k("lo_import_filters"),
            "--pidfile": "files",
            "--display": "none",
            "--accept": [
                #{value: "socket,host=localhost,port=", suffix: "", desc: "a TCP socket (then ;urp)"},
                #{value: "pipe,name=", suffix: "", desc: "a named pipe (then ;urp)"},
            ],
            "--unaccept": ["all"],
            "--language": "none",
            "--pt": k("printers"),
            "--printer-name": k("printers"),
            "--convert-to": k("lo_convert"),
            "--outdir": "dirs",
            "--convert-images-to": "none",
        },
        skip: #{"-env:": k("lo_bootstrap")},
        strict_eq: true,
    }
}

// The options of GTK 3 that GNOME programs take (`--help-gtk`).
fn gtk_opts() {
    `
        --class=CLASS               program class, for the window manager
        --name=NAME                 program name, for the window manager
        --gtk-module=MODULES        load additional GTK modules
        --g-fatal-warnings          make all warnings fatal
        --display=DISPLAY           X display to use
    `
}

fn gtk_values() {
    #{"--class": "none", "--name": "none", "--gtk-module": "none", "--display": "none"}
}

// evince [OPTIONS] [FILES]
fn evince() {
    let v = gtk_values();
    v.mixin(#{"--page-label": "none", "--page-index": "none", "--named-dest": "none", "--find": "none"});
    #{
        opts: `
            -h, --help                  show the help
            --help-all                  show all the help
            --help-gtk                  show GTK's options
            --version                   show the version
            -o, --new-window            open a new window
            -p, --page-label=PAGE       the page label to show
            -i, --page-index=NUMBER     the page number to show
            -n, --named-dest=DEST       the named destination to show
            -f, --fullscreen            start in full screen
            -s, --presentation          start in presentation mode
            -w, --preview               run as a previewer
            -l, --find=STRING           the word or phrase to find
        ` + gtk_opts(),
        values: v,
    }
}

// zathura [OPTIONS] [FILES]: a file `-` is standard input.
fn zathura() {
    #{
        opts: `
            -h, --help                  show the help
            -v, --version               show the version
            -c, --config-dir=PATH       the configuration directory
            -d, --data-dir=PATH         the data directory
            --cache-dir=PATH            the cache directory
            -p, --plugins-dir=PATH      the directories of the plugins (:-separated)
            --fork                      fork into the background
            -w, --password=PASSWORD     the document's password
            -P, --page=NUMBER           the page to go to
            -l, --log-level=LEVEL       the log level
            -x, --synctex-editor-command=CMD  the SyncTeX editor command (%{input}, %{line}, %{column})
            --synctex-forward=POSITION  move to a SyncTeX position (LINE:COLUMN:INPUT)
            --synctex-pid=PID           highlight the position in this zathura
            --mode=MODE                 start in a non-default mode
            -b, --bookmark=BOOKMARK     the bookmark to go to
            -f, --find=STRING           search for a phrase and show the results
        `,
        values: #{
            "--config-dir": "dirs",
            "--data-dir": "dirs",
            "--cache-dir": "dirs",
            "--plugins-dir": "dirs",
            "--password": "none",
            "--page": "none",
            "--log-level": ["debug", "info", "warning", "error"],
            "--synctex-editor-command": "none",
            "--synctex-forward": "none",
            "--synctex-pid": k("zathura_pids"),
            "--mode": ["presentation", "fullscreen"],
            "--bookmark": "none",
            "--find": "none",
        },
    }
}

// okular [OPTIONS] [FILES]: a file `-` is standard input.
fn okular() {
    qt::with_kde(#{
        opts: `
            -p, --page NUMBER       the page to show
            --presentation          start in presentation mode
            --print                 start with the print dialog
            --print-and-exit        start with the print dialog and quit after printing
            --unique                open in the running okular, if there is one
            --noraise               don't raise the window
            --find STRING           find a string in the text
            --editor-cmd STRING     the external editor command
        `,
        values: #{"--page": "none", "--find": "none", "--editor-cmd": "none"},
    })
}

// xdg-open {FILE | URL}: the options only alone.
fn xdg_open() {
    #{
        opts: `
            --help                  show the help
            --manual                show the manual
            --version               show the version
        `,
        args: ["files", "none"],
    }
}

fn spec(cmd) {
    switch cmd {
        "libreoffice" | "soffice" => libreoffice(),
        "evince" => evince(),
        "okular" => okular(),
        "zathura" => zathura(),
        "xdg-open" => xdg_open(),
        _ => #{},
    }
}
