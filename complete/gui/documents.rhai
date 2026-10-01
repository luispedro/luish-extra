// Documents: libreoffice and soffice (LibreOffice 24.2.7.2; soffice is the same program).

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

fn spec(cmd) {
    switch cmd {
        "libreoffice" | "soffice" => libreoffice(),
        _ => #{},
    }
}
