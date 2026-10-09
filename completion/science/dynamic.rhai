// Commands whose help is read when Tab is pressed, not written out here: their options come from the
// installed program's own `-h`, through extra-lib's `help`, so that no table has to follow every release.
// It is for programs whose help has a regular format (xsv and qsv: docopt).

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

import "../extra-lib/help" as help;

fn how() {
    #{sub_spec: own("dynamic")}
}

// xsv and qsv: the commands are those of `PROG -h` (xsv), or `qsv --list`, and the options those of
// `PROG COMMAND -h`.
fn csv_tool(prog) {
    let s = help::spec(prog, how());
    if prog == "qsv" {
        s.commands = help::commands(help::text("qsv", #{flag: "--list"}));
    }
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
        "xsv" | "qsv" => help::sub(name, sub, how()),
        _ => (),
    }
}
