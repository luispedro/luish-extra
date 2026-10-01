// ipython and the Jupyter applications, from their `--help` (traitlets; ipython 9.9.0, jupyterlab 4.5.2,
// notebook 7.5.2, nbconvert 7.16.6, jupyter_client 8.8.0, jupyter_server 2.17.0, jupyter_core 5.9.1). They take
// seconds to start, which is why the tables are written out. The options of the classes (`--Application.log_level`)
// are not offered: they are in `--help-all`.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn ipython() {
    #{
        opts: `
            --debug                       set log level to logging.DEBUG (maximize logging output)
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --quiet                       set log level to logging.CRITICAL (minimize logging output)
            --init                        initialize profile with default config files
            --autoindent                  turn on autoindenting
            --no-autoindent               turn off autoindenting
            --automagic                   turn on the auto calling of magic commands
            --no-automagic                turn off the auto calling of magic commands
            --pdb                         enable auto calling the pdb debugger after every exception
            --no-pdb                      disable auto calling the pdb debugger after every exception
            --pprint                      enable auto pretty printing of results
            --no-pprint                   disable auto pretty printing of results
            --color-info                  IPython can display information about objects via a set of functions
            --no-color-info               disable using colors for info related things
            --ignore-cwd                  exclude the current working directory from sys.path
            --no-ignore-cwd               include the current working directory in sys.path
            --nosep                       eliminate all spacing between prompts
            --pylab                       pre-load matplotlib and numpy for interactive use with
            --matplotlib                  configure matplotlib for interactive use with
            --autoedit-syntax             turn on auto editing of files with syntax errors
            --no-autoedit-syntax          turn off auto editing of files with syntax errors
            --simple-prompt               force simple minimal prompt using 'raw_input'
            --no-simple-prompt            use a rich interactive prompt with prompt_toolkit
            --banner                      display a banner upon starting IPython
            --no-banner                   don't display a banner upon starting IPython
            --confirm-exit                set to confirm when you try to exit IPython with an EOF
            --no-confirm-exit             don't prompt the user when exiting
            --tip                         shows a tip when IPython starts
            --no-tip                      don't show tip when IPython starts
            --term-title                  enable auto setting the terminal title
            --no-term-title               disable auto setting the terminal title
            --classic                     gives IPython a similar feel to the classic Python prompt
            --quick                       enable quick startup with no config files
            -i                            if running code from the command line, become interactive afterwards
            --log-level VALUE             set the log level by value or name
            --profile-dir VALUE           set the profile location directly
            --profile VALUE               the IPython profile to use
            --ipython-dir VALUE           the name of the IPython directory
            --config VALUE                path to an extra config file to load
            --autocall VALUE              make IPython automatically call any callable object even if you didn't type
            --colors VALUE                set the color scheme (nocolor, neutral, linux, lightbg)
            --theme VALUE                 set the color scheme (nocolor, neutral, linux, lightbg)
            --logfile VALUE               the name of the logfile to use
            --logappend VALUE             start logging to the given file in append mode
            -c VALUE                      execute the given command string
            -m VALUE                      run the module as a script
            --gui VALUE                   enable GUI event loop integration with any of
            --pylab VALUE                 pre-load matplotlib and numpy for interactive use, selecting a particular
            --matplotlib VALUE            configure matplotlib for interactive use with the default matplotlib
            --cache-size VALUE            set the size of the output cache
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--profile-dir": "dirs", "--profile": "none", "--ipython-dir": "dirs", "--config": "files",
            "--autocall": ["0", "1", "2"], "--colors": ["nocolor", "neutral", "linux", "lightbg"],
            "--theme": ["nocolor", "neutral", "linux", "lightbg"], "--logfile": "files", "--logappend": "none",
            "-c": "none", "-m": "none",
            "--gui": [
                "asyncio", "glut", "gtk", "gtk2", "gtk3", "gtk4", "osx", "pyglet", "qt", "qt5", "qt6", "tk", "wx",
                "gtk2", "qt4",
            ],
            "--pylab": [
                "agg", "auto", "gtk", "gtk3", "gtk4", "inline", "ipympl", "nbagg", "notebook", "osx", "pdf", "ps",
                "qt", "qt4", "qt5", "qt6", "svg", "tk", "webagg", "widget", "wx",
            ],
            "--matplotlib": [
                "agg", "auto", "gtk", "gtk3", "gtk4", "inline", "ipympl", "nbagg", "notebook", "osx", "pdf", "ps",
                "qt", "qt4", "qt5", "qt6", "svg", "tk", "webagg", "widget", "wx",
            ], "--cache-size": "none",
        },
        args: [own("kinds:python_script")],
    }
}

fn nbconvert() {
    #{
        opts: `
            --debug                       set log level to logging.DEBUG (maximize logging output)
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --generate-config             generate default config file
            -y                            answer yes to any questions instead of prompting
            --execute                     execute the notebook prior to export
            --allow-errors                continue notebook execution even if one of the cells throws an error and include the
            --stdin                       read a single notebook file from stdin
            --stdout                      write notebook output to stdout instead of files
            --inplace                     run nbconvert in place, overwriting the existing notebook
            --clear-output                clear output of current file and save in place
            --coalesce-streams            coalesce consecutive stdout and stderr outputs into one stream (within each cell)
            --no-prompt                   exclude input and output prompts from converted document
            --no-input                    exclude input cells and output prompts from converted document
            --allow-chromium-download     whether to allow downloading chromium if no suitable version is found on the system
            --disable-chromium-sandbox    disable chromium security sandbox when converting to PDF
            --show-input                  shows code input
            --embed-images                embed the images as base64 dataurls in the output
            --sanitize-html               whether the HTML in Markdown cells and cell outputs should be sanitized
            --log-level VALUE             set the log level by value or name
            --config VALUE                full path of a config file
            --to VALUE                    the export format to be used, either one of the built-in formats
            --template VALUE              name of the template to use
            --template-file VALUE         name of the template file to use
            --theme VALUE                 template specific theme
            --sanitize_html VALUE         whether the HTML in Markdown cells and cell outputs should be sanitized.This
            --writer VALUE                writer class used to write the results of the conversion
            --post VALUE                  postProcessor class used to write the results of the conversion
            --output VALUE                overwrite base name use for output files
            --output-dir VALUE            directory to write output(s) to
            --reveal-prefix VALUE         the URL prefix for reveal.js (version 3.x)
            --nbformat VALUE              the nbformat version to write
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--config": "files",
            "--to": [
                "asciidoc", "custom", "html", "latex", "markdown", "notebook", "pdf", "python", "qtpdf", "qtpng",
                "rst", "script", "slides", "webpdf",
            ], "--template": "none", "--template-file": "files", "--theme": "none", "--sanitize_html": "none",
            "--writer": "none", "--post": "none", "--output": "none", "--output-dir": "dirs",
            "--reveal-prefix": "none", "--nbformat": ["1", "2", "3", "4"],
        },
        args: [own("kinds:notebook")],
    }
}

