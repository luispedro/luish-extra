// Commands whose help is read when Tab is pressed, not written out here: their options come from the
// installed program's own `-h`, through extra-lib's `help`, so that no table has to follow every release.
// It is for fast programs whose help has a regular format (ruff: clap, a few milliseconds).

import "@extra-complete/extra-lib/help" as help;

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

// ruff is built with clap, whose `help` takes the names of the commands.
fn how() {
    #{sub_spec: "@extra-complete/dev/dynamic", help_command: true}
}

fn ruff() {
    let s = help::spec("ruff", how());
    s.values.mixin(ruff_values());
    s
}

// A command of ruff (or of one of its commands, `path`, such as `ruff analyze`).
fn ruff_sub(path, sub) {
    let s = help::sub(path, sub, how());
    if s == () || sub == "help" {
        return s;
    }
    s.values.mixin(ruff_values());
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
        "ruff" => ruff(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    if name.starts_with("ruff") { ruff_sub(name, sub) } else { () }
}
