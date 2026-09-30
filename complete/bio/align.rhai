// Mapping and quantification: bwa, bwa-mem2, bowtie2, minimap2, hisat2, STAR,
// kallisto and featureCounts. The option tables come from the tools' own
// `--help` (versions in completion-todo.md).

fn k(name) { "@extra-complete/bio/kinds:" + name }

fn bwa() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: `
            index       index sequences in the FASTA format
            mem         BWA-MEM algorithm
            fastmap     identify super-maximal exact matches
            pemerge     merge overlapping paired ends (experimental)
            aln         gapped/ungapped alignment
            samse       generate alignment (single ended)
            sampe       generate alignment (paired ended)
            bwasw       BWA-SW for long queries (deprecated)
            shm         manage indices in shared memory
            fa2pac      convert FASTA to PAC format
            pac2bwt     generate BWT from PAC
            pac2bwtgen  alternative algorithm for generating BWT
            bwtupdate   update .bwt to the new format
            bwt2sa      generate SA from BWT and Occ
        `,
        sub_spec: "@extra-complete/bio/align:bwa",
    }
}

fn bwa_sub(sub) {
    switch sub {
        "index" => #{
        opts: `
            -a STR  BWT construction algorithm: bwtsw, is or rb2
            -p STR  prefix of the index [same as fasta name]
            -b INT  block size for the bwtsw algorithm (effective with -a bwtsw)
            -6      index files named as <in.fasta>.64.* instead of <in.fasta>.*
        `,
        values: #{
            "-a": ["bwtsw", "is", "rb2"], "-p": "files", "-b": "none",
        },
        args: [k("fasta")],
        },
        "mem" => #{
        opts: `
            -t INT                        number of threads
            -k INT                        minimum seed length
            -w INT                        band width for banded alignment
            -d INT                        off-diagonal X-dropoff
            -r FLOAT                      look for internal seeds inside a seed longer than {-k} * FLOAT
            -y INT                        seed occurrence for the 3rd round seeding
            -c INT                        skip seeds with more than INT occurrences
            -D FLOAT                      drop chains shorter than FLOAT fraction of the longest overlapping chain
            -W INT                        discard a chain if seeded bases shorter than INT
            -m INT                        perform at most INT rounds of mate rescues for each read
            -S                            skip mate rescue
            -P                            skip pairing; mate rescue performed unless -S also in use
            -A INT                        score for a sequence match, which scales options -TdBOELU unless overridden
            -B INT                        penalty for a mismatch
            -O INT[,INT]                  gap open penalties for deletions and insertions
            -E INT[,INT]                  gap extension penalty; a gap of size k cost '{-O} + {-E}*k'
            -L INT[,INT]                  penalty for 5'- and 3'-end clipping
            -U INT                        penalty for an unpaired read pair
            -x STR                        read type
            -p                            smart pairing (ignoring in2.fq)
            -R STR                        read group header line such as '@RG\tID:foo\tSM:bar'
            -H STR/FILE                   insert STR to header if it starts with @; or insert lines in FILE
            -o FILE                       sam file to output results to
            -j                            treat ALT contigs as part of the primary assembly
            -5                            for split alignment, take the alignment with the smallest query (not genomic) coordinate
            -q                            don't modify mapQ of supplementary alignments
            -K INT                        process INT input bases in each batch regardless of nThreads (for reproducibility)
            -v INT                        verbosity level: 1=error, 2=warning, 3=message, 4+=debugging
            -T INT                        minimum score to output
            -h INT[,INT]                  if there are <INT hits with score >80.00% of the max score, output all in XA [5,200] A
            -z FLOAT                      the fraction of the max score to use with -h
            -a                            output all alignments for SE or unpaired PE
            -C                            append FASTA/FASTQ comment to SAM output
            -V                            output the reference FASTA header in the XR tag
            -Y                            use soft clipping for supplementary alignments
            -M                            mark shorter split hits as secondary
            -I FLOAT[,FLOAT[,INT[,INT]]]  specify the mean, standard deviation (10% of the mean if absent), max
            -u                            output XB instead of XA; XB is XA with the alignment score and mapping quality added
        `,
        values: #{
            "-t": "none", "-k": "none", "-w": "none", "-d": "none", "-r": "none", "-y": "none", "-c": "none",
            "-D": "none", "-W": "none", "-m": "none", "-A": "none", "-B": "none", "-O": "none", "-E": "none",
            "-L": "none", "-U": "none", "-x": ["pacbio", "ont2d", "intractg"], "-R": "none", "-H": "files",
            "-o": "files", "-K": "none", "-v": "none", "-T": "none", "-h": "none", "-z": "none", "-I": "none",
        },
        args: [k("bwa_index"), k("sequences")],
        },
        "aln" => #{
        opts: `
            -n NUM   max #diff (int) or missing prob under 0.02 err rate (float)
            -o INT   maximum number or fraction of gap opens
            -e INT   maximum number of gap extensions, -1 for disabling long gaps
            -i INT   do not put an indel within INT bp towards the ends
            -d INT   maximum occurrences for extending a long deletion
            -l INT   seed length
            -k INT   maximum differences in the seed
            -m INT   maximum entries in the queue
            -t INT   number of threads
            -M INT   mismatch penalty
            -O INT   gap open penalty
            -E INT   gap extension penalty
            -R INT   stop searching when there are >INT equally best hits
            -q INT   quality threshold for read trimming down to 35bp
            -f FILE  file to write output to instead of stdout
            -B INT   length of barcode
            -L       log-scaled gap penalty for long deletions
            -N       non-iterative mode: search for all n-difference hits (slooow)
            -I       the input is in the Illumina 1.3+ FASTQ-like format
            -b       the input read file is in the BAM format
            -0       use single-end reads only (effective with -b)
            -1       use the 1st read in a pair (effective with -b)
            -2       use the 2nd read in a pair (effective with -b)
            -Y       filter Casava-filtered sequences
        `,
        values: #{
            "-n": "none", "-o": "none", "-e": "none", "-i": "none", "-d": "none", "-l": "none", "-k": "none",
            "-m": "none", "-t": "none", "-M": "none", "-O": "none", "-E": "none", "-R": "none", "-q": "none",
            "-f": "files", "-B": "none",
        },
        args: [k("bwa_index"), k("fastq")],
        },
        "samse" => #{
        opts: `
            -n INT   maximum number of alignments to output in the XA tag
            -f FILE  write the SAM output to FILE
            -r STR   read group header line such as '@RG\tID:foo\tSM:bar'
        `,
        values: #{
            "-n": "none", "-f": "files", "-r": "none",
        },
        args: [k("bwa_index"), k("sai"), k("fastq")],
        },
        "sampe" => #{
        opts: `
            -a INT    maximum insert size
            -o INT    maximum occurrences for one end
            -n INT    maximum hits to output for paired reads
            -N INT    maximum hits to output for discordant pairs
            -c FLOAT  prior of chimeric rate (lower bound)
            -f FILE   sam file to output results to
            -r STR    read group header line such as '@RG\tID:foo\tSM:bar'
            -P        preload index into memory (for base-space reads only)
            -s        disable Smith-Waterman for the unmapped mate
            -A        disable insert size estimate (force -s)
        `,
        values: #{
            "-a": "none", "-o": "none", "-n": "none", "-N": "none", "-c": "none", "-f": "files", "-r": "none",
        },
        args: [k("bwa_index"), k("sai"), k("sai"), k("fastq"), k("fastq")],
        },
        "fastmap" => #{
        opts: `
            -l INT  min SMEM length to output
            -w INT  max interval size to find coordiantes
            -i INT  min SMEM interval size
            -L INT  max MEM length
            -I INT  stop if MEM is longer than -l with a size less than INT
        `,
        values: #{
            "-l": "none", "-w": "none", "-i": "none", "-L": "none", "-I": "none",
        },
        args: [k("bwa_index"), k("fastq")],
        },
        "pemerge" => #{
        opts: `
            -m      output merged reads only
            -u      output unmerged reads only
            -t INT  number of threads
            -T INT  minimum end overlap
            -Q INT  max sum of errors
        `,
        values: #{
            "-t": "none", "-T": "none", "-Q": "none",
        },
        args: [k("fastq")],
        },
        "bwasw" => #{
        opts: `
            -a INT    score for a match
            -b INT    mismatch penalty
            -q INT    gap open penalty
            -r INT    gap extension penalty
            -w INT    band width
            -m FLOAT  mask level
            -t INT    number of threads
            -f FILE   file to output results to instead of stdout
            -H        in SAM output, use hard clipping instead of soft clipping
            -C        copy FASTA/Q comment to SAM output
            -M        mark multi-part alignments as secondary
            -S        skip Smith-Waterman read pairing
            -I INT    ignore pairs with insert >=INT for inferring the size distr
            -T INT    score threshold divided by a
            -c FLOAT  coefficient of length-threshold adjustment
            -z INT    z-best
            -s INT    maximum seeding interval size
            -N INT    # seeds to trigger rev aln; 2*INT is also the chaining threshold
            -G INT    maximum gap size during chaining
        `,
        values: #{
            "-a": "none", "-b": "none", "-q": "none", "-r": "none", "-w": "none", "-m": "none", "-t": "none",
            "-f": "files", "-I": "none", "-T": "none", "-c": "none", "-z": "none", "-s": "none", "-N": "none",
            "-G": "none",
        },
        args: [k("bwa_index"), k("fasta")],
        },
        "shm" => #{
        opts: `
            -d       destroy all indices in shared memory
            -l       list names of indices in shared memory
            -f FILE  temporary file when loading indices
        `,
        values: #{
            "-f": "files",
        },
        args: [k("bwa_index")],
        },
        "fa2pac" | "pac2bwt" | "pac2bwtgen" | "bwtupdate" | "bwt2sa" => #{},
        _ => (),
    }
}

fn bwa_mem2() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: `
            index    index sequences in the FASTA format
            mem      BWA-MEM2 algorithm
            version  show the version
        `,
        sub_spec: "@extra-complete/bio/align:bwa-mem2",
    }
}

