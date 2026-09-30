// Completion for scientific computing commands, by the command's name. Each
// command is described by a spec in one of the modules below, and completed
// by std's engine (`@std/completion/lib`). The modules are imported by the
// completer, so that they are compiled on the first Tab for one of their
// commands. luish calls a completer with the command's name as the first
// word. Every module has `fn spec(cmd)`, and, for commands with subcommands,
// the spec's `sub_spec` is `"@extra-complete/science/MODULE:CMD"`, that is
// `MODULE::sub_spec(CMD, SUBCOMMAND)`.

// One function per module, since an import can't be chosen at run time.
fn workflow(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "workflow" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["jug", "nf-test"] {
    workflow(cmd);
}

fn snakemake(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "snakemake" as m;
        lib::complete(m::spec(), words, i)
    });
}

snakemake("snakemake");

fn nextflow(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "nextflow" as m;
        lib::complete(m::spec(words), words, i)
    });
}

nextflow("nextflow");

fn pandoc(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "pandoc" as m;
        lib::complete(m::spec(), words, i)
    });
}

pandoc("pandoc");

// Programs whose help is read when Tab is pressed (docopt: xsv and qsv).
fn dynamic(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "dynamic" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["xsv", "qsv"] {
    dynamic(cmd);
}

fn tex(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "tex" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["pdflatex", "pdftex", "xelatex", "xetex", "lualatex", "luatex", "luahbtex", "bibtex", "latexmk"] {
    tex(cmd);
}

// Programs that complete themselves are asked, through std's bridges (`bridges::cobra` for Go programs
// built with Cobra, `bridges::click` for Python programs built with Click), so there is no spec here.
// Each Tab runs the program: apptainer answers in 10 ms, nf-core in 0.1 s. A program that isn't
// installed, or that doesn't answer, gets filenames. planemo (Click) takes 1.4 s: `complete-click planemo`.
fn cobra(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::cobra(words, i)
    });
}

for cmd in ["apptainer", "singularity"] {
    cobra(cmd);
}

fn click(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::click(words, i)
    });
}

for cmd in ["nf-core"] {
    click(cmd);
}

fn quarto(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "quarto" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

quarto("quarto");

fn jupyter(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "jupyter" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["jupyter", "ipython", "ipython3", "jupyter-lab", "jupyter-notebook", "jupyter-nbconvert", "jupyter-execute",
            "jupyter-console", "jupyter-server", "jupyter-trust", "jupyter-kernelspec"] {
    jupyter(cmd);
}

fn tools(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "tools" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["duckdb", "datamash", "pigz", "gnuplot", "Rscript", "R"] {
    tools(cmd);
}

fn aria2(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "aria2" as m;
        lib::complete(m::spec(), words, i)
    });
}

aria2("aria2c");

fn parallel(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "parallel" as m;
        lib::complete(m::spec(), words, i)
    });
}

parallel("parallel");

fn miller(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "miller" as m;
        lib::complete(m::spec(), words, i)
    });
}

miller("mlr");

// The AWS CLI has its own completer, `aws_completer` (50 ms).
sh::completer("aws", |words, i| {
    import "bridges" as bridges;
    bridges::aws(words, i)
});

fn cwltool(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "cwltool" as m;
        lib::complete(m::spec(), words, i)
    });
}

cwltool("cwltool");
