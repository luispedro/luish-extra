// Commands whose help is read when Tab is pressed, not written out here: their options come from the
// installed program's own `-h`, through std's `help_spec`, so that no table has to follow every release.
// It is for fast programs whose help has a regular format (ruff: clap, a few milliseconds).

import "@std/completion/lib" as lib;

fn k(name) { "@extra-complete/dev/kinds:" + name }

// The values of ruff's options that its `-h` doesn't give (it gives those with `[possible values: ...]`).
fn ruff_values() {
    let rules = k("ruff_rules");
    #{
        "--select": rules, "--ignore": rules, "--extend-select": rules, "--fixable": rules, "--unfixable": rules,
        "--extend-fixable": rules, "--config": "files", "-o": "files", "--output-file": "files",
        "--cache-dir": "dirs", "--stdin-filename": "files", "--direction": ["dependencies", "dependents"],
        "--python": "dirs",
    }
}

// ruff (or one of its commands, `path`, such as `ruff analyze`).
fn ruff(path) {
    let s = lib::help_spec(lib::help_of(path));
    s.guess_values = true;
    s.values.mixin(ruff_values());
    s.sub_spec = "@extra-complete/dev/dynamic:" + path;
    s
}

fn ruff_sub(path, sub) {
    if sub == "help" {
        // (clap's `help` has no `-h` of its own.)
        return #{args: [lib::parse_commands(lib::help_spec(lib::help_of(path)).commands ?? "").map(|c| c.names[0])]};
    }
    let s = ruff(path + " " + sub);
    if s.opts == "" {
        return ();    // not one of ruff's commands
    }
    if s.commands == () {
        s.remove("sub_spec");
    }
    if path == "ruff" {
        s.args = switch sub {
            "check" | "format" => [k("ruff_files")],
            "rule" => [k("ruff_rules")],
            "config" => [k("ruff_config_keys")],
            "linter" | "clean" | "version" | "server" => ["none"],
            _ => s.args,
        };
    } else if path == "ruff analyze" && sub == "graph" {
        s.args = [k("ruff_files")];
    }
    s
}

fn spec(cmd) {
    switch cmd {
        "ruff" => ruff("ruff"),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    if name.starts_with("ruff") { ruff_sub(name, sub) } else { () }
}
