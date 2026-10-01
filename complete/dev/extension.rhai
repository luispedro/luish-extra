// Completion for development commands, by the command's name. Each command is
// described by a spec in one of the modules below, and completed by std's
// engine (`@std/completion/lib`). The modules are imported by the completer,
// so that they are compiled on the first Tab for one of their commands. luish
// calls a completer with the command's name as the first word. Every module
// has `fn spec(cmd)`, and, for commands whose subcommands are read when
// needed, the spec's `sub_spec` is `"@extra-complete/dev/MODULE:NAME"`, that
// is `MODULE::sub_spec(NAME, SUBCOMMAND)`.

// The module of each command.
let module_of = #{};
for m in [
    ["pytest", ["pytest", "py.test"]],
    ["mypy", ["mypy"]],
    ["poetry", ["poetry"]],
    ["python", ["twine"]],
    // Programs whose help is read when Tab is pressed (ruff: clap).
    ["dynamic", ["ruff"]],
    ["tools", ["fzf", "bat", "batcat"]],
] {
    for cmd in m[1] {
        module_of[cmd] = m[0];
    }
}

for cmd in module_of.keys() {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        let m = module_of[words[0]];
        import m as specs;
        lib::complete(specs::spec(words[0]), words, i)
    });
}