fn bwa_mem2_sub(sub) {
    switch sub {
        "index" => #{
        opts: `
            -p STR  prefix of the index
        `,
        values: #{
            "-p": "files",
        },
        args: [k("fasta")],
        },
        "mem" => #{
        opts: `
            -----------------------------
            -----------------------------
            -o STR                         output SAM file name
            -t INT                         number of threads
            -k INT                         minimum seed length
            -w INT                         band width for banded alignment
            -d INT                         off-diagonal X-dropoff
            -r FLOAT                       look for internal seeds inside a seed longer than {-k} * FLOAT
            -y INT                         seed occurrence for the 3rd round seeding
            -c INT                         skip seeds with more than INT occurrences
            -D FLOAT                       drop chains shorter than FLOAT fraction of the longest overlapping chain
            -W INT                         discard a chain if seeded bases shorter than INT
            -m INT                         perform at most INT rounds of mate rescues for each read
            -S                             skip mate rescue
            -P                             skip pairing; mate rescue performed unless -S also in use
            -A INT                         score for a sequence match, which scales options -TdBOELU unless overridden
            -B INT                         penalty for a mismatch
            -O INT[,INT]                   gap open penalties for deletions and insertions
            -E INT[,INT]                   gap extension penalty; a gap of size k cost '{-O} + {-E}*k'
            -L INT[,INT]                   penalty for 5'- and 3'-end clipping
            -U INT                         penalty for an unpaired read pair
            -p                             smart pairing (ignoring in2.fq)
            -R STR                         read group header line such as '@RG\tID:foo\tSM:bar'
            -H STR/FILE                    insert STR to header if it starts with @; or insert lines in FILE
            -j                             treat ALT contigs as part of the primary assembly
            -5                             for split alignment, take the alignment with the smallest coordinate as primary
            -q                             don't modify mapQ of supplementary alignments
            -K INT                         process INT input bases in each batch regardless of nThreads (for reproducibility)
            -v INT                         verbose level: 1=error, 2=warning, 3=message, 4+=debugging
            -T INT                         minimum score to output
            -h INT[,INT]                   if there are <INT hits with score >80% of the max score, output all in XA
            -a                             output all alignments for SE or unpaired PE
            -C                             append FASTA/FASTQ comment to SAM output
            -V                             output the reference FASTA header in the XR tag
            -Y                             use soft clipping for supplementary alignments
            -M                             mark shorter split hits as secondary
            -I FLOAT[,FLOAT[,INT[,INT]]]   specify the mean, standard deviation (10% of the mean if absent), max
        `,
        values: #{
            "-o": "files", "-t": "none", "-k": "none", "-w": "none", "-d": "none", "-r": "none", "-y": "none",
            "-c": "none", "-D": "none", "-W": "none", "-m": "none", "-A": "none", "-B": "none", "-O": "none",
            "-E": "none", "-L": "none", "-U": "none", "-R": "none", "-H": "files", "-K": "none", "-v": "none",
            "-T": "none", "-h": "none", "-I": "none", "-x": ["pacbio", "ont2d", "intractg"],
        },
        args: [k("bwa_index"), k("sequences")],
        },
        _ => (),
    }
}

fn bowtie2() {
    #{
        opts: `
            -q                            query input files are FASTQ .fq/.fastq
            --tab5                        query input files are TAB5 .tab5
            --tab6                        query input files are TAB6 .tab6
            --qseq                        query input files are in Illumina's qseq format
            -f                            query input files are (multi-)FASTA .fa/.mfa
            -r                            query input files are raw one-sequence-per-line
            -s, --skip <int>              skip the first <int> reads/pairs in the input (none)
            -u, --upto <int>              stop after first <int> reads/pairs (no limit)
            -5, --trim5 <int>             trim <int> bases from 5'/left end of reads (0)
            -3, --trim3 <int>             trim <int> bases from 3'/right end of reads (0)
            --trim-to [3:|5:]<int>        trim reads exceeding <int> bases from either 3' or 5' end If the read end is not
            --phred33                     qualities are Phred+33
            --phred64                     qualities are Phred+64
            --int-quals                   qualities encoded as space-delimited integers
            -N <int>                      max # mismatches in seed alignment; can be 0 or 1 (0)
            -L <int>                      length of seed substrings; must be >3, <32 (22)
            -i <func>                     interval between seed substrings w/r/t read len (S,1,1.15)
            --n-ceil <func>               func for max # non-A/C/G/Ts permitted in aln (L,0,0.15)
            --dpad <int>                  include <int> extra ref chars on sides of DP table (15)
            --gbar <int>                  disallow gaps within <int> nucs of read extremes (4)
            --ignore-quals                treat all quality values as 30 on Phred scale (off)
            --nofw                        do not align forward (original) version of read (off)
            --norc                        do not align reverse-complement version of read (off)
            --ma <int>                    match bonus (0 for --end-to-end, 2 for --local)
            --mp <int>                    max penalty for mismatch; lower qual = lower penalty (6)
            --np <int>                    penalty for non-A/C/G/Ts in read/ref (1)
            --rdg <int>,<int>             read gap open, extend penalties (5,3)
            --rfg <int>,<int>             reference gap open, extend penalties (5,3)
            --score-min <func>            min acceptable alignment score w/r/t read length
            -k <int>                      report up to <int> alns per read; MAPQ not meaningful
            -D <int>                      give up extending after <int> failed extends in a row (15)
            -R <int>                      for reads w/ repetitive seeds, try <int> sets of seeds (2)
            -I, --minins <int>            minimum fragment length (0)
            -X, --maxins <int>            maximum fragment length (500)
            --no-mixed                    suppress unpaired alignments for paired reads
            --no-discordant               suppress discordant alignments for paired reads
            --dovetail                    concordant when mates extend past each other
            --no-contain                  not concordant when one mate alignment contains other
            --no-overlap                  not concordant when mates overlap at all
            -t, --time                    print wall-clock time taken by search phases
            --un <path>                   write unpaired reads that didn't align to <path>
            --al <path>                   write unpaired reads that aligned at least once to <path>
            --un-conc <path>              write pairs that didn't align concordantly to <path>
            --al-conc <path>              write pairs that aligned concordantly at least once to <path>
            --quiet                       print nothing to stderr except serious errors
            --met-file <path>             send metrics to file at <path> (off)
            --met-stderr                  send metrics to stderr (off)
            --met <int>                   report internal counters & metrics every <int> secs (1)
            --no-unal                     suppress SAM records for unaligned reads
            --no-sq                       suppress @SQ header lines
            --rg-id <text>                set read group id, reflected in @RG line and RG:Z: opt field
            --rg <text>                   add <text> ("lab:value") to @RG line of SAM header
            --omit-sec-seq                put '*' in SEQ and QUAL fields for secondary alignments
            --sam-no-qname-trunc          suppress standard behavior of truncating readname at first whitespace
            --xeq                         use '='/'X', instead of 'M,' to specify matches/mismatches in SAM record
            --soft-clipped-unmapped-tlen  exclude soft-clipped bases when reporting TLEN
            --sam-append-comment          append FASTA/FASTQ comment to SAM record
            --sam-opt-config <config>     use <config>, example '-MD,YP,-AS', to toggle SAM Optional fields
            -p, --threads <int>           number of alignment threads to launch (1)
            --reorder                     force SAM output order to match order of input reads
            --mm                          use memory-mapped I/O for index; many 'bowtie's can share
            --qc-filter                   filter out reads that are bad according to QSEQ filter
            --seed <int>                  seed for random number generator (0)
            --version                     print version information and quit
            -h, --help                    print this usage message
            -x BT2_IDX                    index filename prefix (minus the trailing .X.bt2)
            -1 FILE                       files with #1 mates, paired with the files of -2
            -2 FILE                       files with #2 mates, paired with the files of -1
            -U FILE                       files with unpaired reads
            --interleaved FILE            files with interleaved paired-end FASTQ or FASTA reads
            -b BAM                        files are unaligned BAM sorted by read name
            -S FILE                       write the SAM output to FILE
            -c                            the reads (-1, -2, -U) are sequences themselves, not files
            -F k:INT,i:INT                reads are substrings (k-mers) extracted from FASTA files
            --end-to-end                  the entire read must align, with no clipping
            --local                       local alignment: the ends might be soft clipped
            -a, --all                     report all alignments (very slow)
            -l, --lowseeds N              ignore low quality seeds with ranges over this threshold
            -d, --deterministic-seeds     consider all seeds in order (no subsampling; best with -a)
            --very-fast                   same as -D 5 -R 1 -N 0 -L 22 -i S,0,2.50
            --fast                        same as -D 10 -R 2 -N 0 -L 22 -i S,0,2.50
            --sensitive                   same as -D 15 -R 2 -N 0 -L 22 -i S,1,1.15 (the default)
            --very-sensitive              same as -D 20 -R 3 -N 0 -L 20 -i S,1,0.50
            --very-fast-local             same as -D 5 -R 1 -N 0 -L 25 -i S,1,2.00
            --fast-local                  same as -D 10 -R 2 -N 0 -L 22 -i S,1,1.75
            --sensitive-local             same as -D 15 -R 2 -N 0 -L 20 -i S,1,0.75 (the default with --local)
            --very-sensitive-local        same as -D 20 -R 3 -N 0 -L 20 -i S,1,0.50
            --fr                          mates align forward/reverse (the default)
            --rf                          mates align reverse/forward
            --ff                          mates align forward/forward
            --un-gz PATH                  like --un, gzip compressed (also --un-bz2, --un-lz4, and --al-*, --un-conc-*, --al-conc-*)
            --no-head                     suppress the header lines (starting with @)
            --non-deterministic           seed the random number generator arbitrarily each time
            --align-paired-reads          align paired reads from a BAM file (with -b)
            --preserve-tags               preserve the tags of the original BAM record (with -b)
            --no-1mm-upfront              do not allow 1 mismatch alignments before attempting to scan for the optimal seeded alignments
        `,
        values: #{
            "-s": "none", "--skip": "none", "-u": "none", "--upto": "none", "-5": "none", "--trim5": "none",
            "-3": "none", "--trim3": "none", "--trim-to": "none", "-N": "none", "-L": "none", "-i": "none",
            "--n-ceil": "none", "--dpad": "none", "--gbar": "none", "--ma": "none", "--mp": "none", "--np": "none",
            "--rdg": "none", "--rfg": "none", "--score-min": "none", "-k": "none", "-D": "none", "-R": "none",
            "-I": "none", "--minins": "none", "-X": "none", "--maxins": "none", "--un": "files", "--al": "files",
            "--un-conc": "files", "--al-conc": "files", "--met-file": "files", "--met": "none", "--rg-id": "none",
            "--rg": "none", "--sam-opt-config": "none", "-p": "none", "--threads": "none", "--seed": "none",
            "-x": k("bowtie2_index"), "-1": k("sequences"), "-2": k("sequences"), "-U": k("sequences"),
            "--interleaved": k("sequences"), "-b": k("bam"), "-S": "files", "-F": "none", "-l": "none",
            "--lowseeds": "none", "--un-gz": "files",
        },
    }
}

fn bowtie2_build() {
    #{
        opts: `
            -f                     reference files are Fasta
            -c                     reference sequences given on cmd line
            --large-index          force generated index to be 'large', even if ref has fewer than 4 billion nucleotides
            --debug                use the debug binary; slower, assertions enabled
            --sanitized            use sanitized binary; slower, uses ASan and/or UBSan
            --verbose              log the issued command
            -a, --noauto           disable automatic -p/--bmax/--dcv memory-fitting
            -p, --packed           use packed strings internally; slower, less memory
            --bmax <int>           max bucket sz for blockwise suffix-array builder
            --bmaxdivn <int>       max bucket sz as divisor of ref len
            --dcv <int>            diff-cover period for blockwise
            --nodc                 disable diff-cover (algorithm becomes quadratic)
            -r, --noref            don't build .3/.4 index files
            -3, --justref          just build .3/.4 index files
            -o, --offrate <int>    SA is sampled every 2^<int> BWT chars
            -t, --ftabchars <int>  # of chars consumed in initial lookup
            --threads <int>        # of threads
            --seed <int>           seed for random number generator
            -q, --quiet            verbose output (for debugging)
            --version              print version information and quit
        `,
        values: #{
            "--bmax": "none", "--bmaxdivn": "none", "--dcv": "none", "-o": "none", "--offrate": "none",
            "-t": "none", "--ftabchars": "none", "--threads": "none", "--seed": "none",
        },
        args: [k("fasta"), k("bowtie2_index")],
    }
}

