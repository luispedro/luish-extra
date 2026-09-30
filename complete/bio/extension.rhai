// Completion for bioinformatics commands, by the command's name (not its
// Bioconda package's). Each command is described by a spec in one of the
// modules below, and completed by std's engine (`@std/completion/lib`).
//
// The modules are imported by the completer, so that they are compiled on
// the first Tab for one of their commands rather than whenever a shell
// starts. luish calls a completer with the command's name as the first word.
// Every module has `fn spec(cmd)`, and, for commands with subcommands, the
// spec's `sub_spec` is `"@extra-complete/bio/MODULE:CMD"`, that is
// `MODULE::sub_spec(CMD, SUBCOMMAND)`.

// One function per module, since an import can't be chosen at run time.
fn ours(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "ours" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

fn hts(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "hts" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["ngless", "SemiBin2", "SemiBin", "macrel", "argnorm"] {
    ours(cmd);
}

for cmd in ["samtools", "tabix", "bgzip", "htsfile", "bedtools"] {
    hts(cmd);
}
