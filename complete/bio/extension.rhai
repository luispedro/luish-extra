// Completion for bioinformatics commands, by the command's name (not its
// Bioconda package's). Each command is described by a spec in one of the
// modules below, and completed by std's engine (`@std/completion/lib`).
//
// The modules are imported by the completer, so that they are compiled on
// the first Tab for one of their commands rather than whenever a shell
// starts. luish calls a completer with the command's name as the first word.
// Every module has `fn spec(cmd)`, and, for commands with subcommands, the
// spec's `sub_spec` is `own("MODULE:CMD")`, that is
// `MODULE::sub_spec(CMD, SUBCOMMAND)`.

// The module of each command.
let module_of = #{};
for m in [
    ["ours", ["ngless", "SemiBin2", "SemiBin", "macrel", "argnorm"]],
    ["hts", ["samtools", "tabix", "bgzip", "htsfile", "bedtools"]],
    ["bcftools", ["bcftools"]],
    ["bam", ["sambamba", "bamtools", "samblaster", "mosdepth", "cramino", "vcftools"]],
    ["align", ["bwa", "bwa-mem2", "bowtie2", "bowtie2-build", "hisat2", "hisat2-build", "minimap2", "STAR", "kallisto",
               "featureCounts"]],
    ["blast", ["blastn", "blastp", "blastx", "tblastn", "tblastx", "psiblast", "rpsblast", "rpstblastn", "deltablast",
               "makeblastdb", "blastdbcmd", "blast_formatter", "blastdb_aliastool", "dustmasker", "segmasker",
               "windowmasker", "makeprofiledb", "blastdbcheck", "update_blastdb.pl"]],
    ["diamond", ["diamond"]],
    // Programs whose help is read when Tab is pressed (mmseqs).
    ["dynamic", ["mmseqs"]],
    ["hmmer", ["hmmsearch", "hmmscan", "phmmer", "jackhmmer", "nhmmer", "nhmmscan", "hmmbuild", "hmmalign", "hmmpress",
               "hmmfetch", "hmmemit", "hmmconvert", "hmmstat"]],
    ["reads", ["fastp", "fastqc", "falco", "cutadapt", "trimmomatic", "trim_galore", "fastq_screen", "seqtk",
               "filtlong", "chopper", "nanoq", "rasusa", "porechop", "NanoPlot", "NanoFilt", "NanoStat"]],
    ["asm", ["spades.py", "metaspades.py", "megahit", "flye", "quast", "quast.py", "metaquast", "metaquast.py",
             "busco", "prodigal", "prokka", "bakta", "barrnap"]],
    ["meta", ["rgi"]],
    ["profile", ["kraken2", "kraken2-build", "kraken2-inspect", "k2", "bracken", "bracken-build",
                "combine_bracken_outputs.py", "krakenuniq", "krakenuniq-build", "krakenuniq-report",
                "krakenuniq-download", "centrifuge", "centrifuge-build", "centrifuge-inspect", "centrifuge-kreport",
                "kaiju", "kaiju-multi", "kaiju2table", "kaiju2krona", "kaiju-addTaxonNames", "kaiju-mergeOutputs",
                "kaiju-makedb", "kaiju-mkbwt", "kaiju-mkfmi", "metaphlan", "merge_metaphlan_tables.py", "strainphlan",
                "sample2markers.py", "extract_markers.py", "humann", "humann_databases", "humann_config",
                "humann_join_tables", "humann_renorm_table", "humann_regroup_table", "humann_split_stratified_table",
                "humann_rename_table", "humann_split_table", "humann_reduce_table", "humann_unpack_pathways",
                "humann_barplot", "motus"]],
    ["bins", ["checkm", "checkm2", "gunc", "gtdbtk", "metabat2", "jgi_summarize_bam_contig_depths", "concoct",
              "concoct_coverage_table.py", "cut_up_fasta.py", "merge_cutup_clustering.py", "extract_fasta_bins.py",
              "run_MaxBin.pl", "DAS_Tool", "Fasta_to_Contig2Bin.sh", "dRep", "coverm", "vamb"]],
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

// Go programs built with Cobra complete themselves too: std's Cobra bridge asks
// them (`PROG __complete`, see `bridges::cobra`), in about 10 ms.
for cmd in ["seqkit", "csvtk", "taxonkit"] {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::cobra(words, i)
    });
}

// Python programs built with Click complete themselves: std's Click bridge asks
// them (`_PROG_COMPLETE=fish_complete`, see `bridges::click`), so there is no
// spec here. Each Tab runs the program, so these are the ones that answer in
// under a second (checked with scripts/clickcheck.sh, see completion-todo.md);
// the ones that import too much at startup (cooltools, bigscape, iphop, genomad,
// pyprophet, easypqp, ms2rescore, velocyto) can be added by the user with
// `complete-click PROG`. A program that isn't installed, or that doesn't
// answer, gets filenames.
for cmd in ["multiqc", "peddy", "genmod", "plassembler", "cooler", "pairtools", "checkv", "virsorter", "metacoag",
            "harpy", "defense-finder", "dnaapler", "genomepy", "freyja", "fastq-dl", "biom"] {
    sh::completer(cmd, |words, i| {
        import "@std/completion/bridges" as bridges;
        bridges::click(words, i)
    });
}
