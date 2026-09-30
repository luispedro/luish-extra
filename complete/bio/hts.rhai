// Alignment files, variants and intervals: samtools, tabix, bgzip, htsfile
// and bedtools.

fn k(name) { "@extra-complete/bio/kinds:" + name }

// ---- samtools ----

// The options that most samtools subcommands share.
fn samtools_common() {
    `
        -@, --threads N                  number of additional threads to use
        --verbosity N                    set the level of verbosity
        --input-fmt-option OPT[=VAL]    an input format option
        --output-fmt-option OPT[=VAL]   an output format option
        -O, --output-fmt FORMAT[,OPT[=VAL]]  the output format
        --reference FILE                the reference FASTA
        --write-index                   automatically index the output files
    `
}

fn samtools_values() {
    #{
        "--reference": k("fasta"),
        "--threads": "none",
        "-@": "none",
        "--verbosity": "none",
        "--input-fmt-option": "none",
        "--output-fmt-option": "none",
        "--output-fmt": ["SAM", "BAM", "CRAM"],
        "-O": ["SAM", "BAM", "CRAM"],
    }
}

// Pieces of the "standard options" block that many subcommands have, by key:
// `in` --input-fmt-option, `out` -O/--output-fmt, `outlong` --output-fmt only,
// `outopt` --output-fmt-option, `ref` --reference, `refT` -T/--reference,
// `thr` -@/--threads, `wi` --write-index, `verb` --verbosity.
fn st_opts(keys) {
    let lines = #{
        "in": "--input-fmt-option OPT[=VAL]   an input format option",
        "out": "-O, --output-fmt FORMAT[,OPT[=VAL]]  the output format",
        outlong: "--output-fmt FORMAT[,OPT[=VAL]]  the output format",
        outopt: "--output-fmt-option OPT[=VAL]  an output format option",
        ref: "--reference FILE   the reference FASTA",
        refT: "-T, --reference FILE   the reference FASTA",
        thr: "-@, --threads N   number of additional threads to use",
        wi: "--write-index   automatically index the output files",
        verb: "--verbosity N   set the level of verbosity",
    };
    let out = "\n";
    for key in keys {
        out += lines[key] + "\n";
    }
    out
}

// The values of those options, all of them (unused ones do no harm).
fn st_values() {
    #{
        "--reference": k("fasta"), "-T": k("fasta"), "--threads": "none", "-@": "none", "--verbosity": "none",
        "--input-fmt-option": "none", "--output-fmt-option": "none",
        "--output-fmt": ["SAM", "BAM", "CRAM"], "-O": ["SAM", "BAM", "CRAM"], "--input-fmt": ["SAM", "BAM", "CRAM"],
    }
}

// The lines of an option table except those that start with one of `prefixes`.
fn without(table, prefixes) {
    let out = "";
    for l in table.split("\n") {
        let t = l;
        t.trim();
        if !prefixes.some(|p| t.starts_with(p)) {
            out += l + "\n";
        }
    }
    out
}

fn samtools() {
    #{
        opts: `
            -h, --help      show help
            --version       show the version
        `,
        commands: `
            dict           create a sequence dictionary file
            faidx          index or extract from a FASTA file
            fqidx          index or extract from a FASTQ file
            index          index an alignment file
            calmd          recalculate MD/NM tags and '=' bases
            fixmate        fix mate information
            reheader       replace the BAM header
            targetcut      cut fosmid regions (fosmid pools only)
            addreplacerg   add or replace RG tags
            markdup        mark duplicates
            ampliconclip   clip oligos from the end of reads
            collate        shuffle and group alignments by name
            cat            concatenate BAMs
            consensus      produce a consensus pileup, FASTA or FASTQ
            merge          merge sorted alignments
            mpileup        multi-way pileup
            sort           sort an alignment file
            split          split a file by read group
            quickcheck     check quickly that an alignment file is intact
            fastq          convert a BAM to FASTQ
            fasta          convert a BAM to FASTA
            import         convert FASTA or FASTQ files to SAM, BAM or CRAM
            reference      generate a reference from aligned data
            reset          revert aligner changes in reads
            bedcov         read depth per BED region
            coverage       alignment depth and percent coverage
            depth          compute the depth
            flagstat       simple statistics
            idxstats       BAM index statistics
            cram-size      list CRAM content-ID and data-series sizes
            phase          phase heterozygotes
            stats          generate statistics
            ampliconstats  amplicon-specific statistics
            checksum       order-agnostic checksums of sequence content
            flags          explain BAM flags
            head           view the header
            tview          text alignment viewer
            view           convert between SAM, BAM and CRAM
            depad          convert a padded BAM to an unpadded BAM
            samples        list the samples in SAM, BAM or CRAM files
            help           show help for a command
            version        detailed version information
        `,
        sub_spec: "@extra-complete/bio/hts:samtools",
        values: samtools_values(),
    }
}