fn hisat2() {
    #{
        opts: `
            -q                                 query input files are FASTQ .fq/.fastq
            --qseq                             query input files are in Illumina's qseq format
            -f                                 query input files are (multi-)FASTA .fa/.mfa
            -r                                 query input files are raw one-sequence-per-line
            -s, --skip <int>                   skip the first <int> reads/pairs in the input (none)
            -u, --upto <int>                   stop after first <int> reads/pairs (no limit)
            -5, --trim5 <int>                  trim <int> bases from 5'/left end of reads (0)
            -3, --trim3 <int>                  trim <int> bases from 3'/right end of reads (0)
            --phred33                          qualities are Phred+33
            --phred64                          qualities are Phred+64
            --int-quals                        qualities encoded as space-delimited integers
            --n-ceil <func>                    func for max # non-A/C/G/Ts permitted in aln (L,0,0.15)
            --ignore-quals                     treat all quality values as 30 on Phred scale (off)
            --nofw                             do not align forward (original) version of read (off)
            --norc                             do not align reverse-complement version of read (off)
            --no-repeat-index                  do not use repeat index
            --pen-cansplice <int>              penalty for a canonical splice site (0)
            --pen-noncansplice <int>           penalty for a non-canonical splice site (12)
            --pen-canintronlen <func>          penalty for long introns (G,-8,1) with canonical splice sites
            --pen-noncanintronlen <func>       penalty for long introns (G,-8,1) with noncanonical splice sites
            --min-intronlen <int>              minimum intron length (20)
            --max-intronlen <int>              maximum intron length (500000)
            --known-splicesite-infile <path>   provide a list of known splice sites
            --novel-splicesite-outfile <path>  report a list of splice sites
            --novel-splicesite-infile <path>   provide a list of novel splice sites
            --no-temp-splicesite               disable the use of splice sites found
            --no-spliced-alignment             disable spliced alignment
            --rna-strandness <string>          specify strand-specific information (unstranded)
            --tmo                              reports only those alignments within known transcriptome
            --dta                              reports alignments tailored for transcript assemblers
            --dta-cufflinks                    reports alignments tailored specifically for cufflinks
            --avoid-pseudogene                 tries to avoid aligning reads to pseudogenes (experimental option)
            --no-templatelen-adjustment        disables template length adjustment for RNA-seq reads
            --mp <int>,<int>                   max and min penalties for mismatch; lower qual = lower penalty <6,2>
            --sp <int>,<int>                   max and min penalties for soft-clipping; lower qual = lower penalty <2,1>
            --no-softclip                      no soft-clipping
            --np <int>                         penalty for non-A/C/G/Ts in read/ref (1)
            --rdg <int>,<int>                  read gap open, extend penalties (5,3)
            --rfg <int>,<int>                  reference gap open, extend penalties (5,3)
            --score-min <func>                 min acceptable alignment score w/r/t read length (L,0.0,-0.2)
            --repeat                           report alignments to repeat sequences directly
            -I, --minins <int>                 minimum fragment length (0), only valid with --no-spliced-alignment
            -X, --maxins <int>                 maximum fragment length (500), only valid with --no-spliced-alignment
            --no-mixed                         suppress unpaired alignments for paired reads
            --no-discordant                    suppress discordant alignments for paired reads
            -t, --time                         print wall-clock time taken by search phases
            --un <path>                        write unpaired reads that didn't align to <path>
            --al <path>                        write unpaired reads that aligned at least once to <path>
            --un-conc <path>                   write pairs that didn't align concordantly to <path>
            --al-conc <path>                   write pairs that aligned concordantly at least once to <path>
            --summary-file <path>              print alignment summary to this file
            --new-summary                      print alignment summary in a new style, which is more machine-friendly
            --quiet                            print nothing to stderr except serious errors
            --met-file <path>                  send metrics to file at <path> (off)
            --met-stderr                       send metrics to stderr (off)
            --met <int>                        report internal counters & metrics every <int> secs (1)
            --no-sq                            suppress @SQ header lines
            --rg-id <text>                     set read group id, reflected in @RG line and RG:Z: opt field
            --rg <text>                        add <text> ("lab:value") to @RG line of SAM header
            --omit-sec-seq                     put '*' in SEQ and QUAL fields for secondary alignments
            -o, --offrate <int>                override offrate of index; must be >= index's offrate
            -p, --threads <int>                number of alignment threads to launch (1)
            --reorder                          force SAM output order to match order of input reads
            --mm                               use memory-mapped I/O for index; many 'hisat2's can share
            --qc-filter                        filter out reads that are bad according to QSEQ filter
            --seed <int>                       seed for random number generator (0)
            --remove-chrname                   remove 'chr' from reference names in alignment
            --add-chrname                      add 'chr' to reference names in alignment
            --version                          print version information and quit
            -h, --help                         print this usage message
            -x HT2_IDX                         index filename prefix (minus the trailing .X.ht2)
            -1 FILE                            files with #1 mates, paired with the files of -2
            -2 FILE                            files with #2 mates, paired with the files of -1
            -U FILE                            files with unpaired reads
            -S FILE                            write the SAM output to FILE
            -c                                 the reads (-1, -2, -U) are sequences themselves, not files
            --fast                             same as --no-repeat-index
            --sensitive                        same as --bowtie2-dp 1 -k 30 --score-min L,0,-0.5
            --very-sensitive                   same as --bowtie2-dp 2 -k 50 --score-min L,0,-1
            --bowtie2-dp INT                   use Bowtie2's dynamic programming alignment algorithm: 0 no, 1 when needed, 2 always
            -k INT                             search for at most INT distinct primary alignments for each read
            --max-seeds INT                    maximum number of seeds to extend
            -a, --all                          report all the alignments it can find
            --fr                               mates align forward/reverse (the default)
            --rf                               mates align reverse/forward
            --ff                               mates align forward/forward
            --un-gz PATH                       like --un, gzip compressed (also --un-bz2, and --al-*, --un-conc-*, --al-conc-*)
            --no-head                          suppress the header lines (starting with @)
            --non-deterministic                seed the random number generator arbitrarily each time
            --temp-directory DIR               the directory for temporary files
        `,
        values: #{
            "-s": "none", "--skip": "none", "-u": "none", "--upto": "none", "-5": "none", "--trim5": "none",
            "-3": "none", "--trim3": "none", "--n-ceil": "none", "--pen-cansplice": "none",
            "--pen-noncansplice": "none", "--pen-canintronlen": "none", "--pen-noncanintronlen": "none",
            "--min-intronlen": "none", "--max-intronlen": "none", "--known-splicesite-infile": "files",
            "--novel-splicesite-outfile": "files", "--novel-splicesite-infile": "files",
            "--rna-strandness": ["F", "R", "FR", "RF"], "--mp": "none", "--sp": "none", "--np": "none",
            "--rdg": "none", "--rfg": "none", "--score-min": "none", "-I": "none", "--minins": "none",
            "-X": "none", "--maxins": "none", "--un": "files", "--al": "files", "--un-conc": "files",
            "--al-conc": "files", "--summary-file": "files", "--met-file": "files", "--met": "none",
            "--rg-id": "none", "--rg": "none", "-o": "none", "--offrate": "none", "-p": "none",
            "--threads": "none", "--seed": "none", "-x": k("hisat2_index"), "-1": k("sequences"),
            "-2": k("sequences"), "-U": k("sequences"), "-S": "files", "--bowtie2-dp": "none", "-k": "none",
            "--max-seeds": "none", "--un-gz": "files", "--temp-directory": "dirs",
        },
    }
}

fn hisat2_build() {
    #{
        opts: `
            -c                         reference sequences given on cmd line
            --large-index              force generated index to be 'large', even if ref has fewer than 4 billion nucleotides
            -a, --noauto               disable automatic -p/--bmax/--dcv memory-fitting
            -p <int>                   number of threads
            --bmax <int>               max bucket sz for blockwise suffix-array builder
            --bmaxdivn <int>           max bucket sz as divisor of ref len
            --dcv <int>                diff-cover period for blockwise
            --nodc                     disable diff-cover (algorithm becomes quadratic)
            -r, --noref                don't build .3/.4.ht2 (packed reference) portion
            -3, --justref              just build .3/.4.ht2 (packed reference) portion
            -o, --offrate <int>        SA is sampled every 2^offRate BWT chars
            -t, --ftabchars <int>      # of chars consumed in initial lookup
            --localoffrate <int>       SA (local) is sampled every 2^offRate BWT chars
            --localftabchars <int>     # of chars consumed in initial lookup in a local index
            --snp <path>               SNP file name
            --haplotype <path>         haplotype file name
            --ss <path>                splice site file name
            --exon <path>              exon file name
            --repeat-ref <path>        repeat reference file name
            --repeat-info <path>       repeat information file name
            --repeat-snp <path>        repeat snp file name
            --repeat-haplotype <path>  repeat haplotype file name
            --seed <int>               seed for random number generator
            -q, --quiet                disable verbose output (for debugging)
            --version                  print version information and quit
        `,
        values: #{
            "-p": "none", "--bmax": "none", "--bmaxdivn": "none", "--dcv": "none", "-o": "none",
            "--offrate": "none", "-t": "none", "--ftabchars": "none", "--localoffrate": "none",
            "--localftabchars": "none", "--snp": "files", "--haplotype": "files", "--ss": "files",
            "--exon": "files", "--repeat-ref": "dirs", "--repeat-info": "dirs", "--repeat-snp": "dirs",
            "--repeat-haplotype": "dirs", "--seed": "none",
        },
        args: [k("fasta"), k("hisat2_index")],
    }
}

