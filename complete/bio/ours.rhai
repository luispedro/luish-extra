// The group's own tools: ngless, SemiBin2 (and SemiBin), macrel, argnorm.
// Their options are written out (not read from `--help`): SemiBin2 imports
// torch and takes seconds to answer.

fn fasta() { "@extra-complete/bio/kinds:fasta" }
fn fastq() { "@extra-complete/bio/kinds:fastq" }
fn bam() { "@extra-complete/bio/kinds:bam" }

fn ngless() {
    #{
        opts: `
            -V, --version                 print version and exit
            --version-short               print just version string
            --version-debug               print detailed version information
            --date-short                  print just release date string
            -h, --help                    show help
            -e, --script SCRIPT           inline script to execute
            --debug FLAG                  debug options
            -n, --validate-only           only validate input, do not run script
            -p, --print-last              print value of last line in script
            -j, --jobs, --threads N       number of threads to use
            --strict-threads              strictly respect the --threads option
            --no-strict-threads           opposite of --strict-threads
            --create-report               create the report directory
            --no-create-report            opposite of --create-report
            -o, --html-report-directory DIR  name of output directory
            -t, --temporary-directory DIR    where to store temporary files
            --keep-temporary-files        keep temporary files
            --no-keep-temporary-files     opposite of --keep-temporary-files
            --config-file FILE            configuration file to parse
            --no-header                   do not print copyright information
            --subsample                   quickly test a pipeline on 1% of the input
            --experimental-features       allow the use of experimental features
            --export-json FILE            write a JSON representation of the script to FILE
            --export-cwl FILE             write a CWL wrapper of the script to FILE
            --check-deprecation           check if ngless or any used modules are deprecated
            --search-dir DIR              deprecated, use --search-path
            --search-path DIR             reference search directories
            --index-path DIR              directory where indices are stored
            --download-file               download a file
            --download-url URL            the URL to download
            --local-file FILE             where to save the download
            --download-demo DEMO          download a demo
            --install-reference-data REF  install a reference
            --print-path EXEC             print the path of an executable
            --check-install               check that ngless is correctly installed
            -v, --verbosity LEVEL         verbosity level
            -q, --quiet                   quiet mode
            --color WHEN                  color settings
            --trace                       highest verbosity mode
            --no-trace                    opposite of --trace
        `,
        values: #{
            "--color": ["auto", "force", "no"],
            "--verbosity": ["quiet", "info", "normal"],
            "--script": "none",
            "--debug": "none",
            "--jobs": "none",
            "--search-path": "dirs",
            "--search-dir": "dirs",
            "--index-path": "dirs",
            "--html-report-directory": "dirs",
            "--temporary-directory": "dirs",
            "--config-file": "files",
            "--export-json": "files",
            "--export-cwl": "files",
            "--local-file": "files",
            "--download-url": "none",
            "--download-demo": "none",
            "--install-reference-data": "none",
            "--print-path": "none",
        },
        // SCRIPT [ARGUMENTS...]
        args: ["@extra-complete/bio/kinds:ngless", "files"],
    }
}

// The options of SemiBin2's subcommands, by the names of the arguments.
fn semibin_opts(name) {
    switch name {
        "input" => "-i, --input-fasta FILE  the input FASTA file (contigs)",
        "inputs" => "-i, --input-fasta FILE...  the input FASTA files (contigs)",
        "output" => "-o, --output DIR  the output directory",
        "bams" => "-b, --input-bam FILE...  the input BAM or CRAM files",
        "abundance" => "-a, --abundance FILE...  abundance files from strobealign-aemb",
        "abundance_multi" => "-a, --abundance, --abundances FILE...  abundance files from strobealign-aemb",
        "data" => "--data FILE  the data.csv file",
        "data_many" => "--data FILE...  the data.csv files",
        "data_split" => "--data-split FILE...  the data_split.csv files",
        "output_opts" => `
            --write-pre-reclustering-bins    write pre-reclustering bins to disk
            --no-write-pre-reclustering-bins opposite of --write-pre-reclustering-bins
            --tag-output TAG                 tag to add to output file names
            --compression TYPE               compression of the output files
        `,
        "orf" => `
            --orf-finder FINDER            ORF finder used to estimate the number of bins
            --prodigal-output-faa FILE     [deprecated] use this .faa file instead of calling ORFs
        `,
        "depth" => "--depth-metabat2 FILE  depth file generated by metabat2 (single-sample)",
        "kmer" => "--kmer  only write data.csv, with the k-mer features",
        "min_len" => `
            -m, --min-len N                minimal length for contigs in binning
            --ratio RATIO                  ratio of contigs of 1000-2500 bp that sets the minimal length
        `,
        "min_len_only" => "-m, --min-len N  minimal length for contigs in binning",
        "compression" => "--compression TYPE  compression of the output files",
        "log" => `
            --verbose                      verbose output
            -q, --quiet                    quiet output
        `,
        "general" => `
            --tmpdir DIR                   temporary directory
            -p, -t, --processes, --threads N  number of CPUs used (0 for all)
            --verbose                      verbose output
            -q, --quiet                    quiet output
        `,
        "training" => `
            --epochs, --epoches N          number of epochs used in training
            --batch-size N                 batch size used in training
            --random-seed N                random seed
            --engine ENGINE                device used to train the model
        `,
        "seed_engine" => `
            --random-seed N                random seed
            --engine ENGINE                device used to train the model
        `,
        "from_many" => "--train-from-many, --no-train-from-many  train the model with several samples",
        "binning" => `
            --minfasta-kbs N               minimum bin size in Kbps
            --max-edges N                  maximum number of edges connected to one contig
            --max-node FRACTION            fraction of contigs considered to be binned
            --no-recluster                 do not recluster bins
        `,
        "minfasta" => "--minfasta-kbs N  minimum bin size in Kbps",
        "ml" => "--ml-threshold N  length threshold for generating must-link constraints",
        "environment" => "--environment, --habitat, --biome NAME  environment for the built-in model",
        "model" => "--model FILE  the trained deep learning model",
        "easy" => `
            -r, --reference-db-data-dir, --reference-db DIR  GTDB reference storage path
            --cannot-name NAME             name for the cannot-link file
            --taxonomy-annotation-table FILE...  pre-computed mmseqs2 taxonomy TSV file
            --semi-supervised              train the model with semi-supervised learning
            --self-supervised              train the model with self-supervised learning
            --sequencing-type TYPE         sequencing type
        `,
        "separator" => "-s, --separator SEP  separates sample name and contig name",
        _ => throw `unknown SemiBin2 option group: ${name}`,
    }
}