fn samtools_sub(sub) {
    let sam = k("sam");
    switch sub {
        "view" => #{
            opts: `
                -b, --bam                   output BAM
                -C, --cram                  output CRAM (requires -T)
                -1, --fast                  use fast BAM compression
                -u, --uncompressed          uncompressed BAM output
                -h, --with-header           include the header in SAM output
                -H, --header-only           print the SAM header only
                --no-header                 print alignment records only
                -c, --count                 print only the count of matching records
                --save-counts FILE          write counts of passed and failed records to FILE
                -o, --output FILE           write output to FILE
                -U, --unoutput, --output-unselected FILE  write reads not selected by filters to FILE
                -p, --unmap                 set UNMAP on reads not selected
                -P, --fetch-pairs           retrieve complete pairs even when outside of the region
                -t, --fai-reference FILE    file listing reference names and lengths
                -M, --use-index             use the index and multi-region iterator for regions
                --region-file, --regions-file FILE  use the index to include only reads overlapping FILE
                -X, --customized-index      expect an extra index file argument after the input
                -L, --target-file, --targets-file FILE  only reads overlapping the BED regions in FILE
                -N, --qname-file FILE       only reads whose name is listed in FILE
                -r, --read-group STR        only reads in read group STR
                -R, --read-group-file FILE  only reads in a read group listed in FILE
                -d, --tag STR               only reads with tag STR[:VALUE]
                -D, --tag-file STR:FILE     only reads with tag STR whose value is listed in FILE
                -q, --min-MQ N             only reads with mapping quality >= N
                -l, --library STR           only reads in library STR
                -m, --min-qlen N            only reads that cover >= N query bases
                -e, --expr EXPR             only reads that match the filter expression
                -f, --require-flags FLAG    only reads with all the FLAGs present
                -F, --excl-flags, --exclude-flags FLAG  only reads with none of the FLAGs present
                --rf, --incl-flags, --include-flags FLAG  only reads with some of the FLAGs present
                -G FLAG                     exclude reads with all of the FLAGs present
                --subsample FLOAT           keep only this fraction of templates
                --subsample-seed N          influence which reads are kept in subsampling
                -s N.FRAC                   same as --subsample 0.FRAC --subsample-seed N
                --add-flags FLAG            add FLAGs to reads
                --remove-flags FLAG         remove FLAGs from reads
                -x, --remove-tag STR        comma-separated read tags to strip
                --keep-tag STR              comma-separated read tags to keep
                -B, --remove-B              collapse the backward CIGAR operation
                -z, --sanitize FLAGS        sanity-check and fix records
                -T, --reference FILE        the reference FASTA
                -S                          ignored (the format is detected)
                --no-PG                     do not add a PG line
            ` + samtools_common(),
            values: samtools_values() + #{
                "-T": k("fasta"),
                "-L": k("bed"),
                "--target-file": k("bed"),
                "--targets-file": k("bed"),
                "--qname-file": "files",
                "-N": "files",
                "--read-group-file": "files",
                "--region-file": "files",
                "--regions-file": "files",
                "--save-counts": "files",
                "--unoutput": "files",
                "--output-unselected": "files",
                "-U": "files",
                "-t": "files",
                "--read-group": "none",
                "--library": "none",
                "--expr": "none",
                "--tag": "none",
                "--tag-file": "none",
                "--min-MQ": "none",
                "-q": "none",
            },
            args: [sam, k("regions")],
        },
        "sort" => #{
            opts: `
                -l N                    compression level, from 0 to 9
                -u                      uncompressed output
                -m N                    maximum memory per thread (K, M or G)
                -M                      use minimisers for clustering unaligned reads
                -R                      do not use the reverse strand (with -M)
                -K N                    k-mer size for the minimiser
                -I FILE                 order minimisers by their position in FILE
                -w N                    window size for minimiser indexing
                -H                      squash homopolymers for the minimiser
                -n                      sort by read name (natural)
                -N                      sort by read name (ASCII)
                -t TAG                  sort by the value of TAG
                -o FILE                 write output to FILE
                -T PREFIX               write temporary files to PREFIX.nnnn.bam
                --no-PG                 do not add a PG line
                --template-coordinate   sort by template coordinate
            ` + samtools_common(),
            values: samtools_values() + #{"-I": k("fasta"), "-t": "none"},
            args: [sam],
        },
        "index" => #{
            opts: `
                -b, --bai               generate a BAI index (default)
                -c, --csi               generate a CSI index
                -m, --min-shift N       minimum interval size for CSI indices, 2^N
                -M                      interpret all arguments as files to index
                -o, --output FILE       write the index to FILE
                -@, --threads N         number of additional threads to use
            `,
            values: #{"--output": "files", "-o": "files"},
            args: [sam, k("bam_index")],
        },
        "faidx" => #{
            opts: `
                -o, --output FILE           write FASTA to FILE
                -n, --length N              length of FASTA sequence lines
                -c, --continue              continue after failing to retrieve a region
                -r, --region-file FILE      file of regions, one per line
                -i, --reverse-complement    reverse complement sequences
                --mark-strand TYPE          add a strand indicator to the sequence name
                --fai-idx FILE              name of the index file
                --gzi-idx FILE              name of the compressed-file index
                -f, --fastq                 the file and index are FASTQ
                -h, --help                  show help
                --output-fmt-option OPT[=VAL]  an output format option
                -@, --threads N             number of additional threads to use
                --write-index               automatically index the output files
            `,
            values: #{
                "--mark-strand": ["rc", "no", "sign", "custom,"],
                "--region-file": "files",
                "-r": "files",
                "--fai-idx": "files",
                "--gzi-idx": "files",
                "--length": "none",
                "-n": "none",
                "--output": "files",
                "-o": "files",
            },
            args: [k("sequences"), k("regions")],
        },
        "flagstat" => #{
            opts: `
                --input-fmt-option OPT[=VAL]  an input format option
                -@, --threads N               number of additional threads to use
                --verbosity N                 set the level of verbosity
                -O, --output-fmt FORMAT       the output format
            `,
            values: #{"--output-fmt": ["json", "tsv"], "-O": ["json", "tsv"]},
            args: [sam],
        },
        "idxstats" => #{
            opts: `
                -X                            include a customized index file
                --input-fmt-option OPT[=VAL]  an input format option
                -@, --threads N               number of additional threads to use
                --verbosity N                 set the level of verbosity
            `,
            args: [sam],
        },
        "stats" => #{
            opts: `
                -c, --coverage MIN,MAX,STEP   coverage distribution
                -d, --remove-dups             exclude reads marked as duplicates
                -X, --customized-index-file   use a customized index file
                -f, --required-flag FLAG      required flag
                -F, --filtering-flag FLAG     filtering flag
                --GC-depth FLOAT              size of GC-depth bins
                -h, --help                    show help
                -i, --insert-size N           maximum insert size
                -I, --id STR                  include only the read group or sample
                -l, --read-length N           include only reads with this length
                -m, --most-inserts FLOAT      report only the main part of inserts
                -P, --split-prefix STR        prefix for the files written by -S
                -q, --trim-quality N          the BWA trimming parameter
                -r, --ref-seq FILE            reference sequence, for GC-depth and mismatches
                -s, --sam                     ignored (the format is detected)
                -S, --split TAG               also write statistics split by tagged field
                -t, --target-regions FILE     statistics in these regions only
                -x, --sparse                  suppress IS rows where there are no insertions
                -p, --remove-overlaps         remove overlaps of paired-end reads
                -g, --cov-threshold N         only bases with coverage above this
                --input-fmt-option OPT[=VAL]  an input format option
                --reference FILE              the reference FASTA
                -@, --threads N               number of additional threads to use
                --verbosity N                 set the level of verbosity
            `,
            values: #{
                "--ref-seq": k("fasta"),
                "-r": k("fasta"),
                "--reference": k("fasta"),
                "--target-regions": k("bed"),
                "-t": k("bed"),
            },
            args: [sam, k("regions")],
        },
        "depth" => #{
            opts: `
                -a                        output all positions (including zero depth)
                -r REG                    a region
                -b FILE                   BED file with the regions
                -f FILE                   file listing the input alignment files
                -X                        use customized index files
                -g N                      remove these flags from the default filter-out list
                -G, --excl-flags FLAGS    add these flags to the filter-out list
                --incl-flags FLAGS        include only records with one of the flags
                --require-flags FLAGS     include only records with all of the flags
                -H                        print a header line
                -l N                      minimum read length
                -o FILE                   write output to FILE
                -q, --min-BQ N            filter bases with base quality below N
                -Q, --min-MQ N            filter alignments with mapping quality below N
                -J                        include reads with deletions in the depth
                -s                        do not count overlapping reads within a template
                --input-fmt-option OPT[=VAL]  an input format option
                --reference FILE          the reference FASTA
                -@, --threads N           number of additional threads to use
                --verbosity N             set the level of verbosity
            `,
            values: #{"-r": k("regions"), "-b": k("bed"), "-f": "files", "--reference": k("fasta"), "-o": "files"},
            args: [sam],
        },
        "coverage" => #{
            opts: `
                -b, --bam-list FILE       file listing the input alignment files
                -l, --min-read-len N      ignore reads shorter than N bp
                -q, --min-MQ N            mapping quality threshold
                -Q, --min-BQ N            base quality threshold
                --rf FLAG                 required flags
                --ff FLAG                 filter flags
                -d, --depth N             maximum coverage depth
                -m, --histogram           show a histogram instead of a table
                -D, --plot-depth          plot depth instead of a table
                -A, --ascii               show only ASCII characters in the histogram
                -o, --output FILE         write output to FILE
                -H, --no-header           no header in tabular mode
                -w, --n-bins N            number of bins in the histogram
                -r, --region REG          show this region
                -h, --help                show help
                --input-fmt-option OPT[=VAL]  an input format option
                --reference FILE          the reference FASTA
                --verbosity N             set the level of verbosity
            `,
            values: #{"--bam-list": "files", "-b": "files", "--region": k("regions"), "-r": k("regions"),
                      "--reference": k("fasta"), "--output": "files", "-o": "files"},
            args: [sam],
        },
        "merge" => #{
            opts: `
                -n                    inputs are sorted by read name (natural)
                -N                    inputs are sorted by read name (ASCII)
                -t TAG                inputs are sorted by TAG
                -r                    attach an RG tag (inferred from file names)
                -u                    uncompressed BAM output
                -f                    overwrite the output BAM
                -o FILE               the output file
                -1                    compression level 1
                -l N                  compression level, from 0 to 9
                -R STR                merge the file in this region
                -h FILE               copy the header in FILE to the output
                -c                    combine @RG headers with colliding IDs
                -p                    combine @PG headers with colliding IDs
                -s VALUE              override the random seed
                -b FILE               list of input BAM filenames, one per line
                -X                    use customized index files
                -L FILE               BED file for multiple region filtering
                --no-PG               do not add a PG line
                --template-coordinate inputs are sorted by template coordinate
            ` + samtools_common(),
            values: samtools_values() + #{"-h": k("sam"), "-b": "files", "-L": k("bed"), "-R": k("regions"),
                                          "-t": "none", "-s": "none"},
            args: [sam],
        },
        "mpileup" => #{
            opts: `
                -6, --illumina1.3+          quality is in the Illumina 1.3+ encoding
                -A, --count-orphans         do not discard anomalous read pairs
                -b, --bam-list FILE         list of input BAM filenames, one per line
                -B, --no-BAQ                disable BAQ
                -C, --adjust-MQ N           adjust mapping quality
                -d, --max-depth N           maximum depth per file
                -E, --redo-BAQ              recalculate BAQ on the fly
                -f, --fasta-ref FILE        faidx-indexed reference sequence file
                -G, --exclude-RG FILE       exclude read groups listed in FILE
                -l, --positions FILE        skip unlisted positions or regions
                -q, --min-MQ N              skip alignments with mapping quality below N
                -Q, --min-BQ N             skip bases with base quality below N
                -r, --region REG            region in which the pileup is generated
                -R, --ignore-RG             ignore RG tags
                --rf, --incl-flags FLAG     required flags
                --ff, --excl-flags FLAG     filter flags
                -x, --ignore-overlaps-removal, --disable-overlap-removal  disable read-pair overlap detection
                -X, --customized-index      use customized index files
                -o, --output FILE           write output to FILE
                -O, --output-BP             output base positions on reads
                --output-BP-5               output base positions on reads, 5' to 3'
                -M, --output-mods           output base modifications
                -s, --output-MQ             output mapping quality
                --output-QNAME              output read names
                --output-extra STR          output extra read fields and tag values
                --output-sep CHAR           separator for tag lists
                --output-empty CHAR         no-value character for tag lists
                --no-output-ins             skip insertion sequences after +NUM
                --no-output-ins-mods        do not display base modifications within insertions
                --no-output-del             skip deletion sequences after -NUM
                --no-output-ends            remove ^MQUAL and $ markup
                --reverse-del               use # for deletions on the reverse strand
                -a                          output all positions
                --input-fmt-option OPT[=VAL]  an input format option
                --reference FILE            the reference FASTA
                --verbosity N               set the level of verbosity
            `,
            values: #{
                "--bam-list": "files", "-b": "files",
                "--fasta-ref": k("fasta"), "-f": k("fasta"), "--reference": k("fasta"),
                "--exclude-RG": "files", "-G": "files",
                "--positions": k("bed"), "-l": k("bed"),
                "--region": k("regions"), "-r": k("regions"),
                "--output": "files", "-o": "files",
            },
            args: [sam],
        },
        "dict" => #{
            opts: `
                -a, --assembly STR     assembly name
                -H, --no-header        do not print the @HD line
                -o, --output FILE      write to FILE
                -s, --species STR      species
                -u, --uri STR          URI
                -A, --alias, --alternative-name  add AN tags by adding or removing 'chr'
                -l, --alt FILE         add AH:* tags to alternate locus sequences
            `,
            values: #{"--output": "files", "-o": "files", "--alt": "files", "-l": "files"},
            args: [k("fasta")],
        },
        "quickcheck" => #{
            opts: `
                -v                     verbose output (repeat for more)
                -q                     suppress warning messages
                -u                     unmapped input (do not require targets in the header)
            `,
            args: [sam],
        },
        "fastq" | "fasta" => {
            let spec = #{
            opts: `
                -0 FILE                write reads with neither READ1 nor READ2 to FILE
                -1 FILE                write READ1 reads to FILE
                -2 FILE                write READ2 reads to FILE
                -o FILE                write reads with READ1 or READ2 to FILE
                -s FILE                write singleton reads to FILE
                -n                     do not append /1 and /2 to the read name
                -N                     always append /1 and /2 to the read name
                -O                     use the quality values from OQ tags
                -t                     copy RG, BC and QT tags to the header line
                -T TAGLIST             copy arbitrary tags to the header line
                -v N                   default quality for missing values
                -f, --require-flags FLAG  only reads with all the FLAGs present
                -F, --excl-flags, --exclude-flags FLAG  only reads with none of the FLAGs present
                -G FLAG                exclude reads with all of the FLAGs present
                -i                     add Illumina Casava 1.8 format entry to the header
                -c N                   compression level
                -d, --tag TAG[:VAL]    only reads with tag TAG, optionally with value VAL
                -D, --tag-file STR:FILE  only reads with tag STR whose value is listed in FILE
                --rf, --incl-flags, --include-flags FLAG  only reads with some of the FLAGs present
                --i1 FILE              write the first index reads to FILE
                --i2 FILE              write the second index reads to FILE
                --barcode-tag TAG      the barcode tag
                --quality-tag TAG      the barcode quality tag
                --index-format STR     how to parse the barcode and quality tags
            ` + st_opts(["in", "ref", "thr", "verb"]),
            values: st_values() + #{"-0": "files", "-1": "files", "-2": "files", "-o": "files", "-s": "files",
                "--i1": "files", "--i2": "files"},
            args: [sam],
            };
            if sub == "fasta" {
                // samtools fasta has no quality-related or index-read options.
                spec.opts = without(spec.opts, ["-O ", "-v ", "-i ", "-c ", "--i1 ", "--i2 ", "--barcode-tag ", "--quality-tag ", "--index-format "]);
            }
            spec
        },
        "bedcov" => #{
            opts: `
                -Q, --min-MQ N         mapping quality threshold
                -X                     use customized index files
                -g FLAGS               remove these flags from the default filter-out list
                -G FLAGS               add these flags to the filter-out list
                -j                     do not include deletions in the coverage
                -d N                   print the number of bases with depth at least N
                --max-depth N          maximum depth used in the mpileup algorithm
                -c                     add a column with the read count
                -H                     print a header line with the column information
            ` + st_opts(["in", "ref", "verb"]),
            values: st_values() + #{"-Q": "none", "--min-MQ": "none", "-g": "none", "-G": "none", "-d": "none", "--max-depth": "none"},
            args: [k("bed"), k("sam")],
        },
        "fqidx" => #{
            opts: `
                -o, --output FILE          write FASTQ to FILE
                -n, --length N             length of the FASTQ sequence lines
                -c, --continue             continue after trying to retrieve a missing region
                -r, --region-file FILE     file of regions, one chr:from-to per line
                -i, --reverse-complement   reverse complement the sequences
                --mark-strand TYPE         add a strand indicator to the sequence name
                --fai-idx FILE             name of the index file
                --gzi-idx FILE             name of the compressed file index
            ` + st_opts(["outopt", "thr", "wi"]),
            values: #{
                "--output": "files", "--length": "none", "--region-file": "files", "--fai-idx": "files",
                "--gzi-idx": "files", "--output-fmt-option": "none", "--threads": "none", "-@": "none",
                "--mark-strand": ["rc", "no", "sign", "custom,"],
            },
            args: [k("fastq"), k("regions")],
        },
        "calmd" => #{
            opts: `
                -e      change identical bases to '='
                -u      uncompressed BAM output
                -b      compressed BAM output
                -S      ignored (the format is detected)
                -A      modify the quality string
                -Q      quiet mode
                -r      compute the BQ tag (without -A) or cap baseQ by BAQ (with -A)
                -E      extended BAQ for better sensitivity but lower specificity
                --no-PG do not add a PG line
            ` + st_opts(["in", "outlong", "outopt", "ref", "thr", "verb"]),
            values: st_values(),
            args: [sam, k("fasta")],
        },
        "fixmate" => #{
            opts: `
                -r                remove unmapped reads and secondary alignments
                -p                disable the FR proper pair check
                -c                add the template CIGAR ct tag
                -m                add the mate score tag
                -u                uncompressed output
                -z, --sanitize FLAG[,FLAG]  sanitize alignment fields
                -M                fix base modification tags (MM/ML/MN)
                --no-PG           do not add a PG line
            ` + st_opts(["in", "out", "outopt", "ref", "thr", "verb"]),
            values: st_values() + #{"--sanitize": "none", "-z": "none"},
            args: [sam, sam],
        },
        "reheader" => #{
            opts: `
                -P, --no-PG        do not add a PG line
                -i, --in-place     modify the CRAM file directly, if possible
                -c, --command CMD  pass the header in SAM format to the program CMD
            `,
            values: #{"--command": "none", "-c": "none"},
            args: [k("sam_header"), sam],
        },
        "addreplacerg" => #{
            opts: `
                -m MODE          the mode: overwrite_all or orphan_only
                -o FILE          write the output to FILE
                -r STRING        @RG line text
                -R STRING        ID of an @RG line of the existing header to use
                -u               uncompressed output
                -w               overwrite an existing @RG line
                --no-PG          do not add a PG line
                --input-fmt FORMAT[,OPT[=VAL]]  the input format
            ` + st_opts(["in", "out", "outopt", "ref", "thr", "wi", "verb"]),
            values: st_values() + #{
                "-m": ["overwrite_all", "orphan_only"], "-o": "files", "-r": "none", "-R": "none",
                "--input-fmt": ["SAM", "BAM", "CRAM"],
            },
            args: [sam],
        },
        "markdup" => #{
            opts: `
                -r                  remove duplicate reads
                -l N                maximum read length
                -S                  mark supplementary alignments of duplicates as duplicates (slower)
                -s                  report stats
                -f NAME             write the stats to file NAME (implies -s)
                --json              write the stats as JSON (implies -s)
                -T PREFIX           write temporary files to PREFIX.samtools.nnnn.nnnn.tmp
                -d N                optical distance (marks with the dt tag)
                -c                  clear previous duplicate settings and tags
                -m, --mode TYPE     the duplicate decision method for paired reads (t or s)
                -u                  uncompressed output
                --include-fails     include reads that failed the quality check
                --no-PG             do not add a PG line
                --no-multi-dup      check less for duplicates of duplicates
                --read-coords STR   regex for the coordinates in the read name
                --coords-order STR  order of the regex elements
                --barcode-tag STR   a barcode tag that duplicates must match
                --barcode-name      use the UMI or barcode of the read name (its eighth colon-delimited part)
                --barcode-rgx STR   regex for the barcode in the read name
                --use-read-groups   use the read group tags in duplicate matching
                -t                  mark primary duplicates with the name of the original in a 'do' tag
                --duplicate-count   record the duplication count of the original in a 'dc' tag
            ` + st_opts(["in", "out", "outopt", "ref", "thr", "wi", "verb"]),
            values: st_values() + #{
                "-f": "files", "-T": "none", "-l": "none", "-d": "none", "--mode": [
                    #{value: "t", desc: "positions from the template start and end"},
                    #{value: "s", desc: "positions from the sequence start"},
                ],
                "-m": [
                    #{value: "t", desc: "positions from the template start and end"},
                    #{value: "s", desc: "positions from the sequence start"},
                ],
                "--read-coords": "none", "--coords-order": "none", "--barcode-tag": "none",
                "--barcode-rgx": "none",
            },
            args: [sam, sam],
        },
        "ampliconclip" => #{
            opts: `
                -b FILE               BED file of the regions (such as primers) to remove
                -o FILE               write the output to FILE
                -f FILE               write the stats to FILE
                -u                    uncompressed output
                --soft-clip           soft clip the primers from the reads (the default)
                --hard-clip           hard clip the primers from the reads
                --both-ends           clip on both the 5' and the 3' ends
                --strand              use the strand of the BED file to match the read direction
                --clipped             only output clipped reads
                --fail                mark unclipped, mapped reads as QCFAIL
                --filter-len N        do not output reads of N bases or shorter
                --fail-len N          mark reads of N bases or shorter as QCFAIL
                --unmap-len N         unmap reads of N bases or shorter
                --no-excluded         do not write the excluded reads (unmapped or QCFAIL)
                --rejects-file FILE   write the filtered reads to FILE
                --primer-counts FILE  write the read counts per BED entry to FILE (bedGraph)
                --original            add an OA tag with the original data to clipped entries
                --keep-tag            keep the old NM and MD tags of clipped entries
                --tolerance N         match a region within N bases
                --no-PG               do not add a PG line
            ` + st_opts(["in", "out", "outopt", "ref", "thr", "verb"]),
            values: st_values() + #{
                "-b": k("bed"), "-o": "files", "-f": "files", "--rejects-file": "files",
                "--primer-counts": "files", "--filter-len": "none", "--fail-len": "none",
                "--unmap-len": "none", "--tolerance": "none",
            },
            args: [sam],
        },
        "collate" => #{
            opts: `
                -O                output to standard output
                -o FILE           output file name (the prefix is used if not set)
                -u                uncompressed BAM output
                -f                fast (only primary alignments)
                -r N              working reads stored (with -f)
                -l N              compression level
                -n N              number of temporary files
                -T PREFIX         write temporary files to PREFIX.nnnn.bam
                --no-PG           do not add a PG line
            ` + st_opts(["in", "outlong", "outopt", "ref", "thr", "verb"]),
            values: st_values() + #{"-o": "files", "-r": "none", "-l": "none", "-n": "none", "-T": "none"},
            args: [sam],
        },
        "cat" => #{
            opts: `
                -b FILE      list of the input BAM or CRAM files, one per line
                -h FILE      copy the header from FILE
                -o FILE      output BAM or CRAM
                --no-PG      do not add a PG line
                -r REG       (CRAM) filter to the region REG
                -p N/M       (CRAM) part N of M
                -f           (CRAM) fast mode: do not filter containers to exactly match the region
                -q           (CRAM) query the total number of indexed containers
            ` + st_opts(["outopt", "verb"]),
            values: #{
                "-b": "files", "-h": k("sam"), "-o": "files", "-r": "none", "-p": "none",
                "--output-fmt-option": "none", "--verbosity": "none",
            },
            args: [sam],
        },
        "consensus" => #{
            opts: `
                -r, --region REG          limit the query to REG (requires an index)
                -f, --format FMT          the output format
                -l, --line-len N          wrap FASTA or FASTQ at line length N
                -o, --output FILE         write the consensus to FILE
                -m, --mode STR            the consensus mode
                -a                        output all bases (start and end of the reference)
                --rf, --incl-flags STR|INT  only include reads with any of these flag bits set
                --ff, --excl-flags STR|INT  exclude reads with any of these flag bits set
                --min-MQ N                exclude reads with mapping quality below N
                --min-BQ N                exclude reads with base quality below N
                --show-del yes/no         whether to show deletions as "*"
                --show-ins yes/no         whether to show insertions
                --mark-ins                add '+' before every inserted base or quality
                -A, --ambig               enable IUPAC ambiguity codes
                -d, --min-depth N         minimum depth
                -Z, --block-size N        size of a chromosome block (bp) when threading
                --ref-qual N              QUAL to use for reference bases
                -q, --use-qual, --no-use-qual  (simple mode) use quality values in the calculation
                -c, --call-fract FLOAT    (simple mode) portion of the bases that must agree
                -H, --het-fract FLOAT     (simple mode) minimum fraction of the 2nd most common base to the most common
                -C, --cutoff N            (Bayesian mode) consensus cutoff quality
                --adj-qual, --no-adj-qual  (Bayesian mode) modify the quality with local minima
                --use-MQ, --no-use-MQ     (Bayesian mode) use the mapping quality in the calculation
                --adj-MQ, --no-adj-MQ     (Bayesian mode) modify the mapping quality by the local NM
                --NM-halo N               (Bayesian mode) size of the window for the NM count in --adj-MQ
                --scale-MQ FLOAT          (Bayesian mode) scale the mapping quality by FLOAT
                --low-MQ N                (Bayesian mode) cap the minimum mapping quality
                --high-MQ N               (Bayesian mode) cap the maximum mapping quality
                --P-het FLOAT             (Bayesian mode) probability of a heterozygous site
                --P-indel FLOAT           (Bayesian mode) probability of an indel site
                --het-scale FLOAT         (Bayesian mode) heterozygous SNP probability multiplier
                -p, --homopoly-fix        (Bayesian mode) spread low-quality bases to both ends of homopolymers
                --homopoly-score FLOAT    (Bayesian mode) quality fraction adjustment for -p
                -t, --qual-calibration FILE  (Bayesian mode) load a quality calibration file
                -X, --config STR          use a pre-defined configuration set
            ` + st_opts(["in", "refT", "thr", "verb"]),
            values: st_values() + #{
                "--region": k("regions"), "-r": k("regions"),
                "--format": ["FASTA", "FASTQ", "PILEUP"], "-f": ["FASTA", "FASTQ", "PILEUP"],
                "--mode": ["simple", "bayesian"], "-m": ["simple", "bayesian"],
                "--output": "files", "-o": "files",
                "--show-del": ["yes", "no"], "--show-ins": ["yes", "no"],
                "--qual-calibration": "files", "-t": "files",
                "--config": ["hiseq", "hifi", "r10.4_sup", "r10.4_dup", "ultima"],
                "-X": ["hiseq", "hifi", "r10.4_sup", "r10.4_dup", "ultima"],
                "--line-len": "none", "--incl-flags": "none", "--rf": "none", "--excl-flags": "none",
                "--ff": "none", "--min-MQ": "none", "--min-BQ": "none", "--min-depth": "none", "-d": "none",
                "--block-size": "none", "-Z": "none", "--ref-qual": "none", "--call-fract": "none", "-c": "none",
                "--het-fract": "none", "-H": "none", "--cutoff": "none", "-C": "none", "--NM-halo": "none",
                "--scale-MQ": "none", "--low-MQ": "none", "--high-MQ": "none", "--P-het": "none",
                "--P-indel": "none", "--het-scale": "none", "--homopoly-score": "none",
            },
            args: [sam],
        },
        "split" => #{
            opts: `
                -f STRING          output file name format string
                -u FILE            put the left-over reads in FILE
                -h FILE            override the header with FILE (for the -u file only)
                -d TAG             split by the value of TAG (a string)
                -p N               zero-pad the numbers in file names to N digits
                -M, --max-split N  limit the number of output files from -d to N
                -v                 verbose output
                --no-PG            do not add a PG line
            ` + st_opts(["in", "outlong", "outopt", "ref", "thr", "wi", "verb"]),
            values: st_values() + #{
                "-f": "none", "-u": "files", "-h": k("sam"), "-d": "none", "-p": "none",
                "--max-split": "none", "-M": "none",
            },
            args: [sam],
        },
        "import" => #{
            opts: `
                -s FILE            paired-end data from a single FILE
                -0 FILE            single-end data from FILE
                -1 FILE            read 1 from FILE
                -2 FILE            read 2 from FILE
                --i1 FILE          index 1 from FILE
                --i2 FILE          index 2 from FILE
                -i                 parse the CASAVA identifier
                --barcode-tag TAG  the tag for the barcode sequences
                --quality-tag TAG  the tag for the barcode qualities
                -N, --name2        use the 2nd field as the read name (SRA format)
                -r STRING          build up a complete @RG line
                -R STRING          add a simple RG line "@RG\tID:STRING"
                -T TAGLIST         parse tags in SAM format ('*' for all)
                -o FILE            write to FILE instead of standard output
                -u                 uncompressed output
                --order TAG        store the Nth record count in TAG
                --no-PG            do not add a PG line
            ` + st_opts(["in", "out", "outopt", "thr"]),
            values: st_values() + #{
                "-s": k("fastq"), "-0": k("fastq"), "-1": k("fastq"), "-2": k("fastq"),
                "--i1": k("fastq"), "--i2": k("fastq"), "-o": "files", "--barcode-tag": "none",
                "--quality-tag": "none", "-r": "none", "-R": "none", "-T": "none", "--order": "none",
            },
            args: [k("fastq")],
        },
        "reference" => #{
            opts: `
                -@ N          number of additional threads to use
                -r REGION     the region to output
                -e            use = for bases that match the reference
                -q            use quiet mode
                -o FILE       write the output to FILE
            `,
            values: #{"-@": "none", "-r": "none", "-o": "files"},
            args: [k("bam")],
        },
        "reset" => #{
            opts: `
                -o FILE               write the output to FILE
                -x, --remove-tag STR  aux tags to remove
                --keep-tag STR        aux tags to keep (like -x ^STR)
                --reject-PG ID        remove the PG line with this ID and the ones after it
                --no-RG               do not keep the RG lines
                --no-PG               do not add a PG entry for the reset operation
                --dupflag             keep the duplicate flag
            ` + st_opts(["out", "thr"]),
            values: #{
                "-o": "files", "--remove-tag": "none", "-x": "none", "--keep-tag": "none",
                "--reject-PG": "none", "--output-fmt": ["SAM", "BAM", "CRAM"], "-O": ["SAM", "BAM", "CRAM"],
                "--threads": "none", "-@": "none",
            },
            args: [sam],
        },
        "phase" => #{
            opts: `
                -k N              block length
                -b STR            prefix of the BAMs to output
                -q N              minimum het phred-LOD
                -Q, --min-BQ N    minimum base quality in het calling
                -D N              maximum read depth
                -F                do not attempt to fix chimeras
                -A                drop reads with ambiguous phase
                --no-PG           do not add a PG line
            ` + st_opts(["in", "outlong", "outopt", "ref", "verb"]),
            values: st_values() + #{"-k": "none", "-b": "none", "-q": "none", "--min-BQ": "none", "-Q": "none", "-D": "none"},
            args: [sam],
        },
        "ampliconstats" => #{
            opts: `
                -f, --required-flag STR|INT   only reads with all of the flags present
                -F, --filter-flag STR|INT     only reads with none of the flags present
                -a, --max-amplicons N         the maximum number of amplicons permitted
                -l, --max-amplicon-length N   the maximum length of an amplicon
                -d, --min-depth N[,N]...      minimum base depth(s) to consider a position covered
                -m, --pos-margin N            margin of error for matching primer positions
                -o, --output FILE             write the output to FILE
                -s, --use-sample-name         use the sample name of the first @RG header line
                -t, --tlen-adjust N           add or subtract from TLEN (when clipping without fixmate)
                -b, --tcoord-bin N            bin template start and end positions into multiples of N
                -c, --tcoord-min-count N      minimum template start and end frequency to record
                -D, --depth-bin FRACTION      merge FDP values within +/- FRACTION
                -S, --single-ref              force the single-reference (<=1.12) output format
                -I, --input-fmt FORMAT[,OPT[=VAL]]  the input format
            ` + st_opts(["in", "ref", "thr"]),
            values: st_values() + #{
                "-f": "none", "--required-flag": "none", "-F": "none", "--filter-flag": "none",
                "-a": "none", "--max-amplicons": "none", "-l": "none", "--max-amplicon-length": "none",
                "-d": "none", "--min-depth": "none", "-m": "none", "--pos-margin": "none",
                "-o": "files", "--output": "files", "-t": "none", "--tlen-adjust": "none",
                "-b": "none", "--tcoord-bin": "none", "-c": "none", "--tcoord-min-count": "none",
                "-D": "none", "--depth-bin": "none", "-I": ["SAM", "BAM", "CRAM"], "--input-fmt": ["SAM", "BAM", "CRAM"],
            },
            args: [k("bed"), k("sam")],
        },
        "checksum" => #{
            opts: `
                -F, --exclude-flags FLAG   filter if any FLAGs are present
                -f, --require-flags FLAG   filter unless all FLAGs are present
                -b, --flag-mask FLAG       BAM FLAGs to use in the checksums
                -c, --no-rev-comp          do not reverse-complement the sequences
                -t, --tags STR[,STR]       tags to checksum
                -O, --in-order             use order-specific checksumming
                -P, --check-pos            also checksum CHR and POS
                -C, --check-cigar          also checksum MAPQ and CIGAR
                -M, --check_mate           also checksum PNEXT, RNEXT and TLEN
                -z, --sanitize FLAGS       sanity-check and fix records
                -N, --count N              stop after N records
                -o, --output FILE          write the report to FILE
                -q, --show-qc              also show the QC pass and fail lines
                -v, --verbose              show the lines with 0 counts
                -a, --all                  check everything (-PCMOc -b 0xfff -f0 -F0 -z all,cigarx)
                -T, --tabs                 tab-delimited output
                -m, --merge FILE           merge the checksum output files
                -B, --bamseqchksum         report in bamseqchksum format
            ` + st_opts(["in", "thr"]),
            values: st_values() + #{
                "-F": "none", "--exclude-flags": "none", "-f": "none", "--require-flags": "none",
                "-b": "none", "--flag-mask": "none", "-t": "none", "--tags": "none", "-z": "none",
                "--sanitize": "none", "-N": "none", "--count": "none", "-o": "files", "--output": "files",
                "-m": "files", "--merge": "files",
            },
            args: [sam],
        },
        "head" => #{
            opts: `
                -h, --headers N     display N header lines
                -n, --records N     display N alignment record lines
                -T, --reference FILE  the reference FASTA
            ` + st_opts(["in", "thr", "verb"]),
            values: st_values() + #{"--headers": "none", "-h": "none", "--records": "none", "-n": "none"},
            args: [sam],
        },
        "tview" => #{
            opts: `
                -d display      output as (H)tml, (C)urses or (T)ext
                -X              include a customized index file
                -p chr:pos      go directly to this position
                -s STR          display only reads from this sample or group
                -w N            display width (with -d T only)
                -i              hide inserts
            ` + st_opts(["in", "ref", "verb"]),
            values: st_values() + #{
                "-d": [#{value: "H", desc: "html"}, #{value: "C", desc: "curses"}, #{value: "T", desc: "text"}],
                "-p": k("regions"), "-s": "none", "-w": "none",
            },
            args: [k("bam"), k("fasta")],
        },
        "depad" => #{
            opts: `
                -s               output SAM (default: BAM)
                -S               input is SAM (default: BAM)
                -u               uncompressed BAM output (not with -s)
                -1               fast compression BAM output (not with -s)
                -T, --reference FILE  the padded reference sequence FASTA
                -o FILE          write the output to FILE
                --no-PG          do not add a PG line
            ` + st_opts(["in", "outlong", "outopt", "wi", "verb"]),
            values: st_values() + #{"-o": "files", "-T": k("fasta")},
            args: [sam],
        },
        "samples" => #{
            opts: `
                -h              add the column header before printing the results
                -i              test if the file is indexed
                -T TAG          the sample tag name of the @RG line
                -o FILE         write the output to FILE
                -f FILE         add an indexed FASTA file to the collection of references (repeatable)
                -F FILE         read a file of paths to indexed FASTA files, one per line
                -X              use a custom index file
            `,
            values: #{"-T": "none", "-o": "files", "-f": k("fasta"), "-F": "files"},
            args: [sam],
        },
        "targetcut" => #{
            opts: `
                -Q N              minimum quality
                -i N              indel penalty
                -0 N              em0 parameter
                -1 N              em1 parameter
                -2 N              em2 parameter
                -f, --reference FILE  the reference FASTA
            ` + st_opts(["in", "verb"]),
            values: st_values() + #{"-Q": "none", "-i": "none", "-0": "none", "-1": "none", "-2": "none", "-f": k("fasta")},
            args: [sam],
        },
        "cram-size" | "cram_size" => #{
            opts: `
                -v          verbose output
                -e          also list the embedded reference
                -o FILE     write the output to FILE
            `,
            values: #{"-o": "files"},
            args: [k("bam")],
        },
        _ => #{args: [sam]},
    }
}

