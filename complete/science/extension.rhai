// Completion for scientific computing commands, by the command's name. Each
// command is described by a spec in one of the modules below, and completed
// by std's engine (`@std/completion/lib`). The modules are imported by the
// completer, so that they are compiled on the first Tab for one of their
// commands. luish calls a completer with the command's name as the first
// word. Every module has `fn spec(cmd)`, and, for commands with subcommands,
// the spec's `sub_spec` is `"@extra-complete/science/MODULE:CMD"`, that is
// `MODULE::sub_spec(CMD, SUBCOMMAND)`.

// The module of each command.
let module_of = #{};
for m in [
    ["workflow", ["jug", "nf-test"]],
    ["snakemake", ["snakemake"]],
    ["pandoc", ["pandoc"]],
    // Programs whose help is read when Tab is pressed (docopt: xsv and qsv).
    ["dynamic", ["xsv", "qsv"]],
    ["tex", ["pdflatex", "pdftex", "xelatex", "xetex", "lualatex", "luatex", "luahbtex", "bibtex", "latexmk"]],
    ["quarto", ["quarto"]],
    ["jupyter", ["jupyter", "ipython", "ipython3", "jupyter-lab", "jupyter-notebook", "jupyter-nbconvert",
                 "jupyter-execute", "jupyter-console", "jupyter-server", "jupyter-trust", "jupyter-kernelspec"]],
    ["tools", ["duckdb", "datamash", "pigz", "gnuplot", "Rscript", "R"]],
    ["aria2", ["aria2c"]],
    ["parallel", ["parallel"]],
    ["miller", ["mlr"]],
    ["cwltool", ["cwltool"]],
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

// nextflow's spec depends on the line: `nextflow run PIPELINE` has the
// pipeline's parameters.
sh::completer("nextflow", |words, i| {
    import "@std/completion/lib" as lib;
    import "nextflow" as m;
    lib::complete(m::spec(words), words, i)
});

// Programs that complete themselves are asked, through std's bridges (`bridges::cobra` for Go programs
// built with Cobra, `bridges::click` for Python programs built with Click), so there is no spec here.
// Each Tab runs the program: apptainer answers in 10 ms, nf-core in 0.1 s. A program that isn't
// installed, or that doesn't answer, gets filenames. planemo (Click) takes 1.4 s: `complete-click planemo`.
for cmd in ["apptainer", "singularity"] {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::cobra(words, i)
    });
}

for cmd in ["nf-core"] {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::click(words, i)
    });
}

// The AWS CLI has its own completer, `aws_completer` (50 ms).
sh::completer("aws", |words, i| {
    import "bridges" as bridges;
    bridges::aws(words, i)
});
