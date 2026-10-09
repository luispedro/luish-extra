// Workflow managers: jug (Jug 2.5.0), and those that need more than a table of options.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

// A subcommand of jug: its options, and the jugfile.
fn sub(opts) {
    #{opts: opts, args: [k("jugfile")]}
}

// jug SUBCOMMAND [JUGFILE] [OPTIONS...]
fn jug() {
    let common = `
        -h, --help               show help
        --aggressive-unload      unload data from memory aggressively
        --jugdir DIR             directory in which to save intermediate files
        --verbose LEVEL          verbosity level
        --short                  short output
        --pdb                    drop to a PDB (debug) console on error
        --debug                  debug mode
        --will-cite              suppress the request for citation
    `;
    #{
        opts: `
            -h, --help  show help
            --version   show the version
        `,
        commands: `
            check           return 0 if all tasks are finished, 1 otherwise
            cleanup         remove result files that are not used
            count           count tasks
            demo            create a demo directory
            execute         execute tasks
            graph           produce a diagram of task dependencies
            install-skills  install the bundled Jug skill into a skills directory
            invalidate      invalidate the results of a task
            pack            pack the results
            shell           run a shell after initialization
            sleep-until     wait until all tasks are done, then exit
            status          print the status
            test-jug        run the jug test suite
            webstatus       start a web interface that displays the status
        `,
        common: common,
        values: #{
            "--jugdir": "dirs",
            "--verbose": ["quiet", "info", "debug"],
            "--wait-cycle-time": "none",
            "--nr-wait-cycles": "none",
            "--target": "none",
            "--invalid": "none",
            "--output": "dirs",
            "--cache-file": "files",
            "--port": "none",
            "--ip": "none",
        },
        args: [k("jugfile")],
        subs: #{
            "execute": sub(`
                --wait-cycle-time N    how long to wait in each cycle, in seconds
                --nr-wait-cycles N     how many wait cycles to do
                --target NAME          restrict tasks to execute based on their name
                --keep-going           continue after errors
                --keep-failed          keep failed tasks locked
                --no-check-environment  do not check the JUG_* variables and the stop file
            `),
            "cleanup": sub(`
                --locks-only           clean up locks, leaving computed results untouched
                --failed-only          clean up failed locks only
                --keep-locks           clean up unused results, leaving locks untouched
            `),
            "graph": sub(`
                --no-status            do not include status information
                --file-format          set the format of the graph output file
            `),
            "install-skills": sub(`
                --output DIR           directory where the bundled skill is installed
                --force                overwrite OUTPUT/jug if it exists
            `),
            "invalidate": sub(`
                --target, --invalid NAME  name of the task to invalidate
            `),
            "status": sub(`
                --cache                use a cache for faster status
                --cache-file FILE      file to use for the status cache
                --clear                remove the cache file
            `),
            "webstatus": sub(`
                --port PORT            port to listen on
                --ip IP                address to listen on
            `),
        },
    }
}

// nf-test 0.9.5 (picocli: the options are those of `nf-test COMMAND --help`, which nf-test prints as an error).
fn nftest() {
    let common = `
        --log FILE             filename for log file
        --silent               hide header and program version
    `;
    let tests = [k("nftest")];
    #{
        commands: `
            clean           remove the .nf-test directory
            init            initialize a project
            test            run tests
            coverage        print the status of the tests
            list, ls        list tests
            generate        generate tests for sources
            update-plugins  update the plugins
            version         show the version
        `,
        values: #{"--log": "files"},
        subs: #{
            "clean": #{opts: common},
            "init": #{opts: common},
            "update-plugins": #{opts: common},
            "version": #{opts: common},
            "coverage": #{
                opts: `
                    -c, --config FILE      nf-test.config filename
                    --csv FILE             write status results in csv format
                    --html FILE            write status results in html format
                ` + common,
                values: #{"-c": "files", "--config": "files", "--csv": "files", "--html": "files", "--log": "files"},
            },
            "list": #{
                opts: `
                    --debug                show debugging infos
                    --format FORMAT        output format
                    --tags                 show all available tags
                ` + common,
                values: #{"--format": "none", "--log": "files"},
                args: tests,
            },
            "generate": #{
                commands: `
                    function  generate tests for functions
                    pipeline  generate tests for pipelines
                    process   generate tests for processes
                    workflow  generate tests for workflows
                `,
                subs: #{
                    "function": #{args: [k("nextflow_script")]},
                    "pipeline": #{args: [k("nextflow_script")]},
                    "process": #{args: [k("nextflow_script")]},
                    "workflow": #{args: [k("nextflow_script")]},
                },
            },
            "test": #{
                opts: `
                    -c, --config FILE                  nf-test.config filename
                    --changedSince, --changed-since REV  run tests related to the changes since a branch or commit hash
                    --changedUntil, --changed-until REV  run tests related to the changes until a branch or commit hash
                    --ci                               CI mode: fail instead of storing a new snapshot
                    --coverage                         print simple coverage calculation
                    --csv FILE                         write test results in csv format
                    --debug                            show debugging infos and dump channels
                    --dryRun, --dry-run                execute most of test discovery but stop before running any test case
                    --filter TYPES                     filter test cases by types (process, pipeline, workflow, function)
                    --followDependencies, --follow-dependencies  follow all dependencies when related-tests is set
                    --graph FILE                       export dependency graph as dot file
                    --junitxml FILE                    write test results in Junit Xml format
                    --lib PATH                         library extension path
                    --log FILE                         filename for log file
                    --onlyChanged, --only-changed      run tests only for the files modified in the current git repository
                    --plugins PATH                     library extension path
                    --profile NAME                     profile to execute all tests
                    --relatedTests, --related-tests    find and execute all related tests for the provided files
                    --shard I/N                        split into chunks and execute the I-th of N
                    --shard-strategy STRATEGY          strategy to build shards
                    --silent                           hide header and program version
                    --smartTesting, --smart-testing    run in smart testing mode (--ci --changed-since HEAD^)
                    --stopOnFirstFailure, --stop-on-first-failure  stop execution immediately after the first test failure
                    --tag TAGS                         execute only tests with this tag
                    --tap FILE                         write test results to tap file
                    --updateSnapshot, --update-snapshot  re-record every snapshot that fails during this test run
                    --verbose                          show Nextflow output
                    --wipeSnapshot, --cleanSnapshot, --wipe-snapshot, --clean-snapshot  remove all obsolete snapshots
                    --without-trace                    run nextflow tests without the trace parameter
                `,
                values: #{
                    "-c": "files", "--config": "files", "--changedSince": "none", "--changed-since": "none",
                    "--changedUntil": "none", "--changed-until": "none", "--csv": "files",
                    "--filter": ["process", "pipeline", "workflow", "function"], "--graph": "files",
                    "--junitxml": "files", "--lib": "dirs", "--log": "files", "--plugins": "none", "--profile": "none",
                    "--shard": "none", "--shard-strategy": ["round-robin", "none"], "--tag": "none", "--tap": "files",
                },
                args: tests,
            },
        },
    }
}

fn spec(cmd) {
    switch cmd {
        "jug" => jug(),
        "nf-test" => nftest(),
        _ => #{},
    }
}
