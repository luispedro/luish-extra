// bcftools, from `bcftools SUBCOMMAND --help` (1.24). The options that
// the subcommands share are written once, as functions returning tables.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

fn regions_opts() {
    `
        -r, --regions REGION         restrict to a comma-separated list of regions
        -R, --regions-file FILE      restrict to the regions listed in a file
        --regions-overlap 0|1|2      include if POS is in the region (0), the record overlaps (1), the variant overlaps (2)
    `
}

fn targets_opts() {
    `
        -t, --targets REGION         like -r but streams rather than jumps by the index
        -T, --targets-file FILE      like -R but streams rather than jumps by the index
        --targets-overlap 0|1|2      include if POS is in the region (0), the record overlaps (1), the variant overlaps (2)
    `
}

fn filter_opts() {
    `
        -e, --exclude EXPR           exclude sites for which the expression is true
        -i, --include EXPR           select sites for which the expression is true
    `
}

fn samples_opts() {
    `
        -s, --samples LIST           comma-separated list of samples to include
        -S, --samples-file FILE      file of samples to include
    `
}

fn output_opts() {
    `
        --no-version                 do not append the version and command line to the header
        -o, --output FILE            write the output to FILE
        -O, --output-type TYPE       u/b: un/compressed BCF, v/z: un/compressed VCF (then 0-9: compression level)
    `
}

fn threads_opts() {
    `
        --threads INT                use multithreading with INT worker threads
        -v, --verbosity INT          verbosity level
        -W, --write-index[=FMT]      automatically index the output files
    `
}

fn output_types() {
    [
        #{value: "u", desc: "uncompressed BCF"},
        #{value: "b", desc: "compressed BCF"},
        #{value: "v", desc: "uncompressed VCF"},
        #{value: "z", desc: "compressed VCF"},
    ]
}

fn overlaps() {
    [
        #{value: "0", desc: "POS is in the region"},
        #{value: "1", desc: "the record overlaps the region"},
        #{value: "2", desc: "the variant overlaps the region"},
    ]
}

// The values of the shared options, for all the subcommands (an option a
// subcommand does not have is never asked for).
fn common_values() {
    let vcf = k("vcf");
    #{
        "--regions": k("vcf_regions"), "-r": k("vcf_regions"),
        "--targets": k("vcf_regions"), "-t": k("vcf_regions"),
        "--regions-file": k("bed"), "-R": k("bed"), "--targets-file": k("bed"), "-T": k("bed"),
        "--regions-overlap": overlaps(), "--targets-overlap": overlaps(),
        "--include": "none", "-i": "none", "--exclude": "none", "-e": "none",
        "--samples": k("vcf_samples"), "-s": k("vcf_samples"),
        "--samples-file": "files", "-S": "files",
        "--output": "files", "-o": "files",
        "--output-type": output_types(), "-O": output_types(),
        "--threads": "none", "--verbosity": "none", "-v": "none",
        "--write-index": ["csi", "tbi"],
        "--fasta-ref": k("fasta"), "-f": k("fasta"),
    }
}

fn bcftools() {
    #{
        opts: `
            -h, --help                   show help
            --version                    show the version
            --version-only               show only the version number
        `,
        commands: `
            index        index VCF/BCF files
            annotate     annotate and edit VCF/BCF files
            concat       concatenate VCF/BCF files from the same set of samples
            convert      convert VCF/BCF files to different formats and back
            head         view VCF/BCF file headers
            isec         intersections of VCF/BCF files
            merge        merge VCF/BCF files from non-overlapping sample sets
            norm         left-align and normalize indels
            plugin       user-defined plugins
            query        transform VCF/BCF into user-defined formats
            reheader     modify the VCF/BCF header, change sample names
            sort         sort a VCF/BCF file
            view         convert, view, subset and filter VCF/BCF files
            call         SNP/indel calling
            consensus    create a consensus sequence by applying VCF variants
            cnv          HMM CNV calling
            csq          call variation consequences
            filter       filter VCF/BCF files using fixed thresholds
            gtcheck      check sample concordance, detect sample swaps and contamination
            mpileup      multi-way pileup producing genotype likelihoods
            polysomy     detect the number of chromosomal copies
            roh          identify runs of autozygosity (HMM)
            stats        produce VCF/BCF stats
            help         show help for a command
        `,
        sub_spec: own("bcftools:bcftools"),
    }
}

fn plugins() {
    ["GTisec", "GTsubset", "ad-bias", "add-variantkey", "af-dist", "allele-length", "check-ploidy",
     "check-sparsity", "color-chrs", "contrast", "counts", "dosage", "fill-AN-AC", "fill-from-fasta",
     "fill-tags", "fixploidy", "fixref", "frameshifts", "guess-ploidy", "gvcfz", "impute-info",
     "indel-stats", "isecGT", "mendelian2", "missing2ref", "parental-origin", "prune", "remove-overlaps",
     "scatter", "setGT", "smpl-stats", "split", "split-vep", "tag2tag", "trio-dnm3", "trio-stats",
     "trio-switch-rate", "variant-distance", "variantkey-hex", "vcf2table", "vrfs"]
}

