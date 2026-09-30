// Completion for system administration commands, by the command's name. Each
// command is described by a spec in one of the modules below, and completed by
// std's engine (`@std/completion/lib`). The modules are imported by the
// completer, so that they are compiled on the first Tab for one of their
// commands. luish calls a completer with the command's name as the first word.

// One function per module, since an import can't be chosen at run time.
fn borg(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "borg" as m;
        lib::complete(m::spec(), words, i)
    });
}

borg("borg");

fn tools(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "tools" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["fusermount", "fusermount3"] {
    tools(cmd);
}