fn minimap2() {
    #{
        opts: `
            -H                  use homopolymer-compressed k-mer (preferrable for PacBio)
            -k INT              k-mer size (no larger than 28)
            -w INT              minimizer window size
            -I NUM              split index for every ~NUM input bases
            -d FILE             dump index to FILE
            -f FLOAT            filter out top FLOAT fraction of repetitive minimizers
            -g NUM              stop chain enlongation if there are no minimizers in INT-bp
            -G NUM              max intron length (effective with -xsplice; changing -r)
            -F NUM              max fragment length (effective with -xsr or in the fragment mode)
            -n INT              minimal number of minimizers on a chain
            -m INT              minimal chaining score (matching bases minus log gap penalty)
            -X                  skip self and dual mappings (for the all-vs-all mode)
            -p FLOAT            min secondary-to-primary score ratio
            -N INT              retain at most INT secondary alignments
            -A INT              matching score
            -B INT              mismatch penalty (larger value for lower divergence)
            -O INT[,INT]        gap open penalty
            -E INT[,INT]        gap extension penalty; a k-long gap costs min{O1+k*E1,O2+k*E2}
            -z INT[,INT]        z-drop score and inversion Z-drop score
            -s INT              minimal peak DP alignment score
            -u CHAR             how to find GT-AG. f:transcript strand, b:both strands, n:don't match GT-AG
            -J INT              splice mode
            -j FILE             junctions in BED12 to extend *short* RNA-seq alignment
            -a                  output in the SAM format (PAF by default)
            -o FILE             output alignments to FILE
            -L                  write CIGAR with >65535 ops at the CG tag
            -R STR              SAM read group line in a format like '@RG\tID:foo\tSM:bar'
            -c                  output CIGAR in PAF
            --cs[=STR]          output the cs tag; STR is 'short' (if absent) or 'long'
            --ds                output the ds tag, which is an extension to cs
            --MD                output the MD tag
            --eqx               write =/X CIGAR operators
            -Y                  use soft clipping for supplementary alignments
            -y                  copy FASTA/Q comments to output SAM
            -t INT              number of threads
            -K NUM              minibatch size for mapping
            --version           show version number
            -x STR              preset (always applied before other options; see minimap2.1 for details) [] - lr:hq
            -r NUM[,NUM]        chaining and alignment bandwidth, and long-join bandwidth
            -V, --version       show the version number
            -2                  use two I/O threads during mapping
            --secondary yes|no  whether to output secondary alignments
            --sam-hit-only      in SAM, do not output unmapped reads
            --junc-bed FILE     junctions in BED12 to extend short RNA-seq alignment
            --split-prefix STR  prefix for the temporary files of the split index
            --frag yes|no       fragment mode: use paired-end alignment for the reads
            --for-only          only map to the forward strand of the transcript
            --rev-only          only map to the reverse strand of the transcript
            --seed INT          the random seed
            --max-qlen NUM      skip query sequences longer than NUM
            --end-bonus INT     score bonus when alignment extends to the end of the query
            --no-end-flt        do not filter seeds towards the ends of the chains
            --paf-no-hit        in PAF, output unmapped queries
            --dual yes|no       for the split index, map in both directions
            --MD                output the MD tag
            --splice            splice preset, the same as -x splice
            --sr                short read preset, the same as -x sr
            --heap-sort yes|no  use heap sort instead of radix sort when merging
        `,
        values: #{
            "-k": "none", "-w": "none", "-I": "none", "-d": "files", "-f": "none", "-g": "none", "-G": "none",
            "-F": "none", "-n": "none", "-m": "none", "-p": "none", "-N": "none", "-A": "none", "-B": "none",
            "-O": "none", "-E": "none", "-z": "none", "-s": "none", "-u": ["f", "b", "n"], "-J": "none",
            "-j": k("bed"), "-o": "files", "-R": "none", "-t": "none", "-K": "none",
            "-x": ["map-ont", "map-hifi", "map-pb", "lr:hq", "splice", "splice:hq", "splice:sr", "asm5", "asm10", "asm20", "sr", "ava-pb", "ava-ont"],
            "-r": "none", "--secondary": ["yes", "no"], "--junc-bed": k("bed"), "--split-prefix": "files",
            "--frag": ["yes", "no"], "--seed": "none", "--max-qlen": "none", "--end-bonus": "none",
            "--dual": ["yes", "no"], "--heap-sort": ["yes", "no"],
        },
        args: [k("minimap2_ref"), k("sequences")],
    }
}

