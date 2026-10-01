// Commands whose help is read when Tab is pressed, not written out here:
// their options come from the installed program's own `-h`, through
// extra-lib's `help` (as std does for cargo and rustup). It is for programs
// whose help has a regular format, so that no table has to follow every
// release.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

import "@std/completion/lib" as lib;
import "../extra-lib/help" as help;

// MMseqs2 prints its help on standard error. Its modules are the lines
// `  NAME<TAB>description` of `mmseqs -h`, under headings by purpose.
fn how() {
    #{stderr: "merge", sub_spec: own("dynamic")}
}

fn mmseqs() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: help::commands(help::text("mmseqs", how())),
        sub_spec: own("dynamic:mmseqs"),
    }
}

fn mmseqs_sub(sub) {
    let s = help::sub("mmseqs", sub, how());
    if s == () {
        return ();
    }
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