fn lab() {
    #{
        opts: `
            --debug                       set debug level for the extension and underlying server applications
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --generate-config             generate default config file
            -y                            answer yes to any questions instead of prompting
            --allow-root                  allow the server to be run from root user
            --no-browser                  prevent the opening of the default url in the browser
            --autoreload                  autoreload the webapp
            --script                      DEPRECATED, IGNORED
            --no-script                   DEPRECATED, IGNORED
            --core-mode                   start the app in core mode
            --dev-mode                    start the app in dev mode for running from source
            --skip-dev-build              skip the initial install and JS build of the app in dev mode
            --watch                       start the app in watch mode
            --splice-source               splice source packages into app directory
            --expose-app-in-browser       expose the global app instance to browser via window.jupyterapp
            --extensions-in-dev-mode      load prebuilt extensions in dev-mode
            --collaborative               to enable real-time collaboration, you must install the extension 'jupyter_collaboration'
            --custom-css                  load custom CSS in template html files
            --log-level VALUE             set the log level by value or name
            --config VALUE                full path of a config file
            --ip VALUE                    the IP address the Jupyter server will listen on
            --port VALUE                  the port the server will listen on (env: JUPYTER_PORT)
            --port-retries VALUE          the number of additional ports to try if the specified port is not available
            --keyfile VALUE               the full path to a private key file for usage with SSL/TLS
            --certfile VALUE              the full path to an SSL/TLS certificate file
            --client-ca VALUE             the full path to a certificate authority certificate for SSL/TLS client
            --notebook-dir VALUE          the directory to use for notebooks and kernels
            --browser VALUE               specify what command to use to invoke a web browser when starting the
            --pylab VALUE                 DISABLED: use %pylab or %matplotlib in the notebook to enable matplotlib
            --watch VALUE                 whether to serve the app in watch mode
            --app-dir VALUE               the app directory to launch JupyterLab from
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--config": "files", "--ip": "none", "--port": "none", "--port-retries": "none", "--keyfile": "files",
            "--certfile": "files", "--client-ca": "none", "--notebook-dir": "dirs", "--browser": "none",
            "--pylab": "none", "--watch": "none", "--app-dir": "dirs",
        },
        args: [own("kinds:notebook")],
    }
}

fn notebook() {
    #{
        opts: `
            --debug                       set debug level for the extension and underlying server applications
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --generate-config             generate default config file
            -y                            answer yes to any questions instead of prompting
            --allow-root                  allow the server to be run from root user
            --no-browser                  prevent the opening of the default url in the browser
            --autoreload                  autoreload the webapp
            --script                      DEPRECATED, IGNORED
            --no-script                   DEPRECATED, IGNORED
            --expose-app-in-browser       expose the global app instance to browser via window.jupyterapp
            --custom-css                  load custom CSS in template html files
            --log-level VALUE             set the log level by value or name
            --config VALUE                full path of a config file
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--config": "files",
        },
        args: [own("kinds:notebook")],
    }
}