// ---- htslib: tabix, bgzip, htsfile ----

fn tabix() {
    #{
        opts: `
            -0, --zero-based           coordinates are zero-based
            -b, --begin N              column for the region start
            -c, --comment CHAR         skip comment lines starting with CHAR
            -C, --csi                  generate a CSI index
            -e, --end N                column for the region end
            -f, --force                overwrite an existing index
            -m, --min-shift N          minimal interval size for CSI indices, 2^N
            -p, --preset STR           the format preset
            -s, --sequence N           column for the sequence names
            -S, --skip-lines N         skip the first N lines
            -h, --print-header         print also the header lines
            -H, --only-header          print only the header lines
            -l, --list-chroms          list chromosome names
            -r, --reheader FILE        replace the header with the content of FILE
            -R, --regions FILE         restrict to the regions listed in FILE
            -T, --targets FILE         like -R, but streams instead of jumping by the index
            -D                         do not download the index file
            --cache N                  cache size in megabytes
            --separate-regions         separate the output by region
            --verbosity N              set the verbosity
            -@, --threads N            number of additional threads to use
        `,
        values: #{
            "--preset": [
                #{value: "gff", desc: "GFF"}, #{value: "bed", desc: "BED"}, #{value: "sam", desc: "SAM"},
                #{value: "vcf", desc: "VCF"}, #{value: "gaf", desc: "GAF"},
            ],
            "--reheader": "files",
            "--regions": k("bed"),
            "--targets": k("bed"),
            "--begin": "none", "--end": "none", "--comment": "none", "--min-shift": "none",
            "--sequence": "none", "--skip-lines": "none", "--cache": "none", "--verbosity": "none",
            "--threads": "none",
        },
        args: [k("bgzipped"), k("tabix_regions")],
    }
}