fn semibin_values() {
    #{
        "--input-fasta": fasta(),
        "--output": "dirs",
        "--input-bam": bam(),
        "--abundance": "files",
        "--abundances": "files",
        "--data": "files",
        "--data-split": "files",
        "--model": "files",
        "--depth-metabat2": "files",
        "--prodigal-output-faa": "files",
        "--tmpdir": "dirs",
        "--reference-db-data-dir": "dirs",
        "--reference-db": "dirs",
        "--taxonomy-annotation-table": "files",
        "--compression": ["gz", "xz", "bz2", "none"],
        "--orf-finder": ["fast-naive", "prodigal", "fraggenescan"],
        "--environment": ["human_gut", "dog_gut", "ocean", "soil", "cat_gut", "human_oral", "mouse_gut", "pig_gut", "built_environment", "wastewater", "chicken_caecum", "global"],
        "--habitat": ["human_gut", "dog_gut", "ocean", "soil", "cat_gut", "human_oral", "mouse_gut", "pig_gut", "built_environment", "wastewater", "chicken_caecum", "global"],
        "--biome": ["human_gut", "dog_gut", "ocean", "soil", "cat_gut", "human_oral", "mouse_gut", "pig_gut", "built_environment", "wastewater", "chicken_caecum", "global"],
        "--engine": ["auto", "gpu", "cpu"],
        "--sequencing-type": ["short_read", "long_read", "hybrid"],
    }
}

fn semibin() {
    #{
        opts: `
            -h, --help                   show help
            -v, -V, --version            print the version number
            --verbose                    verbose output
            -q, --quiet                  quiet output
        `,
        commands: `
            single_easy_bin                  bin contigs (single or co-assembly) using one command
            multi_easy_bin                   bin contigs (multi-sample) using one command
            generate_sequence_features_single  generate k-mer and abundance features (single or co-assembly)
            generate_sequence_features_multi   generate k-mer and abundance features (multi-sample)
            check_install                    check whether required dependencies are present
            concatenate_fasta                concatenate FASTA files for multi-sample binning
            split_contigs                    split contigs (strobealign-aemb pipeline)
            train_self                       train the model with self-supervised learning
            bin, bin_short                   group the contigs into bins
            bin_long                         group the contigs from long reads into bins
            train_semi                       [deprecated] train the model with semi-supervised learning
            generate_cannot_links, predict_taxonomy  [deprecated] annotate contigs with mmseqs and GTDB
            download_GTDB                    [deprecated] download GTDB reference genomes
            install-skills, install_skills   install the bundled agent skills
            citation                         print citation information
        `,
        sub_spec: "@extra-complete/bio/ours:semibin",
        values: semibin_values(),
        args: ["none"],
    }
}

