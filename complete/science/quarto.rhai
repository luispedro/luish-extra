// Quarto 1.9.38, from `quarto --help` and `quarto COMMAND --help`. The output formats of `--to`, the
// providers of `publish` and the tools of `install` are from Quarto's documentation, since the help only says
// `[provider]`. `quarto pandoc` takes pandoc's options (the spec of pandoc.rhai).

fn k(name) { "@extra-complete/science/kinds:" + name }

import "pandoc" as pandoc;

fn logging() {
    `
        --log FILE                path to log file
        --log-level LEVEL         log level
        --log-format FORMAT       log format
        --quiet                   suppress console output
        --profile NAMES           active project profile(s)
    `
}

fn formats() {
    [
        "html", "pdf", "docx", "odt", "pptx", "revealjs", "beamer", "typst", "latex", "epub", "gfm", "commonmark",
        "markdown", "ipynb", "asciidoc", "dokuwiki", "jats", "jira", "man", "mediawiki", "muse", "org", "plain",
        "rst", "rtf", "tei", "textile", "xwiki", "zimwiki", "docbook", "dzslides", "slidy", "slideous", "s5",
        "ms", "opml", "texinfo", "context", "icml", "native", "json", "chunkedhtml", "all",
    ]
}

fn values() {
    #{
        "--log": "files", "--log-level": ["debug", "info", "warning", "error", "critical"],
        "--log-format": ["plain", "json-stream"], "--profile": "none",
        "--to": formats(), "-t": formats(), "--output": "files", "-o": "files", "--output-dir": "dirs",
        "--site-url": "none", "--metadata": "none", "-M": "none", "--execute-param": "none", "-P": "none",
        "--execute-params": k("params_file"), "--execute-dir": "dirs",
        "--port": "none", "-p": "none", "--host": "none", "--render": formats(), "--timeout": "none",
        "--open": ["positron", "vscode", "rstudio"], "--embed": "none",
        "--id": "none", "--server": "none", "--token": "none",
    }
}

fn quarto() {
    #{
        opts: `
            -h, --help     show help
            -V, --version  show the version number
        `,
        commands: `
            render     render files or projects to various document types
            preview    render and preview a document or website project
            serve      serve a Shiny interactive document
            create     create a Quarto project or extension
            use        automate document or project setup tasks
            add        add an extension to this folder or project
            update     update an extension or global dependency
            remove     remove an extension
            convert    convert documents to alternate representations
            pandoc     run the version of Pandoc embedded within Quarto
            typst      run the version of Typst embedded within Quarto
            run        run a TypeScript, R, Python, or Lua script
            list       list an extension or global dependency
            install    install a global dependency
            uninstall  uninstall a global dependency
            tools      display the status of Quarto installed dependencies
            publish    publish a document or project to a provider
            check      verify correct functioning of the Quarto installation
            call       access functions of Quarto subsystems such as its rendering engines
            inspect    inspect a document or project
            help       show the help of a command
        `,
        values: values(),
        sub_spec: "@extra-complete/science/quarto:sub",
    }
}

fn source() { k("quarto_source") }

fn sub_spec(name, sub) {
    switch sub {
        "render" => #{
            opts: `
                -t, --to FORMAT           specify output format(s)
                -o, --output FILE         write output to FILE (use '--output -' for stdout)
                --output-dir DIR          write output to DIR (path is input/project relative)
                -M, --metadata KEY:VALUE  metadata value
                --site-url URL            override site-url for website or book output
                --execute                 execute code
                --no-execute              skip code execution
                -P, --execute-param KEY:VALUE  execution parameter
                --execute-params FILE     YAML file with execution parameters
                --execute-dir DIR         working directory for code execution
                --execute-daemon SECONDS  keep Jupyter kernel alive
                --execute-daemon-restart  restart keepalive Jupyter kernel before render
                --execute-debug           show debug output when executing computations
                --use-freezer             force use of frozen computations for an incremental file render
                --cache                   cache execution output
                --no-cache                prevent caching of execution output
                --cache-refresh           force refresh of execution cache
                --no-clean                do not clean project output-dir prior to render
                --debug                   leave intermediate files in place after render
            ` + logging(),
            values: values(),
            args: [source()],
        },
        "preview" => #{
            opts: `
                --port PORT               suggested port to listen on
                --host HOST               hostname to bind to
                --render FORMAT           render to the specified format(s) before previewing
                --no-serve                do not run a local preview web server
                --no-navigate             do not navigate the browser automatically when outputs are updated
                --no-browser              do not open a browser to preview the site
                --no-watch-inputs         do not re-render input files when they change
                --timeout SECONDS         time after which to exit if there are no active clients
            ` + logging(),
            values: values(),
            args: [source()],
        },
        "serve" => #{
            opts: `
                --no-render               do not render the document before serving
                -p, --port PORT           the TCP port that the application should listen on
                --host HOST               hostname to bind to
                --browser                 open a browser to preview the site
            ` + logging(),
            values: values(),
            args: [source()],
        },
        "create" => #{
            opts: `
                --open EDITOR             open new artifact in this editor
                --no-open                 do not open in an editor
                --no-prompt               do not prompt to confirm actions
            ` + logging(),
            values: values(),
            args: [["project", "extension"]],
        },
        "convert" => #{
            opts: `
                -o, --output PATH         write output to PATH
                --with-ids                include ids in the conversion
            ` + logging(),
            values: values(),
            args: [k("quarto_convertible")],
        },
        "pandoc" => pandoc::spec("pandoc"),
        "add" | "update" | "remove" => #{
            opts: `
                --no-prompt               do not prompt to confirm actions
                --embed ID                embed or remove this extension within another extension
            ` + logging(),
            values: values(),
            args: [["tinytex", "chromium", "chrome-headless-shell", "verapdf"]],
        },
        "install" | "uninstall" => #{
            opts: `
                --no-prompt               do not prompt to confirm actions
                --update-path             update system path when a tool is installed
            ` + logging(),
            values: values(),
            args: [["tinytex", "chromium", "chrome-headless-shell", "verapdf"]],
        },
        "list" => #{opts: logging(), values: values(), args: [["extensions", "tools"]]},
        "publish" => #{
            opts: `
                --id ID                   identifier of content to publish
                --server SERVER           server to publish to
                --token TOKEN             access token for the publishing provider
                --no-render               do not render before publishing
                --no-prompt               do not prompt to confirm the publishing destination
                --no-browser              do not open a browser to the site after publishing
            ` + logging(),
            values: values(),
            args: [["gh-pages", "netlify", "quarto-pub", "posit-connect", "posit-cloud", "confluence", "huggingface"], "dirs"],
        },
        "check" => #{
            opts: `
                --output PATH             output as JSON to a file
                --no-strict               do not fail if dependency versions don't match precisely
            ` + logging(),
            values: values(),
        },
        "use" => #{
            opts: `--no-prompt  do not prompt to confirm actions\n` + logging(),
            values: values(),
            commands: `
                template  use a Quarto template for this directory or project
                binder    configure the current project with Binder support
                brand     use a brand for this project
            `,
        },
        "call" => #{
            commands: `
                engine               access functionality specific to Quarto's rendering engines
                build-ts-extension   build TypeScript execution engine extensions
                typst-gather         gather Typst packages for a format extension
            `,
        },
        "run" => #{args: [k("quarto_script"), "files"]},
        "inspect" => #{opts: logging(), values: values(), args: [source(), "files"]},
        "tools" => #{opts: logging(), values: values()},
        _ => (),
    }
}

fn spec(cmd) {
    quarto()
}