fn bgzip() {
    #{
        opts: `
            -b, --offset N             decompress at this virtual file pointer
            -c, --stdout               write to standard output, keep the input files
            -d, --decompress           decompress
            -f, --force                overwrite files without asking
            -g, --rebgzip              use an index file to bgzip a file
            -h, --help                 show help
            -i, --index                compress and create a BGZF index
            -I, --index-name FILE      name of the BGZF index file
            -k, --keep                 do not delete the input files
            -l, --compress-level N     compression level, from 0 to 9 (-1 for the default)
            -o, --output FILE          write to FILE, keep the input files
            -r, --reindex              (re)index a compressed file
            -s, --size N               decompress N bytes
            -t, --test                 test the integrity of a compressed file
            --binary                   do not align blocks with text lines
            -@, --threads N            number of compression threads
        `,
        values: #{"--index-name": "files", "--output": "files", "--offset": "none", "--size": "none",
                  "--compress-level": "none", "--threads": "none"},
    }
}

fn htsfile() {
    #{
        opts: `
            -c, --view          write the textual form of the files to standard output
            -C, --copy          copy the exact contents of a file to another
            -h, --header-only   display only headers in view mode
            -H, --no-header     suppress the header in view mode
            -v, --verbose       increase the verbosity of warnings and diagnostics
        `,
    }
}

