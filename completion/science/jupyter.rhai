// ipython, and jupyter with its subcommands (jupyter_specs.rhai, generated from their `--help`, which takes seconds).
// The subcommands of `jupyter` are the `jupyter-*` programs in PATH, which is how jupyter finds them.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

import "jupyter_specs" as specs;

// The names X of the programs `jupyter-X` in PATH.
fn jupyter_programs() {
    sh::commands("jupyter-").filter(|n| n.len() > 8 && !n.contains(".")).map(|n| n.sub_string(8))
}

fn jupyter() {
    let commands = "";
    for n in jupyter_programs() {
        commands += n + "  jupyter " + n + "\n";
    }
    #{
        opts: `
            -h, --help     show help
            --version      show the versions of core jupyter packages and exit
            --config-dir   show Jupyter config dir
            --data-dir     show Jupyter data dir
            --runtime-dir  show Jupyter runtime dir
            --paths        show all Jupyter paths
            --json         output paths as machine-readable json
            --debug        output debug information about paths
        `,
        commands: commands,
        sub_spec: own("jupyter:jupyter"),
    }
}

fn sub_spec(name, sub) {
    switch sub {
        "kernelspec" => #{
            commands: `
                list          list installed kernel specifications
                install       install a kernel specification directory
                uninstall     alias for remove
                remove        remove one or more Jupyter kernelspecs by name
                install-self  install the IPython kernel spec directory for this Python (deprecated)
                provisioners  list available provisioners for use in kernel specifications
            `,
            common: "--json  output spec information as JSON",
        },
        _ => specs::sub_spec(sub),
    }
}

// ipython's first argument is a script or a subcommand (`ipython profile create`): kind `ipython_args`.
fn ipython() {
    let s = specs::sub_spec("ipython");
    s.args = [own("kinds:ipython_args")];
    s
}

fn spec(cmd) {
    switch cmd {
        "jupyter" => jupyter(),
        "ipython" | "ipython3" => ipython(),
        _ => {
            // jupyter-lab, jupyter-nbconvert, ...
            if cmd.starts_with("jupyter-") { specs::sub_spec(cmd.sub_string(8)) ?? #{} } else { #{} }
        }
    }
}
