// Coding agents whose help is irregular or slow to read at Tab time: opencode (opencode 1.18.34; yargs, and a
// start-up of most of a second). claude and codex are read from their help (dynamic.rhai).

// opencode [project], opencode COMMAND [OPTIONS]
fn opencode() {
    let server = `
        --port NUMBER           port to listen on
        --hostname HOST         hostname to listen on
        --mdns                  enable mDNS service discovery (defaults hostname to 0.0.0.0)
        --mdns-domain DOMAIN    custom domain name for mDNS service
        --cors DOMAIN           additional domains to allow for CORS
    `;
    let session = `
        -c, --continue          continue the last session
        -s, --session ID        session id to continue
        --fork                  fork the session when continuing (use with --continue or --session)
    `;
    let mini = `
        --mini                  start the minimal interactive interface
        --no-replay             disable mini session history replay on resume and after resize
        --replay-limit N        cap visible mini replay to the newest N messages
    `;
    let remote = `
        -p, --password PASSWORD basic auth password (defaults to OPENCODE_SERVER_PASSWORD)
        -u, --username USER     basic auth username (defaults to OPENCODE_SERVER_USERNAME or 'opencode')
    `;
    let names = ["none"];
    #{
        opts: server + session + mini + `
            -m, --model MODEL       model to use in the format of provider/model
            --prompt PROMPT         prompt to use
            --agent AGENT           agent to use
            --auto                  auto-approve permissions that are not explicitly denied (dangerous!)
        `,
        common: `
            -h, --help              show help
            -v, --version           show version number
            --print-logs            print logs to stderr
            --log-level LEVEL       log level
            --pure                  run without external plugins
        `,
        commands: `
            completion         generate shell completion script
            acp                start ACP (Agent Client Protocol) server
            mcp                manage MCP (Model Context Protocol) servers
            attach             attach to a running opencode server
            run                run opencode with a message
            debug              debugging and troubleshooting tools
            providers, auth    manage AI providers and credentials
            agent              manage agents
            upgrade            upgrade opencode to the latest or a specific version
            uninstall          uninstall opencode and remove all related files
            serve              starts a headless opencode server
            web                start opencode server and open web interface
            models             list all available models
            stats              show token usage and cost statistics
            export             export session data as JSON
            import             import session data from JSON file or URL
            github             manage GitHub agent
            pr                 fetch and checkout a GitHub PR branch, then run opencode
            session            manage sessions
            plugin, plug       install plugin and update config
            db                 database tools
        `,
        values: #{
            "--log-level": ["DEBUG", "INFO", "WARN", "ERROR"], "--port": "none", "--hostname": "none",
            "--mdns-domain": "none", "--cors": "none", "-s": "none", "--session": "none", "--replay-limit": "none",
            "-p": "none", "--password": "none", "-u": "none", "--username": "none", "-m": "none", "--model": "none",
            "--prompt": "none", "--agent": "none",
        },
        args: ["dirs"],
        subs: #{
            "completion": #{args: names},
            "acp": #{
                opts: server + `
                    --cwd DIR           working directory
                `,
                values: #{"--cwd": "dirs"},
                args: names,
            },
            "attach": #{
                opts: session + mini + remote + `
                    --dir DIR           directory to run in
                `,
                values: #{"--dir": "dirs"},
                args: names,
            },
            "run": #{
                opts: session + remote + `
                    --command COMMAND   the command to run, use message for args
                    --share             share the session
                    -m, --model MODEL   model to use in the format of provider/model
                    --agent AGENT       agent to use
                    --format FORMAT     format: default (formatted) or json (raw JSON events)
                    -f, --file FILE     file(s) to attach to message
                    --title TITLE       title for the session (uses truncated prompt if no value provided)
                    --attach URL        attach to a running opencode server (e.g., http://localhost:4096)
                    --dir DIR           directory to run in, path on remote server if attaching
                    --port NUMBER       port for the local server (defaults to random port if no value provided)
                    --variant VARIANT   model variant (provider-specific reasoning effort, e.g., high, max, minimal)
                    --thinking          show thinking blocks
                    -i, --interactive   run in direct interactive split-footer mode
                    --auto              auto-approve permissions that are not explicitly denied (dangerous!)
                `,
                values: #{
                    "--format": ["default", "json"], "-f": "files", "--file": "files", "--dir": "dirs",
                    "--command": "none", "--title": "none", "--attach": "none", "--variant": "none",
                },
                args: names,
            },
            "debug": #{
                commands: `
                    config      show resolved configuration
                    lsp         LSP debugging utilities
                    rg          ripgrep debugging utilities
                    file        file system debugging utilities
                    scrap       list all known projects
                    skill       list all available skills
                    snapshot    snapshot debugging utilities
                    startup     print startup timing
                    agent       show agent configuration details
                    v2          debug v2 catalog and built-in plugins
                    info        show debug information
                    paths       show global paths (data, config, cache, state)
                    wait        wait indefinitely (for debugging)
                `,
                args: names,
            },
            "providers": providers(),
            "agent": #{
                commands: `
                    create  create a new agent
                    list    list all available agents
                `,
                subs: #{
                    "create": #{
                        opts: `
                            --path DIR                directory path to generate the agent file
                            --description TEXT        what the agent should do
                            --mode MODE               agent mode
                            --permissions, --tools LIST  comma-separated list of permissions to allow (default: all)
                            -m, --model MODEL         model to use in the format of provider/model
                        `,
                        values: #{
                            "--path": "dirs", "--description": "none", "--mode": ["all", "primary", "subagent"],
                            "--permissions": "none", "--tools": "none", "-m": "none", "--model": "none",
                        },
                        args: names,
                    },
                    "list": #{args: names},
                },
            },
            "upgrade": #{
                opts: `
                    -m, --method METHOD  installation method to use
                `,
                values: #{"-m": ["curl", "npm", "pnpm", "bun", "brew", "choco", "scoop"], "--method": ["curl", "npm", "pnpm", "bun", "brew", "choco", "scoop"]},
                args: names,
            },
            "uninstall": #{
                opts: `
                    -c, --keep-config   keep configuration files
                    -d, --keep-data     keep session data and snapshots
                    --dry-run           show what would be removed without removing
                    -f, --force         skip confirmation prompts
                `,
                args: names,
            },
            "serve": #{opts: server, values: #{"--port": "none", "--hostname": "none", "--mdns-domain": "none", "--cors": "none"}, args: names},
            "web": #{opts: server, values: #{"--port": "none", "--hostname": "none", "--mdns-domain": "none", "--cors": "none"}, args: names},
            "models": #{
                opts: `
                    --verbose           use more verbose model output (includes metadata like costs)
                    --refresh           refresh the models cache from models.dev
                `,
                args: names,
            },
            "stats": #{
                opts: `
                    --days N            show stats for the last N days (default: all time)
                    --tools N           number of tools to show (default: all)
                    --models N          show model statistics (default: hidden); a number shows the top N
                    --project NAME      filter by project (default: all projects, empty string: current project)
                `,
                values: #{"--days": "none", "--tools": "none", "--models": "none", "--project": "none"},
                args: names,
            },
            "export": #{opts: `--sanitize  redact sensitive transcript and file data`, args: names},
            "import": #{args: ["files"]},
            "github": #{
                commands: `
                    install  install the GitHub agent
                    run      run the GitHub agent
                `,
                subs: #{
                    "install": #{args: names},
                    "run": #{
                        opts: `
                            --event EVENT   GitHub mock event to run the agent for
                            --token TOKEN   GitHub personal access token (github_pat_********)
                        `,
                        values: #{"--event": "none", "--token": "none"},
                        args: names,
                    },
                },
            },
            "pr": #{args: names},
            "session": #{
                commands: `
                    list    list sessions
                    delete  delete a session
                `,
                subs: #{
                    "list": #{
                        opts: `
                            -n, --max-count N   limit to N most recent sessions
                            --format FORMAT     output format
                        `,
                        values: #{"-n": "none", "--max-count": "none", "--format": ["table", "json"]},
                        args: names,
                    },
                    "delete": #{args: names},
                },
            },
            "plugin": #{
                opts: `
                    -g, --global        install in global config
                    -f, --force         replace existing plugin version
                `,
                args: names,
            },
            "db": #{
                opts: `--format FORMAT  output format`,
                values: #{"--format": ["json", "tsv"]},
                commands: `path  print the database path`,
                subs: #{"path": #{args: names}},
                args: names,
            },
            "mcp": #{
                commands: `
                    add         add an MCP server
                    list, ls    list MCP servers and their status
                    auth        authenticate with an OAuth-enabled MCP server
                    logout      remove OAuth credentials for an MCP server
                    debug       debug OAuth connection for an MCP server
                `,
                subs: #{
                    "add": #{
                        opts: `
                            --url URL           URL for a remote MCP server
                            --env KEY=VALUE     environment variable for a local MCP server
                            --header KEY=VALUE  HTTP header for a remote MCP server
                        `,
                        values: #{"--url": "none", "--env": "none", "--header": "none"},
                        args: names,
                    },
                    "list": #{args: names},
                    "auth": #{args: names},
                    "logout": #{args: names},
                    "debug": #{args: names},
                },
            },
        },
    }
}

// opencode providers (alias auth)
fn providers() {
    #{
        commands: `
            list, ls  list providers and credentials
            login     log in to a provider
            logout    log out from a configured provider
        `,
        subs: #{
            "list": #{args: ["none"]},
            "login": #{
                opts: `
                    -p, --provider PROVIDER  provider id or name to log in to (skips provider selection)
                    -m, --method METHOD      login method label (skips method selection)
                `,
                values: #{"-p": "none", "--provider": "none", "-m": "none", "--method": "none"},
                args: ["none"],
            },
            "logout": #{args: ["none"]},
        },
    }
}

fn spec(cmd) {
    switch cmd {
        "opencode" => opencode(),
        _ => #{},
    }
}