// ---- bedtools ----

fn bedtools() {
    #{
        opts: `
            --help         show help
            --version      show the version
            --contact      where to send feature requests and bugs
            --cram-ref FILE  reference used by a CRAM input
        `,
        commands: `
            intersect      find overlapping intervals in various ways
            window         find overlapping intervals within a window around an interval
            closest        find the closest, potentially non-overlapping interval
            coverage       compute the coverage over defined intervals
            map            apply a function to a column for each overlapping interval
            genomecov      compute the coverage over an entire genome
            merge          combine overlapping or nearby intervals into a single interval
            cluster        cluster (but do not merge) overlapping or nearby intervals
            complement     extract intervals not represented by an interval file
            shift          adjust the position of intervals
            subtract       remove intervals based on overlaps between two files
            slop           adjust the size of intervals
            flank          create new intervals from the flanks of existing intervals
            sort           order the intervals in a file
            random         generate random intervals in a genome
            shuffle        randomly redistribute intervals in a genome
            sample         sample random records from a file
            spacing        report the gap lengths between intervals in a file
            annotate       annotate coverage of features from multiple files
            multiinter     identify common intervals among multiple interval files
            unionbedg      combine coverage intervals from multiple bedGraph files
            pairtobed      find pairs that overlap intervals in various ways
            pairtopair     find pairs that overlap other pairs in various ways
            bamtobed       convert BAM alignments to BED and other formats
            bedtobam       convert intervals to BAM records
            bamtofastq     convert BAM records to FASTQ records
            bedpetobam     convert BEDPE intervals to BAM records
            bed12tobed6    break BED12 intervals into BED6 intervals
            getfasta       use intervals to extract sequences from a FASTA file
            maskfasta      use intervals to mask sequences from a FASTA file
            nuc            profile the nucleotide content of intervals in a FASTA file
            multicov       count coverage from multiple BAMs at intervals
            tag            tag BAM alignments based on overlaps with interval files
            jaccard        calculate the Jaccard statistic between two sets of intervals
            reldist        calculate the distribution of relative distances between two files
            fisher         calculate the Fisher statistic between two feature files
            overlap        compute the amount of overlap from two intervals
            igv            create an IGV snapshot batch script
            links          create an HTML page of links to UCSC locations
            makewindows    make interval windows across a genome
            groupby        group by common columns and summarize the others
            expand         replicate lines based on lists of values in columns
            split          split a file into multiple files
            summary        statistical summary of intervals in a file
        `,
        sub_spec: "@extra-complete/bio/hts:bedtools",
        single_dash: true,
        values: #{"--cram-ref": k("fasta")},
    }
}

