// Commands whose help is read when Tab is pressed, not written out here:
// their options come from the installed program's own `-h`, through std's
// `help_spec` (as std does for cargo and rustup). It is for programs whose
// help has a regular format, so that no table has to follow every release.

import "@std/completion/lib" as lib;

// Whether `s` can be a subcommand name (the words come from the command
// line, and mmseqs is only asked about names).
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

// MMseqs2: the modules are the lines `  NAME<TAB>description` of `mmseqs -h`.
fn mmseqs() {
    let commands = "";
    for line in sh::capture(["mmseqs", "-h"], "merge").out.split("\n") {
        let tab = line.index_of("\t");
        if !line.starts_with("  ") || tab < 0 {
            continue;
        }
        let name = line.sub_string(0, tab);
        name.trim();
        let desc = line.sub_string(tab);
        desc.trim();
        if is_name(name) {
            commands += name + "  " + desc + "\n";
        }
    }
    #{
        opts: `
            -h, --help  show help
        `,
        commands: commands,
        sub_spec: "@extra-complete/bio/dynamic:mmseqs",
    }
}

fn mmseqs_sub(sub) {
    if !is_name(sub) {
        return ();
    }
    let s = lib::help_spec(sh::capture(["mmseqs", sub, "-h"], "merge").out);
    s.guess_values = true;
    // BOOL takes 0 or 1.
    for o in lib::parse(s.opts).opts {
        if o.argname == "BOOL" {
            for n in o.names {
                s.values[n] = ["0", "1"];
            }
        }
    }
    s
}

fn spec(cmd) {
    switch cmd {
        "mmseqs" => mmseqs(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "mmseqs" => mmseqs_sub(sub),
        _ => (),
    }
}
