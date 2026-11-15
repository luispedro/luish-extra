// pathed (and vipath, which is `pathed edit`), as commands, and pathed's completion (pathed.rhai).
//
// The module is imported when one of them first runs, or on the first Tab, so loading the plugin costs little.

for name in ["pathed", "vipath"] {
    sh::builtin(name, |argv| {
        import "pathed" as pathed;
        pathed::main(argv)
    });
}

sh::completer("pathed", |words, i| {
    import "@std/completion/lib" as lib;
    import "pathed" as pathed;
    lib::complete(pathed::spec(), words, i)
});