fn star() {
    #{
        opts: `
            --versionGenome VALUE  earliest genome index version compatible with this STAR release
            --parametersFiles VALUE  name of a user-defined parameters file, "-": none
            --sysShell VALUE  path to the shell binary, preferably bash, e.g
            --runMode VALUE  type of the run
            --runThreadN VALUE  number of threads to run STAR
            --runDirPerm VALUE  permissions for the directories created at the run-time
            --runRNGseed VALUE  random number generator seed
            --genomeDir VALUE  path to the directory where genome files are stored (for --runMode alignReads) or will...
            --genomeLoad VALUE  mode of shared memory usage for the genome files
            --genomeFastaFiles VALUE  path(s) to the fasta files with the genome sequences, separated by spaces
            --genomeChainFiles VALUE  chain files for genomic liftover
            --genomeFileSizes VALUE  genome files exact sizes in bytes
            --genomeTransformOutput VALUE  which output to transform back to original genome
            --genomeChrSetMitochondrial VALUE  names of the mitochondrial chromosomes
            --genomeChrBinNbits VALUE  =log2(chrBin), where chrBin is the size of the bins for genome storage: each...
            --genomeSAindexNbases VALUE  length (bases) of the SA pre-indexing string
            --genomeSAsparseD VALUE  suffux array sparsity, i.e
            --genomeSuffixLengthMax VALUE  maximum length of the suffixes, has to be longer than read length
            --genomeTransformType VALUE  type of genome transformation
            --genomeTransformVCF VALUE  path to VCF file for genome transformation
            --genomeType VALUE  type of genome to generate
            --sjdbFileChrStartEnd VALUE  path to the files with genomic coordinates (chr <tab> start <tab> end <tab> strand)...
            --sjdbGTFfile VALUE  path to the GTF file with annotations
            --sjdbGTFchrPrefix VALUE  prefix for chromosome names in a GTF file (e.g
            --sjdbGTFfeatureExon VALUE  feature type in GTF file to be used as exons for building transcripts
            --sjdbGTFtagExonParentTranscript VALUE  GTF attribute name for parent transcript ID (default "transcript_id" works for GTF files)
            --sjdbGTFtagExonParentGene VALUE  GTF attribute name for parent gene ID (default "gene_id" works for GTF files)
            --sjdbGTFtagExonParentGeneName VALUE  GTF attribute name for parent gene name
            --sjdbGTFtagExonParentGeneType VALUE  GTF attribute name for parent gene type
            --sjdbOverhang VALUE  length of the donor/acceptor sequence on each side of the junctions, ideally =...
            --sjdbScore VALUE  extra alignment score for alignments that cross database junctions
            --sjdbInsertSave VALUE  which files to save when sjdb junctions are inserted on the fly at the mapping step
            --varVCFfile VALUE  path to the VCF file that contains variation data
            --inputBAMfile VALUE  path to BAM input file, to be used with --runMode inputAlignmentsFromBAM
            --readFilesType VALUE  format of input read files
            --readFilesSAMattrKeep VALUE  for --readFilesType SAM SE/PE, which SAM tags to keep in the output BAM, e.g....
            --readFilesIn VALUE  paths to files that contain input read1 (and, if needed, read2)
            --readFilesManifest VALUE  path to the "manifest" file with the names of read files
            --readFilesPrefix VALUE  prefix for the read files names, i.e
            --readFilesCommand VALUE  command line to execute for each of the input file
            --readMapNumber VALUE  number of reads to map from the beginning of the file
            --readMatesLengthsIn VALUE  equal/NotEqual - lengths of names,sequences,qualities for both mates are the same /...
            --readNameSeparator VALUE  character(s) separating the part of the read names that will be trimmed in output...
            --readQualityScoreBase VALUE  number to be subtracted from the ASCII code to get Phred quality score
            --clipAdapterType VALUE  adapter clipping type
            --clip3pNbases VALUE  number(s) of bases to clip from 3p of each mate
            --clip3pAdapterSeq VALUE  adapter sequences to clip from 3p of each mate
            --clip3pAdapterMMp VALUE  max proportion of mismatches for 3p adapter clipping for each mate
            --clip3pAfterAdapterNbases VALUE  number of bases to clip from 3p of each mate after the adapter clipping
            --clip5pNbases VALUE  number(s) of bases to clip from 5p of each mate
            --clip5pAdapterSeq VALUE  adapter sequences to clip from 5p of each mate, separated by space
            --clip5pAdapterMMp VALUE  max proportion of mismatches for 5p adapter clipping for each mate, separated by space
            --clip5pAfterAdapterNbases VALUE  number of bases to clip from 5p of each mate after the adapter clipping, separated by...
            --limitGenomeGenerateRAM VALUE  maximum available RAM (bytes) for genome generation
            --limitIObufferSize VALUE  max available buffers size (bytes) for input/output, per thread
            --limitOutSAMoneReadBytes VALUE  max size of the SAM record (bytes) for one read
            --limitOutSJoneRead VALUE  max number of junctions for one read (including all multi-mappers)
            --limitOutSJcollapsed VALUE  max number of collapsed junctions
            --limitBAMsortRAM VALUE  maximum available RAM (bytes) for sorting BAM. If =0, it will be set to the genome...
            --limitSjdbInsertNsj VALUE  maximum number of junctions to be inserted to the genome on the fly at the mapping...
            --limitNreadsSoft VALUE  soft limit on the number of reads
            --outFileNamePrefix VALUE  output files name prefix (including full or relative path)
            --outTmpDir VALUE  path to a directory that will be used as temporary by STAR. All contents of this...
            --outTmpKeep VALUE  whether to keep the temporary files after STAR runs is finished
            --outStd VALUE  which output will be directed to stdout (standard out)
            --outReadsUnmapped VALUE  
            --outQSconversionAdd VALUE  
            --outMultimapperOrder VALUE  order of multimapping alignments in the output files
            --outSAMtype VALUE  type of SAM/BAM output
            --outSAMmode VALUE  mode of SAM output
            --outSAMstrandField VALUE  cufflinks-like strand field flag
            --outSAMattributes VALUE  a string of desired SAM attributes, in the order desired for the output SAM. Tags can...
            --outSAMattrIHstart VALUE  start value for the IH attribute
            --outSAMunmapped VALUE  output of unmapped reads in the SAM format
            --outSAMorder VALUE  type of sorting for the SAM output
            --outSAMprimaryFlag VALUE  which alignments are considered primary - all others will be marked with 0x100 bit in...
            --outSAMreadID VALUE  read ID record type
            --outSAMmapqUnique VALUE  0 to 255: the MAPQ value for unique mappers
            --outSAMflagOR VALUE  0 to 65535: sam FLAG will be bitwise OR'd with this value, i.e
            --outSAMflagAND VALUE  0 to 65535: sam FLAG will be bitwise AND'd with this value, i.e
            --outSAMattrRGline VALUE  SAM/BAM read group line
            --outSAMheaderHD VALUE  @HD (header) line of the SAM header
            --outSAMheaderPG VALUE  extra @PG (software) line of the SAM header (in addition to STAR)
            --outSAMfilter VALUE  filter the output into main SAM/BAM files
            --outSAMmultNmax VALUE  max number of multiple alignments for a read that will be output to the SAM/BAM files
            --outSAMtlen VALUE  calculation method for the TLEN field in the SAM/BAM files
            --outBAMcompression VALUE  -1 to 10 BAM compression level, -1=default compression (6?), 0=no compression...
            --outBAMsortingThreadN VALUE  >=0: number of threads for BAM sorting
            --outBAMsortingBinsN VALUE  >0: number of genome bins for coordinate-sorting
            --bamRemoveDuplicatesType VALUE  mark duplicates in the BAM file, for now only works with (i) sorted BAM fed with...
            --bamRemoveDuplicatesMate2basesN VALUE  number of bases from the 5' of mate 2 to use in collapsing (e.g
            --outWigType VALUE  type of signal output, e.g
            --outWigStrand VALUE  strandedness of wiggle/bedGraph output
            --outWigReferencesPrefix VALUE  prefix matching reference names to include in the output wiggle file, e.g
            --outWigNorm VALUE  type of normalization for the signal
            --outFilterType VALUE  type of filtering
            --outFilterMultimapScoreRange VALUE  the score range below the maximum score for multimapping alignments
            --outFilterMultimapNmax VALUE  maximum number of loci the read is allowed to map to
            --outFilterMismatchNmax VALUE  alignment will be output only if it has no more mismatches than this value
            --outFilterMismatchNoverLmax VALUE  alignment will be output only if its ratio of mismatches to *mapped* length is less...
            --outFilterMismatchNoverReadLmax VALUE  alignment will be output only if its ratio of mismatches to *read* length is less than...
            --outFilterScoreMin VALUE  alignment will be output only if its score is higher than or equal to this value
            --outFilterScoreMinOverLread VALUE  same as outFilterScoreMin, but normalized to read length (sum of mates' lengths for...
            --outFilterMatchNmin VALUE  alignment will be output only if the number of matched bases is higher than or equal...
            --outFilterMatchNminOverLread VALUE  sam as outFilterMatchNmin, but normalized to the read length (sum of mates' lengths...
            --outFilterIntronMotifs VALUE  filter alignment using their motifs
            --outFilterIntronStrands VALUE  filter alignments
            --outSJtype VALUE  type of splice junction output
            --outSJfilterReads VALUE  which reads to consider for collapsed splice junctions output
            --outSJfilterOverhangMin VALUE  minimum overhang length for splice junctions on both sides for: (1) non-canonical...
            --outSJfilterCountUniqueMin VALUE  minimum uniquely mapping read count per junction for: (1) non-canonical motifs, (2)...
            --outSJfilterCountTotalMin VALUE  minimum total (multi-mapping+unique) read count per junction for: (1) non-canonical...
            --outSJfilterDistToOtherSJmin VALUE  minimum allowed distance to other junctions' donor/acceptor
            --outSJfilterIntronMaxVsReadN VALUE  maximum gap allowed for junctions supported by 1,2,3,,,N reads
            --scoreGap VALUE  splice junction penalty (independent on intron motif)
            --scoreGapNoncan VALUE  non-canonical junction penalty (in addition to scoreGap)
            --scoreGapGCAG VALUE  GC/AG and CT/GC junction penalty (in addition to scoreGap)
            --scoreGapATAC VALUE  AT/AC and GT/AT junction penalty (in addition to scoreGap)
            --scoreGenomicLengthLog2scale VALUE  extra score logarithmically scaled with genomic length of the alignment...
            --scoreDelOpen VALUE  deletion open penalty
            --scoreDelBase VALUE  deletion extension penalty per base (in addition to scoreDelOpen)
            --scoreInsOpen VALUE  insertion open penalty
            --scoreInsBase VALUE  insertion extension penalty per base (in addition to scoreInsOpen)
            --scoreStitchSJshift VALUE  maximum score reduction while searching for SJ boundaries in the stitching step
            --seedSearchStartLmax VALUE  defines the search start point through the read - the read is split into pieces no...
            --seedSearchStartLmaxOverLread VALUE  seedSearchStartLmax normalized to read length (sum of mates' lengths for paired-end reads)
            --seedSearchLmax VALUE  defines the maximum length of the seeds, if =0 seed length is not limited
            --seedMultimapNmax VALUE  only pieces that map fewer than this value are utilized in the stitching procedure
            --seedPerReadNmax VALUE  max number of seeds per read
            --seedPerWindowNmax VALUE  max number of seeds per window
            --seedNoneLociPerWindow VALUE  max number of one seed loci per window
            --seedSplitMin VALUE  min length of the seed sequences split by Ns or mate gap
            --seedMapMin VALUE  min length of seeds to be mapped
            --alignIntronMin VALUE  minimum intron size, genomic gap is considered intron if its length>=alignIntronMin...
            --alignIntronMax VALUE  maximum intron size, if 0, max intron size will be determined by...
            --alignMatesGapMax VALUE  maximum gap between two mates, if 0, max intron gap will be determined by...
            --alignSJoverhangMin VALUE  minimum overhang (i.e
            --alignSJstitchMismatchNmax VALUE  maximum number of mismatches for stitching of the splice junctions (-1: no limit)
            --alignSJDBoverhangMin VALUE  minimum overhang (i.e
            --alignSplicedMateMapLmin VALUE  minimum mapped length for a read mate that is spliced
            --alignWindowsPerReadNmax VALUE  max number of windows per read
            --alignTranscriptsPerWindowNmax VALUE  max number of transcripts per window
            --alignTranscriptsPerReadNmax VALUE  max number of different alignments per read to consider
            --alignEndsType VALUE  type of read ends alignment
            --alignEndsProtrude VALUE  allow protrusion of alignment ends, i.e
            --alignSoftClipAtReferenceEnds VALUE  allow the soft-clipping of the alignments past the end of the chromosomes
            --alignInsertionFlush VALUE  how to flush ambiguous insertion positions
            --peOverlapNbasesMin VALUE  minimum number of overlapping bases to trigger mates merging and realignment
            --peOverlapMMp VALUE  maximum proportion of mismatched bases in the overlap area
            --winAnchorMultimapNmax VALUE  max number of loci anchors are allowed to map to
            --winBinNbits VALUE  =log2(winBin), where winBin is the size of the bin for the windows/clustering, each...
            --winAnchorDistNbins VALUE  max number of bins between two anchors that allows aggregation of anchors into one window
            --winFlankNbins VALUE  log2(winFlank), where win Flank is the size of the left and right flanking regions for...
            --winReadCoverageRelativeMin VALUE  minimum relative coverage of the read sequence by the seeds in a window, for STARlong...
            --winReadCoverageBasesMin VALUE  minimum number of bases covered by the seeds in a window , for STARlong algorithm only
            --chimOutType VALUE  type of chimeric output
            --chimSegmentMin VALUE  minimum length of chimeric segment length, if ==0, no chimeric output
            --chimScoreMin VALUE  minimum total (summed) score of the chimeric segments
            --chimScoreDropMax VALUE  max drop (difference) of chimeric score (the sum of scores of all chimeric segments)...
            --chimScoreSeparation VALUE  minimum difference (separation) between the best chimeric score and the next one
            --chimScoreJunctionNonGTAG VALUE  penalty for a non-GT/AG chimeric junction
            --chimJunctionOverhangMin VALUE  minimum overhang for a chimeric junction
            --chimSegmentReadGapMax VALUE  maximum gap in the read sequence between chimeric segments
            --chimFilter VALUE  different filters for chimeric alignments
            --chimMainSegmentMultNmax VALUE  maximum number of multi-alignments for the main chimeric segment
            --chimMultimapNmax VALUE  maximum number of chimeric multi-alignments
            --chimMultimapScoreRange VALUE  the score range for multi-mapping chimeras below the best chimeric score
            --chimNonchimScoreDropMin VALUE  to trigger chimeric detection, the drop in the best non-chimeric alignment score with...
            --chimOutJunctionFormat VALUE  formatting type for the Chimeric.out.junction file
            --quantMode VALUE  types of quantification requested
            --quantTranscriptomeBAMcompression VALUE  -2 to 10 transcriptome BAM compression level
            --twopassMode VALUE  2-pass mapping mode
            --twopass1readsN VALUE  number of reads to process for the 1st step
            --waspOutputMode VALUE  WASP allele-specific output type
            --soloType VALUE  type of single-cell RNA-seq
            --soloCBtype VALUE  cell barcode type
            --soloCBwhitelist VALUE  file(s) with whitelist(s) of cell barcodes
            --soloCBstart VALUE  cell barcode start base
            --soloCBlen VALUE  cell barcode length
            --soloUMIstart VALUE  UMI start base
            --soloUMIlen VALUE  UMI length
            --soloBarcodeReadLength VALUE  length of the barcode read
            --soloBarcodeMate VALUE  identifies which read mate contains the barcode (CB+UMI) sequence
            --soloCBposition VALUE  position of Cell Barcode(s) on the barcode read
            --soloUMIposition VALUE  position of the UMI on the barcode read, same as soloCBposition
            --soloAdapterSequence VALUE  adapter sequence to anchor barcodes
            --soloAdapterMismatchesNmax VALUE  maximum number of mismatches allowed in adapter sequence
            --soloCBmatchWLtype VALUE  matching the Cell Barcodes to the WhiteList
            --soloInputSAMattrBarcodeSeq VALUE  when inputting reads from a SAM file (--readsFileType SAM SE/PE), these SAM attributes...
            --soloInputSAMattrBarcodeQual VALUE  when inputting reads from a SAM file (--readsFileType SAM SE/PE), these SAM attributes...
            --soloStrand VALUE  strandedness of the solo libraries:
            --soloFeatures VALUE  genomic features for which the UMI counts per Cell Barcode are collected
            --soloMultiMappers VALUE  counting method for reads mapping to multiple genes
            --soloUMIdedup VALUE  type of UMI deduplication (collapsing) algorithm
            --soloUMIfiltering VALUE  type of UMI filtering (for reads uniquely mapping to genes)
            --soloOutFileNames VALUE  file names for STARsolo output:
            --soloCellFilter VALUE  cell filtering type and parameters
            --soloOutFormatFeaturesGeneField3 VALUE  field 3 in the Gene features.tsv file
            --soloCellReadStats VALUE  output reads statistics for each CB
            --soloClusterCBfile VALUE  file containing the cluster information for cell barcodes, two columns: CB cluster_index
        `,
        values: #{
            "--versionGenome": "none", "--parametersFiles": "files", "--sysShell": "files",
            "--runMode": [#{value: "alignReads", desc: "map reads"}, #{value: "genomeGenerate", desc: "generate genome files"}, #{value: "inputAlignmentsFromBAM", desc: "input alignments from BAM. Presently only works with --outWigType and..."}, #{value: "liftOver", desc: "lift-over of GTF files (--sjdbGTFfile) between genome assemblies using chain file(s)..."}],
            "--runThreadN": "none",
            "--runDirPerm": [#{value: "User_RWX", desc: "user-read/write/execute"}, #{value: "All_RWX", desc: "all-read/write/execute (same as chmod 777)"}],
            "--runRNGseed": "none", "--genomeDir": "dirs",
            "--genomeLoad": [#{value: "LoadAndKeep", desc: "load genome into shared and keep it in memory after run"}, #{value: "LoadAndRemove", desc: "load genome into shared but remove it after run"}, #{value: "LoadAndExit", desc: "load genome into shared memory and exit, keeping the genome in memory for future runs"}, #{value: "Remove", desc: "do not map anything, just remove loaded genome from memory"}, #{value: "NoSharedMemory", desc: "do not use shared memory, each job will have its own private copy of the genome"}],
            "--genomeFastaFiles": k("fasta"), "--genomeChainFiles": "files", "--genomeFileSizes": "none",
            "--genomeTransformOutput": [#{value: "SAM", desc: "SAM/BAM alignments"}, #{value: "SJ", desc: "splice junctions (SJ.out.tab)"}, #{value: "Quant", desc: "quantifications (from --quantMode option)"}, #{value: "None", desc: "no transformation of the output"}],
            "--genomeChrSetMitochondrial": "none", "--genomeChrBinNbits": "none", "--genomeSAindexNbases": "none",
            "--genomeSAsparseD": "none", "--genomeSuffixLengthMax": "none",
            "--genomeTransformType": [#{value: "None", desc: "no transformation"}, #{value: "Haploid", desc: "replace reference alleles with alternative alleles from VCF file (e.g"}, #{value: "Diploid", desc: "create two haplotypes for each chromosome listed in VCF file, for genotypes 1|2..."}],
            "--genomeTransformVCF": "files",
            "--genomeType": [#{value: "Full", desc: "full (normal) genome"}, #{value: "Transcriptome", desc: "genome consists of transcript sequences"}, #{value: "SuperTransriptome", desc: "genome consists of superTranscript sequences"}],
            "--sjdbFileChrStartEnd": "files", "--sjdbGTFfile": k("gff"), "--sjdbGTFchrPrefix": "files",
            "--sjdbGTFfeatureExon": "files", "--sjdbGTFtagExonParentTranscript": "files",
            "--sjdbGTFtagExonParentGene": "files", "--sjdbGTFtagExonParentGeneName": "none",
            "--sjdbGTFtagExonParentGeneType": "none", "--sjdbOverhang": "none", "--sjdbScore": "none",
            "--sjdbInsertSave": [#{value: "Basic", desc: "only small junction / transcript files"}, #{value: "All", desc: "all files including big Genome, SA and SAindex - this will create a complete genome..."}],
            "--varVCFfile": "files", "--inputBAMfile": k("bam"),
            "--readFilesType": [#{value: "Fastx", desc: "FASTA or FASTQ"}],
            "--readFilesSAMattrKeep": [#{value: "All", desc: "keep all tags"}, #{value: "None", desc: "do not keep any tags"}],
            "--readFilesIn": k("sequences"), "--readFilesManifest": "files", "--readFilesPrefix": "files",
            "--readFilesCommand": "files", "--readMapNumber": "none", "--readMatesLengthsIn": "none",
            "--readNameSeparator": "none", "--readQualityScoreBase": "none",
            "--clipAdapterType": [#{value: "Hamming", desc: "adapter clipping based on Hamming distance, with the number of mismatches controlled..."}, #{value: "CellRanger4", desc: "5p and 3p adapter clipping similar to CellRanger4"}, #{value: "None", desc: "no adapter clipping, all other clip* parameters are disregarded"}],
            "--clip3pNbases": "none",
            "--clip3pAdapterSeq": [#{value: "polyA", desc: "polyA sequence with the length equal to read length"}],
            "--clip3pAdapterMMp": "none", "--clip3pAfterAdapterNbases": "none", "--clip5pNbases": "none",
            "--clip5pAdapterSeq": "none", "--clip5pAdapterMMp": "none", "--clip5pAfterAdapterNbases": "none",
            "--limitGenomeGenerateRAM": "none", "--limitIObufferSize": "none", "--limitOutSAMoneReadBytes": "none",
            "--limitOutSJoneRead": "none", "--limitOutSJcollapsed": "none", "--limitBAMsortRAM": "none",
            "--limitSjdbInsertNsj": "none", "--limitNreadsSoft": "none", "--outFileNamePrefix": "files",
            "--outTmpDir": "dirs",
            "--outTmpKeep": [#{value: "None", desc: "remove all temporary files"}, #{value: "All", desc: "keep all files"}],
            "--outStd": [#{value: "Log", desc: "log messages"}, #{value: "SAM", desc: "alignments in SAM format (which normally are output to Aligned.out.sam file), normal..."}, #{value: "BAM_Unsorted", desc: "alignments in BAM format, unsorted"}, #{value: "BAM_SortedByCoordinate", desc: "alignments in BAM format, sorted by coordinate"}, #{value: "BAM_Quant", desc: "alignments to transcriptome in BAM format, unsorted"}],
            "--outReadsUnmapped": [#{value: "None", desc: "no output"}, #{value: "Fastx", desc: "output in separate fasta/fastq files, Unmapped.out.mate1/2"}],
            "--outQSconversionAdd": "none",
            "--outMultimapperOrder": [#{value: "Old_2.4", desc: "quasi-random order used before 2.5.0"}, #{value: "Random", desc: "random order of alignments for each multi-mapper"}],
            "--outSAMtype": [#{value: "BAM", desc: "output BAM without sorting"}, #{value: "SAM", desc: "output SAM without sorting"}, #{value: "None", desc: "no SAM/BAM output"}, #{value: "Unsorted", desc: "standard unsorted"}, #{value: "SortedByCoordinate", desc: "sorted by coordinate"}],
            "--outSAMmode": [#{value: "None", desc: "no SAM output"}, #{value: "Full", desc: "full SAM output"}, #{value: "NoQS", desc: "full SAM but without quality scores"}],
            "--outSAMstrandField": [#{value: "None", desc: "not used"}, #{value: "intronMotif", desc: "strand derived from the intron motif"}],
            "--outSAMattributes": [#{value: "None", desc: "no attributes"}, #{value: "Standard", desc: "NH HI AS nM"}, #{value: "All", desc: "NH HI AS nM NM MD jM jI MC ch"}, #{value: "NH", desc: "number of loci the reads maps to: =1 for unique mappers, >1 for multimappers"}, #{value: "HI", desc: "multiple alignment index, starts with --outSAMattrIHstart (=1 by default)"}, #{value: "AS", desc: "local alignment score, +1/-1 for matches/mismateches, score* penalties for indels and gaps"}, #{value: "nM", desc: "number of mismatches"}, #{value: "NM", desc: "edit distance to the reference (number of mismatched + inserted + deleted bases) for..."}, #{value: "MD", desc: "string encoding mismatched and deleted reference bases (see standard SAM specifications)"}, #{value: "jM", desc: "intron motifs for all junctions (i.e"}, #{value: "jI", desc: "start and end of introns for all junctions (1-based)"}, #{value: "XS", desc: "alignment strand according to --outSAMstrandField"}, #{value: "MC", desc: "mate's CIGAR string"}, #{value: "ch", desc: "marks all segment of all chimeric alingments for --chimOutType WithinBAM output"}, #{value: "cN", desc: "number of bases clipped from the read ends: 5' and 3'"}, #{value: "vA", desc: "variant allele"}, #{value: "vG", desc: "genomic coordinate of the variant overlapped by the read"}, #{value: "vW", desc: "1 - alignment passes WASP filtering; 2,3,4,5,6,7 - alignment does not pass WASP filtering"}, #{value: "ha", desc: "haplotype (1/2) when mapping to the diploid genome"}, #{value: "sM", desc: "assessment of CB and UMI"}, #{value: "sS", desc: "sequence of the entire barcode (CB,UMI,adapter)"}, #{value: "sQ", desc: "quality of the entire barcode"}, #{value: "sF", desc: "type of feature overlap and number of features for each alignment"}, #{value: "rB", desc: "alignment block read/genomic coordinates"}, #{value: "vR", desc: "read coordinate of the variant"}],
            "--outSAMattrIHstart": "none",
            "--outSAMunmapped": [#{value: "None", desc: "no output"}, #{value: "Within", desc: "output unmapped reads within the main SAM file (i.e"}, #{value: "KeepPairs", desc: "record unmapped mate for each alignment, and, in case of unsorted output, keep it..."}],
            "--outSAMorder": "none",
            "--outSAMprimaryFlag": [#{value: "OneBestScore", desc: "only one alignment with the best score is primary"}, #{value: "AllBestScore", desc: "all alignments with the best score are primary"}],
            "--outSAMreadID": [#{value: "Standard", desc: "first word (until space) from the FASTx read ID line, removing /1,/2 from the end"}, #{value: "Number", desc: "read number (index) in the FASTx file"}],
            "--outSAMmapqUnique": "none", "--outSAMflagOR": "none", "--outSAMflagAND": "none",
            "--outSAMattrRGline": "none", "--outSAMheaderHD": "none", "--outSAMheaderPG": "none",
            "--outSAMfilter": [#{value: "KeepOnlyAddedReferences", desc: "only keep the reads for which all alignments are to the extra reference sequences..."}, #{value: "KeepAllAddedReferences", desc: "keep all alignments to the extra reference sequences added with --genomeFastaFiles at..."}],
            "--outSAMmultNmax": [#{value: "-1", desc: "all alignments (up to --outFilterMultimapNmax) will be output"}],
            "--outSAMtlen": [#{value: "1", desc: "leftmost base of the (+)strand mate to rightmost base of the (-)mate"}, #{value: "2", desc: "leftmost base of any mate to rightmost base of any mate"}],
            "--outBAMcompression": "none", "--outBAMsortingThreadN": "none", "--outBAMsortingBinsN": "none",
            "--bamRemoveDuplicatesType": [#{value: "-", desc: "no duplicate removal/marking"}, #{value: "UniqueIdentical", desc: "mark all multimappers, and duplicate unique mappers"}, #{value: "UniqueIdenticalNotMulti", desc: "mark duplicate unique mappers but not multimappers"}],
            "--bamRemoveDuplicatesMate2basesN": "none",
            "--outWigType": [#{value: "None", desc: "no signal output"}, #{value: "bedGraph", desc: "bedGraph format"}, #{value: "wiggle", desc: "wiggle format"}, #{value: "read1_5p", desc: "signal from only 5' of the 1st read, useful for CAGE/RAMPAGE etc"}, #{value: "read2", desc: "signal from only 2nd read"}],
            "--outWigStrand": [#{value: "Stranded", desc: "separate strands, str1 and str2"}, #{value: "Unstranded", desc: "collapsed strands"}],
            "--outWigReferencesPrefix": "files",
            "--outWigNorm": [#{value: "RPM", desc: "reads per million of mapped reads"}, #{value: "None", desc: "no normalization, 'raw' counts"}],
            "--outFilterType": [#{value: "Normal", desc: "standard filtering using only current alignment"}, #{value: "BySJout", desc: "keep only those reads that contain junctions that passed filtering into SJ.out.tab"}],
            "--outFilterMultimapScoreRange": "none", "--outFilterMultimapNmax": "none",
            "--outFilterMismatchNmax": "none", "--outFilterMismatchNoverLmax": "none",
            "--outFilterMismatchNoverReadLmax": "none", "--outFilterScoreMin": "none",
            "--outFilterScoreMinOverLread": "none", "--outFilterMatchNmin": "none",
            "--outFilterMatchNminOverLread": "none",
            "--outFilterIntronMotifs": [#{value: "None", desc: "no filtering"}, #{value: "RemoveNoncanonical", desc: "filter out alignments that contain non-canonical junctions"}, #{value: "RemoveNoncanonicalUnannotated", desc: "filter out alignments that contain non-canonical unannotated junctions when using..."}],
            "--outFilterIntronStrands": [#{value: "RemoveInconsistentStrands", desc: "remove alignments that have junctions with inconsistent strands"}, #{value: "None", desc: "no filtering"}],
            "--outSJtype": [#{value: "Standard", desc: "standard SJ.out.tab output"}, #{value: "None", desc: "no splice junction output"}],
            "--outSJfilterReads": [#{value: "All", desc: "all reads, unique- and multi-mappers"}, #{value: "Unique", desc: "uniquely mapping reads only"}],
            "--outSJfilterOverhangMin": "none", "--outSJfilterCountUniqueMin": "none",
            "--outSJfilterCountTotalMin": "none", "--outSJfilterDistToOtherSJmin": "none",
            "--outSJfilterIntronMaxVsReadN": "none", "--scoreGap": "none", "--scoreGapNoncan": "none",
            "--scoreGapGCAG": "none", "--scoreGapATAC": "none", "--scoreGenomicLengthLog2scale": "none",
            "--scoreDelOpen": "none", "--scoreDelBase": "none", "--scoreInsOpen": "none", "--scoreInsBase": "none",
            "--scoreStitchSJshift": "none", "--seedSearchStartLmax": "none",
            "--seedSearchStartLmaxOverLread": "none", "--seedSearchLmax": "none", "--seedMultimapNmax": "none",
            "--seedPerReadNmax": "none", "--seedPerWindowNmax": "none", "--seedNoneLociPerWindow": "none",
            "--seedSplitMin": "none", "--seedMapMin": "none", "--alignIntronMin": "none", "--alignIntronMax": "none",
            "--alignMatesGapMax": "none", "--alignSJoverhangMin": "none", "--alignSJstitchMismatchNmax": "none",
            "--alignSJDBoverhangMin": "none", "--alignSplicedMateMapLmin": "none",
            "--alignWindowsPerReadNmax": "none", "--alignTranscriptsPerWindowNmax": "none",
            "--alignTranscriptsPerReadNmax": "none",
            "--alignEndsType": [#{value: "Local", desc: "standard local alignment with soft-clipping allowed"}, #{value: "EndToEnd", desc: "force end-to-end read alignment, do not soft-clip"}, #{value: "Extend5pOfRead1", desc: "fully extend only the 5p of the read1, all other ends: local alignment"}, #{value: "Extend5pOfReads12", desc: "fully extend only the 5p of the both read1 and read2, all other ends: local alignment"}],
            "--alignEndsProtrude": [#{value: "ConcordantPair", desc: "report alignments with non-zero protrusion as concordant pairs"}, #{value: "DiscordantPair", desc: "report alignments with non-zero protrusion as discordant pairs"}],
            "--alignSoftClipAtReferenceEnds": [#{value: "Yes", desc: "allow"}, #{value: "No", desc: "prohibit, useful for compatibility with Cufflinks"}],
            "--alignInsertionFlush": [#{value: "None", desc: "insertions are not flushed"}, #{value: "Right", desc: "insertions are flushed to the right"}],
            "--peOverlapNbasesMin": "none", "--peOverlapMMp": "none", "--winAnchorMultimapNmax": "none",
            "--winBinNbits": "none", "--winAnchorDistNbins": "none", "--winFlankNbins": "none",
            "--winReadCoverageRelativeMin": "none", "--winReadCoverageBasesMin": "none",
            "--chimOutType": [#{value: "Junctions", desc: "chimeric.out.junction"}, #{value: "SeparateSAMold", desc: "output old SAM into separate Chimeric.out.sam file"}, #{value: "WithinBAM", desc: "output into main aligned BAM files (Aligned.*.bam)"}],
            "--chimSegmentMin": "none", "--chimScoreMin": "none", "--chimScoreDropMax": "none",
            "--chimScoreSeparation": "none", "--chimScoreJunctionNonGTAG": "none",
            "--chimJunctionOverhangMin": "none", "--chimSegmentReadGapMax": "none",
            "--chimFilter": [#{value: "None", desc: "no filtering"}, #{value: "banGenomicN", desc: "ns are not allowed in the genome sequence around the chimeric junction"}],
            "--chimMainSegmentMultNmax": "none",
            "--chimMultimapNmax": [#{value: "0", desc: "use the old scheme for chimeric detection which only considered unique alignments"}],
            "--chimMultimapScoreRange": "none", "--chimNonchimScoreDropMin": "none",
            "--chimOutJunctionFormat": [#{value: "0", desc: "no comment lines/headers"}, #{value: "1", desc: "comment lines at the end of the file: command line and Nreads: total, unique/multi-mapping"}],
            "--quantMode": [#{value: "-", desc: "none"}, #{value: "TranscriptomeSAM", desc: "output SAM/BAM alignments to transcriptome into a separate file"}, #{value: "GeneCounts", desc: "count reads per gene"}],
            "--quantTranscriptomeBAMcompression": [#{value: "-2", desc: "no BAM output"}, #{value: "-1", desc: "default compression (6?)"}, #{value: "0", desc: "no compression"}, #{value: "10", desc: "maximum compression"}, #{value: "BanSingleEnd_BanIndels_ExtendSoftclip", desc: "prohibit indels and single-end alignments, extend softclips - compatible with RSEM"}, #{value: "BanSingleEnd", desc: "prohibit single-end alignments, allow indels and softclips"}, #{value: "BanSingleEnd_ExtendSoftclip", desc: "prohibit single-end alignments, extend softclips, allow indels"}],
            "--twopassMode": [#{value: "None", desc: "1-pass mapping"}, #{value: "Basic", desc: "basic 2-pass mapping, with all 1st pass junctions inserted into the genome indices on..."}],
            "--twopass1readsN": "none",
            "--waspOutputMode": [#{value: "SAMtag", desc: "add WASP tags to the alignments that pass WASP filtering"}],
            "--soloType": [#{value: "CB_UMI_Simple", desc: "(a.k.a"}, #{value: "CB_UMI_Complex", desc: "multiple Cell Barcodes of varying length, one UMI of fixed length and one adapter..."}, #{value: "CB_samTagOut", desc: "output Cell Barcode as CR and/or CB SAm tag"}, #{value: "SmartSeq", desc: "smart-seq: each cell in a separate FASTQ (paired- or single-end), barcodes are..."}],
            "--soloCBtype": "none", "--soloCBwhitelist": "files", "--soloCBstart": "none", "--soloCBlen": "none",
            "--soloUMIstart": "none", "--soloUMIlen": "none",
            "--soloBarcodeReadLength": [#{value: "1", desc: "equal to sum of soloCBlen+soloUMIlen"}, #{value: "0", desc: "not defined, do not check"}],
            "--soloBarcodeMate": [#{value: "0", desc: "barcode sequence is on separate read, which should always be the last file in the..."}, #{value: "1", desc: "barcode sequence is a part of mate 1"}, #{value: "2", desc: "barcode sequence is a part of mate 2"}],
            "--soloCBposition": "none", "--soloUMIposition": "none", "--soloAdapterSequence": "none",
            "--soloAdapterMismatchesNmax": "none",
            "--soloCBmatchWLtype": [#{value: "Exact", desc: "only exact matches allowed"}, #{value: "1MM", desc: "only one match in whitelist with 1 mismatched base allowed"}, #{value: "1MM_multi", desc: "multiple matches in whitelist with 1 mismatched base allowed, posterior probability..."}, #{value: "1MM_multi_pseudocounts", desc: "same as 1MM_Multi, but pseudocounts of 1 are added to all whitelist barcodes"}, #{value: "1MM_multi_Nbase_pseudocounts", desc: "same as 1MM_multi_pseudocounts, multimatching to WL is allowed for CBs with N-bases"}, #{value: "EditDist_2", desc: "allow up to edit distance of 3 fpr each of the barcodes"}],
            "--soloInputSAMattrBarcodeSeq": "files", "--soloInputSAMattrBarcodeQual": "files",
            "--soloStrand": [#{value: "Unstranded", desc: "no strand information"}, #{value: "Forward", desc: "read strand same as the original RNA molecule"}, #{value: "Reverse", desc: "read strand opposite to the original RNA molecule"}],
            "--soloFeatures": [#{value: "Gene", desc: "genes: reads match the gene transcript"}, #{value: "SJ", desc: "splice junctions: reported in SJ.out.tab"}, #{value: "GeneFull", desc: "full gene (pre-mRNA): count all reads overlapping genes' exons and introns"}, #{value: "GeneFull_ExonOverIntron", desc: "full gene (pre-mRNA): count all reads overlapping genes' exons and introns: prioritize..."}, #{value: "GeneFull_Ex50pAS", desc: "full gene (pre-RNA): count all reads overlapping genes' exons and introns: prioritize..."}, #{value: "Transcript3p", desc: "quantification of transcript for 3' protocols"}],
            "--soloMultiMappers": [#{value: "Unique", desc: "count only reads that map to unique genes"}, #{value: "Uniform", desc: "uniformly distribute multi-genic UMIs to all genes"}, #{value: "Rescue", desc: "distribute UMIs proportionally to unique+uniform counts (~ first iteration of EM)"}, #{value: "PropUnique", desc: "distribute UMIs proportionally to unique mappers, if present, and uniformly if not"}, #{value: "EM", desc: "multi-gene UMIs are distributed using Expectation Maximization algorithm"}],
            "--soloUMIdedup": [#{value: "1MM_All", desc: "all UMIs with 1 mismatch distance to each other are collapsed (i.e"}, #{value: "1MM_Directional_UMItools", desc: "follows the 'directional' method from the UMI-tools by Smith, Heger and Sudbery..."}, #{value: "1MM_Directional", desc: "same as 1MM_Directional_UMItools, but with more stringent criteria for duplicate UMIs"}, #{value: "Exact", desc: "only exactly matching UMIs are collapsed"}, #{value: "NoDedup", desc: "no deduplication of UMIs, count all reads"}, #{value: "1MM_CR", desc: "cellRanger2-4 algorithm for 1MM UMI collapsing"}],
            "--soloUMIfiltering": [#{value: "-", desc: "basic filtering: remove UMIs with N and homopolymers (similar to CellRanger 2.2.0)"}, #{value: "MultiGeneUMI", desc: "basic + remove lower-count UMIs that map to more than one gene"}, #{value: "MultiGeneUMI_All", desc: "basic + remove all UMIs that map to more than one gene"}, #{value: "MultiGeneUMI_CR", desc: "basic + remove lower-count UMIs that map to more than one gene, matching CellRanger >..."}],
            "--soloOutFileNames": "files",
            "--soloCellFilter": [#{value: "None", desc: "do not output filtered cells"}, #{value: "TopCells", desc: "only report top cells by UMI count, followed by the exact number of cells"}, #{value: "CellRanger2.2", desc: "simple filtering of CellRanger 2.2"}, #{value: "EmptyDrops_CR", desc: "emptyDrops filtering in CellRanger flavor"}],
            "--soloOutFormatFeaturesGeneField3": "files",
            "--soloCellReadStats": [#{value: "Standard", desc: "standard output"}],
            "--soloClusterCBfile": "files",
        },
        strict_eq: true,
    }
}

fn kallisto() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: `
            index      build a kallisto index
            quant      run the quantification algorithm
            quant-tcc  run quantification on transcript-compatibility counts
            bus        generate BUS files for single-cell data
            h5dump     convert HDF5-formatted results to plaintext
            inspect    inspect an index and give information about it
            version    print version information
            cite       print citation information
        `,
        sub_spec: "@extra-complete/bio/align:kallisto",
    }
}

fn kallisto_sub(sub) {
    switch sub {
        "index" => #{
        opts: `
            -i, --index=STRING        filename for the kallisto index to be constructed
            -k, --kmer-size=INT       k-mer (odd) length
            -t, --threads=INT         number of threads to use
            -d, --d-list=STRING Path  to a FASTA-file containing sequences to mask from quantification
            --make-unique             replace repeated target names with unique names
            --aa                      generate index from a FASTA-file containing amino acid sequences
            --distinguish             generate index where sequences are distinguished by the sequence name
            -T, --tmp=STRING          temporary directory
            -m, --min-size=INT        length of minimizers
            -e, --ec-max-size=INT     maximum number of targets in an equivalence class
        `,
        values: #{
            "-d": k("fasta"), "--d-list=STRING": k("fasta"), "-i": k("kallisto_index"),
            "--index": k("kallisto_index"), "-o": "dirs", "--output-dir": "dirs", "-g": k("gff"),
            "--gtf": k("gff"), "-c": "files", "--chromosomes": "files", "--d-list": k("fasta"), "-T": "dirs",
            "--tmp": "dirs", "-B": "files", "--batch": "files", "-p": "files", "--priors": "files",
        },
        args: [k("fasta")],
        },
        "quant" => #{
        opts: `
            -i, --index=STRING            filename for the kallisto index to be used for quantification
            -o, --output-dir=STRING       directory to write output to
            -b, --bootstrap-samples=INT   number of bootstrap samples
            --seed=INT                    seed for the bootstrap sampling
            --plaintext                   output plaintext instead of HDF5
            --single                      quantify single-end reads
            --single-overhang             include reads where unobserved rest of fragment is predicted to lie outside a transcript
            --fr-stranded                 strand specific reads, first read forward
            --rf-stranded                 strand specific reads, first read reverse
            -l, --fragment-length=DOUBLE  estimated average fragment length
            -s, --sd=DOUBLE               estimated standard deviation of fragment length
            -p, --priors                  priors for the EM algorithm, either as raw counts or as probabilities
            --pseudobam                   save pseudoalignments to transcriptome to BAM file
            --genomebam                   project pseudoalignments to genome sorted BAM file
            -g, --gtf GTF file            for transcriptome information (required for --genomebam)
            -c, --chromosomes             tab separated file with chromosome names and lengths
            -t, --threads=INT             number of threads to use
            --verbose                     print out progress information every 1M proccessed reads
        `,
        values: #{
            "-g": k("gff"), "--gtf": k("gff"), "-i": k("kallisto_index"), "--index": k("kallisto_index"),
            "-o": "dirs", "--output-dir": "dirs", "-c": "files", "--chromosomes": "files", "-d": k("fasta"),
            "--d-list": k("fasta"), "-T": "dirs", "--tmp": "dirs", "-B": "files", "--batch": "files",
            "-p": "files", "--priors": "files",
        },
        args: [k("fastq")],
        },
        "bus" => #{
        opts: `
            -i, --index=STRING       filename for the kallisto index to be used for pseudoalignment
            -o, --output-dir=STRING  directory to write output to
            -x, --technology=STRING  single-cell technology used
            -l, --list               list all single-cell technologies supported
            -B, --batch=FILE         process files listed in FILE
            -t, --threads=INT        number of threads to use
            -b, --bam                input file is a BAM file
            -n, --num                output number of read in flag column (incompatible with --bam)
            -N, --numReads           maximum number of reads to process from supplied input
            -T, --tag=STRING         5′ tag sequence to identify UMI reads for certain technologies
            --fr-stranded            strand specific reads for UMI-tagged reads, first read forward
            --rf-stranded            strand specific reads for UMI-tagged reads, first read reverse
            --unstranded             treat all read as non-strand-specific
            --paired                 treat reads as paired
            --long                   treat reads as long
            --threshold              threshold for rate of unmapped kmers per read
            --aa                     align to index generated from a FASTA-file containing amino acid sequences
            --inleaved               specifies that input is an interleaved FASTQ file
            --batch-barcodes         records both batch and extracted barcode in BUS file
            --genomebam              project pseudoalignments to genome sorted BAM file
            -g, --gtf GTF file       for transcriptome information (required for --genomebam)
            -c, --chromosomes        tab separated file with chromosome names and lengths
            --verbose                print out progress information every 1M proccessed reads
        `,
        values: #{
            "-g": k("gff"), "--gtf": k("gff"), "-i": k("kallisto_index"), "--index": k("kallisto_index"),
            "-o": "dirs", "--output-dir": "dirs", "-c": "files", "--chromosomes": "files", "-d": k("fasta"),
            "--d-list": k("fasta"), "-T": "dirs", "--tmp": "dirs", "-B": "files", "--batch": "files",
            "-p": "files", "--priors": "files", "-x": "none",
        },
        args: [k("fastq")],
        },
        "h5dump" => #{
        opts: `
            -o, --output-dir=STRING  directory to write output to
        `,
        values: #{
            "-i": k("kallisto_index"), "--index": k("kallisto_index"), "-o": "dirs", "--output-dir": "dirs",
            "-g": k("gff"), "--gtf": k("gff"), "-c": "files", "--chromosomes": "files", "-d": k("fasta"),
            "--d-list": k("fasta"), "-T": "dirs", "--tmp": "dirs", "-B": "files", "--batch": "files",
            "-p": "files", "--priors": "files",
        },
        args: ["files"],
        },
        "inspect" => #{
        opts: `
            -t  number of threads
        `,
        args: [k("kallisto_index")],
        },
        _ => (),
    }
}

fn featurecounts() {
    #{
        opts: `
            -a <string>                   name of an annotation file
            -o <string>                   name of output file including read counts
            -F <string>                   specify format of the provided annotation file
            -t <string>                   specify feature type(s) in a GTF annotation
            -g <string>                   specify attribute type in GTF annotation
            --extraAttributes             extract extra attribute types from the provided GTF annotation and include them in the
            -A <string>                   provide a chromosome name alias file to match chr names in annotation with those in the
            -f                            perform read counting at feature level
            -O                            assign reads to all their overlapping meta-features (or features if -f is specified)
            --minOverlap <int>            minimum number of overlapping bases in a read that is required for read assignment
            --fracOverlap <float>         minimum fraction of overlapping bases in a read that is required for read assignment
            --fracOverlapFeature <float>  minimum fraction of overlapping bases in a feature that is required for read assignment
            --largestOverlap              assign reads to a meta-feature/feature that has the largest number of overlapping bases
            --nonOverlap <int>            maximum number of non-overlapping bases in a read (or a read pair) that is allowed when
            --nonOverlapFeature <int>     maximum number of non-overlapping bases in a feature that is allowed in read assignment
            --readExtension5 <int>        reads are extended upstream by <int> bases from their 5' end
            --readExtension3 <int>        reads are extended upstream by <int> bases from their 3' end
            --read2pos <5:3>              reduce reads to their 5' most base or 3' most base
            -M                            multi-mapping reads will also be counted
            --fraction                    assign fractional counts to features
            -Q <int>                      the minimum mapping quality score a read must satisfy in order to be counted
            --splitOnly                   count split alignments only
            --nonSplitOnly                if specified, only non-split alignments (CIGAR strings do not contain letter 'N') will be
            --primary                     count primary alignments only
            --ignoreDup                   ignore duplicate reads in read counting
            -s <int or string>            perform strand-specific read counting
            -J                            count number of reads supporting each exon-exon junction
            -G <string>                   provide the name of a FASTA-format file that contains the reference sequences used in
            -p                            if specified, libraries are assumed to contain paired-end reads
            --countReadPairs              if specified, fragments (or templates) will be counted instead of reads
            -B                            only count read pairs that have both ends aligned
            -P                            check validity of paired-end distance when counting read pairs
            -d <int>                      minimum fragment/template length, 50 by default
            -D <int>                      maximum fragment/template length, 600 by default
            -C                            do not count read pairs that have their two ends mapping to different chromosomes or
            --donotsort                   do not sort reads in BAM/SAM input
            -T <int>                      number of the threads
            --byReadGroup                 assign reads by read group
            -L                            count long reads such as Nanopore and PacBio reads
            -R <format>                   output detailed assignment results for each read or read- pair
            --Rpath <string>              specify a directory to save the detailed assignment results
            --tmpDir <string>             directory under which intermediate files are saved (later removed)
            --verbose                     output verbose information for debugging, such as un- matched chromosome/contig names
            -v                            output version of the program
        `,
        values: #{
            "-a": k("gff"), "-o": "files", "-F": ["GTF", "SAF"], "-t": "none", "-g": "none", "-A": "files",
            "--minOverlap": "none", "--fracOverlap": "none", "--fracOverlapFeature": "none",
            "--nonOverlap": "none", "--nonOverlapFeature": "none", "--readExtension5": "none",
            "--readExtension3": "none", "--read2pos": ["5", "3"], "-Q": "none", "-s": ["0", "1", "2"],
            "-G": k("fasta"), "-d": "none", "-D": "none", "-T": "none", "-R": ["CORE", "SAM", "BAM"],
            "--Rpath": "dirs", "--tmpDir": "dirs",
        },
        args: [k("sam")],
    }
}

fn spec(cmd) {
    switch cmd {
        "bwa" => bwa(),
        "bwa-mem2" => bwa_mem2(),
        "bowtie2" => bowtie2(),
        "bowtie2-build" => bowtie2_build(),
        "hisat2" => hisat2(),
        "hisat2-build" => hisat2_build(),
        "minimap2" => minimap2(),
        "STAR" => star(),
        "kallisto" => kallisto(),
        "featureCounts" => featurecounts(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "bwa" => bwa_sub(sub),
        "bwa-mem2" => bwa_mem2_sub(sub),
        "kallisto" => kallisto_sub(sub),
        _ => (),
    }
}
