// Specs read from a program's own help when Tab is pressed, for programs
// whose help has a regular format, so that no table has to follow every
// release: `import "../extra-lib/help" as help;`.
//
// `how` is a map of how to read the help, all of it optional:
//   flag          the option that prints the help (`-h`)
//   stderr        `sh::capture`'s second argument, `"merge"` for a program
//                 that prints its help there (mmseqs)
//   sub_spec      the module whose `sub_spec(PATH, SUB)` completes the
//                 subcommands of PATH (`own("dynamic")`),
//                 usually by calling `sub` and adding what the help lacks
//   help_command  whether `PROG help` takes the names of the commands
//                 (clap)
import "@std/completion/lib" as lib;
import "text" as lib_text;

// The help of the command `path` (a program and its subcommands, separated
// by spaces), which clap doesn't wrap with COLUMNS=400, or "" if a word of
// it isn't a name (the words come from the command line). It is kept 300 s,
// as std's `lib::help_of` keeps it, so that Tab doesn't run the program again.
fn text(path, how) {
    let words = path.split(" ");
    for w in words {
        if !lib_text::is_name(w) {
            return "";
        }
    }
    let argv = ["env", "COLUMNS=400"] + words + [how.flag ?? "-h"];
    if how.stderr == () { sh::capture_cached(300, argv).out } else { sh::capture_cached(300, argv, how.stderr).out }
}

// The commands listed in `text`, as the `commands` of a spec: its indented
// lines `NAME DESCRIPTION`, with any spaces or tabs between (mmseqs puts a
// tab after the name, and `qsv --list` a single space after its longest
// one), under any heading.
fn commands(text) {
    let table = "";
    for line in text.split("\n") {
        if !line.starts_with(" ") && !line.starts_with("\t") {
            continue;
        }
        let t = line;
        t.trim();
        let gap = -1;
        let j = 0;
        for c in t.chars() {
            if c == ' ' || c == '\t' {
                gap = j;
                break;
            }
            j += 1;
        }
        if gap <= 0 {
            continue;
        }
        let name = t.sub_string(0, gap);
        let desc = t.sub_string(gap);
        desc.trim();
        if lib_text::is_name(name) && desc != "" {
            table += "  " + name + "  " + desc + "\n";
        }
    }
    lib::help_spec("Commands:\n" + table).commands ?? ""
}

// The spec of the command `path` from its help, with the values of its
// options guessed from the names of their arguments where the help doesn't
// list them, and, with `how.sub_spec`, a `sub_spec` for its subcommands.
fn spec(path, how) {
    let s = lib::help_spec(text(path, how));
    s.guess_values = true;
    if how.sub_spec != () {
        s.sub_spec = how.sub_spec + ":" + path;
    }
    s
}

// The spec of the subcommand `word` of `path`, read from its help, or () if
// it isn't one (its help has no options).
fn sub(path, word, how) {
    if how.help_command == true && word == "help" {
        // (clap's `help` has no `-h` of its own.)
        let names = lib::parse_commands(lib::help_spec(text(path, how)).commands ?? "").map(|c| c.names[0]);
        return #{args: [names]};
    }
    let s = spec(path + " " + word, how);
    if s.opts == "" {
        return ();
    }
    if s.commands == () {
        s.remove("sub_spec");
    }
    s
}
