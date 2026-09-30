// Commands whose help is read when Tab is pressed, not written out here: their options come from the
// installed program's own `-h`, through std's `help_spec`, so that no table has to follow every release.
// It is for programs whose help has a regular format (xsv and qsv: docopt).

import "@std/completion/lib" as lib;

// Whether `s` can be a subcommand name (the words come from the command line, and the program is only asked about
// names).
fn is_name(s) {
    if s == "" || s.starts_with("-") {
        return false;
    }
    for c in s.chars() {
        if !(c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '-' || c == '_' || c == '.') {
            return false;
        }
    }
    true
}

// The commands in the output of `qsv --list`: lines `    NAME description` (the longest name has one space
// only, which `help_spec` doesn't take as a table).
fn qsv_commands(text) {
    let out = "";
    for line in text.split("\n") {
        if !line.starts_with("    ") {
            continue;
        }
        let t = line;
        t.trim();
        let gap = t.index_of(" ");
        if gap <= 0 {
            continue;
        }
        let name = t.sub_string(0, gap);
        let desc = t.sub_string(gap);
        desc.trim();
        if is_name(name) {
            out += name + "  " + (if desc.len() > 1 && desc[1] >= 'a' && desc[1] <= 'z' { desc[0].to_lower() + desc.sub_string(1) } else { desc }) + "\n";
        }
    }
    out
}

// xsv and qsv: the commands are those of `PROG -h` (xsv), or `qsv --list`, and the options those of
// `PROG COMMAND -h`.
fn csv_tool(prog) {
    let s = lib::help_spec(lib::help_of(prog));
    if prog == "qsv" {
        s.commands = qsv_commands(sh::capture(["qsv", "--list"]).out);
    }
    s.sub_spec = "@extra-complete/science/dynamic:" + prog;
    s
}

fn csv_tool_sub(prog, sub) {
    if !is_name(sub) {
        return ();
    }
    let s = lib::help_spec(lib::help_of(prog + " " + sub));
    s.guess_values = true;
    s
}

fn spec(cmd) {
    switch cmd {
        "xsv" | "qsv" => csv_tool(cmd),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "xsv" | "qsv" => csv_tool_sub(name, sub),
        _ => (),
    }
}
