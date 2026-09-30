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
                --alias                add AN tags with alternative names
            `,
            values: #{"--output": "files", "-o": "files"},
            args: [k("fasta")],
        },
        "quickcheck" => #{
            opts: `
                -v, --verbose          verbose output
                -q, --quiet            do not report failures
            `,
            args: [sam],
        },
        "fastq" | "fasta" => #{
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
                -F, --excl-flags FLAG  only reads with none of the FLAGs present
                -G FLAG                exclude reads with all of the FLAGs present
                -i                     add Illumina Casava 1.8 format entry to the header
                -c N                   compression level
                -@, --threads N        number of additional threads to use
            `,
            values: #{"-0": "files", "-1": "files", "-2": "files", "-o": "files", "-s": "files"},
            args: [sam],
        },
        "bedcov" => #{
            opts: `
                -Q N                   mapping quality threshold
                -X                     use customized index files
                -g FLAGS               remove these flags from the default filter-out list
                -G FLAGS               add these flags to the filter-out list
                -j                     do not include deletions in the coverage
                -d N                   print the number of bases with depth at least N
            `,
            args: [k("bed"), k("sam")],
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

fn bedtools_values() {
    let v = #{
        "-a": k("intervals"), "-b": k("intervals"), "-i": k("intervals"), "-abam": k("bam"),
        "-g": k("genome"), "-fi": k("fasta"), "-fo": "files", "-bed": k("intervals"),
        "-excl": k("intervals"), "-incl": k("intervals"), "-faidx": "files",
    };
    // Options with a number, a text or a column list.
    for o in ["-f", "-F", "-iobuf", "-names", "-c", "-o", "-d", "-w", "-l", "-r", "-n", "-s", "-p", "-m", "-k",
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
