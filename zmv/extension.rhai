// zmv, zcp, zln and mmv (zmv.rhai), as commands, and their completion.
//
// The module is imported when one of them first runs, so loading the plugin costs little.

for name in ["zmv", "zcp", "zln", "mmv"] {
    sh::builtin(name, |argv| {
        import "zmv" as zmv;
        zmv::main(argv)
    });
    sh::completer(name, |words, i| {
        import "zmv" as zmv;
        zmv::complete(words, i)
    });
}
