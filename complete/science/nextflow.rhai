// Nextflow 26.04.6, from `nextflow -h` and `nextflow COMMAND -h`. Its options start with one `-`. A
// `-with-docker[=IMAGE]` may have a value, which is given after `=` here since the next word is
// usually the pipeline. The parameters of an nf-core pipeline (`--input`, ...) come from its
// `nextflow_schema.json`, when `nextflow run` names a directory or a project that has one.

import "kinds" as kinds;

fn k(name) { "@extra-complete/science/kinds:" + name }

fn run_opts() {
    `
        -E                          export all current system environment
        -ansi-log BOOL              enable or disable ANSI console logging
        -bucket-dir DIR             remote bucket where intermediate result files are stored
        -cache BOOL                 enable or disable process caching
        -d, -deep N                 create a shallow clone of the specified depth
        -disable-jobs-cancellation  prevent the cancellation of child jobs on termination
        -dump-channels[=NAMES]      dump channels for debugging purposes
        -dump-hashes                dump task hash keys for debugging purposes
        -entry NAME                 entry workflow name to be executed
        -h, -help                   print the command usage
        -hub NAME                   service hub where the project is hosted
        -latest                     pull latest changes before run
        -lib PATH                   library extension path
        -main-script FILE           the script file to be executed when launching a project
        -name NAME                  assign a mnemonic name to the pipeline run
        -offline                    do not check for remote project updates
        -o, -output-dir DIR         directory where workflow outputs are stored
        -output-format FORMAT       output format for printing workflow outputs
        -params-file FILE           load script parameters from a JSON/YAML file
        -plugins NAMES              plugins to be applied for this run
        -preview                    run the workflow skipping the execution of all processes
        -profile NAMES              choose a configuration profile
        -qs, -queue-size N          max number of processes executed in parallel by each executor
        -resume[=SESSION]           execute the script using the cached results
        -r, -revision REV           revision of the project to run (branch, tag or commit)
        -stub-run, -stub            execute the workflow replacing process scripts with stubs
        -test NAME                  test a script function with the name specified
        -user NAME                  private repository user name
        -with-apptainer[=IMAGE]     enable process execution in an Apptainer container
        -with-charliecloud[=IMAGE]  enable process execution in a Charliecloud container
        -with-cloudcache[=PATH]     use an object storage bucket as storage for cache metadata
        -with-conda[=ENV]           use the specified Conda environment package or file
        -with-dag[=FILE]            create pipeline DAG file
        -with-docker[=IMAGE]        enable process execution in a Docker container
        -N, -with-notification EMAIL  send a notification email on workflow completion
        -with-podman[=IMAGE]        enable process execution in a Podman container
        -with-report[=FILE]         create processes execution html report
        -with-singularity[=IMAGE]   enable process execution in a Singularity container
        -with-spack[=ENV]           use the specified Spack environment package or file
        -with-timeline[=FILE]       create processes execution timeline file
        -with-tower[=URL]           monitor workflow execution with Seqera Platform
        -with-trace[=FILE]          create processes execution tracing file
        -with-weblog[=URL]          send workflow status messages via HTTP to target URL
        -without-conda              disable the use of Conda environments
        -without-docker             disable process execution with Docker
        -without-podman             disable process execution in a Podman container
        -without-spack              disable the use of Spack environments
        -w, -work-dir DIR           directory where intermediate result files are stored
    `
}

fn run_values() {
    #{
        "-ansi-log": ["true", "false"],
        "-cache": ["true", "false"],
        "-bucket-dir": "none",
        "-deep": "none", "-d": "none",
        "-entry": "none",
        "-hub": ["github", "gitlab", "gitea", "bitbucket"],
        "-lib": "dirs",
        "-main-script": "files",
        "-name": "none",
        "-output-dir": "dirs", "-o": "dirs",
        "-output-format": ["text", "json", "none"],
        "-params-file": k("params_file"),
        "-plugins": "none",
        "-profile": k("nextflow_profiles"),
        "-queue-size": "none", "-qs": "none",
        "-revision": "none", "-r": "none",
        "-test": "none",
        "-user": "none",
        "-with-notification": "none", "-N": "none",
        "-work-dir": "dirs", "-w": "dirs",
        "-dump-channels": "none", "-resume": "none",
        "-with-apptainer": "none", "-with-charliecloud": "none", "-with-cloudcache": "none", "-with-conda": "files",
        "-with-dag": "files", "-with-docker": "none", "-with-podman": "none", "-with-report": "files",
        "-with-singularity": "none", "-with-spack": "files", "-with-timeline": "files", "-with-tower": "none",
        "-with-trace": "files", "-with-weblog": "none",
    }
}

