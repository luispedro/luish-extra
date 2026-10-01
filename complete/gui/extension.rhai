// Completion for desktop programs, by the command's name. Each command is
// described by a spec in one of the modules below, and completed by std's
// engine (`@std/completion/lib`). The modules are imported by the completer,
// so that they are compiled on the first Tab for one of their commands. luish
// calls a completer with the command's name as the first word. Every module
// has `fn spec(cmd)`.

// The module of each command.
let module_of = #{};
for m in [
    ["documents", ["libreoffice", "soffice", "okular", "xdg-open"]],
    ["editors", ["kate"]],
    ["media", ["gimp", "inkscape", "obs", "audacity"]],
    ["viewers", ["cytoscape", "Cytoscape", "cytoscape.sh"]],
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

// mpv's options are read from the installed mpv's `--list-options`, and
// those offered depend on the word (`--no-` for the negations of flags), so
// it has a completer of its own.
sh::completer("mpv", |words, i| {
    import "mpv" as m;
    m::complete(words, i)
});
