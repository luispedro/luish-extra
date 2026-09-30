// Completion for development commands, by the command's name. Each command is
// described by a spec in one of the modules below, and completed by std's
// engine (`@std/completion/lib`). The modules are imported by the completer,
// so that they are compiled on the first Tab for one of their commands. luish
// calls a completer with the command's name as the first word. Every module
// has `fn spec(cmd)` (or `fn spec()` for a module of one command), and, for
// commands whose subcommands are read when needed, the spec's `sub_spec` is
// `"@extra-complete/dev/MODULE:NAME"`, that is `MODULE::sub_spec(NAME, SUBCOMMAND)`.

// One function per module, since an import can't be chosen at run time.
fn pytest(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "pytest" as m;
        lib::complete(m::spec(), words, i)
    });
}

for cmd in ["pytest", "py.test"] {
    pytest(cmd);
}

fn mypy(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "mypy" as m;
        lib::complete(m::spec(), words, i)
    });
}

mypy("mypy");

fn poetry(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "poetry" as m;
        lib::complete(m::spec(), words, i)
    });
}

poetry("poetry");

fn python(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "python" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

python("twine");

// Programs whose help is read when Tab is pressed (ruff: clap).
fn dynamic(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "dynamic" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

dynamic("ruff");

fn tools(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "tools" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["fzf", "bat", "batcat"] {
    tools(cmd);
}