// The options that the commands that compare A with B share.
fn bedtools_overlap() {
    `
        -s                  require the same strand
        -S                  require the opposite strand
        -f FRACTION         minimum overlap required, as a fraction of A
        -F FRACTION         minimum overlap required, as a fraction of B
        -r                  require the overlap to be reciprocal for A and B
        -e                  require the minimum fraction for A or for B
        -split              treat split BAM or BED12 entries as distinct intervals
        -g FILE             genome file, for a consistent chromosome order
        -nonamecheck        do not fail if chromosome naming conventions differ
        -sorted             use the chromsweep algorithm for sorted input
        -bed                write BED output for BAM input
        -header             print the header from the A file first
        -nobuf              disable buffered output
        -iobuf SIZE         memory to use for the input buffer
    `
}

// The overlap options of `bedtools_overlap` that do not include the I/O ones.
fn bedtools_overlap_noio() {
    `
        -s                  require the same strand
        -S                  require the opposite strand
        -f FRACTION         minimum overlap required, as a fraction of A
        -F FRACTION         minimum overlap required, as a fraction of B
        -r                  require the overlap to be reciprocal for A and B
        -e                  require the minimum fraction for A or for B
        -split              treat split BAM or BED12 entries as distinct intervals
        -g FILE             genome file, for a consistent chromosome order
        -nonamecheck        do not fail if chromosome naming conventions differ
    `
}

fn bedtools_values() {
    let v = #{
        "-a": k("intervals"), "-b": k("intervals"), "-i": k("intervals"), "-abam": k("bam"),
        "-g": k("genome"), "-fi": k("fasta"), "-fo": "files", "-bed": k("intervals"),
        "-excl": k("intervals"), "-incl": k("intervals"), "-faidx": "files",
    };
    // Options with a number, a text or a column list.
    for o in ["-fq", "-fq2", "-files", "-bams", "-labels", "-cols", "-base", "-org", "-db", "-sess", "-path",
              "-f", "-F", "-iobuf", "-names", "-c", "-o", "-d", "-w", "-l", "-r", "-n", "-s", "-p", "-m", "-k",
              "-mc", "-max", "-scale", "-fs", "-tag", "-color", "-pattern", "-prec", "-delim", "-grp", "-opCols",
              "-ops", "-seed", "-maxTries", "-trackopts", "-e"] {
        v[o] = "none";
    }
    v
}

