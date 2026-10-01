// Completion for desktop programs, by the command's name. Each command is
// described by a spec in one of the modules below, and completed by std's
// engine (`@std/completion/lib`). The modules are imported by the completer,
// so that they are compiled on the first Tab for one of their commands. luish
// calls a completer with the command's name as the first word. Every module
// has `fn spec(cmd)`.

// The module of each command.
let module_of = #{};
for m in [
    ["browsers", ["firefox", "thunderbird", "chromium", "chromium-browser", "google-chrome", "google-chrome-stable"]],
    ["documents", ["libreoffice", "soffice", "evince", "okular", "zathura", "xdg-open"]],
    ["editors", ["meld", "gedit", "kate"]],
    ["media", ["vlc", "cvlc", "gimp", "inkscape", "krita", "blender", "obs", "audacity", "eog"]],
    ["viewers", ["cytoscape", "Cytoscape", "cytoscape.sh", "jalview", "art", "act", "bamview", "dnaplotter", "tablet",
                 "pymol", "chimerax", "ChimeraX", "vmd"]],
    ["bandage", ["BandageNG"]],
    ["desktop", ["xrandr", "gsettings", "dconf", "notify-send", "wmctrl", "swaymsg", "hyprctl"]],
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

// code's subcommands are only its first word, and its other arguments are paths, so it has a completer of its own.
sh::completer("code", |words, i| {
    import "editors" as m;
    m::complete_code(words, i)
});

// xdotool's commands are chained on one line, so it has a completer of its own.
sh::completer("xdotool", |words, i| {
    import "desktop" as m;
    m::complete_xdotool(words, i)
});

// proksee is built with Click and completes itself through std's Click bridge (207 ms, proksee 1.0.0a6).
sh::completer("proksee", |words, i| {
    import "@std/completion/bridges" as bridges;
    bridges::click(words, i)
});
