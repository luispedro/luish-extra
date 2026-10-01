// DIAMOND, from `diamond COMMAND` (2.2.8). diamond does not say which options
// take a value, so the switches are listed in the generator of this file.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

fn diamond() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: `
            makedb               build a DIAMOND database from a FASTA file
            blastp               align amino acid query sequences against a protein reference database
            blastx               align DNA query sequences against a protein reference database
            cluster              cluster protein sequences
            linclust             cluster protein sequences in linear time
            realign              realign clustered sequences against their centroids
            recluster            recompute the clustering to fix errors
            reassign             reassign clustered sequences to the closest centroid
            view                 view a DIAMOND alignment archive (DAA) file
            merge-daa            merge DAA files
            help                 produce a help message
            version              display the version information
            getseq               retrieve sequences from a DIAMOND database file
            dbinfo               print information about a DIAMOND database file
            test                 run the regression tests
            makeidx              make a database index
            greedy-vertex-cover  compute a greedy vertex cover
            countdistinct        count the distinct sequences in a FASTA file
        `,
        sub_spec: own("diamond:diamond"),
    }
}

fn diamond_sub(sub) {
    switch sub {
        "makedb" => #{
            opts: `
                -p, --threads VALUE       number of CPU threads
                --log                     enable debug log
                --quiet                   disable console output
                -t, --tmpdir VALUE        directory for temporary files
                --keep-temp-files         do not delete temporarary files
                -d, --db VALUE            database file
                --in VALUE                input reference file in FASTA format/input DAA files for merge-daa
                --taxonmap VALUE          protein accession to taxid mapping file
                --taxonnodes VALUE        taxonomy nodes.dmp from NCBI
                --taxonnames VALUE        taxonomy names.dmp from NCBI
                --file-buffer-size VALUE  file buffer size in bytes
                --no-unlink               do not unlink temporary files
                --ignore-warnings         ignore warnings
                --no-parse-seqids         print raw seqids without parsing
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": "files", "--db": "files",
                "--in": k("sequences"), "--taxonmap": "files", "--taxonnodes": "files", "--taxonnames": "files",
                "--file-buffer-size": "none",
            },
            args: ["none"],
        },
        "blastp" => #{
            opts: `
                -p, --threads VALUE                     number of CPU threads
                --log                                   enable debug log
                --quiet                                 disable console output
                -t, --tmpdir VALUE                      directory for temporary files
                --keep-temp-files                       do not delete temporarary files
                -d, --db VALUE                          database file
                -o, --out VALUE                         output file
                --header VALUE                          use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE                composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE      tolerance for matrix adjust relative entropy
                --masking VALUE                         masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                    soft masking (none=default, seg, tantan)
                --gapopen VALUE                         gap open penalty
                --gapextend VALUE                       gap extension penalty
                --matrix VALUE                          score matrix for protein alignment
                --custom-matrix VALUE                   file containing custom scoring matrix
                -e, --evalue VALUE                      maximum e-value to report alignments
                --motif-masking VALUE                   softmask abundant motifs (0/1)
                --approx-id VALUE                       minimum approx
                --id VALUE                              minimum identity% to report an alignment
                --ext VALUE                             extension mode (banded-fast/banded-slow/full/global/none)
                --min-len-ratio VALUE                   sequence length ratio cutoff for mutual coverage
                -k, --max-target-seqs VALUE             maximum number of target sequences to report alignments for
                --top VALUE                             report alignments within this percentage range of top alignment score
                --faster                                enable faster mode
                --fast                                  enable fast mode
                --mid-sensitive                         enable mid-sensitive mode
                --linclust-20                           enable mode for linear search at 20% identity
                --shapes-6x10                           enable mode using 30 seed shapes of weight 10
                --shapes-30x10                          enable mode using 30 seed shapes of weight 10
                --sensitive                             enable sensitive mode
                --more-sensitive                        enable more sensitive mode
                --very-sensitive                        enable very sensitive mode
                --ultra-sensitive                       enable ultra sensitive mode
                --shapes VALUE                          number of seed shapes
                -q, --query VALUE                       input query file
                --strand VALUE                          query strands to search (both/minus/plus)
                --un VALUE                              file for unaligned queries
                --al VALUE                              file or aligned queries
                --unfmt VALUE                           format of unaligned query file (fasta/fastq)
                --alfmt VALUE                           format of aligned query file (fasta/fastq)
                --unal VALUE                            report unaligned queries (0=no, 1=yes)
                --max-hsps VALUE                        maximum number of HSPs per target sequence to report for each query
                --range-culling                         restrict hit culling to overlapping query ranges
                --compress VALUE                        compression for output files (0=none, 1=gzip, zstd)
                --min-score VALUE                       minimum bit score to report alignments (overrides e-value setting)
                --query-cover VALUE                     minimum query cover% to report an alignment
                --subject-cover VALUE                   minimum subject cover% to report an alignment
                --swipe                                 exhaustive alignment against all database sequences
                --iterate VALUE                         iterated search with increasing sensitivity
                --global-ranking VALUE                  number of targets for global ranking
                -b, --block-size VALUE                  sequence block size in billions of letters
                -c, --index-chunks VALUE                number of chunks for index processing
                -F, --frameshift VALUE                  frame shift penalty
                --long-reads                            short for --range-culling --top 10 -F 15
                --query-gencode VALUE                   genetic code to use to translate query (see user manual)
                --salltitles                            include full subject titles in DAA file
                --sallseqid                             include all subject ids in DAA file
                --no-self-hits                          suppress reporting of identical self hits
                --taxonlist VALUE                       restrict search to list of taxon ids (comma-separated)
                --taxon-exclude VALUE                   exclude list of taxon ids (comma-separated)
                --seqidlist VALUE                       filter the database by list of accessions
                --skip-missing-seqids                   ignore accessions missing in the database
                --symmetrize-evalue                     symmetrize evalues over queries and targets
                -f, --outfmt VALUE                      output format
                --include-lineage                       include lineage in the taxonomic classification format
                --file-buffer-size VALUE                file buffer size in bytes
                --no-unlink                             do not unlink temporary files
                --ignore-warnings                       ignore warnings
                --no-parse-seqids                       print raw seqids without parsing
                --parallel-tmpdir VALUE                 directory for temporary files used by multiprocessing
                --bin VALUE                             number of query bins for seed search
                --ext-chunk-size VALUE                  chunk size for adaptive ranking
                --no-ranking                            disable ranking heuristic
                --dbsize VALUE                          effective database size (in letters)
                --no-auto-append                        disable auto appending of DAA and DMND file extensions
                --tantan-minMaskProb VALUE              minimum repeat probability for masking
                --oid-output                            output OIDs instead of accessions (clustering)
                --swipe-task-size VALUE                 task size for DP parallelism (100000000)
                --query-match-distance-threshold VALUE  matrix adjust threshold
                --length-ratio-threshold VALUE          matrix adjust threshold
                --cbs-angle VALUE                       matrix adjust threshold
                --hit-membuf                            buffer intermediate hits in memory
                --fpu-compat                            floating point operations compatibility mode
                --no-mempool                            disable per-thread memory pool
                --new-ext                               enable new extension pipeline
                --algo VALUE                            seed search algorithm (0=double-indexed/1=query-indexed/ctg=contiguous-seed)
                --min-orf VALUE                         ignore translated sequences without an open reading frame of at least this length
                --min-query-len VALUE                   filter query sequences shorter than this length
                --load-threads VALUE                    number of CPU threads for file I/O
                --minichunk VALUE                       mini chunk size for file I/O
                --seed-cut VALUE                        cutoff for seed complexity
                --freq-masking VALUE                    mask seeds based on frequency
                --freq-sd VALUE                         number of standard deviations for ignoring frequent seeds
                --sketch-size VALUE                     subsample seeds based on minimizer sketch of the given size
                --tile-size VALUE                       loop tiling size
                --id2 VALUE                             minimum number of identities for stage 1 hit
                --linsearch                             only consider seed hits against longest target for identical seeds
                --lin-stage1                            only consider seed hits against longest query for identical seeds
                --xdrop VALUE                           xdrop for ungapped alignment
                --reseek-xdrop VALUE                    xdrop for ungapped alignment (using --reseek-diags)
                --ungapped-evalue VALUE                 e-value threshold for ungapped filter (auto)
                --ungapped-evalue-short VALUE           e-value threshold for ungapped filter (short reads) (auto)
                --short-query-ungapped-bitscore VALUE   bit score threshold for ungapped alignments for short queries
                --gapped-filter-evalue VALUE            e-value threshold for gapped filter (auto)
                --band VALUE                            band for dynamic programming computation
                --shape-mask VALUE                      seed shapes
                --taxdump VALUE                         directory containing NCBI taxdump files
                --reseek-diags                          recompute diagonals prior to chaining
                --word-threshold VALUE                  word threshold in bits
                --double-hit-window VALUE               window for double hits
                --multiprocessing                       enable distributed-memory parallel processing
                --mp-init                               initialize multiprocessing run
                --mp-recover                            enable continuation of interrupted multiprocessing run
                --mp-query-chunk VALUE                  process only a single query chunk as specified
                --culling-overlap VALUE                 minimum range overlap with higher scoring hit to delete a hit
                --taxon-k VALUE                         maximum number of targets to report per species
                --range-cover VALUE                     percentage of query range to be covered for range culling
                --xml-blord-format                      use gnl|BL_ORD_ID| style format in XML output
                --sam-query-len                         add the query length to the SAM format (tag ZQ)
                --stop-match-score VALUE                set the match score of stop codons against each other
                --target-indexed                        enable target-indexed mode
                --self                                  enable self-alignment
                --no-reorder                            do not reorder alignment output
                --daa-build-version VALUE               diamond build version to write to DAA file
                --daa VALUE                             DIAMOND alignment archive (DAA) file
                --window VALUE                          window size for local hit search
                --ungapped-score VALUE                  minimum alignment score to continue local extension
                --hit-band VALUE                        band for hit verification
                --hit-score VALUE                       minimum score to keep a tentative alignment
                --gapped-xdrop VALUE                    xdrop for gapped alignment in bits
                --rank-ratio2 VALUE                     include subjects within this ratio of last hit (stage 2)
                --rank-ratio VALUE                      include subjects within this ratio of last hit
                --lambda VALUE                          lambda parameter for custom matrix
                --K VALUE                               k parameter for custom matrix
                -v, --verbose                           verbose console output
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "--gapopen": "none", "--gapextend": "none",
                "--matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"],
                "--custom-matrix": "files", "-e": "none", "--evalue": "none", "--motif-masking": ["0", "1"],
                "--approx-id": "none", "--id": "none",
                "--ext": ["banded-fast", "banded-slow", "full", "global", "none"], "--min-len-ratio": "none",
                "-k": "none", "--max-target-seqs": "none", "--top": "none", "--shapes": "none", "-q": k("sequences"),
                "--query": k("sequences"), "--strand": ["both", "minus", "plus"], "--un": "files", "--al": "files",
                "--unfmt": ["fasta", "fastq"], "--alfmt": ["fasta", "fastq"], "--unal": ["0", "1"],
                "--max-hsps": "none", "--compress": ["0", "1", "zstd"], "--min-score": "none",
                "--query-cover": "none", "--subject-cover": "none", "--iterate": "none", "--global-ranking": "none",
                "-b": "none", "--block-size": "none", "-c": "none", "--index-chunks": "none", "-F": "none",
                "--frameshift": "none", "--query-gencode": "none", "--taxonlist": "none", "--taxon-exclude": "none",
                "--seqidlist": "files",
                "-f": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--outfmt": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--file-buffer-size": "none", "--parallel-tmpdir": "dirs", "--bin": "none",
                "--ext-chunk-size": "none", "--dbsize": "none", "--tantan-minMaskProb": "none",
                "--swipe-task-size": "none", "--query-match-distance-threshold": "none",
                "--length-ratio-threshold": "none", "--cbs-angle": "none", "--algo": ["0", "1", "ctg"],
                "--min-orf": "none", "--min-query-len": "none", "--load-threads": "none", "--minichunk": "none",
                "--seed-cut": "none", "--freq-masking": "none", "--freq-sd": "none", "--sketch-size": "none",
                "--tile-size": "none", "--id2": "none", "--xdrop": "none", "--reseek-xdrop": "none",
                "--ungapped-evalue": "none", "--ungapped-evalue-short": "none",
                "--short-query-ungapped-bitscore": "none", "--gapped-filter-evalue": "none", "--band": "none",
                "--shape-mask": "none", "--taxdump": "dirs", "--word-threshold": "none",
                "--double-hit-window": "none", "--mp-query-chunk": "none", "--culling-overlap": "none",
                "--taxon-k": "none", "--range-cover": "none", "--stop-match-score": "none",
                "--daa-build-version": "none", "--daa": "files", "--window": "none", "--ungapped-score": "none",
                "--hit-band": "none", "--hit-score": "none", "--gapped-xdrop": "none", "--rank-ratio2": "none",
                "--rank-ratio": "none", "--lambda": "none", "--K": "none",
            },
            args: ["none"],
        },
        "blastx" => #{
            opts: `
                -p, --threads VALUE                     number of CPU threads
                --log                                   enable debug log
                --quiet                                 disable console output
                -t, --tmpdir VALUE                      directory for temporary files
                --keep-temp-files                       do not delete temporarary files
                -d, --db VALUE                          database file
                -o, --out VALUE                         output file
                --header VALUE                          use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE                composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE      tolerance for matrix adjust relative entropy
                --masking VALUE                         masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                    soft masking (none=default, seg, tantan)
                --gapopen VALUE                         gap open penalty
                --gapextend VALUE                       gap extension penalty
                --matrix VALUE                          score matrix for protein alignment
                --custom-matrix VALUE                   file containing custom scoring matrix
                -e, --evalue VALUE                      maximum e-value to report alignments
                --motif-masking VALUE                   softmask abundant motifs (0/1)
                --approx-id VALUE                       minimum approx
                --id VALUE                              minimum identity% to report an alignment
                --ext VALUE                             extension mode (banded-fast/banded-slow/full/global/none)
                --min-len-ratio VALUE                   sequence length ratio cutoff for mutual coverage
                -k, --max-target-seqs VALUE             maximum number of target sequences to report alignments for
                --top VALUE                             report alignments within this percentage range of top alignment score
                --faster                                enable faster mode
                --fast                                  enable fast mode
                --mid-sensitive                         enable mid-sensitive mode
                --linclust-20                           enable mode for linear search at 20% identity
                --shapes-6x10                           enable mode using 30 seed shapes of weight 10
                --shapes-30x10                          enable mode using 30 seed shapes of weight 10
                --sensitive                             enable sensitive mode
                --more-sensitive                        enable more sensitive mode
                --very-sensitive                        enable very sensitive mode
                --ultra-sensitive                       enable ultra sensitive mode
                --shapes VALUE                          number of seed shapes
                -q, --query VALUE                       input query file
                --strand VALUE                          query strands to search (both/minus/plus)
                --un VALUE                              file for unaligned queries
                --al VALUE                              file or aligned queries
                --unfmt VALUE                           format of unaligned query file (fasta/fastq)
                --alfmt VALUE                           format of aligned query file (fasta/fastq)
                --unal VALUE                            report unaligned queries (0=no, 1=yes)
                --max-hsps VALUE                        maximum number of HSPs per target sequence to report for each query
                --range-culling                         restrict hit culling to overlapping query ranges
                --compress VALUE                        compression for output files (0=none, 1=gzip, zstd)
                --min-score VALUE                       minimum bit score to report alignments (overrides e-value setting)
                --query-cover VALUE                     minimum query cover% to report an alignment
                --subject-cover VALUE                   minimum subject cover% to report an alignment
                --swipe                                 exhaustive alignment against all database sequences
                --iterate VALUE                         iterated search with increasing sensitivity
                --global-ranking VALUE                  number of targets for global ranking
                -b, --block-size VALUE                  sequence block size in billions of letters
                -c, --index-chunks VALUE                number of chunks for index processing
                -F, --frameshift VALUE                  frame shift penalty
                --long-reads                            short for --range-culling --top 10 -F 15
                --query-gencode VALUE                   genetic code to use to translate query (see user manual)
                --salltitles                            include full subject titles in DAA file
                --sallseqid                             include all subject ids in DAA file
                --no-self-hits                          suppress reporting of identical self hits
                --taxonlist VALUE                       restrict search to list of taxon ids (comma-separated)
                --taxon-exclude VALUE                   exclude list of taxon ids (comma-separated)
                --seqidlist VALUE                       filter the database by list of accessions
                --skip-missing-seqids                   ignore accessions missing in the database
                --symmetrize-evalue                     symmetrize evalues over queries and targets
                -f, --outfmt VALUE                      output format
                --include-lineage                       include lineage in the taxonomic classification format
                --file-buffer-size VALUE                file buffer size in bytes
                --no-unlink                             do not unlink temporary files
                --ignore-warnings                       ignore warnings
                --no-parse-seqids                       print raw seqids without parsing
                --parallel-tmpdir VALUE                 directory for temporary files used by multiprocessing
                --bin VALUE                             number of query bins for seed search
                --ext-chunk-size VALUE                  chunk size for adaptive ranking
                --no-ranking                            disable ranking heuristic
                --dbsize VALUE                          effective database size (in letters)
                --no-auto-append                        disable auto appending of DAA and DMND file extensions
                --tantan-minMaskProb VALUE              minimum repeat probability for masking
                --oid-output                            output OIDs instead of accessions (clustering)
                --swipe-task-size VALUE                 task size for DP parallelism (100000000)
                --query-match-distance-threshold VALUE  matrix adjust threshold
                --length-ratio-threshold VALUE          matrix adjust threshold
                --cbs-angle VALUE                       matrix adjust threshold
                --hit-membuf                            buffer intermediate hits in memory
                --fpu-compat                            floating point operations compatibility mode
                --no-mempool                            disable per-thread memory pool
                --new-ext                               enable new extension pipeline
                --algo VALUE                            seed search algorithm (0=double-indexed/1=query-indexed/ctg=contiguous-seed)
                --min-orf VALUE                         ignore translated sequences without an open reading frame of at least this length
                --min-query-len VALUE                   filter query sequences shorter than this length
                --load-threads VALUE                    number of CPU threads for file I/O
                --minichunk VALUE                       mini chunk size for file I/O
                --seed-cut VALUE                        cutoff for seed complexity
                --freq-masking VALUE                    mask seeds based on frequency
                --freq-sd VALUE                         number of standard deviations for ignoring frequent seeds
                --sketch-size VALUE                     subsample seeds based on minimizer sketch of the given size
                --tile-size VALUE                       loop tiling size
                --id2 VALUE                             minimum number of identities for stage 1 hit
                --linsearch                             only consider seed hits against longest target for identical seeds
                --lin-stage1                            only consider seed hits against longest query for identical seeds
                --xdrop VALUE                           xdrop for ungapped alignment
                --reseek-xdrop VALUE                    xdrop for ungapped alignment (using --reseek-diags)
                --ungapped-evalue VALUE                 e-value threshold for ungapped filter (auto)
                --ungapped-evalue-short VALUE           e-value threshold for ungapped filter (short reads) (auto)
                --short-query-ungapped-bitscore VALUE   bit score threshold for ungapped alignments for short queries
                --gapped-filter-evalue VALUE            e-value threshold for gapped filter (auto)
                --band VALUE                            band for dynamic programming computation
                --shape-mask VALUE                      seed shapes
                --taxdump VALUE                         directory containing NCBI taxdump files
                --reseek-diags                          recompute diagonals prior to chaining
                --word-threshold VALUE                  word threshold in bits
                --double-hit-window VALUE               window for double hits
                --multiprocessing                       enable distributed-memory parallel processing
                --mp-init                               initialize multiprocessing run
                --mp-recover                            enable continuation of interrupted multiprocessing run
                --mp-query-chunk VALUE                  process only a single query chunk as specified
                --culling-overlap VALUE                 minimum range overlap with higher scoring hit to delete a hit
                --taxon-k VALUE                         maximum number of targets to report per species
                --range-cover VALUE                     percentage of query range to be covered for range culling
                --xml-blord-format                      use gnl|BL_ORD_ID| style format in XML output
                --sam-query-len                         add the query length to the SAM format (tag ZQ)
                --stop-match-score VALUE                set the match score of stop codons against each other
                --target-indexed                        enable target-indexed mode
                --self                                  enable self-alignment
                --no-reorder                            do not reorder alignment output
                --daa-build-version VALUE               diamond build version to write to DAA file
                --daa VALUE                             DIAMOND alignment archive (DAA) file
                --window VALUE                          window size for local hit search
                --ungapped-score VALUE                  minimum alignment score to continue local extension
                --hit-band VALUE                        band for hit verification
                --hit-score VALUE                       minimum score to keep a tentative alignment
                --gapped-xdrop VALUE                    xdrop for gapped alignment in bits
                --rank-ratio2 VALUE                     include subjects within this ratio of last hit (stage 2)
                --rank-ratio VALUE                      include subjects within this ratio of last hit
                --lambda VALUE                          lambda parameter for custom matrix
                --K VALUE                               k parameter for custom matrix
                -v, --verbose                           verbose console output
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "--gapopen": "none", "--gapextend": "none",
                "--matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"],
                "--custom-matrix": "files", "-e": "none", "--evalue": "none", "--motif-masking": ["0", "1"],
                "--approx-id": "none", "--id": "none",
                "--ext": ["banded-fast", "banded-slow", "full", "global", "none"], "--min-len-ratio": "none",
                "-k": "none", "--max-target-seqs": "none", "--top": "none", "--shapes": "none", "-q": k("sequences"),
                "--query": k("sequences"), "--strand": ["both", "minus", "plus"], "--un": "files", "--al": "files",
                "--unfmt": ["fasta", "fastq"], "--alfmt": ["fasta", "fastq"], "--unal": ["0", "1"],
                "--max-hsps": "none", "--compress": ["0", "1", "zstd"], "--min-score": "none",
                "--query-cover": "none", "--subject-cover": "none", "--iterate": "none", "--global-ranking": "none",
                "-b": "none", "--block-size": "none", "-c": "none", "--index-chunks": "none", "-F": "none",
                "--frameshift": "none", "--query-gencode": "none", "--taxonlist": "none", "--taxon-exclude": "none",
                "--seqidlist": "files",
                "-f": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--outfmt": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--file-buffer-size": "none", "--parallel-tmpdir": "dirs", "--bin": "none",
                "--ext-chunk-size": "none", "--dbsize": "none", "--tantan-minMaskProb": "none",
                "--swipe-task-size": "none", "--query-match-distance-threshold": "none",
                "--length-ratio-threshold": "none", "--cbs-angle": "none", "--algo": ["0", "1", "ctg"],
                "--min-orf": "none", "--min-query-len": "none", "--load-threads": "none", "--minichunk": "none",
                "--seed-cut": "none", "--freq-masking": "none", "--freq-sd": "none", "--sketch-size": "none",
                "--tile-size": "none", "--id2": "none", "--xdrop": "none", "--reseek-xdrop": "none",
                "--ungapped-evalue": "none", "--ungapped-evalue-short": "none",
                "--short-query-ungapped-bitscore": "none", "--gapped-filter-evalue": "none", "--band": "none",
                "--shape-mask": "none", "--taxdump": "dirs", "--word-threshold": "none",
                "--double-hit-window": "none", "--mp-query-chunk": "none", "--culling-overlap": "none",
                "--taxon-k": "none", "--range-cover": "none", "--stop-match-score": "none",
                "--daa-build-version": "none", "--daa": "files", "--window": "none", "--ungapped-score": "none",
                "--hit-band": "none", "--hit-score": "none", "--gapped-xdrop": "none", "--rank-ratio2": "none",
                "--rank-ratio": "none", "--lambda": "none", "--K": "none",
            },
            args: ["none"],
        },
        "cluster" => #{
            opts: `
                -p, --threads VALUE                     number of CPU threads
                --log                                   enable debug log
                --quiet                                 disable console output
                -t, --tmpdir VALUE                      directory for temporary files
                --keep-temp-files                       do not delete temporarary files
                -d, --db VALUE                          database file
                -o, --out VALUE                         output file
                --header VALUE                          use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE                composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE      tolerance for matrix adjust relative entropy
                --masking VALUE                         masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                    soft masking (none=default, seg, tantan)
                --gapopen VALUE                         gap open penalty
                --gapextend VALUE                       gap extension penalty
                --matrix VALUE                          score matrix for protein alignment
                --custom-matrix VALUE                   file containing custom scoring matrix
                -e, --evalue VALUE                      maximum e-value to report alignments
                --motif-masking VALUE                   softmask abundant motifs (0/1)
                --approx-id VALUE                       minimum approx
                --id VALUE                              minimum identity% to report an alignment
                --ext VALUE                             extension mode (banded-fast/banded-slow/full/global/none)
                --min-len-ratio VALUE                   sequence length ratio cutoff for mutual coverage
                --cluster-steps VALUE                   clustering rounds for cascaded clustering
                --kmer-ranking VALUE                    rank sequences based on kmer frequency in linear stage
                --round-coverage VALUE                  per-round coverage cutoffs for cascaded clustering
                --round-approx-id VALUE                 per-round approx-id cutoffs for cascaded clustering
                --aln-out VALUE                         output file for clustering alignments
                --reps VALUE                            output file for representative sequences in FASTA format
                --single-step                           perform one computational step of clustering then exit
                --linclust-minichunk VALUE              minimal chunk size for linclust
                --kmer-prefilter VALUE                  aggressiveness of the 3-mer prefilter of linear rounds at approx-id >= 70
                -M, --memory-limit VALUE                memory limit in GB
                --member-cover VALUE                    minimum coverage% of the cluster member sequence
                --mutual-cover VALUE                    minimum mutual coverage% of the cluster member and representative sequence
                --no-reassign                           do not reassign to closest representative
                --file-buffer-size VALUE                file buffer size in bytes
                --no-unlink                             do not unlink temporary files
                --ignore-warnings                       ignore warnings
                --no-parse-seqids                       print raw seqids without parsing
                --parallel-tmpdir VALUE                 directory for temporary files used by multiprocessing
                --bin VALUE                             number of query bins for seed search
                --ext-chunk-size VALUE                  chunk size for adaptive ranking
                --no-ranking                            disable ranking heuristic
                --dbsize VALUE                          effective database size (in letters)
                --no-auto-append                        disable auto appending of DAA and DMND file extensions
                --tantan-minMaskProb VALUE              minimum repeat probability for masking
                --oid-output                            output OIDs instead of accessions (clustering)
                --swipe-task-size VALUE                 task size for DP parallelism (100000000)
                --query-match-distance-threshold VALUE  matrix adjust threshold
                --length-ratio-threshold VALUE          matrix adjust threshold
                --cbs-angle VALUE                       matrix adjust threshold
                --hit-membuf                            buffer intermediate hits in memory
                --fpu-compat                            floating point operations compatibility mode
                --no-mempool                            disable per-thread memory pool
                --new-ext                               enable new extension pipeline
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "--gapopen": "none", "--gapextend": "none",
                "--matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"],
                "--custom-matrix": "files", "-e": "none", "--evalue": "none", "--motif-masking": ["0", "1"],
                "--approx-id": "none", "--id": "none",
                "--ext": ["banded-fast", "banded-slow", "full", "global", "none"], "--min-len-ratio": "none",
                "--cluster-steps": "none", "--kmer-ranking": "none", "--round-coverage": "none",
                "--round-approx-id": "none", "--aln-out": "files", "--reps": "files", "--linclust-minichunk": "none",
                "--kmer-prefilter": "none", "-M": "none", "--memory-limit": "none", "--member-cover": "none",
                "--mutual-cover": "none", "--file-buffer-size": "none", "--parallel-tmpdir": "dirs", "--bin": "none",
                "--ext-chunk-size": "none", "--dbsize": "none", "--tantan-minMaskProb": "none",
                "--swipe-task-size": "none", "--query-match-distance-threshold": "none",
                "--length-ratio-threshold": "none", "--cbs-angle": "none",
            },
            args: ["none"],
        },
        "linclust" => #{
            opts: `
                -p, --threads VALUE                     number of CPU threads
                --log                                   enable debug log
                --quiet                                 disable console output
                -t, --tmpdir VALUE                      directory for temporary files
                --keep-temp-files                       do not delete temporarary files
                -d, --db VALUE                          database file
                -o, --out VALUE                         output file
                --header VALUE                          use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE                composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE      tolerance for matrix adjust relative entropy
                --masking VALUE                         masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                    soft masking (none=default, seg, tantan)
                --gapopen VALUE                         gap open penalty
                --gapextend VALUE                       gap extension penalty
                --matrix VALUE                          score matrix for protein alignment
                --custom-matrix VALUE                   file containing custom scoring matrix
                -e, --evalue VALUE                      maximum e-value to report alignments
                --motif-masking VALUE                   softmask abundant motifs (0/1)
                --approx-id VALUE                       minimum approx
                --id VALUE                              minimum identity% to report an alignment
                --ext VALUE                             extension mode (banded-fast/banded-slow/full/global/none)
                --min-len-ratio VALUE                   sequence length ratio cutoff for mutual coverage
                --cluster-steps VALUE                   clustering rounds for cascaded clustering
                --kmer-ranking VALUE                    rank sequences based on kmer frequency in linear stage
                --round-coverage VALUE                  per-round coverage cutoffs for cascaded clustering
                --round-approx-id VALUE                 per-round approx-id cutoffs for cascaded clustering
                --aln-out VALUE                         output file for clustering alignments
                --reps VALUE                            output file for representative sequences in FASTA format
                --single-step                           perform one computational step of clustering then exit
                --linclust-minichunk VALUE              minimal chunk size for linclust
                --kmer-prefilter VALUE                  aggressiveness of the 3-mer prefilter of linear rounds at approx-id >= 70
                -M, --memory-limit VALUE                memory limit in GB
                --member-cover VALUE                    minimum coverage% of the cluster member sequence
                --mutual-cover VALUE                    minimum mutual coverage% of the cluster member and representative sequence
                --no-reassign                           do not reassign to closest representative
                --file-buffer-size VALUE                file buffer size in bytes
                --no-unlink                             do not unlink temporary files
                --ignore-warnings                       ignore warnings
                --no-parse-seqids                       print raw seqids without parsing
                --parallel-tmpdir VALUE                 directory for temporary files used by multiprocessing
                --bin VALUE                             number of query bins for seed search
                --ext-chunk-size VALUE                  chunk size for adaptive ranking
                --no-ranking                            disable ranking heuristic
                --dbsize VALUE                          effective database size (in letters)
                --no-auto-append                        disable auto appending of DAA and DMND file extensions
                --tantan-minMaskProb VALUE              minimum repeat probability for masking
                --oid-output                            output OIDs instead of accessions (clustering)
                --swipe-task-size VALUE                 task size for DP parallelism (100000000)
                --query-match-distance-threshold VALUE  matrix adjust threshold
                --length-ratio-threshold VALUE          matrix adjust threshold
                --cbs-angle VALUE                       matrix adjust threshold
                --hit-membuf                            buffer intermediate hits in memory
                --fpu-compat                            floating point operations compatibility mode
                --no-mempool                            disable per-thread memory pool
                --new-ext                               enable new extension pipeline
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "--gapopen": "none", "--gapextend": "none",
                "--matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"],
                "--custom-matrix": "files", "-e": "none", "--evalue": "none", "--motif-masking": ["0", "1"],
                "--approx-id": "none", "--id": "none",
                "--ext": ["banded-fast", "banded-slow", "full", "global", "none"], "--min-len-ratio": "none",
                "--cluster-steps": "none", "--kmer-ranking": "none", "--round-coverage": "none",
                "--round-approx-id": "none", "--aln-out": "files", "--reps": "files", "--linclust-minichunk": "none",
                "--kmer-prefilter": "none", "-M": "none", "--memory-limit": "none", "--member-cover": "none",
                "--mutual-cover": "none", "--file-buffer-size": "none", "--parallel-tmpdir": "dirs", "--bin": "none",
                "--ext-chunk-size": "none", "--dbsize": "none", "--tantan-minMaskProb": "none",
                "--swipe-task-size": "none", "--query-match-distance-threshold": "none",
                "--length-ratio-threshold": "none", "--cbs-angle": "none",
            },
            args: ["none"],
        },
        "realign" => #{
            opts: `
                -p, --threads VALUE                 number of CPU threads
                --log                               enable debug log
                --quiet                             disable console output
                -t, --tmpdir VALUE                  directory for temporary files
                --keep-temp-files                   do not delete temporarary files
                -d, --db VALUE                      database file
                -o, --out VALUE                     output file
                --header VALUE                      use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE            composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE  tolerance for matrix adjust relative entropy
                --masking VALUE                     masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                soft masking (none=default, seg, tantan)
                -f, --outfmt VALUE                  output format
                -M, --memory-limit VALUE            memory limit in GB
                --clusters VALUE                    clustering input file mapping sequences to representatives
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "-f": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--outfmt": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "-M": "none", "--memory-limit": "none", "--clusters": "files",
            },
            args: ["none"],
        },
        "recluster" => #{
            opts: `
                -p, --threads VALUE                     number of CPU threads
                --log                                   enable debug log
                --quiet                                 disable console output
                -t, --tmpdir VALUE                      directory for temporary files
                --keep-temp-files                       do not delete temporarary files
                -d, --db VALUE                          database file
                -o, --out VALUE                         output file
                --header VALUE                          use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE                composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE      tolerance for matrix adjust relative entropy
                --masking VALUE                         masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                    soft masking (none=default, seg, tantan)
                --gapopen VALUE                         gap open penalty
                --gapextend VALUE                       gap extension penalty
                --matrix VALUE                          score matrix for protein alignment
                --custom-matrix VALUE                   file containing custom scoring matrix
                -e, --evalue VALUE                      maximum e-value to report alignments
                --motif-masking VALUE                   softmask abundant motifs (0/1)
                --approx-id VALUE                       minimum approx
                --id VALUE                              minimum identity% to report an alignment
                --ext VALUE                             extension mode (banded-fast/banded-slow/full/global/none)
                --min-len-ratio VALUE                   sequence length ratio cutoff for mutual coverage
                --cluster-steps VALUE                   clustering rounds for cascaded clustering
                --kmer-ranking VALUE                    rank sequences based on kmer frequency in linear stage
                --round-coverage VALUE                  per-round coverage cutoffs for cascaded clustering
                --round-approx-id VALUE                 per-round approx-id cutoffs for cascaded clustering
                --aln-out VALUE                         output file for clustering alignments
                --reps VALUE                            output file for representative sequences in FASTA format
                --single-step                           perform one computational step of clustering then exit
                --linclust-minichunk VALUE              minimal chunk size for linclust
                --kmer-prefilter VALUE                  aggressiveness of the 3-mer prefilter of linear rounds at approx-id >= 70
                -M, --memory-limit VALUE                memory limit in GB
                --member-cover VALUE                    minimum coverage% of the cluster member sequence
                --mutual-cover VALUE                    minimum mutual coverage% of the cluster member and representative sequence
                --no-reassign                           do not reassign to closest representative
                --clusters VALUE                        clustering input file mapping sequences to representatives
                --parallel-tmpdir VALUE                 directory for temporary files used by multiprocessing
                --bin VALUE                             number of query bins for seed search
                --ext-chunk-size VALUE                  chunk size for adaptive ranking
                --no-ranking                            disable ranking heuristic
                --dbsize VALUE                          effective database size (in letters)
                --no-auto-append                        disable auto appending of DAA and DMND file extensions
                --tantan-minMaskProb VALUE              minimum repeat probability for masking
                --oid-output                            output OIDs instead of accessions (clustering)
                --swipe-task-size VALUE                 task size for DP parallelism (100000000)
                --query-match-distance-threshold VALUE  matrix adjust threshold
                --length-ratio-threshold VALUE          matrix adjust threshold
                --cbs-angle VALUE                       matrix adjust threshold
                --hit-membuf                            buffer intermediate hits in memory
                --fpu-compat                            floating point operations compatibility mode
                --no-mempool                            disable per-thread memory pool
                --new-ext                               enable new extension pipeline
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "--gapopen": "none", "--gapextend": "none",
                "--matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"],
                "--custom-matrix": "files", "-e": "none", "--evalue": "none", "--motif-masking": ["0", "1"],
                "--approx-id": "none", "--id": "none",
                "--ext": ["banded-fast", "banded-slow", "full", "global", "none"], "--min-len-ratio": "none",
                "--cluster-steps": "none", "--kmer-ranking": "none", "--round-coverage": "none",
                "--round-approx-id": "none", "--aln-out": "files", "--reps": "files", "--linclust-minichunk": "none",
                "--kmer-prefilter": "none", "-M": "none", "--memory-limit": "none", "--member-cover": "none",
                "--mutual-cover": "none", "--clusters": "files", "--parallel-tmpdir": "dirs", "--bin": "none",
                "--ext-chunk-size": "none", "--dbsize": "none", "--tantan-minMaskProb": "none",
                "--swipe-task-size": "none", "--query-match-distance-threshold": "none",
                "--length-ratio-threshold": "none", "--cbs-angle": "none",
            },
            args: ["none"],
        },
        "reassign" => #{
            opts: `
                -p, --threads VALUE                     number of CPU threads
                --log                                   enable debug log
                --quiet                                 disable console output
                -t, --tmpdir VALUE                      directory for temporary files
                --keep-temp-files                       do not delete temporarary files
                -d, --db VALUE                          database file
                -o, --out VALUE                         output file
                --header VALUE                          use header lines in tabular output format (0/simple/verbose)
                --comp-based-stats VALUE                composition based statistics mode (0-6)
                --relative-entropy-tolerance VALUE      tolerance for matrix adjust relative entropy
                --masking VALUE                         masking algorithm (none, seg, seg-all, tantan=default)
                --soft-masking VALUE                    soft masking (none=default, seg, tantan)
                --gapopen VALUE                         gap open penalty
                --gapextend VALUE                       gap extension penalty
                --matrix VALUE                          score matrix for protein alignment
                --custom-matrix VALUE                   file containing custom scoring matrix
                -e, --evalue VALUE                      maximum e-value to report alignments
                --motif-masking VALUE                   softmask abundant motifs (0/1)
                --approx-id VALUE                       minimum approx
                --id VALUE                              minimum identity% to report an alignment
                --ext VALUE                             extension mode (banded-fast/banded-slow/full/global/none)
                --min-len-ratio VALUE                   sequence length ratio cutoff for mutual coverage
                -M, --memory-limit VALUE                memory limit in GB
                --member-cover VALUE                    minimum coverage% of the cluster member sequence
                --mutual-cover VALUE                    minimum mutual coverage% of the cluster member and representative sequence
                --no-reassign                           do not reassign to closest representative
                --clusters VALUE                        clustering input file mapping sequences to representatives
                --file-buffer-size VALUE                file buffer size in bytes
                --no-unlink                             do not unlink temporary files
                --ignore-warnings                       ignore warnings
                --no-parse-seqids                       print raw seqids without parsing
                --parallel-tmpdir VALUE                 directory for temporary files used by multiprocessing
                --bin VALUE                             number of query bins for seed search
                --ext-chunk-size VALUE                  chunk size for adaptive ranking
                --no-ranking                            disable ranking heuristic
                --dbsize VALUE                          effective database size (in letters)
                --no-auto-append                        disable auto appending of DAA and DMND file extensions
                --tantan-minMaskProb VALUE              minimum repeat probability for masking
                --oid-output                            output OIDs instead of accessions (clustering)
                --swipe-task-size VALUE                 task size for DP parallelism (100000000)
                --query-match-distance-threshold VALUE  matrix adjust threshold
                --length-ratio-threshold VALUE          matrix adjust threshold
                --cbs-angle VALUE                       matrix adjust threshold
                --hit-membuf                            buffer intermediate hits in memory
                --fpu-compat                            floating point operations compatibility mode
                --no-mempool                            disable per-thread memory pool
                --new-ext                               enable new extension pipeline
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "--comp-based-stats": "none", "--relative-entropy-tolerance": "none",
                "--masking": ["none", "seg", "seg-all", "tantan"], "--soft-masking": ["none", "seg", "tantan"],
                "--gapopen": "none", "--gapextend": "none",
                "--matrix": ["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"],
                "--custom-matrix": "files", "-e": "none", "--evalue": "none", "--motif-masking": ["0", "1"],
                "--approx-id": "none", "--id": "none",
                "--ext": ["banded-fast", "banded-slow", "full", "global", "none"], "--min-len-ratio": "none",
                "-M": "none", "--memory-limit": "none", "--member-cover": "none", "--mutual-cover": "none",
                "--clusters": "files", "--file-buffer-size": "none", "--parallel-tmpdir": "dirs", "--bin": "none",
                "--ext-chunk-size": "none", "--dbsize": "none", "--tantan-minMaskProb": "none",
                "--swipe-task-size": "none", "--query-match-distance-threshold": "none",
                "--length-ratio-threshold": "none", "--cbs-angle": "none",
            },
            args: ["none"],
        },
        "view" => #{
            opts: `
                -p, --threads VALUE          number of CPU threads
                --log                        enable debug log
                --quiet                      disable console output
                -t, --tmpdir VALUE           directory for temporary files
                --keep-temp-files            do not delete temporarary files
                -o, --out VALUE              output file
                --header VALUE               use header lines in tabular output format (0/simple/verbose)
                -k, --max-target-seqs VALUE  maximum number of target sequences to report alignments for
                --top VALUE                  report alignments within this percentage range of top alignment score
                -f, --outfmt VALUE           output format
                --daa VALUE                  DIAMOND alignment archive (DAA) file
                --forwardonly                only show alignments of forward strand
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-o": "files", "--out": "files",
                "--header": ["0", "simple", "verbose"], "-k": "none", "--max-target-seqs": "none", "--top": "none",
                "-f": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--outfmt": [#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}],
                "--daa": "files",
            },
            args: ["none"],
        },
        "merge-daa" => #{
            opts: `
                -p, --threads VALUE  number of CPU threads
                --log                enable debug log
                --quiet              disable console output
                -t, --tmpdir VALUE   directory for temporary files
                --keep-temp-files    do not delete temporarary files
                -o, --out VALUE      output file
                --in VALUE           input reference file in FASTA format/input DAA files for merge-daa
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-o": "files", "--out": "files",
                "--in": k("sequences"),
            },
            args: ["none"],
        },
        "getseq" => #{
            opts: `
                -p, --threads VALUE  number of CPU threads
                --log                enable debug log
                --quiet              disable console output
                -t, --tmpdir VALUE   directory for temporary files
                --keep-temp-files    do not delete temporarary files
                -d, --db VALUE       database file
                -o, --out VALUE      output file
                --seq VALUE          space-separated list of sequence numbers to display
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--seq": "none",
            },
            args: ["none"],
        },
        "dbinfo" => #{
            opts: `
                -p, --threads VALUE  number of CPU threads
                --log                enable debug log
                --quiet              disable console output
                -t, --tmpdir VALUE   directory for temporary files
                --keep-temp-files    do not delete temporarary files
                -d, --db VALUE       database file
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"),
            },
            args: ["none"],
        },
        "makeidx" => #{
            opts: `
                -p, --threads VALUE  number of CPU threads
                --log                enable debug log
                --quiet              disable console output
                -t, --tmpdir VALUE   directory for temporary files
                --keep-temp-files    do not delete temporarary files
                -d, --db VALUE       database file
                --faster             enable faster mode
                --fast               enable fast mode
                --mid-sensitive      enable mid-sensitive mode
                --linclust-20        enable mode for linear search at 20% identity
                --shapes-6x10        enable mode using 30 seed shapes of weight 10
                --shapes-30x10       enable mode using 30 seed shapes of weight 10
                --sensitive          enable sensitive mode
                --more-sensitive     enable more sensitive mode
                --very-sensitive     enable very sensitive mode
                --ultra-sensitive    enable ultra sensitive mode
                --shapes VALUE       number of seed shapes
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "--shapes": "none",
            },
            args: ["none"],
        },
        "greedy-vertex-cover" => #{
            opts: `
                -p, --threads VALUE       number of CPU threads
                --log                     enable debug log
                --quiet                   disable console output
                -t, --tmpdir VALUE        directory for temporary files
                --keep-temp-files         do not delete temporarary files
                -d, --db VALUE            database file
                -o, --out VALUE           output file
                --header VALUE            use header lines in tabular output format (0/simple/verbose)
                -M, --memory-limit VALUE  memory limit in GB
                --member-cover VALUE      minimum coverage% of the cluster member sequence
                --mutual-cover VALUE      minimum mutual coverage% of the cluster member and representative sequence
                --no-reassign             do not reassign to closest representative
                --centroid-out VALUE      output file for centroids
                --edges VALUE             input file for greedy vertex cover
                --edge-format VALUE       edge format for greedy vertex cover
                --max-oid VALUE           maximum ordinal vertex ID (enables direct numeric indexing)
                --symmetric               edges are symmetric
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-d": k("diamond_db"),
                "--db": k("diamond_db"), "-o": "files", "--out": "files", "--header": ["0", "simple", "verbose"],
                "-M": "none", "--memory-limit": "none", "--member-cover": "none", "--mutual-cover": "none",
                "--centroid-out": "files", "--edges": "files", "--edge-format": "none", "--max-oid": "none",
            },
            args: ["none"],
        },
        "countdistinct" => #{
            opts: `
                -p, --threads VALUE       number of CPU threads
                --log                     enable debug log
                --quiet                   disable console output
                -t, --tmpdir VALUE        directory for temporary files
                --keep-temp-files         do not delete temporarary files
                -o, --out VALUE           output file
                --in VALUE                input reference file in FASTA format/input DAA files for merge-daa
                -M, --memory-limit VALUE  memory limit in GB
            `,
            values: #{
                "-p": "none", "--threads": "none", "-t": "dirs", "--tmpdir": "dirs", "-o": "files", "--out": "files",
                "--in": k("sequences"), "-M": "none", "--memory-limit": "none",
            },
            args: ["none"],
        },
        _ => (),
    }
}

fn spec(cmd) {
    switch cmd {
        "diamond" => diamond(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "diamond" => diamond_sub(sub),
        _ => (),
    }
}