fn server() {
    #{
        opts: `
            --debug                       set debug level for the extension and underlying server applications
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --generate-config             generate default config file
            -y                            answer yes to any questions instead of prompting
            --allow-root                  allow the server to be run from root user
            --no-browser                  prevent the opening of the default url in the browser
            --autoreload                  autoreload the webapp
            --script                      DEPRECATED, IGNORED
            --no-script                   DEPRECATED, IGNORED
            --log-level VALUE             set the log level by value or name
            --config VALUE                full path of a config file
            --ip VALUE                    the IP address the Jupyter server will listen on
            --port VALUE                  the port the server will listen on (env: JUPYTER_PORT)
            --port-retries VALUE          the number of additional ports to try if the specified port is not available
            --sock VALUE                  the UNIX socket the Jupyter server will listen on
            --sock-mode VALUE             the permissions mode for UNIX socket creation
            --transport VALUE
            --keyfile VALUE               the full path to a private key file for usage with SSL/TLS
            --certfile VALUE              the full path to an SSL/TLS certificate file
            --client-ca VALUE             the full path to a certificate authority certificate for SSL/TLS client
            --notebook-dir VALUE          the directory to use for notebooks and kernels
            --preferred-dir VALUE         preferred starting directory to use for notebooks and kernels
            --browser VALUE               specify what command to use to invoke a web browser when starting the
            --pylab VALUE                 DISABLED: use %pylab or %matplotlib in the notebook to enable matplotlib
            --gateway-url VALUE           the url of the Kernel or Enterprise Gateway server where kernel
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--config": "files", "--ip": "none", "--port": "none", "--port-retries": "none", "--sock": "none",
            "--sock-mode": "none", "--transport": ["tcp", "ipc"], "--keyfile": "files", "--certfile": "files",
            "--client-ca": "none", "--notebook-dir": "dirs", "--preferred-dir": "dirs", "--browser": "none",
            "--pylab": "none", "--gateway-url": "none",
        },
        args: ["dirs"],
    }
}

fn console() {
    #{
        opts: `
            --debug                       set log level to logging.DEBUG (maximize logging output)
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --generate-config             generate default config file
            -y                            answer yes to any questions instead of prompting
            --existing                    connect to an existing kernel
            --confirm-exit                set to display confirmation dialog on exit
            --no-confirm-exit             don't prompt the user when exiting
            --simple-prompt               force simple minimal prompt using 'raw_input'
            --no-simple-prompt            use a rich interactive prompt with prompt_toolkit
            --log-level VALUE             set the log level by value or name
            --config VALUE                full path of a config file
            --ip VALUE                    set the kernel's IP address
            --transport VALUE
            --hb VALUE                    set the heartbeat port
            --shell VALUE                 set the shell (ROUTER) port
            --iopub VALUE                 set the iopub (PUB) port
            --stdin VALUE                 set the stdin (ROUTER) port
            --control VALUE               set the control (ROUTER) port
            --existing VALUE              connect to an already running kernel
            -f VALUE                      JSON file in which to store connection info
            --kernel VALUE                the name of the default kernel to start
            --ssh VALUE                   the SSH server to use to connect to the kernel
            --sshkey VALUE                path to the ssh key to use for logging in to the ssh server
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--config": "files", "--ip": "none", "--transport": ["tcp", "ipc"], "--hb": "none", "--shell": "none",
            "--iopub": "none", "--stdin": "none", "--control": "none", "--existing": "none", "-f": "none",
            "--kernel": "none", "--ssh": "none", "--sshkey": "none",
        },
        args: ["files"],
    }
}

fn execute() {
    #{
        opts: `
            --allow-errors                errors are ignored and execution is continued until the end of the notebook
            --inplace                     overwrite input notebook with executed results
            --timeout VALUE               the time to wait (in seconds) for output from executions
            --startup_timeout VALUE       the time to wait (in seconds) for the kernel to start
            --kernel_name VALUE           name of kernel to use to execute the cells
            --output VALUE                write executed notebook to this file base name
        `,
        values: #{
            "--timeout": "none", "--startup_timeout": "none", "--kernel_name": "none", "--output": "none",
        },
        args: [own("kinds:notebook")],
    }
}

fn trust() {
    #{
        opts: `
            --reset                       delete the trusted notebook cache
            --debug                       set log level to logging.DEBUG (maximize logging output)
            --show-config                 show the application's configuration (human-readable format)
            --show-config-json            show the application's configuration (json format)
            --generate-config             generate default config file
            -y                            answer yes to any questions instead of prompting
            --log-level VALUE             set the log level by value or name
            --config VALUE                full path of a config file
        `,
        values: #{
            "--log-level": ["0", "10", "20", "30", "40", "50", "DEBUG", "INFO", "WARN", "ERROR", "CRITICAL"],
            "--config": "files",
        },
        args: [own("kinds:notebook")],
    }
}

fn kernelspec() {
    #{
        args: ["files"],
    }
}

fn sub_spec(name) {
    switch name {
        "ipython" => ipython(),
        "nbconvert" => nbconvert(),
        "lab" => lab(),
        "notebook" => notebook(),
        "server" => server(),
        "console" => console(),
        "execute" => execute(),
        "trust" => trust(),
        "kernelspec" => kernelspec(),
        _ => (),
    }
}
