// Commands whose help is read when Tab is pressed, not written out here: their options come from the
// installed program's own `-h`, through extra-lib's `help`, so that no table has to follow every release.
// It is for fast programs whose help has a regular format (ruff and codex: clap, a few milliseconds; claude:
// Commander, which `commander()` puts in the shape of clap's first).

import "@std/completion/lib" as lib;
import "../extra-lib/help" as help;
import "../extra-lib/text" as lib_text;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

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
    #{sub_spec: own("dynamic"), help_command: true}
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

// codex is built with clap. Its `-p` takes the name of a `$CODEX_HOME/NAME.config.toml` (or, before, of a
// `[profiles.NAME]`).
fn codex_values() {
    #{
        "-p": k("codex_profiles"), "--profile": k("codex_profiles"), "-m": "none", "--model": "none",
        "-C": "dirs", "--cd": "dirs", "--add-dir": "dirs", "-i": "files", "--image": "files",
    }
}

fn codex() {
    let s = help::spec("codex", how());
    s.values.mixin(codex_values());
    s
}

// A command of codex (or of one of its commands, `path`, such as `codex mcp`).
fn codex_sub(path, sub) {
    let s = help::sub(path, sub, how());
    if s == () || sub == "help" {
        return s;
    }
    s.values.mixin(codex_values());
    // codex lists some commands without a description (`codex mcp`), which std's `help_spec` leaves out.
    let bare = "";
    let in_commands = false;
    for line in help::text(path + " " + sub, how()).split("\n") {
        if !line.starts_with(" ") {
            in_commands = line.starts_with("Commands:");
            continue;
        }
        let t = line;
        t.trim();
        if in_commands && lib_text::is_name(t) {
            bare += "  " + t + "\n";
        }
    }
    if bare != "" {
        s.commands = bare + (s.commands ?? "");
        s.sub_spec = own("dynamic") + ":" + path + " " + sub;
    }
    s
}

fn join(list, sep) {
    let out = "";
    for x in list {
        out += (if out == "" { "" } else { sep }) + x;
    }
    out
}

// One entry of Commander's help in the shape that std's `help_spec` reads (clap's): an option with its
// description on its line, and `(choices: "a", "b")` as `[possible values: a, b]`; a command without the
// `[options] <arguments>` after its names, and `stop|kill <id>` as `stop, kill`.
fn commander_entry(section, head, desc) {
    if head == "" {
        return "";
    }
    if head.starts_with("-") {
        // (help_spec ends a description at the first ". ".)
        desc.replace("e.g. ", "e.g., ");
        let a = desc.index_of("(choices: ");
        let b = if a < 0 { -1 } else { desc.index_of(")", a) };
        if b > 0 {
            let values = [];
            for v in desc.sub_string(a + 10, b - a - 10).split(", ") {
                if !v.starts_with("default:") {
                    let w = v;
                    w.replace("\"", "");
                    values.push(w);
                }
            }
            desc = desc.sub_string(0, a) + "[possible values: " + join(values, ", ") + "]";
        }
        return "  " + head + "  " + desc + "\n";
    }
    if !section.starts_with("Commands") {
        return "";
    }
    // (A name, with its aliases after `|`; what follows is its arguments. Examples in the help aren't names.)
    let names = [];
    for name in head.split()[0].split("|") {
        if !lib_text::is_name(name) {
            return "";
        }
        names.push(name);
    }
    "  " + join(names, ", ") + "  " + desc + "\n"
}

// Commander's help (claude's) in the shape of clap's. Commander wraps a description onto lines that are more
// indented than the option or command, so those go to its entry.
fn commander(text) {
    let out = "";
    let section = "";
    let head = "";
    let desc = "";
    for line in text.split("\n") {
        let t = line;
        t.trim();
        if t == "" {
            continue;
        }
        let n = lib_text::indent(line);
        if n > 2 && head != "" {
            desc += " " + t;
            continue;
        }
        out += commander_entry(section, head, desc);
        head = "";
        desc = "";
        if n == 0 {
            section = t;
            out += t + "\n";
        } else {
            let gap = t.index_of("  ");
            head = if gap < 0 { t } else { t.sub_string(0, gap) };
            if gap > 0 {
                desc = t.sub_string(gap);
                desc.trim();
            }
        }
    }
    out + commander_entry(section, head, desc)
}

// claude (Commander): the options whose values its help doesn't list.
fn claude_values() {
    let models = ["sonnet", "opus", "haiku", "fable"];
    #{
        "--model": models, "--fallback-model": models, "--effort": ["low", "medium", "high", "xhigh", "max"],
        "--agent": k("claude_agents"), "--mcp-config": "files", "--plugin-dir": "files", "--settings": "files",
        "--add-dir": "dirs", "--append-system-prompt": "none", "--system-prompt": "none", "--name": "none", "-n": "none",
        "--session-id": "none", "--resume": "none", "-r": "none", "--setting-sources": ["user", "project", "local"],
        "-s": ["local", "user", "project"], "--scope": ["local", "user", "project"],
        "-t": ["stdio", "sse", "http"], "--transport": ["stdio", "sse", "http"],
        "-e": "none", "--env": "none", "-H": "none", "--header": "none", "--client-id": "none",
        "--callback-port": "none",
    }
}

// The help of the command `path` (`claude mcp`) in the shape of clap's, or "" if a word of it isn't a name.
fn claude_help(path) {
    let words = path.split(" ");
    for w in words {
        if !lib_text::is_name(w) {
            return "";
        }
    }
    commander(sh::capture(words + ["--help"]).out)
}

fn claude_spec(path) {
    let s = lib::help_spec(claude_help(path));
    s.guess_values = true;
    s.values.mixin(claude_values());
    s.sub_spec = own("dynamic") + ":" + path;
    s
}

// A command of claude (or of one of its commands, `path`, such as `claude mcp`). Its first word that isn't an
// option is its prompt (`claude fix the bug`), for which `--help` prints the help of claude itself: only the
// names that the help of `path` gives are commands.
fn claude_sub(path, sub) {
    if sub == "help" {
        return ();
    }
    let known = false;
    for c in lib::parse_commands(lib::help_spec(claude_help(path)).commands ?? "") {
        if c.names.contains(sub) {
            known = true;
        }
    }
    if !known {
        if path != "claude" {
            return ();
        }
        // A prompt: what follows it takes claude's options.
        let top = claude_spec("claude");
        top.remove("commands");
        top.remove("sub_spec");
        top.args = ["none"];
        return top;
    }
    let s = claude_spec(path + " " + sub);
    if s.commands == () {
        s.remove("sub_spec");
    }
    s
}

fn spec(cmd) {
    switch cmd {
        "ruff" => ruff(),
        "codex" => codex(),
        "claude" => claude_spec("claude"),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    if name.starts_with("ruff") {
        ruff_sub(name, sub)
    } else if name.starts_with("codex") {
        codex_sub(name, sub)
    } else if name.starts_with("claude") {
        claude_sub(name, sub)
    } else {
        ()
    }
}
