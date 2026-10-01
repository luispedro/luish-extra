// Metagenomics and microbial genomics: rgi. Written out from `rgi --help` and
// `rgi SUB --help` (rgi 6.0.8, see completion-todo.md).

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

fn rgi() {
    #{
        opts: `
            -h, --help  show this help message and exit
        `,
        commands: `
            main                 run RGI to predict a resistome from a FASTA or gzip file
            tab                  create a tab-delimited file from an RGI results JSON file
            parser               create categorical JSON files for the RGI wheel visualization
            load                 load the CARD database, annotations and k-mer database
            auto_load            automatically load the CARD database, annotations and k-mer database
            clean                remove BLAST databases and temporary files
            database             information on the installed CARD database
            galaxy               Galaxy project wrapper
            bwt                  align reads to CARD and in silico predicted allelic variants
            tm                   baits melting temperature
            card_annotation      create FASTA files with annotations from card.json
            wildcard_annotation  create FASTA files with annotations from variants
            baits_annotation     create FASTA files with annotations from baits
            remove_duplicates    remove duplicate sequences from an annotated FASTA file
            heatmap              heatmap for multiple RGI results
            kmer_build           build the k-mer sets for CARD*kmers
            kmer_query           test sequences using CARD*kmers
        `,
        sub_spec: own("meta:rgi"),
        args: ["none"],
    }
}