fn bcftools_sub(name) {
    let vcf = k("vcf");
    let spec = switch name {
        "index" => #{
            opts: `
                -c, --csi                    generate a CSI index (the default)
                -f, --force                  overwrite the index if it exists
                -m, --min-shift INT          minimal interval size for CSI indices, 2^INT
                -o, --output FILE            the name of the index file
                -t, --tbi                    generate a TBI index (VCF only)
                --threads INT                use multithreading with INT worker threads
                -v, --verbosity INT          verbosity level
                -a, --all                    with --stats, print the stats of all contigs, even when zero
                -n, --nrecords               print the number of records, from the existing index
                -s, --stats                  print the per-contig stats, from the existing index
            `,
            args: [vcf],
        },
        "annotate" => #{
            opts: `
                -a, --annotations FILE       VCF file or tabix-indexed file with the annotations
                -c, --columns LIST           the columns of the annotation file, e.g. CHROM,POS,REF,ALT,-,INFO/TAG
                -C, --columns-file FILE      read the -c columns from FILE, one per row
                --force                      continue despite parsing errors
                -H, --header-line STR        a line to append to the header (repeatable)
                -h, --header-lines FILE      lines to append to the header
                -I, --set-id [+]FORMAT       set the ID column with a bcftools query-like expression
                -k, --keep-sites             leave the -i/-e sites unchanged instead of discarding them
                -l, --merge-logic TAG:TYPE   merge logic for overlapping regions (experimental)
                -m, --mark-sites [+-]TAG     add an INFO/TAG flag to the sites that are (+) or are not (-) in the -a file
                --min-overlap ANN:VCF        required overlap as a fraction of the annotation, the VCF or both
                --pair-logic STR             how records are matched
                --rename-annots FILE         rename annotations: TYPE/old<TAB>new
                --rename-chrs FILE           rename sequences: old<TAB>new
                --single-overlaps            keep the memory low by avoiding overlapping intervals
                -x, --remove LIST            annotations to remove (or keep with a ^ prefix)
            ` + filter_opts() + samples_opts() + regions_opts() + output_opts() + threads_opts(),
            values: #{
                "--annotations": k("intervals"), "-a": k("intervals"), "--columns": "none", "-c": "none",
                "--columns-file": "files", "-C": "files", "--header-line": "none", "-H": "none",
                "--header-lines": "files", "-h": "files", "--set-id": "none", "-I": "none",
                "--merge-logic": "none", "-l": "none", "--mark-sites": "none", "-m": "none",
                "--min-overlap": "none", "--pair-logic": ["snps", "indels", "both", "all", "some", "exact", "id"],
                "--rename-annots": "files", "--rename-chrs": "files", "--remove": "none", "-x": "none",
            },
            args: [vcf],
        },
        "concat" => #{
            opts: `
                -a, --allow-overlaps         the first coordinate of the next file may precede the last record of this one
                -c, --compact-PS             output the PS tag only at the start of a phase set block
                -d, --rm-dups STRING         output duplicate records present in several files once
                -D, --remove-duplicates      alias for -d exact
                -f, --file-list FILE         read the list of files from a file
                -G, --drop-genotypes         drop the genotype information
                -l, --ligate                 ligate phased VCFs by matching the phase at overlapping haplotypes
                --ligate-force               ligate even non-overlapping chunks, keep all sites
                --ligate-warn                drop sites in imperfect overlaps
                -n, --naive                  concatenate without recompression, with a header compatibility check
                --naive-force                like --naive, without the header check (dangerous)
                -q, --min-PQ INT             break the phase set if the phasing quality is lower than INT
            ` + regions_opts() + output_opts() + threads_opts(),
            values: #{"--rm-dups": ["snps", "indels", "both", "all", "exact"], "-d": ["snps", "indels", "both", "all", "exact"],
                      "--file-list": "files", "-f": "files", "--min-PQ": "none", "-q": "none"},
            args: [vcf],
        },
        "convert" => #{
            opts: `
                -G, --gensample2vcf PREFIX|GEN,SAMPLE   convert IMPUTE2 GEN/SAMPLE files to VCF
                -g, --gensample PREFIX|GEN,SAMPLE       convert VCF to IMPUTE2 GEN/SAMPLE files
                --3N6                        use the 3*N+6 column format instead of 3*N+5
                --tag STRING                 the tag to take the values of the .gen file from
                --chrom                      output the chromosome in the first column
                --keep-duplicates            keep duplicate positions
                --sex FILE                   output a sex column in the sample file
                --vcf-ids                    output the VCF IDs in the second column
                --gvcf2vcf                   expand gVCF reference blocks
                -f, --fasta-ref FILE         the reference sequence in FASTA format
                --hapsample2vcf PREFIX|HAP,SAMPLE   convert SHAPEIT HAP/SAMPLE files to VCF
                --hapsample PREFIX|HAP,SAMPLE       convert VCF to SHAPEIT HAP/SAMPLE files
                --haploid2diploid            convert haploid genotypes to diploid homozygotes
                -H, --haplegendsample2vcf PREFIX|HAP,LEGEND,SAMPLE  convert HAP/LEGEND/SAMPLE files to VCF
                -h, --haplegendsample PREFIX|HAP,LEGEND,SAMPLE      convert VCF to HAP/LEGEND/SAMPLE files
                --tsv2vcf FILE               convert a TSV file to VCF
                -c, --columns STRING         the columns of the input TSV file
            ` + filter_opts() + samples_opts() + regions_opts() + targets_opts() + output_opts() + threads_opts(),
            values: #{
                "--gensample2vcf": "none", "-G": "none", "--gensample": "none", "-g": "none", "--tag": "none",
                "--sex": "files", "--hapsample2vcf": "none", "--hapsample": "none",
                "--haplegendsample2vcf": "none", "-H": "none", "--haplegendsample": "none", "-h": "none",
                "--tsv2vcf": "files", "--columns": "none", "-c": "none",
            },
            args: [vcf],
        },
        "head" => #{
            opts: `
                -h, --headers INT            display INT header lines
                -n, --records INT            display INT variant record lines
                -s, --samples INT            display INT records starting with the #CHROM header line
                -v, --verbosity INT          verbosity level
            `,
            values: #{"--headers": "none", "-h": "none", "--records": "none", "-n": "none",
                      "--samples": "none", "-s": "none", "--verbosity": "none", "-v": "none"},
            args: [vcf],
        },
        "isec" => #{
            opts: `
                -c, --collapse STRING        treat records as identical with snps|indels|both|all|some|none|id
                -C, --complement             output the positions only in the first file
                -f, --apply-filters LIST     require at least one of the listed FILTER strings
                -l, --file-list FILE         read the input file names from a file
                -n, --nfiles [+-=~]INT       output positions present in this many (=), this many or more (+), or fewer (-), or the exact (~) files
                -p, --prefix DIR             subset each of the input files accordingly and write to DIR
                -w, --write LIST             the files to write with -p, by 1-based index
            ` + filter_opts() + regions_opts() + targets_opts() + output_opts() + threads_opts(),
            values: #{"--collapse": ["snps", "indels", "both", "all", "some", "none", "id"],
                      "-c": ["snps", "indels", "both", "all", "some", "none", "id"],
                      "--apply-filters": "none", "-f": "none", "--file-list": "files", "-l": "files",
                      "--nfiles": "none", "-n": "none", "--prefix": "dirs", "-p": "dirs", "--write": "none", "-w": "none"},
            args: [vcf],
        },
        "merge" => #{
            opts: `
                --force-no-index             merge unindexed files (same as --no-index)
                --force-samples              resolve duplicate sample names
                --force-single               run even if there is only one input file
                --print-header               print only the merged header and exit
                --use-header FILE            use the header in FILE
                -0, --missing-to-ref         assume genotypes at missing sites are 0/0
                -f, --apply-filters LIST     require at least one of the listed FILTER strings
                -F, --filter-logic x|+       remove the filters if some input is PASS (x), or apply all filters (+)
                -g, --gvcf REF.FA|-          merge gVCF blocks (INFO/END is expected)
                -i, --info-rules TAG:METHOD,..  rules for merging the INFO fields
                -l, --file-list FILE         read the file names from a file
                -L, --local-alleles INT      above INT alt alleles, drop FMT/PL and output LAA+LPL (0: unlimited)
                -m, --merge STRING           allow multiallelic records for snps,indels,both,snp-ins-del,all,exact,none,id,*,**
                -M, --missing-rules TAG:METHOD  rules for replacing missing values in numeric vectors
                --no-index                   merge unindexed files (the same chromosome order is required)
            ` + regions_opts() + output_opts() + threads_opts(),
            values: #{
                "--use-header": "files", "--filter-logic": ["x", "+"], "-F": ["x", "+"], "--gvcf": k("fasta"), "-g": k("fasta"),
                "--info-rules": "none", "-i": "none", "--file-list": "files", "-l": "files",
                "--local-alleles": "none", "-L": "none", "--apply-filters": "none",
                "--merge": ["snps", "indels", "both", "snp-ins-del", "all", "exact", "none", "id", "*", "**"],
                "-m": ["snps", "indels", "both", "snp-ins-del", "all", "exact", "none", "id", "*", "**"],
                "--missing-rules": "none", "-M": "none",
            },
            args: [vcf],
        },
        "norm" => #{
            opts: `
                -a, --atomize                decompose complex variants (MNVs become consecutive SNVs)
                --atom-overlaps '*'|.        use the star allele for overlapping alleles, or set them to missing
                -c, --check-ref e|w|x|s      check the REF alleles and exit (e), warn (w), exclude (x) or set (s) bad sites
                -D, --remove-duplicates      remove duplicate lines of the same type
                -d, --rm-dup TYPE            remove duplicate snps|indels|both|all|exact
                -f, --fasta-ref FILE         the reference sequence
                --force                      proceed even if malformed tags are found (experimental)
                -g, --gff-annot FILE         follow the HGVS 3' rule in transcripts on the forward strand
                --keep-sum TAG,..            keep the vector sum constant when splitting multiallelics
                -m, --multiallelics TYPE  split multiallelics (-TYPE) or join biallelics (+TYPE)
                --multi-overlaps 0|.         fill in the reference (0) or missing (.) allele when splitting
                -N, --no-realign [NUM]       skip realignment, optionally only for events longer than NUM
                --old-rec-tag STR            annotate modified records with INFO/STR (the original variant)
                -s, --strict-filter          when merging, the merged site is PASS only if all merged sites PASS
                -S, --sort METHOD            the sort order
                -w, --site-win INT           buffer for sorting lines that changed position
            ` + filter_opts() + regions_opts() + targets_opts() + output_opts() + threads_opts(),
            values: #{
                "--atom-overlaps": ["*", "."], "--check-ref": [
                    #{value: "e", desc: "exit"}, #{value: "w", desc: "warn"},
                    #{value: "x", desc: "exclude bad sites"}, #{value: "s", desc: "set bad sites"},
                ],
                "-c": [
                    #{value: "e", desc: "exit"}, #{value: "w", desc: "warn"},
                    #{value: "x", desc: "exclude bad sites"}, #{value: "s", desc: "set bad sites"},
                ],
                "--rm-dup": ["snps", "indels", "both", "all", "exact"], "-d": ["snps", "indels", "both", "all", "exact"],
                "--gff-annot": "files", "-g": "files", "--keep-sum": "none",
                "--multiallelics": [#{value: "-", desc: "split multiallelic sites"}, #{value: "+", desc: "join biallelic sites"},
                                   "+snps", "+indels", "+both", "+any"],
                "-m": [#{value: "-", desc: "split multiallelic sites"}, #{value: "+", desc: "join biallelic sites"},
                       "+snps", "+indels", "+both", "+any"],
                "--multi-overlaps": ["0", "."], "--no-realign": "none", "-N": "none", "--old-rec-tag": "none",
                "--sort": ["chr_pos", "lex"], "-S": ["chr_pos", "lex"], "--site-win": "none", "-w": "none",
            },
            args: [vcf],
        },
        "plugin" => #{
            opts: `
                -l, --list-plugins           list the available plugins
                -h, --help                   list the plugin's options
                -V, --version                print the version and exit
            ` + filter_opts() + regions_opts() + targets_opts() + output_opts() + threads_opts(),
            args: [plugins(), vcf],
        },
        "query" => #{
            opts: `
                --force-samples              only warn about unknown subset samples
                -F, --print-filtered STR     output STR for the samples failing the -i/-e expression
                -f, --format STRING          the output format
                -H, --print-header           print the header (-HH to omit the column indices)
                -l, --list-samples           print the list of samples and exit
                -N, --disable-automatic-newline  do not add a newline automatically
                -u, --allow-undef-tags       print "." for undefined tags
                -v, --vcf-list FILE          process the VCFs listed in the file
                -o, --output FILE            write the output to FILE
                --verbosity INT              verbosity level
            ` + filter_opts() + samples_opts() + regions_opts() + targets_opts(),
            values: #{"--print-filtered": "none", "-F": "none", "--format": "none", "-f": "none",
                      "--vcf-list": "files", "-v": "files"},
            args: [vcf],
        },
        "reheader" => #{
            opts: `
                -f, --fai FILE               update the sequences and their lengths from a .fai file
                -h, --header FILE            the new header
                -o, --output FILE            write the output to FILE
                -n, --samples-list LIST      the new sample names, comma-separated
                -N, --samples-file FILE      the new sample names in a file
                -T, --temp-prefix PATH       ignored
                --threads INT                use multithreading with INT worker threads (BCF only)
                -v, --verbosity INT          verbosity level
            `,
            values: #{"--fai": "files", "-f": "files", "--header": "files", "-h": "files",
                      "--samples-list": "none", "-n": "none", "--samples-file": "files", "-N": "files",
                      "--temp-prefix": "dirs", "-T": "dirs"},
            args: [vcf],
        },
        "sort" => #{
            opts: `
                -m, --max-mem FLOAT[kMG]     maximum memory to use
                -o, --output FILE            write the output to FILE
                -O, --output-type TYPE       u/b: un/compressed BCF, v/z: un/compressed VCF (then 0-9: compression level)
                -T, --temp-dir DIR           the directory for temporary files
                -v, --verbosity INT          verbosity level
                -W, --write-index[=FMT]      automatically index the output files
            `,
            values: #{"--max-mem": "none", "-m": "none", "--temp-dir": "dirs", "-T": "dirs"},
            args: [vcf],
        },
        "view" => #{
            opts: `
                -G, --drop-genotypes         drop the genotype information (after subsetting)
                -h, --header-only            print only the header in VCF output
                -H, --no-header              suppress the header in VCF output
                --with-header                print both the header and the records (the default)
                -l, --compression-level INT  compression level, from 0 to 9
                -A, --trim-unseen-allele     remove '<*>' or '<NON_REF>' at variant sites (-AA: at all sites)
                -a, --trim-alt-alleles       trim the ALT alleles not seen in the genotypes
                -I, --no-update              do not recalculate the INFO fields for the subset
                --force-samples              only warn about unknown subset samples
                -c, --min-ac INT[:TYPE]      minimum count of the non-reference alleles
                -C, --max-ac INT[:TYPE]      maximum count of the non-reference alleles
                -f, --apply-filters LIST     require at least one of the listed FILTER strings
                -g, --genotype [^]hom|het|miss  require hom, het or missing genotypes (or exclude with ^)
                -k, --known                  known sites only (ID is not '.')
                -n, --novel                  novel sites only (ID is '.')
                -m, --min-alleles INT        minimum number of alleles listed in REF and ALT
                -M, --max-alleles INT        maximum number of alleles listed in REF and ALT
                -p, --phased                 sites where all samples are phased
                -P, --exclude-phased         exclude sites where all samples are phased
                -q, --min-af FLOAT[:TYPE]    minimum frequency of the non-reference alleles
                -Q, --max-af FLOAT[:TYPE]    maximum frequency of the non-reference alleles
                -u, --uncalled               sites without a called genotype
                -U, --exclude-uncalled       exclude sites without a called genotype
                -v, --types LIST             select variant types: snps,indels,mnps,ref,bnd,other,overlap
                -V, --exclude-types LIST     exclude variant types
                -x, --private                sites where the non-reference alleles are private to the subset samples
                -X, --exclude-private        exclude sites where the non-reference alleles are private to the subset
                --verbosity INT              verbosity level
            ` + filter_opts() + samples_opts() + regions_opts() + targets_opts() + output_opts() + "\n--threads INT  use multithreading with INT worker threads\n-W, --write-index[=FMT]  automatically index the output files\n",
            values: #{
                "--compression-level": "none", "-l": "none", "--min-ac": "none", "-c": "none", "--max-ac": "none", "-C": "none",
                "--apply-filters": "none", "-f": "none", "--genotype": ["hom", "het", "miss", "^hom", "^het", "^miss"],
                "-g": ["hom", "het", "miss", "^hom", "^het", "^miss"], "--min-alleles": "none", "-m": "none",
                "--max-alleles": "none", "-M": "none", "--min-af": "none", "-q": "none", "--max-af": "none", "-Q": "none",
                "--types": ["snps", "indels", "mnps", "ref", "bnd", "other", "overlap"],
                "-v": ["snps", "indels", "mnps", "ref", "bnd", "other", "overlap"],
                "--exclude-types": ["snps", "indels", "mnps", "ref", "bnd", "other", "overlap"],
                "-V": ["snps", "indels", "mnps", "ref", "bnd", "other", "overlap"],
            },
            args: [vcf, k("vcf_regions")],
        },
        "call" => #{
            opts: `
                --ploidy ASSEMBLY[?]         predefined ploidy ('list' to print the settings)
                --ploidy-file FILE           space/tab-delimited list of CHROM,FROM,TO,SEX,PLOIDY
                -A, --keep-alts              keep all possible alternate alleles at variant sites
                -*, --keep-unseen-allele     keep the unobserved allele <*> or <NON_REF>
                -a, --annotate LIST          optional tags to output ('?' to list)
                -F, --prior-freqs AN,AC      use prior allele frequencies from these tags
                -G, --group-samples FILE|-   group samples by population ('-' for single-sample calling)
                --group-samples-tag TAG      the tag to use with -G
                -g, --gvcf INT,[...]         group non-variant sites into gVCF blocks by minimum per-sample DP
                -i, --insert-missed          also output the sites missed by mpileup but present in -T
                -M, --keep-masked-ref        keep sites with a masked reference allele (REF=N)
                -V, --skip-variants TYPE     skip indels or snps
                -v, --variants-only          output variant sites only
                -c, --consensus-caller       the original calling method (conflicts with -m)
                -C, --constrain STR          constrain the calling: alleles or trio
                -m, --multiallelic-caller    the alternative model for multiallelic and rare variants (conflicts with -c)
                -n, --novel-rate FLOAT,[...] likelihood of novel mutation for constrained trio calling
                -p, --pval-threshold FLOAT   variant if P(ref|D)<FLOAT (with -c)
                -P, --prior FLOAT            mutation rate (with -m)
                --verbosity INT              verbosity level
                -t, --targets REGION         like -r but streams rather than jumps by the index
                -T, --targets-file FILE      like -R but streams rather than jumps by the index
            ` + samples_opts() + regions_opts() + output_opts() + "\n--threads INT  use multithreading with INT worker threads\n-W, --write-index[=FMT]  automatically index the output files\n",
            values: #{
                "--ploidy": ["GRCh37", "GRCh38", "X", "Y", "1", "2", "list"], "--ploidy-file": "files",
                "--annotate": "none", "-a": "none", "--prior-freqs": "none", "-F": "none", "--group-samples": "files",
                "-G": "files", "--group-samples-tag": "none", "--gvcf": "none", "-g": "none",
                "--skip-variants": ["indels", "snps"], "-V": ["indels", "snps"],
                "--constrain": ["alleles", "trio"], "-C": ["alleles", "trio"],
                "--novel-rate": "none", "-n": "none", "--pval-threshold": "none", "-p": "none",
                "--prior": "none", "-P": "none",
            },
            args: [vcf],
        },
        "consensus" => #{
            opts: `
                -c, --chain FILE             write a chain file for liftover
                -a, --absent CHAR            replace the positions absent from the VCF with CHAR
                -H, --haplotype WHICH        which allele to use from FORMAT/GT
                -I, --iupac-codes            output IUPAC codes based on FORMAT/GT
                --mark-del CHAR              insert CHAR for deletions instead of removing the sequence
                --mark-ins uc|lc|CHAR        highlight insertions
                --mark-snv uc|lc|CHAR        highlight substitutions
                -m, --mask FILE              replace the regions according to the next --mask-with
                --mask-with CHAR|uc|lc       replace with CHAR, or change to upper or lower case
                -M, --missing CHAR           output CHAR instead of skipping a missing genotype
                -p, --prefix STRING          prefix to add to the output sequence names
                -o, --output FILE            write the output to FILE
                -v, --verbosity INT          verbosity level
                --regions-overlap 0|1|2      include if POS is in the region (0), the record overlaps (1), the variant overlaps (2)
            ` + filter_opts() + samples_opts() + "\n-f, --fasta-ref FILE  the reference sequence in FASTA format\n",
            values: #{
                "--chain": "files", "-c": "files", "--absent": "none", "-a": "none",
                "--haplotype": ["1", "2", "R", "A", "I", "LR", "LA", "SR", "SA"],
                "-H": ["1", "2", "R", "A", "I", "LR", "LA", "SR", "SA"],
                "--mark-del": "none", "--mark-ins": ["uc", "lc"], "--mark-snv": ["uc", "lc"],
                "--mask": k("bed"), "-m": k("bed"), "--mask-with": ["uc", "lc", "N"], "--missing": "none", "-M": "none",
                "--prefix": "none", "-p": "none",
            },
            args: [vcf],
        },
        "cnv" => #{
            opts: `
                -c, --control-sample STRING  optional control sample name, to highlight differences
                -f, --AF-file FILE           read the allele frequencies from a file
                -o, --output-dir PATH        the output directory
                -p, --plot-threshold FLOAT   plot aberrant chromosomes with quality at least FLOAT
                -s, --query-sample STRING    the query sample name
                -v, --verbosity INT          verbosity level
                -a, --aberrant FLOAT[,FLOAT]  fraction of aberrant cells in the query and control
                -b, --BAF-weight FLOAT       relative contribution of the BAF
                -d, --BAF-dev FLOAT[,FLOAT]  expected BAF deviation in the query and control
                -e, --err-prob FLOAT         uniform error probability
                -k, --LRR-dev FLOAT[,FLOAT]  expected LRR deviation
                -l, --LRR-weight FLOAT       relative contribution of the LRR
                -L, --LRR-smooth-win INT     window of the LRR moving average smoothing
                -O, --optimize FLOAT         estimate the fraction of aberrant cells down to FLOAT
                -P, --same-prob FLOAT        prior probability of -s/-c being the same
                -x, --xy-prob FLOAT          P(x|y) transition probability
            ` + regions_opts() + targets_opts(),
            values: #{
                "--control-sample": k("vcf_samples"), "-c": k("vcf_samples"), "--query-sample": k("vcf_samples"),
                "-s": k("vcf_samples"), "--AF-file": "files", "-f": "files", "--output-dir": "dirs", "-o": "dirs",
                "--plot-threshold": "none", "-p": "none", "--aberrant": "none", "-a": "none", "--BAF-weight": "none",
                "-b": "none", "--BAF-dev": "none", "-d": "none", "--err-prob": "none", "-e": "none",
                "--LRR-dev": "none", "-k": "none", "--LRR-weight": "none", "-l": "none", "--LRR-smooth-win": "none",
                "-L": "none", "--optimize": "none", "-O": "none", "--same-prob": "none", "-P": "none",
                "--xy-prob": "none", "-x": "none",
            },
            args: [vcf],
        },
        "csq" => #{
            opts: `
                -f, --fasta-ref FILE         the reference in FASTA format (required)
                -g, --gff-annot FILE         the GFF3 annotation file (required)
                -B, --trim-protein-seq INT   abbreviate protein-changing predictions to at most INT amino acids
                -C, --genetic-code INT|l     the genetic code table to use ('l' to list)
                -c, --custom-tag STRING      use this tag instead of the default BCSQ
                -G, --greedy 0|1             also check the transcript-level consequences after feature hits
                -l, --local-csq              localized predictions, one VCF record at a time
                -n, --ncsq INT               maximum number of per-haplotype consequences for each site
                -p, --phase a|m|r|R|s        how to handle unphased heterozygous genotypes
                --dump-gff FILE.gz           dump the parsed GFF file (for debugging)
                --force                      run even if some sanity checks fail
                --unify-chr-names 0|LIST     unify the chromosome naming by stripping a prefix in VCF,GFF,FASTA
                -s, --samples LIST|-         samples to include, or "-" to apply all variants and ignore the samples
                -S, --samples-file FILE      samples to include
                --no-version                 do not append the version and command line to the header
                -o, --output FILE            write the output to FILE
                -O, --output-type TYPE       b/u: compressed/uncompressed BCF, z/v: compressed/uncompressed VCF, t: text
                --threads INT                use multithreading with INT worker threads
                -v, --verbosity INT          verbosity level, 0-6
                -W, --write-index[=FMT]      automatically index the output files
            ` + filter_opts() + regions_opts() + targets_opts(),
            values: #{
                "--gff-annot": "files", "-g": "files", "--trim-protein-seq": "none", "-B": "none",
                "--genetic-code": "none", "-C": "none", "--custom-tag": "none", "-c": "none",
                "--greedy": ["0", "1"], "-G": ["0", "1"], "--ncsq": "none", "-n": "none",
                "--phase": [
                    #{value: "a", desc: "take GTs as is"}, #{value: "m", desc: "merge all GTs into one haplotype"},
                    #{value: "r", desc: "require phased GTs"}, #{value: "R", desc: "create non-reference haplotypes"},
                    #{value: "s", desc: "skip unphased hets"},
                ],
                "-p": [
                    #{value: "a", desc: "take GTs as is"}, #{value: "m", desc: "merge all GTs into one haplotype"},
                    #{value: "r", desc: "require phased GTs"}, #{value: "R", desc: "create non-reference haplotypes"},
                    #{value: "s", desc: "skip unphased hets"},
                ],
                "--dump-gff": "files", "--unify-chr-names": "none",
                "--output-type": ["b", "u", "z", "v", "t"], "-O": ["b", "u", "z", "v", "t"],
            },
            args: [vcf],
        },
        "filter" => #{
            opts: `
                -g, --SnpGap INT[:TYPE]      filter SNPs within INT base pairs of an indel (or indel,mnp,bnd,other,overlap)
                -G, --IndelGap INT           filter clusters of indels separated by INT or fewer bases, allowing one to pass
                --mask [^]REGION             soft filter regions ("^" to negate)
                -M, --mask-file [^]FILE      soft filter regions listed in a file ("^" to negate)
                --mask-overlap 0|1|2         mask if POS is in the region (0), the record overlaps (1), the variant overlaps (2)
                -m, --mode [+x]              "+": add to the existing FILTER; "x": reset the filters at sites that pass
                -s, --soft-filter STRING     annotate the FILTER column with STRING, or a unique name ("+")
                -S, --set-GTs .|0            set the genotypes of failed samples to missing (.) or ref (0)
            ` + filter_opts() + regions_opts() + targets_opts() + output_opts() + threads_opts(),
            values: #{
                "--SnpGap": "none", "-g": "none", "--IndelGap": "none", "-G": "none", "--mask": "none",
                "--mask-file": "files", "-M": "files", "--mask-overlap": overlaps(),
                "--mode": ["+", "x", "+x"], "-m": ["+", "x", "+x"], "--soft-filter": "none", "-s": "none",
                "--set-GTs": [".", "0"], "-S": [".", "0"],
            },
            args: [vcf],
        },
        "gtcheck" => #{
            opts: `
                --distinctive-sites NUM[,MEM[,TMP]]  find sites that can distinguish at least NUM sample pairs
                --dry-run                    stop after the first record to estimate the time needed
                -E, --error-probability INT  phred-scaled probability of a genotyping error
                -e, --exclude [qry|gt]:EXPR  exclude sites for which the expression is true
                -g, --genotypes FILE         genotypes to compare against
                -H, --homs-only              homozygous genotypes only (requires -g)
                -i, --include [qry|gt]:EXPR  include sites for which the expression is true
                --keep-refs                  keep monoallelic sites with no alternate allele
                --n-matches INT              print only the top INT matches for each sample
                --no-HWE-prob                disable the calculation of the HWE probability
                -o, --output FILE            write the output to FILE
                -O, --output-type t|z        t: plain text, z: compressed
                -p, --pairs LIST             comma-separated sample pairs to compare
                -P, --pairs-file FILE        file with tab-delimited sample pairs to compare
                -s, --samples [qry|gt]:LIST  the query or -g samples ("-" for all)
                -S, --samples-file [qry|gt]:FILE  file with the query or -g samples to compare
                -u, --use TAG1[,TAG2]        which tag to use in the query file and in the -g file
                -v, --verbosity INT          verbosity level
            ` + regions_opts() + targets_opts(),
            values: #{
                "--distinctive-sites": "none", "--error-probability": "none", "-E": "none",
                "--genotypes": k("vcf"), "-g": k("vcf"), "--n-matches": "none",
                "--output-type": [#{value: "t", desc: "plain text"}, #{value: "z", desc: "compressed"}],
                "-O": [#{value: "t", desc: "plain text"}, #{value: "z", desc: "compressed"}],
                "--pairs": "none", "-p": "none", "--pairs-file": "files", "-P": "files", "--use": "none", "-u": "none",
                "--samples": "none", "-s": "none", "--samples-file": "none", "-S": "none",
            },
            args: [vcf],
        },
        "mpileup" => #{
            opts: `
                -6, --illumina1.3+           quality is in the Illumina-1.3+ encoding
                -A, --count-orphans          include anomalous read pairs (PAIRED but not PROPER_PAIR)
                -b, --bam-list FILE          list of the input BAM file names, one per line
                -B, --no-BAQ                 disable BAQ (per-base alignment quality)
                -C, --adjust-MQ INT          adjust the mapping quality
                -D, --full-BAQ               apply BAQ everywhere, not just in problematic regions
                -d, --max-depth INT          maximum raw per-file depth
                -E, --redo-BAQ               recalculate BAQ on the fly, ignoring existing BQs
                -f, --fasta-ref FILE         Faidx-indexed reference sequence file
                --no-reference               do not require a reference FASTA file
                -G, --read-groups FILE       select or exclude the read groups listed in the file
                -q, --min-MQ INT             skip alignments with mapping quality below INT
                -Q, --min-BQ INT             skip bases with baseQ/BAQ below INT
                --max-BQ INT                 limit baseQ/BAQ to at most INT
                --delta-BQ INT               use neighbour_qual + INT if less than qual
                --ignore-RG                  ignore the RG tags (one BAM = one sample)
                --ls, --skip-all-set STR|INT  skip reads with all of these bits set
                --ns, --skip-any-set STR|INT  skip reads with any of these bits set
                --lu, --skip-all-unset STR|INT  skip reads with all of these bits unset
                --nu, --skip-any-unset STR|INT  skip reads with any of these bits unset
                -x, --ignore-overlaps        disable read-pair overlap detection
                --seed INT                   random number seed used for sampling deep regions
                -a, --annotate LIST          optional tags to output ('?' to list)
                -g, --gvcf INT[,...]         group non-variant sites into gVCF blocks
                --no-version                 do not append the version and command line to the header
                -o, --output FILE            write the output to FILE
                -O, --output-type TYPE       b/u: compressed/uncompressed BCF, z/v: compressed/uncompressed VCF
                --threads INT                use multithreading with INT worker threads
                -v, --verbosity INT          verbosity level
                -W, --write-index[=FMT]      automatically index the output files
                -X, --config STR             the platform profile ('-X list' to list)
                -e, --ext-prob INT           phred-scaled gap extension sequence error probability
                -F, --gap-frac FLOAT         minimum fraction of gapped reads
                -h, --tandem-qual INT        coefficient for homopolymer errors
                -I, --skip-indels            do not perform indel calling
                -L, --max-idepth INT         maximum per-file depth for indel calling
                -m, --min-ireads INT         minimum number of gapped reads for indel candidates
                -M, --max-read-len INT       maximum length of a read to pass to BAQ
                -p, --per-sample-mF          apply -m and -F per sample, for more sensitivity
                -P, --platforms STR          comma-separated list of platforms for indels
                --ar, --ambig-reads STR      what to do with ambiguous indel reads
                --indel-bias FLOAT           raise to favour recall over precision
                --del-bias FLOAT             relative likelihood of insertion to deletion
                --score-vs-ref FLOAT         score versus the reference
                --indel-size INT             approximate maximum indel size considered
                --indels-2.0                 new experimental indel calling model (diploid reference consensus)
                --indels-cns                 new experimental indel calling model with edlib
                --seqq-offset                indel-cns tuning for the indel seq-qual scores
                --no-indels-cns              disable the CNS mode, to use after a -X profile
                --poly-mqual                 (edlib mode) use the minimum quality within homopolymers
                --open-prob INT              phred-scaled gap open sequence error probability
                -r, --regions REGION         comma-separated list of regions in which the pileup is generated
                -R, --regions-file FILE      restrict to the regions listed in a file
                -t, --targets REGION         like -r but streams rather than jumps by the index
                -T, --targets-file FILE      like -R but streams rather than jumps by the index
            ` + samples_opts(),
            values: #{
                "--bam-list": "files", "-b": "files", "--adjust-MQ": "none", "-C": "none", "--max-depth": "none", "-d": "none",
                "--fasta-ref": k("fasta"), "-f": k("fasta"), "--read-groups": "files", "-G": "files",
                "--min-MQ": "none", "-q": "none", "--min-BQ": "none", "-Q": "none", "--max-BQ": "none", "--delta-BQ": "none",
                "--skip-all-set": "none", "--ls": "none", "--skip-any-set": "none", "--ns": "none",
                "--skip-all-unset": "none", "--lu": "none", "--skip-any-unset": "none", "--nu": "none",
                "--seed": "none", "--annotate": "none", "-a": "none", "--gvcf": "none", "-g": "none",
                "--config": [
                    "1.12", "bgi", "bgi-1.20", "illumina-1.18", "illumina", "illumina-1.20", "ont", "ont-sup",
                    "ont-sup-1.20", "pacbio-ccs", "pacbio-ccs-1.20",
                ],
                "-X": [
                    "1.12", "bgi", "bgi-1.20", "illumina-1.18", "illumina", "illumina-1.20", "ont", "ont-sup",
                    "ont-sup-1.20", "pacbio-ccs", "pacbio-ccs-1.20",
                ],
                "--ext-prob": "none", "-e": "none", "--open-prob": "none", "--gap-frac": "none", "-F": "none", "--tandem-qual": "none",
                "-h": "none", "--max-idepth": "none", "-L": "none", "--min-ireads": "none", "-m": "none",
                "--max-read-len": "none", "-M": "none", "--platforms": "none", "-P": "none",
                "--ambig-reads": ["drop", "incAD", "incAD0"], "--ar": ["drop", "incAD", "incAD0"],
                "--indel-bias": "none", "--del-bias": "none", "--score-vs-ref": "none", "--indel-size": "none",
                "--output-type": ["b", "u", "z", "v"], "-O": ["b", "u", "z", "v"],
            },
            args: [k("bam")],
        },
        "polysomy" => #{
            opts: `
                -o, --output-dir PATH        the output directory
                -s, --sample NAME            the sample to analyze
                -v, --verbosity INT          verbosity level
                -b, --peak-size FLOAT        minimum peak size (0-1, larger is stricter)
                -c, --cn-penalty FLOAT       penalty for increasing CN (0-1, larger is stricter)
                -f, --fit-th FLOAT           goodness of fit threshold (smaller is stricter)
                -i, --include-aa             include the AA peak in the CN2 and CN3 evaluation
                -m, --min-fraction FLOAT     minimum distinguishable fraction of aberrant cells
                -p, --peak-symmetry FLOAT    peak symmetry threshold (0-1, larger is stricter)
            ` + regions_opts() + targets_opts(),
            values: #{
                "--output-dir": "dirs", "-o": "dirs", "--sample": k("vcf_samples"), "-s": k("vcf_samples"),
                "--peak-size": "none", "-b": "none", "--cn-penalty": "none", "-c": "none", "--fit-th": "none",
                "-f": "none", "--min-fraction": "none", "-m": "none", "--peak-symmetry": "none", "-p": "none",
            },
            args: [vcf],
        },
        "roh" => #{
            opts: `
                --AF-dflt FLOAT              if the AF is not known, use this allele frequency
                --AF-tag TAG                 use TAG for the allele frequency
                --AF-file FILE               read the allele frequencies from a file
                -b, --buffer-size INT[,INT]  buffer size and number of overlapping sites (0: unlimited)
                -e, --estimate-AF [TAG],FILE estimate the AF from FORMAT/TAG (GT or PL) of all samples ("-") or those in FILE
                --exclude EXPR               exclude sites for which the expression is true
                -G, --GTs-only FLOAT         use GTs and ignore PLs, using FLOAT for the PL of the two least likely genotypes
                --include EXPR               select sites for which the expression is true
                -i, --ignore-homref          skip hom-ref genotypes (0/0)
                --include-noalt              include sites with no ALT allele
                -I, --skip-indels            skip indels, as their genotypes are enriched for errors
                -m, --genetic-map FILE       genetic map in IMPUTE2 format (a file, or a mask with {CHROM})
                -M, --rec-rate FLOAT         constant recombination rate per bp
                -o, --output FILE            write the output to FILE
                -O, --output-type [srz]      s: per-site, r: regions, z: compressed
                --threads INT                use multithreading with INT worker threads
                -v, --verbosity INT          verbosity level
                -a, --hw-to-az FLOAT         P(AZ|HW) transition probability from HW to AZ
                -H, --az-to-hw FLOAT         P(HW|AZ) transition probability from AZ to HW
                -V, --viterbi-training FLOAT estimate the HMM parameters (experimental)
            ` + samples_opts() + regions_opts() + targets_opts(),
            values: #{
                "--AF-dflt": "none", "--AF-tag": "none", "--AF-file": "files", "--buffer-size": "none", "-b": "none",
                "--estimate-AF": "none", "-e": "none", "--GTs-only": "none", "-G": "none", "--genetic-map": "files",
                "-m": "files", "--rec-rate": "none", "-M": "none", "--output-type": ["s", "r", "z", "sr", "srz"],
                "-O": ["s", "r", "z", "sr", "srz"], "--hw-to-az": "none", "-a": "none", "--az-to-hw": "none",
                "-H": "none", "--viterbi-training": "none", "-V": "none",
            },
            args: [vcf],
        },
        "stats" => #{
            opts: `
                --af-bins LIST               allele frequency bins, a list (0.1,0.5,1) or a file
                --af-tag STRING              allele frequency tag to use (by default estimated from AN,AC or GT)
                -1, --1st-allele-only        include only the first allele at multiallelic sites
                -c, --collapse STRING        treat records as identical with snps|indels|both|all|some|none
                -d, --depth INT,INT,INT      depth distribution: min,max,bin size
                -E, --exons FILE.gz          exons for indel frameshifts (chr,beg,end; 1-based, bgzip compressed)
                -f, --apply-filters LIST     require at least one of the listed FILTER strings
                -F, --fasta-ref FILE         Faidx-indexed reference sequence, to determine the indel context
                -I, --split-by-ID            collect the stats for sites with an ID separately (known vs novel)
                -u, --user-tstv TAG[:min:max:n]  collect Ts/Tv stats for any tag with the given binning
                --threads INT                use multithreading with INT worker threads
                -v, --verbosity INT          verbosity level
            ` + filter_opts() + samples_opts() + regions_opts() + targets_opts(),
            values: #{
                "--af-bins": "files", "--af-tag": "none",
                "--collapse": ["snps", "indels", "both", "all", "some", "none"], "-c": ["snps", "indels", "both", "all", "some", "none"],
                "--depth": "none", "-d": "none", "--exons": "files", "-E": "files", "--apply-filters": "none",
                "-f": "none", "--fasta-ref": k("fasta"), "-F": k("fasta"), "--user-tstv": "none", "-u": "none",
            },
            args: [vcf],
        },
        _ => return (),
    };
    let values = common_values();
    if spec.contains("values") {
        for key in spec.values.keys() {
            values[key] = spec.values[key];
        }
    }
    spec.values = values;
    spec
}

fn spec(cmd) {
    switch cmd {
        "bcftools" => bcftools(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "bcftools" => bcftools_sub(sub),
        _ => (),
    }
}