fn nextflow() {
    #{
        single_dash: true,
        opts: `
            -C FILE                use the specified configuration file(s) overriding any defaults
            -D PROPERTY            set JVM properties
            -bg                    execute nextflow in background
            -c, -config FILE       add the specified file to configuration set
            -config-ignore-includes  disable the parsing of config includes
            -h                     print help
            -log FILE              set nextflow log file path
            -q, -quiet             do not print information messages
            -remote-debug          enable JVM interactive remote debugging
            -syslog HOST           send logs to a syslog server
            -trace PACKAGE         enable trace level logging for the specified package name
            -v, -version           print the program version
        `,
        values: #{
            "-C": k("nextflow_config"), "-c": k("nextflow_config"), "-config": k("nextflow_config"),
            "-D": "none", "-log": "files", "-syslog": "none", "-trace": "none",
        },
        commands: `
            auth         manage Seqera Platform authentication
            clean        clean up project cache and work directories
            clone        clone a project into a folder
            config       print a project configuration
            console      launch Nextflow interactive console
            drop         delete the local copy of a project
            fs           perform filesystem operations
            help         print the usage help for a command
            info         print project and system runtime information
            inspect      inspect process settings in a pipeline project
            kuberun      execute a workflow in a Kubernetes cluster (experimental)
            launch       launch a workflow in Seqera Platform
            lineage      explore workflows lineage metadata
            lint         lint Nextflow scripts and config files
            list         list all downloaded projects
            log          print executions log and runtime info
            module       manage Nextflow modules
            plugin       execute plugin-specific commands
            pull         download or update a project
            run          execute a pipeline project
            secrets      manage pipeline secrets
            self-update  update nextflow runtime to the latest available version
            view         view project script file(s)
        `,
        sub_spec: "@extra-complete/science/nextflow:sub",
    }
}

fn project_sub(opts, values) {
    #{opts: opts, values: values, args: [k("nextflow_project")]}
}