fn rgi_sub(sub) {
    switch sub {
        "main" => #{
            opts: `
                -h, --help                   show this help message and exit
                -i, --input_sequence FILE    input FASTA (contig or protein), or gzip
                -o, --output_file FILE       output folder and base filename
                -t, --input_type TYPE        specify data input type
                -a, --alignment_tool TOOL    specify alignment tool
                -n, --threads N              number of threads (CPUs) to use in the BLAST search
                --include_loose              include loose hits in addition to strict and perfect hits
                --include_nudge              include hits nudged from loose to strict hits
                --local                      use local database
                --clean                      remove temporary files
                --keep                       keep Prodigal CDS when used with --clean
                --debug                      debug mode
                --low_quality                use for short contigs to predict partial genes
                -d, --data TYPE              specify a data-type
                -v, --version                print software version number
                -g, --orf_finder TOOL        specify ORF finding tool
            `,
            values: #{
                "--input_sequence": k("fasta"), "-i": k("fasta"), "--output_file": "files", "-o": "files",
                "--input_type": ["contig", "protein"], "-t": ["contig", "protein"],
                "--alignment_tool": ["DIAMOND", "BLAST"], "-a": ["DIAMOND", "BLAST"],
                "--threads": "none", "-n": "none",
                "--data": ["wgs", "plasmid", "chromosome", "NA"], "-d": ["wgs", "plasmid", "chromosome", "NA"],
                "--orf_finder": ["PRODIGAL", "PYRODIGAL"], "-g": ["PRODIGAL", "PYRODIGAL"],
            },
            args: ["none"],
        },
        "tab" => #{
            opts: `
                -h, --help          show this help message and exit
                -i, --afile FILE    an rgi results JSON file
            `,
            values: #{"--afile": "files", "-i": "files"},
            args: ["none"],
        },
        "parser" => #{
            opts: `
                -h, --help           show this help message and exit
                -i, --input FILE     RGI results, a JSON file
                -o, --output NAME    name/identifier for the output categorical JSON files
                --include_loose      include loose hits in addition to strict and perfect hits
                -t, --type TYPE      type of input sequence: contig, protein or read
            `,
            values: #{
                "--input": "files", "-i": "files", "--output": "none", "-o": "none",
                "--type": ["contig", "protein", "read"], "-t": ["contig", "protein", "read"],
            },
            args: ["none"],
        },
        "load" => #{
            opts: `
                -h, --help                                   show this help message and exit
                -i, --card_json FILE                         a CARD database JSON file
                --card_annotation FILE                       annotated reference FASTA for homolog models only
                --card_annotation_all_models FILE            annotated reference FASTA which includes all models
                --wildcard_annotation FILE                   annotated reference FASTA for homolog models only
                --wildcard_annotation_all_models FILE        annotated reference FASTA which includes all models
                --wildcard_index FILE                        wildcard index file (index-for-model-sequences.txt)
                --wildcard_version VERSION                   specify variants version used
                --baits_annotation FILE                      annotated reference FASTA
                --baits_index FILE                           baits index file (baits-probes-with-sequence-info.txt)
                --kmer_database FILE                         JSON of kmer database
                --amr_kmers FILE                              text file of all AMR kmers
                --kmer_size N                                 kmer size, if loading kmer files
                --local                                       use local database
                --debug                                       debug mode
            `,
            values: #{
                "--card_json": "files", "-i": "files", "--card_annotation": k("fasta"),
                "--card_annotation_all_models": k("fasta"), "--wildcard_annotation": k("fasta"),
                "--wildcard_annotation_all_models": k("fasta"), "--wildcard_index": "files",
                "--wildcard_version": "none", "--baits_annotation": k("fasta"), "--baits_index": "files",
                "--kmer_database": "files", "--amr_kmers": "files", "--kmer_size": "none",
            },
            args: ["none"],
        },
        "auto_load" => #{
            opts: `
                -h, --help    show this help message and exit
                --local       use local database
                --clean       remove temporary files
                --debug       debug mode
                --canonical   load only CARD canonical data
            `,
            args: ["none"],
        },
        "clean" => #{
            opts: `
                -h, --help  show this help message and exit
                --local     use local database
                --debug     debug mode
            `,
            args: ["none"],
        },
        "galaxy" => #{
            opts: `
                -h, --help                   show this help message and exit
                --galaxy_database DIR       path to CARD data and blast databases
                --debug                     debug mode
            `,
            values: #{"--galaxy_database": "dirs"},
            args: ["none"],
        },
        "database" => #{
            opts: `
                -h, --help     show this help message and exit
                -v, --version  print data version number
                --local        use local database
                --all          data version number used for 'rgi bwt' and 'rgi main'
            `,
            args: ["none"],
        },
        "bwt" => #{
            opts: `
                -h, --help                     show this help message and exit
                -1, --read_one FILE            raw read one (QC and trimmed)
                -2, --read_two FILE            raw read two (QC and trimmed)
                -a, --aligner TOOL             select read aligner
                -n, --threads N                number of threads (CPUs) to use
                -o, --output_file FILE         name of output filename(s)
                --debug                        debug mode
                --clean                        remove temporary files
                --local                        use local database
                --include_wildcard             include wildcard
                --include_other_models         include protein variant, rRNA variant, knockout and protein overexpression models
                --include_baits                include baits
                --mapq N                       filter reads based on MAPQ score
                --mapped N                     filter reads based on mapped reads
                --coverage N                   filter reads based on coverage of reference sequence
            `,
            values: #{
                "--read_one": k("fastq"), "-1": k("fastq"), "--read_two": k("fastq"), "-2": k("fastq"),
                "--aligner": ["kma", "bowtie2", "bwa"], "-a": ["kma", "bowtie2", "bwa"],
                "--threads": "none", "-n": "none", "--output_file": "files", "-o": "files",
                "--mapq": "none", "--mapped": "none", "--coverage": "none",
            },
            args: ["none"],
        },
        "tm" => #{
            opts: `
                -h, --help                           show this help message and exit
                -i, --input_file FILE                input file
                -o, --output_file FILE               output file
                -t, --filter_temperature TEMP        desired melting temperature
                --clean                              remove temporary files
                --debug                               debug mode
            `,
            values: #{
                "--input_file": "files", "-i": "files", "--output_file": "files", "-o": "files",
                "--filter_temperature": "none", "-t": "none",
            },
            args: ["none"],
        },
        "card_annotation" => #{
            opts: `
                -h, --help          show this help message and exit
                -i, --input FILE    a card.json file
                --ncbi              add NCBI accessions to FASTA headers
                --debug             debug mode
            `,
            values: #{"--input": "files", "-i": "files"},
            args: ["none"],
        },
        "wildcard_annotation" => #{
            opts: `
                -h, --help                       show this help message and exit
                -i, --input_directory DIR       input directory for wildcard
                -v, --version VERSION           specify version downloaded for wildcard / variants
                -j, --card_json FILE            a card.json file
                --debug                         debug mode
            `,
            values: #{"--input_directory": "dirs", "-i": "dirs", "--card_json": "files", "-j": "files"},
            args: ["none"],
        },
        "baits_annotation" => #{
            opts: `
                -h, --help                show this help message and exit
                --index_file FILE        index file with baits information
            `,
            values: #{"--index_file": "files"},
            args: ["none"],
        },
        "remove_duplicates" => #{
            opts: `
                -h, --help                           show this help message and exit
                -i, --input FILE                     input FASTA file
                --card_annotation FILE               card_annotation input FASTA file
                -o, --output FILE                    output FASTA file
                --debug                               debug mode
            `,
            values: #{
                "--input": k("fasta"), "-i": k("fasta"), "--card_annotation": k("fasta"), "--output": "files",
                "-o": "files",
            },
            args: ["none"],
        },
        "heatmap" => #{
            opts: `
                -h, --help                        show this help message and exit
                -i, --input DIR                   directory containing the RGI JSON files (required)
                -cat, --category NAME             organize resistance genes based on a category
                -f, --frequency                   represent samples based on resistance profile
                -o, --output NAME                 name for the output EPS and PNG files
                -clus, --cluster MODE             cluster rows (AMR genes) or columns (samples)
                -d, --display MODE                display options for categories
                --debug                           debug mode
            `,
            values: #{
                "--input": "dirs", "-i": "dirs",
                "--category": ["drug_class", "resistance_mechanism", "gene_family"],
                "-cat": ["drug_class", "resistance_mechanism", "gene_family"],
                "--output": "none", "-o": "none",
                "--cluster": ["samples", "genes", "both"], "-clus": ["samples", "genes", "both"],
                "--display": ["plain", "fill", "text"], "-d": ["plain", "fill", "text"],
            },
            args: ["none"],
        },
        "kmer_build" => #{
            opts: `
                -h, --help                         show this help message and exit
                -i, --input_directory DIR         input directory of prevalence data
                -c, --card FILE                   FASTA file of CARD reference sequences
                -k N                              k-mer size (e.g., 61)
                --skip                            skip the concatenation and splitting of the CARD*R*V sequences
                -n, --threads N                   number of threads (CPUs) to use
                --batch_size N                    number of kmers to query at a time using pyahocorasick
            `,
            values: #{"--input_directory": "dirs", "-i": "dirs", "--card": k("fasta"), "-c": k("fasta")},
            args: ["none"],
        },
        "kmer_query" => #{
            opts: `
                -h, --help                show this help message and exit
                -i, --input FILE          a BAM file from RGI*BWT, a JSON file of RGI results, or a FASTA file
                --bwt                     the input file is a BAM file generated from RGI*BWT
                --rgi                     the input file is an RGI results JSON file
                --fasta                   the input file is a FASTA file of sequences
                -k, --kmer_size N         length of k
                -m, --minimum N           minimum number of kmers in the called category for the classification
                -n, --threads N           number of threads (CPUs) to use
                -o, --output FILE         output file name
                --local                   use local database
                --debug                   debug mode
            `,
            values: #{"--input": "files", "-i": "files", "--output": "files", "-o": "files"},
            args: ["none"],
        },
        _ => (),
    }
}

fn spec(cmd) {
    switch cmd {
        "rgi" => rgi(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "rgi" => rgi_sub(sub),
        _ => (),
    }
}