fn bedtools_sub(sub) {
    let ab = "-a FILE  the A file (BED, GFF, VCF or BAM)\n-b FILE...  the B file(s) (BED, GFF, VCF or BAM)\n";
    let iv = k("intervals");
    let spec = switch sub {
        "intersect" => #{
            opts: ab + `
                -wa                 write the original entry in A for each overlap
                -wb                 write the original entry in B for each overlap
                -loj                left outer join: report a null B feature if there is no overlap
                -wo                 write A and B and the number of overlapping bases
                -wao                like -wo, but also A features without overlap
                -u                  write the original A entry once if any overlap is found
                -c                  report the number of overlaps with B for each A entry
                -C                  report the number of overlaps with each B file separately
                -v                  only report the entries in A that have no overlap with B
                -ubam               write uncompressed BAM output
                -names NAME...      an alias for each database
                -filenames          show the complete filename for each database
                -sortout            sort the output database hits
            ` + bedtools_overlap(),
        },
        "window" => #{
            opts: ab + `
                -abam FILE          the A file is BAM (output is BAM too)
                -ubam               write uncompressed BAM output
                -w N                base pairs added upstream and downstream of each entry
                -l N                base pairs added upstream
                -r N                base pairs added downstream
                -sw                 define -l and -r based on strand
                -sm                 only report hits in B on the same strand
                -Sm                 only report hits in B on the opposite strand
                -u                  write the original A entry once if any overlap is found
                -c                  report the number of overlaps with B for each A entry
                -v                  only report the entries in A that have no overlap with B
                -bed                write BED output for BAM input
                -header             print the header from the A file first
            `,
        },
        "closest" => #{
            opts: ab + `
                -d                  also report the distance to the closest feature in B
                -D MODE             like -d, with the distance signed (ref, a or b)
                -io                 ignore features in B that overlap A
                -iu                 ignore features in B that are upstream of A
                -id                 ignore features in B that are downstream of A
                -fu                 choose first from features in B upstream of A
                -fd                 choose first from features in B downstream of A
                -t MODE             how ties are handled
                -mdb MODE           how multiple databases are resolved
                -k N                report the N closest hits
                -N                  require that the query and the closest hit have different names
                -names NAME...      an alias for each database
                -filenames          show the complete filename for each database
                -sortout            sort the output database hits
            ` + bedtools_overlap(),
            values: #{"-D": ["ref", "a", "b"], "-t": ["all", "first", "last"], "-mdb": ["each", "all"]},
        },
        "coverage" => #{
            opts: ab + `
                -hist               report a histogram of coverage for each feature in A
                -d                  report the depth at each position in each A feature
                -counts             only report the count of overlaps
                -mean               report the mean depth of all positions in each A feature
            ` + bedtools_overlap(),
        },
        "map" => #{
            opts: ab + `
                -c COLS             columns from B to map onto the intervals in A
                -o OPS              the operation to apply to -c
                -delim STR          delimiter for the collapse operations
                -prec N             decimal precision of the output
            ` + bedtools_overlap(),
            values: #{"-o": ["sum", "count", "count_distinct", "min", "max", "absmin", "absmax", "mean", "median",
                             "mode", "antimode", "stdev", "sstdev", "collapse", "distinct", "distinct_sort_num",
                             "distinct_sort_num_desc", "concat", "freq_asc", "freq_desc", "first", "last"]},
        },
        "subtract" => #{
            opts: ab + `
                -A                  remove the entire feature if there is any overlap
                -N                  like -A, but with -f the amount is the sum of overlaps
                -wb                 write the original entry in B for each overlap
                -wo                 write A and B and the number of overlapping bases
            ` + bedtools_overlap(),
        },
        "genomecov" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -ibam FILE          the input file is BAM
                -g FILE             genome file, to define chromosome lengths
                -d                  report the depth at each genome position (1-based)
                -dz                 report the depth at each genome position (0-based)
                -bg                 report depth in bedGraph format
                -bga                report depth in bedGraph format, including zero-depth regions
                -split              treat split BAM or BED12 entries as distinct intervals
                -ignoreD            ignore local deletions in BAM entries
                -strand STRAND      calculate coverage of intervals from a strand
                -pc                 calculate coverage of paired-end fragments
                -fs N               use this fragment size instead of the read length
                -du                 change the strand of the mate read
                -5                  calculate coverage of 5' positions
                -3                  calculate coverage of 3' positions
                -max N              combine all positions with a depth >= N
                -scale FACTOR       scale the coverage by a constant factor
                -trackline          add a UCSC track line definition
                -trackopts STR      additional track line definition parameters
            `,
            values: #{"-ibam": k("bam"), "-strand": ["+", "-"]},
        },
        "merge" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -s                  merge only features on the same strand
                -S STRAND           merge only features on this strand
                -d N                maximum distance between features that are merged
                -c COLS             columns to summarize
                -o OPS              the operations to apply to -c
                -delim STR          delimiter for the collapse operations
                -prec N             decimal precision of the output
                -bed                write BED output for BAM input
                -header             print the header first
                -nobuf              disable buffered output
                -iobuf SIZE         memory to use for the input buffer
            `,
            values: #{"-S": ["+", "-"]},
        },
        "cluster" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -s                  only cluster features on the same strand
                -d N                maximum distance between clustered features
            `,
        },
        "sort" => #{
            opts: `
                -i FILE                the input file (BED, GFF or VCF)
                -sizeA                 sort by feature size, ascending
                -sizeD                 sort by feature size, descending
                -chrThenSizeA          sort by chromosome, then feature size ascending
                -chrThenSizeD          sort by chromosome, then feature size descending
                -chrThenScoreA         sort by chromosome, then score ascending
                -chrThenScoreD         sort by chromosome, then score descending
                -g FILE                sort according to the chromosomes in a genome file
                -faidx FILE            sort according to the chromosomes in a file of names
                -header                print the header first
            `,
        },
        "slop" | "flank" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -g FILE             genome file
                -b N                base pairs in each direction
                -l N                base pairs for the start coordinate
                -r N                base pairs for the end coordinate
                -s                  define -l and -r based on strand
                -pct                define -l and -r as a fraction of the feature's length
                -header             print the header first
            `,
        },
        "shift" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -g FILE             genome file
                -s N                base pairs to shift
                -p N                base pairs to shift the + strand
                -m N                base pairs to shift the - strand
                -pct                define shifts as a fraction of the feature's length
                -header             print the header first
            `,
        },
        "complement" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -g FILE             genome file
                -L                  limit the output to the chromosomes with records in the input
            `,
        },
        "getfasta" => #{
            opts: `
                -fi FILE            the input FASTA file
                -fo FILE            the output file
                -bed FILE           BED, GFF or VCF file of the ranges to extract
                -name               use the name field and coordinates for the FASTA header
                -name+              (deprecated) same as -name
                -nameOnly           use the name field for the FASTA header
                -split              extract and concatenate the blocks of BED12
                -tab                write tab-delimited output
                -bedOut             report the sequences in a tab-delimited BED format
                -s                  force strandedness
                -fullHeader         use the full FASTA header
                -rna                the FASTA is RNA, not DNA
            `,
        },
        "maskfasta" => #{
            opts: `
                -fi FILE            the input FASTA file
                -fo FILE            the output file
                -bed FILE           BED, GFF or VCF file of the ranges to mask
                -soft               soft-mask (lowercase) instead of using N
                -mc CHAR            replace masked bases with this character
                -fullHeader         use the full FASTA header
            `,
        },
        "nuc" => #{
            opts: `
                -fi FILE            the input FASTA file
                -bed FILE           BED, GFF or VCF file of the ranges
                -s                  profile the sequence according to strand
                -seq                print the extracted sequence
                -pattern STR        report the number of times a pattern occurs
                -C                  ignore case when matching -pattern
                -fullHeader         use the full FASTA header
            `,
        },
        "makewindows" => #{
            opts: `
                -g FILE             genome file
                -b FILE             BED file of the regions
                -w N                window size
                -s N                step size
                -n N                number of windows
                -reverse            number windows from the end
                -i TYPE             what to use for the window names
            `,
            values: #{"-i": ["src", "winnum", "srcwinnum"]},
        },
        "bamtobed" => #{
            opts: `
                -i FILE             the input BAM file
                -bedpe              write BEDPE
                -mate1              with -bedpe, the first mate comes first
                -bed12              write BED12 (implies -split)
                -split              report split alignments as separate entries
                -splitD             split alignments based on N and D CIGAR operators
                -ed                 use the BAM edit distance (NM) for the score
                -tag TAG            use another numeric BAM tag for the score
                -color R,G,B        color for BED12
                -cigar              add the CIGAR string as the 7th column
            `,
            values: #{"-i": k("bam")},
        },
        "groupby" => #{
            opts: `
                -i FILE             the input file
                -g, -grp COLS       columns (1-based) for the grouping
                -c, -opCols COLS    columns (1-based) to summarize
                -o, -ops OPS        operations to apply to the columns
                -full               print all the columns of the input
                -inheader           the input has a header line
                -outheader          print a header line in the output
                -header             same as -inheader -outheader
                -ignorecase         group values regardless of case
                -prec N             decimal precision of the output
                -delim STR          delimiter for the collapse operations
            `,
            values: #{"-i": "files", "-o": ["sum", "count", "count_distinct", "min", "max", "absmin", "absmax",
                                            "mean", "median", "mode", "antimode", "stdev", "sstdev", "collapse",
                                            "distinct", "concat", "first", "last"]},
        },
        "shuffle" => #{
            opts: `
                -i FILE             the input file (BED, GFF or VCF)
                -g FILE             genome file
                -excl FILE          coordinates in which features cannot be placed
                -incl FILE          place features only in these coordinates
                -chrom              keep features on the same chromosome
                -seed N             seed for the shuffling
                -f FRACTION         maximum overlap with an -excl feature
                -chromFirst         first choose a chromosome, then a position
                -bedpe              the A file is BEDPE
                -maxTries N         maximum tries to place a feature
                -noOverlapping      do not allow shuffled features to overlap
                -allowBeyondChromEnd  allow features to extend beyond the end of a chromosome
            `,
        },
        "random" => #{
            opts: `
                -g FILE             genome file
                -l N                length of the intervals
                -n N                number of intervals
                -seed N             seed for the shuffling
            `,
        },
        "sample" => #{
            opts: `
                -i FILE             the input file
                -n N                number of records to sample
                -seed N             seed for the shuffling
                -ubam               write uncompressed BAM output
                -s                  require the same strand
                -header             print the header of the input file first
                -bed                write BED output for BAM input
                -nobuf              disable buffered output
                -iobuf SIZE         memory to use for the input buffer
            `,
        },
        "spacing" => #{
            opts: `
                -i FILE             the input file
                -bed                write BED output for BAM input
                -header             print the header of the A file first
                -nobuf              disable buffered output
                -iobuf SIZE         memory to use for the input buffer
            `,
        },
        "annotate" => #{
            opts: `
                -i FILE             the input file
                -files FILE...      the files to annotate with
                -names NAME...      a name for each file
                -counts             report the count of overlapping features in each file
                -both               report the counts followed by the percent coverage
                -s                  require the same strand
                -S                  require the opposite strand
            `,
            values: #{"-files": k("intervals")},
        },
        "multiinter" => #{
            opts: `
                -i FILE...          the files to combine
                -cluster            invoke Ryan Layer's clustering algorithm
                -header             print a header line
                -names NAME...      a name for each file
                -g FILE             genome file, to calculate the empty regions
                -empty              report the empty regions (needs -g)
                -filler TEXT        text for intervals with no value
                -examples           show detailed usage examples
            `,
        },
        "unionbedg" => #{
            opts: `
                -i FILE...          the bedGraph files to combine
                -header             print a header line
                -names NAME...      a name for each file
                -g FILE             genome file, to calculate the empty regions
                -empty              report the empty regions (needs -g)
                -filler TEXT        text for intervals with no value
                -examples           show detailed usage examples
            `,
        },
        "pairtobed" => #{
            opts: `
                -a FILE             the A file (BEDPE)
                -b FILE             the B file (BED, GFF or VCF)
                -abam FILE          the A file is BAM, grouped or sorted by query (replaces -a)
                -ubam               write uncompressed BAM output
                -bedpe              write BEDPE output for BAM input
                -ed                 use the BAM edit distance (NM tag) for the BEDPE score
                -f FRACTION         minimum overlap required, as a fraction of A
                -s                  require the same strand
                -S                  require the opposite strand
                -type TYPE          how overlaps between BEDPE and BED are reported
            `,
            values: #{
                "-type": [
                    #{value: "either", desc: "if either end of A overlaps B"},
                    #{value: "neither", desc: "A if neither end overlaps B"},
                    #{value: "both", desc: "if both ends of A overlap B"},
                    #{value: "xor", desc: "if one and only one end overlaps B"},
                    #{value: "notboth", desc: "if neither end or one and only one overlaps B"},
                    #{value: "ispan", desc: "overlaps between [end1, start2] of A and B"},
                    #{value: "ospan", desc: "overlaps between [start1, end2] of A and B"},
                    #{value: "notispan", desc: "A if [end1, start2] does not overlap B"},
                    #{value: "notospan", desc: "A if [start1, end2] does not overlap B"},
                ],
            },
        },
        "pairtopair" => #{
            opts: `
                -a FILE             the A file (BEDPE)
                -b FILE             the B file (BEDPE)
                -f FRACTION         minimum overlap required, as a fraction of A
                -type TYPE          how overlaps between A and B are reported
                -slop N             base pairs of slop added to each footprint of A
                -ss                 add the slop based on the strand
                -is                 ignore the strands when searching for overlaps
                -rdn                require the hits to have different names
            `,
            values: #{"-type": ["neither", "either", "both", "notboth"]},
        },
        "bedtobam" => #{
            opts: `
                -i FILE             the input file
                -g FILE             genome file
                -mapq N             mapping quality of the BAM records
                -bed12              the BED file is BED12 (the CIGAR is made from the blocks)
                -ubam               write uncompressed BAM output
            `,
        },
        "bamtofastq" => #{
            opts: `
                -i FILE             the input BAM file
                -fq FILE            the FASTQ file
                -fq2 FILE           the FASTQ file for the second end (paired-end data)
                -tags               create the FASTQ from the mate information
            `,
            values: #{"-i": k("bam"), "-fq": "files", "-fq2": "files"},
            args: [k("bam")],
        },
        "bedpetobam" => #{
            opts: `
                -i FILE             the input BEDPE file
                -g FILE             genome file
                -mapq N             mapping quality of the BAM records
                -ubam               write uncompressed BAM output
            `,
        },
        "bed12tobed6" => #{
            opts: `
                -i FILE             the input BED12 file
                -n                  force the score to be the block number
            `,
        },
        "multicov" => #{
            opts: `
                -bams FILE...       the BAM files
                -bed FILE           the BED file
                -split              treat split BAM or BED12 entries as distinct intervals
                -s                  require the same strand
                -S                  require the opposite strand
                -f FRACTION         minimum overlap required, as a fraction of each -bed record
                -r                  require the overlap to be reciprocal
                -q N                minimum mapping quality
                -D                  include duplicate reads
                -F                  include reads that failed the QC
                -p                  only count proper pairs
            `,
            values: #{"-bams": k("bam")},
        },
        "tag" => #{
            opts: `
                -i FILE             the input BAM file
                -files FILE...      the annotation files
                -labels LABEL...    a label for each annotation file
                -s                  require overlaps on the same strand
                -S                  require overlaps on the opposite strand
                -f FRACTION         minimum overlap required, as a fraction of the alignment
                -tag TAG            the tag to use (two characters)
                -names              use the name field of the annotation files to populate the tags
                -scores             use the score field of the annotation files to populate the tags
                -intervals          use the full interval to populate the tags (needs -labels)
            `,
            values: #{"-i": k("bam"), "-files": k("intervals")},
            args: [k("bam")],
        },
        "jaccard" => #{
            opts: ab + `
                -bed                write BED output for BAM input
                -header             print the header of the A file first
                -nobuf              disable buffered output
                -iobuf SIZE         memory to use for the input buffer
                -sorted             use the chromsweep algorithm for sorted input
            ` + bedtools_overlap_noio(),
        },
        "fisher" => #{
            opts: ab + `
                -m                  merge overlapping intervals first
                -bed                write BED output for BAM input
                -header             print the header of the A file first
                -nobuf              disable buffered output
                -iobuf SIZE         memory to use for the input buffer
                -sorted             use the chromsweep algorithm for sorted input
            ` + bedtools_overlap_noio(),
        },
        "reldist" => #{
            opts: ab + `
                -detail             report the relative distance for each interval in A
            `,
        },
        "overlap" => #{
            opts: `
                -i FILE             the input file
                -cols COLS          the columns of start1,end1,start2,end2
            `,
        },
        "igv" => #{
            opts: `
                -i FILE             the input file
                -path DIR           where to write the IGV snapshots
                -sess FILE          an IGV session file to load first
                -sort TYPE          how to sort the BAM in each image
                -clps               collapse the aligned reads
                -name               use the name field for the file name of each image
                -slop N             flanking base pairs on each side of the image
                -img TYPE           the type of the image
            `,
            values: #{
                "-path": "dirs", "-sess": "files", "-sort": ["base", "position", "strand", "quality", "sample", "readGroup"],
                "-img": ["png", "eps", "svg"],
            },
        },
        "links" => #{
            opts: `
                -i FILE             the input file
                -base URL           the browser's base name
                -org NAME           the organism
                -db NAME            the genome build
            `,
        },
        "expand" => #{
            opts: `
                -i FILE             the input file
                -c COLS             the columns to expand
            `,
        },
        "split" => #{
            opts: `
                -i, --input FILE    the BED file
                -n, --number N      the number of files to make
                -p, --prefix STR    the prefix of the output files
                -a, --algorithm ALG the algorithm to split with
            `,
            values: #{
                "--algorithm": [
                    #{value: "size", desc: "about the same number of bases in each file"},
                    #{value: "simple", desc: "about the same number of records in each file"},
                ],
                "-a": ["size", "simple"], "--input": k("bed"),
            },
        },
        "summary" => #{
            opts: `
                -i FILE             the input file (BED, GFF, VCF or BAM)
                -g FILE             genome file
            `,
        },
        _ => #{opts: ab + "-i FILE  the input file\n-g FILE  genome file\n-header  print the header first\n", values: #{}},
    };
    let values = bedtools_values();
    if spec.contains("values") {
        for key in spec.values.keys() {
            values[key] = spec.values[key];
        }
    }
    spec.values = values;
    spec.single_dash = true;
    if !spec.contains("args") {
        spec.args = [iv];
    }
    spec
}

fn spec(cmd) {
    switch cmd {
        "samtools" => samtools(),
        "tabix" => tabix(),
        "bgzip" => bgzip(),
        "htsfile" => htsfile(),
        "bedtools" => bedtools(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "samtools" => samtools_sub(sub),
        "bedtools" => bedtools_sub(sub),
        _ => (),
    }
}
