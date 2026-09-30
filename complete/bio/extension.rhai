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

fn bcftools(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "bcftools" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

bcftools("bcftools");

fn align(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "align" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["bwa", "bwa-mem2", "bowtie2", "bowtie2-build", "hisat2", "hisat2-build", "minimap2", "STAR", "kallisto",
            "featureCounts"] {
    align(cmd);
}

fn blast(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "blast" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["blastn", "blastp", "blastx", "tblastn", "tblastx", "psiblast", "rpsblast", "rpstblastn", "deltablast",
            "makeblastdb", "blastdbcmd", "blast_formatter", "blastdb_aliastool", "dustmasker", "segmasker",
            "windowmasker", "makeprofiledb", "blastdbcheck", "update_blastdb.pl"] {
    blast(cmd);
}

fn diamond(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "diamond" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

diamond("diamond");

fn dynamic(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "dynamic" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

dynamic("mmseqs");

fn hmmer(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/lib" as lib;
        import "hmmer" as m;
        lib::complete(m::spec(words[0]), words, i)
    });
}

for cmd in ["hmmsearch", "hmmscan", "phmmer", "jackhmmer", "nhmmer", "nhmmscan", "hmmbuild", "hmmalign", "hmmpress",
            "hmmfetch", "hmmemit", "hmmconvert", "hmmstat"] {
    hmmer(cmd);
}

for cmd in ["ngless", "SemiBin2", "SemiBin", "macrel", "argnorm"] {
    ours(cmd);
}

for cmd in ["samtools", "tabix", "bgzip", "htsfile", "bedtools"] {
    hts(cmd);
}

// Python programs built with Click complete themselves: std's Click bridge asks
// them (`_PROG_COMPLETE=fish_complete`, see `bridges::click`), so there is no
// spec here. Each Tab runs the program, so these are the ones that answer in
// under a second (checked with scripts/clickcheck.sh, see completion-todo.md);
// the ones that import too much at startup (cooltools, bigscape, iphop, genomad,
// pyprophet, easypqp, ms2rescore, velocyto) can be added by the user with
// `complete-click PROG`. A program that isn't installed, or that doesn't
// answer, gets filenames.
fn click(cmd) {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::click(words, i)
    });
}

for cmd in ["multiqc", "peddy", "genmod", "plassembler", "cooler", "pairtools", "checkv", "virsorter", "metacoag",
            "harpy", "defense-finder", "dnaapler", "genomepy", "freyja", "fastq-dl", "biom"] {
    click(cmd);
}