fn semibin_sub(sub) {
    let groups = switch sub {
        "single_easy_bin" => ["input", "output", "bams", "abundance", "output_opts", "orf", "depth", "min_len", "general",
                              "training", "binning", "ml", "environment", "easy"],
        "multi_easy_bin" => ["input", "output", "bams", "abundance_multi", "output_opts", "orf", "min_len", "general",
                             "training", "binning", "ml", "easy", "separator"],
        "generate_sequence_features_single" => ["input", "output", "bams", "abundance", "output_opts", "min_len",
                                                "general", "ml", "kmer"],
        "generate_sequence_features_multi" => ["input", "output", "bams", "abundance_multi", "output_opts", "min_len",
                                               "general", "ml", "separator"],
        "bin" | "bin_short" => ["input", "output", "data", "model", "output_opts", "orf", "depth", "min_len",
                                "general", "environment", "binning", "seed_engine"],
        "bin_long" => ["input", "output", "data", "model", "output_opts", "orf", "depth", "min_len",
                       "general", "environment", "minfasta", "seed_engine"],
        "train_self" => ["output", "data_many", "data_split", "general", "training", "from_many"],
        "concatenate_fasta" => ["inputs", "output", "min_len_only", "separator", "compression", "log"],
        "split_contigs" => ["input", "output", "min_len_only"],
        "check_install" => ["log"],
        "citation" => {
            return #{opts: `
                -h, --help  show help
                --bibtex    print BibTeX-formatted citations
                --ris       print RIS-formatted citations
                --chicago   print a Chicago-style citation
            `, args: ["none"]};
        }
        "install-skills" | "install_skills" => {
            return #{opts: `
                -h, --help              show help
                --user, --global        install to the user-wide skills directory
                --skills-dir DIR        the skills directory
            `, values: #{"--skills-dir": "dirs"}, args: ["none"]};
        }
        _ => return (),
    };
    let opts = "-h, --help  show help\n";
    for g in groups {
        opts += semibin_opts(g) + "\n";
    }
    let spec = #{opts: opts, values: semibin_values(), args: ["none"]};
    if sub == "check_install" {
        spec.opts += "--allow-missing-mmseqs2  do not fail if mmseqs2 is missing\n";
    }
    spec
}

fn macrel() {
    #{
        opts: `
            -h, --help                show help
            -t, --threads N           number of threads to use
            -o, --output DIR          the output directory
            --file-output FILE        the output file
            --tag TAG                 output tag
            -f, --fasta FILE          the input FASTA file
            -1, --reads1 FILE         reads (first mate)
            -2, --reads2 FILE         reads (second mate)
            --mem MEM                 memory to use
            --cluster                 pre-cluster the smORFs (at 100% identity)
            --force                   overwrite the output
            --keep-fasta-headers      keep complete FASTA headers (get-smorfs)
            --tmpdir DIR              temporary directory
            --keep-negatives          keep non-AMPs in the output
            -v, --version             show the version
            -V, --verbose             print debug information
            -q, --quiet               print only errors
            --log-file FILE           write the log to FILE
            --log-append              append to the log file
            --query-mode MODE         query mode for the AMPSphere
            --local                   use the local AMPSphere database
            --re-download-database    download the AMPSphere database again
            --no-download-database    do not download the AMPSphere database
            --cache-dir DIR           directory for caching AMPSphere data
        `,
        values: #{
            "--threads": "none",
            "--output": "dirs",
            "--file-output": "files",
            "--tag": "none",
            "--fasta": fasta(),
            "--reads1": fastq(),
            "--reads2": fastq(),
            "--mem": "none",
            "--tmpdir": "dirs",
            "--log-file": "files",
            "--query-mode": ["exact", "mmseqs", "hhm"],
            "--cache-dir": "dirs",
        },
        // Macrel's command is a word that is not an option, first.
        args: [[
            #{value: "peptides", desc: "predict AMPs in peptides"},
            #{value: "contigs", desc: "predict AMPs in contigs"},
            #{value: "reads", desc: "predict AMPs in reads"},
            #{value: "abundance", desc: "abundance profiles of AMPs"},
            #{value: "get-smorfs", desc: "predict small ORFs"},
            #{value: "query-ampsphere", desc: "query the AMPSphere database"},
            #{value: "get-examples", desc: "download example files"},
        ]],
    }
}

fn argnorm() {
    let dbs = ["argannot", "deeparg", "megares", "ncbi", "resfinder", "resfinderfg", "sarg", "groot-db",
               "groot-core-db", "groot-argannot", "groot-resfinder", "groot-card"];
    #{
        opts: `
            -h, --help                 show help
            -v, --version              show the version
            --db DB                    the database used with the annotation tool
            -i, --input FILE           the ARG annotation result to normalize
            --hamronization_skip_unsupported_tool  warn, do not fail, on unsupported tools in hamronization outputs
            -o, --output FILE          where to write the results
        `,
        values: #{"--db": dbs, "--input": "files", "--output": "files"},
        args: [["argsoap", "abricate", "deeparg", "resfinder", "amrfinderplus", "groot", "hamronization"]],
    }
}

fn spec(cmd) {
    switch cmd {
        "ngless" => ngless(),
        "SemiBin2" | "SemiBin" => semibin(),
        "macrel" => macrel(),
        "argnorm" => argnorm(),
        _ => #{},
    }
}

// The specs of SemiBin2's subcommands.
fn sub_spec(name, sub) {
    switch name {
        "semibin" => semibin_sub(sub),
        _ => (),
    }
}