fn sub_spec(name, sub) {
    switch sub {
        "run" => #{opts: run_opts(), values: run_values(), args: [k("nextflow_pipeline")]},
        "config" => #{
            opts: `
                -flat                  print config using flat notation
                -h, -help              print the command usage
                -o, -output FORMAT     print the config using the specified format
                -profile NAMES         choose a configuration profile
                -properties            print config using Java properties notation
                -r, -revision REV      revision of the project
                -a, -show-profiles     show all configuration profiles
                -sort                  sort config attributes
                -value NAME            print the value of a config option
            `,
            values: #{"-o": ["canonical", "properties", "flat", "json", "yaml"],
                      "-output": ["canonical", "properties", "flat", "json", "yaml"],
                      "-profile": k("nextflow_profiles"), "-r": "none", "-revision": "none", "-value": "none"},
            args: [k("nextflow_pipeline")],
        },
        "clean" => #{
            opts: `
                -after RUN             clean up runs executed after the specified one
                -before RUN            clean up runs executed before the specified one
                -but RUN               clean up all runs except the specified one
                -n, -dry-run           print names of files to be removed without deleting them
                -f, -force             force clean command
                -h, -help              print the command usage
                -k, -keep-logs         remove only temporary files, keeping log entries and metadata
                -q, -quiet             do not print names of files removed
            `,
            values: #{"-after": k("nextflow_runs"), "-before": k("nextflow_runs"), "-but": k("nextflow_runs")},
            args: [k("nextflow_runs")],
        },
        "clone" => project_sub(`
            -d, -deep N            create a shallow clone of the specified depth
            -h, -help              print the command usage
            -hub NAME              service hub where the project is hosted
            -r REV                 revision of the project to clone
            -user NAME             private repository user name
        `, #{"-d": "none", "-hub": ["github", "gitlab", "gitea", "bitbucket"], "-r": "none", "-user": "none"}),
        "drop" => project_sub(`
            -f                     delete the repository without taking care of local changes
            -h, -help              print the command usage
            -r, -revision REV      revision of the project to drop
        `, #{"-r": "none", "-revision": "none"}),
        "info" => project_sub(`
            -u, -check-updates     check for remote updates
            -d                     show detailed information
            -h, -help              print the command usage
            -o FORMAT              output format
        `, #{"-o": ["text", "json", "yaml"]}),
        "inspect" => #{
            opts: `
                -concretize            build the container images resolved by the inspect command
                -format FORMAT         inspect output format
                -h, -help              print the command usage
                -i, -ignore-errors     ignore errors while inspecting the pipeline
                -params-file FILE      load script parameters from a JSON/YAML file
                -profile NAMES         use the given configuration profile(s)
                -r, -revision REV      revision of the project to inspect
            `,
            values: #{"-format": ["json", "config"], "-params-file": k("params_file"),
                      "-profile": k("nextflow_profiles"), "-r": "none", "-revision": "none"},
            args: [k("nextflow_pipeline")],
        },
        "launch" => #{
            opts: `
                -workspace NAME        workspace name
                -compute-env NAME      compute environment name
                -name NAME             assign a mnemonic name to the pipeline run
                -w, -work-dir PATH     directory where intermediate result files are stored
                -r, -revision REV      revision of the project to run
                -profile NAMES         choose a configuration profile
                -c, -config FILE       add the specified file to configuration set
                -params-file FILE      load script parameters from a JSON/YAML file
                -entry NAME            entry workflow name to be executed
                -resume[=SESSION]      execute the script using the cached results
                -latest                pull latest changes before run
                -stub-run, -stub       execute the workflow replacing process scripts with stubs
                -main-script FILE      the script file to be executed when launching a project
                -user-secret NAME      user secret name to use in the pipeline
                -workspace-secret NAME  workspace secret name to use in the pipeline
            `,
            values: #{"-workspace": "none", "-compute-env": "none", "-name": "none", "-work-dir": "none",
                      "-w": "none", "-r": "none", "-revision": "none", "-profile": k("nextflow_profiles"),
                      "-c": k("nextflow_config"), "-config": k("nextflow_config"), "-params-file": k("params_file"),
                      "-entry": "none", "-main-script": "files", "-user-secret": "none", "-workspace-secret": "none",
                      "-resume": "none"},
            args: [k("nextflow_pipeline")],
        },
        "lint" => #{
            opts: `
                -exclude PATTERN       file pattern to exclude from error checking
                -files-from FILE       read the list of paths to lint from a text file
                -format                format scripts and config files that have no errors
                -harshil-alignment     use Harshil alignment
                -h, -help              print the command usage
                -o, -output MODE       output mode for reporting errors
                -project-dir DIR       path to project directory
                -sort-declarations     sort script declarations in Nextflow scripts
                -spaces N              number of spaces to indent
                -tabs                  indent with tabs
            `,
            values: #{"-exclude": "none", "-files-from": "files", "-o": ["full", "extended", "concise", "json", "markdown"],
                      "-output": ["full", "extended", "concise", "json", "markdown"], "-project-dir": "dirs",
                      "-spaces": "none"},
            args: ["files"],
        },
        "log" => #{
            opts: `
                -after RUN             show log entries for runs executed after the specified one
                -before RUN            show log entries for runs executed before the specified one
                -but RUN               show log entries of all runs except the specified one
                -f, -fields FIELDS     comma separated list of fields to include in the printed log
                -F, -filter EXPR       filter log entries by a custom expression
                -h, -help              print the command usage
                -l, -list-fields       show all available fields
                -q, -quiet             show only run names
                -s SEP                 character used to separate column values
                -t, -template TEXT     text template used for each record in the log
            `,
            values: #{"-after": k("nextflow_runs"), "-before": k("nextflow_runs"), "-but": k("nextflow_runs"),
                      "-f": "none", "-fields": "none", "-F": "none", "-filter": "none", "-s": "none",
                      "-t": "none", "-template": "none"},
            args: [k("nextflow_runs")],
        },
        "pull" => project_sub(`
            -a, -all               update all downloaded projects
            -d, -deep N            create a shallow clone of the specified depth
            -h, -help              print the command usage
            -hub NAME              service hub where the project is hosted
            -m, -migrate           migrate projects to multi-revision strategy
            -r, -revision REV      revision of the project to pull
            -user NAME             private repository user name
        `, #{"-d": "none", "-deep": "none", "-hub": ["github", "gitlab", "gitea", "bitbucket"], "-r": "none",
             "-revision": "none", "-user": "none"}),
        "view" => project_sub(`
            -h, -help              print the command usage
            -l                     list repository content
            -q                     hide header line
            -r, -revision REV      revision of the project
        `, #{"-r": "none", "-revision": "none"}),
        "fs" => #{
            commands: `
                cp    copy a file
                mv    move a file
                ls    list the content of a folder
                cat   print a file to the standard output
                rm    remove a file
                stat  print file metadata
            `,
        },
        "lineage" => #{
            commands: `
                check   check the integrity of a lineage file path
                diff    show differences between two lineage descriptions
                find    find lineage metadata descriptions matching a query
                list    list the executions with lineage enabled
                render  render the lineage graph for a workflow output
                view    print the description of a lineage ID
            `,
        },
        "module" => #{
            commands: `
                create    create a new module skeleton
                install   install a module from the registry
                run       run a module directly from the registry
                list      list all installed modules
                remove    remove an installed module
                search    search for modules in the registry
                view      show module information and usage template
                publish   publish a module to the registry
                spec      generate a meta.yml spec for a local module
                validate  validate a module structure and metadata
            `,
        },
        "secrets" => #{
            commands: `
                delete  delete a secret
                get     print a secret
                list    list the secrets
                set     set a secret
            `,
        },
        "console" | "plugin" | "list" | "auth" => #{opts: "-h, -help  print the command usage"},
        _ => (),
    }
}

// The spec for the line `words`: `nextflow run`'s pipeline parameters (`--input`, ...) are added to
// the ones of its subcommand, by name, when the pipeline has a `nextflow_schema.json`.
fn spec(words) {
    let s = nextflow();
    let run = false;
    for j in 1..words.len() - 1 {
        if !words[j].starts_with("-") && words[j] == "run" {
            run = true;
        }
    }
    if run {
        let p = kinds::nextflow_params(words);
        let r = sub_spec("nextflow", "run");
        r.opts += "\n" + p.opts;
        for n in p.values.keys() {
            r.values[n] = p.values[n];
        }
        s.subs = #{"run": r};
    }
    s
}
