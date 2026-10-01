// Miller 6.22.0, from `mlr help flags`, `mlr help list-verbs` and `mlr VERB --help`: the main flags before the verb,
// and the flags of each verb. The values of the separator flags are asked of the installed mlr.

fn spec(cmd) {
    #{
        single_dash: true,
        strict_eq: true,
        opts: `
            --pass-comments                   immediately print commented lines (prefixed by '#') within the input
            --pass-comments-with VALUE        immediately print commented lines within input, with specified prefix
            --skip-comments                   ignore commented lines (prefixed by '#') within the input
            --skip-comments-with VALUE        ignore commented lines within input, with specified prefix
            --bz2in                           uncompress bzip2 within the Miller process
            --gzin                            uncompress gzip within the Miller process
            --prepipe VALUE                   you can, of course, already do without this for single input files, e.g
            --prepipe-bz2                     same as '--prepipe bz2', except this is allowed in '.mlrrc'
            --prepipe-gunzip                  same as '--prepipe gunzip', except this is allowed in '.mlrrc'
            --prepipe-zcat                    same as '--prepipe zcat', except this is allowed in '.mlrrc'
            --prepipe-zstdcat                 same as '--prepipe zstdcat', except this is allowed in '.mlrrc'
            --prepipex VALUE                  like '--prepipe' with one exception: doesn't insert '<' between command and filename at
            --zin                             uncompress zlib within the Miller process
            --zstdin                          uncompress zstd within the Miller process
            --allow-ragged-csv-input, --ragged, --allow-ragged-tsv-input  if a data line has fewer fields than the header line, fill remaining keys with empty
            --csv-trim-leading-space          trims leading spaces in CSV data
            --headerless-csv-output, --ho, --headerless-tsv-output  print only CSV/TSV data lines; do not print CSV/TSV header lines
            --implicit-csv-header, --headerless-csv-input, --hi, --implicit-tsv-header  use 1,2,3,... as field labels, rather than from line 1 of input files
            --lazy-quotes                     accepts quotes appearing in unquoted fields, and non-doubled quotes appearing in quoted
            --no-auto-unsparsify              for CSV/TSV output: if the record keys change from one row to another, emit a blank line
            --no-implicit-csv-header, --no-implicit-tsv-header  opposite of '--implicit-csv-header'. This is the default anyway -- the main use is for
            --quote-all                       force double-quoting of CSV fields
            -N                                keystroke-saver for '--implicit-csv-header --headerless-csv-output'
            --incr-key                        without this option, keyless DKVP fields are keyed by field number
            --asv, --asvlite                  use ASV format for input and output data
            --box                             use Unicode box-drawing tabular format for input and output data
            --csv, -c, --c2c                  use CSV format for input and output data
            --csvlite                         use CSV-lite format for input and output data
            --dcf                             use Debian control file (DCF) format for input and output data
            --dkvp, --d2d                     use DKVP format for input and output data
            --dkvpx                           use DKVPX format for input and output data
            --gen-field-name                  specify field name for --igen
            --gen-start                       specify start value for --igen
            --gen-step                        specify step value for --igen
            --gen-stop                        specify stop value for --igen
            --iasv, --iasvlite                use ASV format for input data
            --ibox                            use Unicode box-drawing tabular format for input data
            --icsv                            use CSV format for input data
            --icsvlite                        use CSV-lite format for input data
            --idcf                            use Debian control file (DCF) format for input data
            --idkvp                           use DKVP format for input data
            --igen                            ignore input files and instead generate sequential numeric input using --gen-field-name
            --ijson                           use JSON format for input data
            --ijsonl                          use JSON Lines format for input data
            --imd, --imarkdown                use markdown-tabular format for input data
            --inidx                           use NIDX format for input data
            --io VALUE                        use format name for input and output data
            --ipprint                         use PPRINT format for input data
            --irecutils                       use GNU recutils (.rec) format for input data
            --itsv                            use TSV format for input data
            --itsvlite                        use TSV-lite format for input data
            --iusv, --iusvlite                use USV format for input data
            --ixtab                           use XTAB format for input data
            --iyaml                           use YAML format for input data
            --json, -j, --j2j                 use JSON format for input and output data
            --jsonl, --l2l                    use JSON Lines format for input and output data
            --md, --markdown                  use markdown-tabular format for input and output data
            --nidx, --n2n                     use NIDX format for input and output data
            --oasv, --oasvlite                use ASV format for output data
            --obox                            use Unicode box-drawing tabular format for output data
            --ocsv                            use CSV format for output data
            --ocsvlite                        use CSV-lite format for output data
            --odcf                            use Debian control file (DCF) format for output data
            --odkvp                           use DKVP format for output data
            --ojson                           use JSON format for output data
            --ojsonl                          use JSON Lines format for output data
            --omd, --omarkdown                use markdown-tabular format for output data
            --onidx                           use NIDX format for output data
            --opprint                         use PPRINT format for output data
            --orecutils                       use GNU recutils (.rec) format for output data
            --otsv                            use TSV format for output data
            --otsvlite                        use TSV-lite format for output data
            --ousv, --ousvlite                use USV format for output data
            --oxtab                           use XTAB format for output data
            --oyaml                           use YAML format for output data
            --pprint, --p2p                   use PPRINT format for input and output data
            --recutils                        use GNU recutils (.rec) format for input and output data
            --tsv, -t, --t2t                  use TSV format for input and output data
            --tsvlite                         use TSV-lite format for input and output data
            --usv, --usvlite                  use USV format for input and output data
            --xtab, --x2x                     use XTAB format for input and output data
            --xvright                         right-justify values for XTAB format
            --yaml, --y2y                     use YAML format for input and output data
            -i VALUE                          use format name for input data
            -o VALUE                          use format name for output data
            --flatsep, --jflatsep VALUE       separator for flattening multi-level JSON keys, e.g
            --no-auto-flatten                 when output is not JSON or YAML, suppress the default auto-flatten behavior
            --no-auto-unflatten               when input is not JSON or YAML and output is JSON or YAML, suppress the default
            -p                                keystroke-saver for '--nidx --fs space --repifs'
            -T                                keystroke-saver for '--nidx --fs tab'
            --jlistwrap, --jl                 wrap JSON output in outermost '[ ]'. This is the default for JSON output format
            --jvquoteall                      force all JSON values -- recursively into lists and object -- to string
            --jvstack                         put one key-value pair per line for JSON output (multi-line output)
            --no-jlistwrap                    do not wrap JSON output in outermost '[ ]'. This is the default for JSON Lines output
            --no-jvstack                      put objects/arrays all on one line for JSON output
            --no-yarray                       do not wrap YAML output in a single array document; emit one YAML document per record
            --yarray, --ya                    wrap YAML output in a single top-level array document
            --jknquoteint                     type information from JSON input files is now preserved throughout the processing stream
            --jquoteall                       type information from JSON input files is now preserved throughout the processing stream
            --json-fatal-arrays-on-input      miller now supports arrays as of version 6
            --json-map-arrays-on-input        miller now supports arrays as of version 6
            --json-skip-arrays-on-input       miller now supports arrays as of version 6
            --jsonx                           the '--jvstack' flag is now default true in Miller 6
            --mmap                            miller no longer uses memory-mapping to access data files
            --no-mmap                         miller no longer uses memory-mapping to access data files
            --ojsonx                          the '--jvstack' flag is now default true in Miller 6
            --quote-minimal                   ignored as of version 6
            --quote-none                      ignored as of version 6
            --quote-numeric                   ignored as of version 6
            --quote-original                  ignored as of version 6
            --vflatsep                        ignored as of version 6
            --md-aligned, --markdown-aligned  use markdown-tabular format for input and output data, with left-justified and padded
            --omd-aligned, --omarkdown-aligned  for markdown-tabular output, left-justify cells and pad each column to a uniform width
            --errors-json                     emit parse errors as a JSON object to stderr instead of a plain text message
            --fflush                          force buffered output to be written after every output record
            --files VALUE                     use this to specify a file which itself contains, one per line, names of input files
            --from VALUE                      use this to specify an input file before the verb(s), rather than after
            --hash-records                    this is an internal parameter which normally does not need to be modified
            --infer-int-as-float, -A          cast all integers in data files to floats
            --infer-none, -S                  don't treat values like 123 or 456.7 in data files as int/float; leave them as strings
            --infer-octal, -O                 treat numbers like 0123 in data files as numeric; default is string
            --load VALUE                      load DSL script file for all put/filter operations on the command line
            --mfrom VALUE                     use this to specify one of more input files before the verb(s), rather than after
            --mload VALUE                     like '--load' but works with more than one filename, e.g
            --no-dedupe-field-names           by default, if an input record has a field named 'x' and another also named 'x', the
            --no-fflush                       let buffered output not be written after every output record
            --no-hash-records                 see --hash-records
            --no-shell                        disable Miller's ability to run external commands: the DSL 'system' and 'exec' functions
            --norc                            do not load a .mlrrc file
            --nr-progress-mod VALUE           with m a positive integer: print filename and record count to os.Stderr every m input
            --ofmt VALUE                      e.g
            --ofmte VALUE                     use --ofmte 6 as shorthand for --ofmt %.6e, etc
            --ofmtf VALUE                     use --ofmtf 6 as shorthand for --ofmt %.6f, etc
            --ofmtg VALUE                     use --ofmtg 6 as shorthand for --ofmt %.6g, etc
            --profile, -P VALUE               apply the settings from the [name] section of your .mlrrc file, after any global
            --records-per-batch VALUE         this is an internal parameter for maximum number of records in a batch size
            --s-no-comment-strip VALUE        take command-line flags from file name, like -s, but with no comment-stripping
            --seed VALUE                      with 'n' of the form '12345678' or '0xcafefeed'. For 'put'/'filter' 'urand', 'urandint'
            --tz VALUE                        specify timezone, overriding '$TZ' environment variable (if any)
            -I                                process files in-place
            -n                                process no input files, nor standard input either
            -s VALUE                          take command-line flags from file name
            -x                                if any record has an error value in it, report it and stop the process
            --always-color, -C                instructs Miller to colorize output even when it normally would not
            --fail-color                      specify the color (see '--list-color-codes' and '--list-color-names') for failing cases
            --help-color                      specify the color (see '--list-color-codes' and '--list-color-names') for highlights in
            --key-color                       specify the color (see '--list-color-codes' and '--list-color-names') for record keys
            --list-color-codes                show the available color codes in the range 0..255, such as 170 for example
            --list-color-names                show the names for the available color codes, such as 'orchid' for example
            --no-color, -M                    instructs Miller to not colorize any output
            --pass-color                      specify the color (see '--list-color-codes' and '--list-color-names') for passing cases
            --value-color                     specify the color (see '--list-color-codes' and '--list-color-names') for record values
            --barred, --barred-output         prints a border around PPRINT output
            --barred-input                    when used in conjunction with --pprint, accepts barred input
            --barred-unicode                  uses unicode printing chars for barred output
            --fixed VALUE                     fixed width specification
            --fw VALUE                        shortcut for --fixed left-align-multi-word
            --right                           right-justifies all fields for PPRINT output
            --right-align-numeric             right-justifies fields with numeric values for PPRINT output, leaving other fields
            --cpuprofile VALUE                create a CPU-profile file for performance analysis
            --time                            print elapsed execution time in seconds to stderr at the end of the execution of the
            --traceprofile                    create a trace-profile file for performance analysis
            --fs VALUE                        specify FS for input and output
            --ifs VALUE                       specify FS for input
            --ifs-regex VALUE                 specify FS for input as a regular expression
            --ips VALUE                       specify PS for input
            --ips-regex VALUE                 specify PS for input as a regular expression
            --irs VALUE                       specify RS for input
            --ofs VALUE                       specify FS for output
            --ops VALUE                       specify PS for output
            --ors VALUE                       specify RS for output
            --ps VALUE                        specify PS for input and output
            --repifs                          let IFS be repeated: e.g
            --rs VALUE                        specify RS for input and output
        `,
        values: #{
            "--pass-comments-with": "none", "--skip-comments-with": "none", "--prepipe": "none",
            "--prepipex": "none", "--io": "none", "-i": "none", "-o": "none",
            "--flatsep": "@extra-complete/science/kinds:miller_separator",
            "--jflatsep": "@extra-complete/science/kinds:miller_separator", "--files": "files", "--from": "files",
            "--load": "files", "--mfrom": "files", "--mload": "files", "--nr-progress-mod": "none",
            "--ofmt": "none", "--ofmte": "none", "--ofmtf": "none", "--ofmtg": "none", "--profile": "none",
            "-P": "none", "--records-per-batch": "none", "--s-no-comment-strip": "files", "--seed": "none",
            "--tz": "none", "-s": "files", "--fixed": "none", "--fw": "none", "--cpuprofile": "files",
            "--fs": "@extra-complete/science/kinds:miller_separator",
            "--ifs": "@extra-complete/science/kinds:miller_separator", "--ifs-regex": "none",
            "--ips": "@extra-complete/science/kinds:miller_separator", "--ips-regex": "none",
            "--irs": "@extra-complete/science/kinds:miller_separator",
            "--ofs": "@extra-complete/science/kinds:miller_separator",
            "--ops": "@extra-complete/science/kinds:miller_separator",
            "--ors": "@extra-complete/science/kinds:miller_separator",
            "--ps": "@extra-complete/science/kinds:miller_separator",
            "--rs": "@extra-complete/science/kinds:miller_separator",
        },
        commands: `
            altkv                   given fields with values of the form a,b,c,d,e,f emits a=b,c=d,e=f pairs
            bar                     replaces a numeric field with a number of asterisks, allowing for cheesy
            bootstrap               emits an n-sample, with replacement, of the input records
            bootstrap-ci            computes bootstrap confidence intervals for statistics of given fields
            case                    uppercases strings in record keys and/or values
            cat                     passes input records directly to output
            check                   consumes records without printing any output
            clean-whitespace        for each record, for each field in the record, whitespace-cleans the keys and/or
            count-distinct          prints number of records having distinct values for specified field names
            count                   prints number of records, optionally grouped by distinct values for specified field names
            count-similar           ingests all records, then emits each record augmented by a count of
            cut                     passes through input records with specified fields included/excluded
            decimate                passes through one of every n records, optionally by category
            describe                shows a compact schema for the input data: field names, types, and value shape
            fill-down               if a given record has a missing value for a given field, fill that from
            fill-empty              fills empty-string fields with specified fill-value
            filter                  lets you use a domain-specific language to programmatically filter which
            flatten                 flattens multi-level maps to single-level ones
            format-values           applies format strings to all field values, depending on autodetected type
            fraction                for each record's value in specified fields, computes the ratio of that
            gap                     emits an empty record every n records, or when certain values change
            grep                    passes through records which match the regular expression
            group-by                outputs records in batches having identical values at specified field names
            group-like              outputs records in batches having identical field names
            gsub                    replaces old string with new string in specified field(s), with regex support
            having-fields           conditionally passes through records depending on each record's field names
            head                    passes through the first n records, optionally by category
            histogram               options
            json-parse              tries to convert string field values to parsed JSON, e.g
            json-stringify          produces string field values from field-value data, e.g
            join                    joins records from specified left file name with records from all file names
            label                   given n comma-separated names, renames the first n fields of each record to
            latin1-to-utf8          recursively converts record strings from Latin-1 to UTF-8
            least-frequent          shows the least frequently occurring distinct values for specified field names
            merge-fields            computes univariate statistics for each input record, accumulated across
            most-frequent           shows the most frequently occurring distinct values for specified field names
            nest                    explodes specified field values into separate fields/records, or reverses this
            nothing                 drops all input records
            put                     lets you use a domain-specific language to programmatically alter stream records
            rank                    for each record's value in specified fields, computes the standard
            regularize              outputs records sorted lexically ascending by keys
            remove-empty-columns    omits fields which are empty on every input row
            rename                  renames specified fields
            reorder                 moves specified names to start of record, or end of record
            repeat                  copies input records to output records multiple times
            reshape                 wide-to-long options
            sample                  reservoir sampling (subsampling without replacement), optionally by category
            sec2gmtdate             replaces a numeric field representing seconds since the epoch with the
            sec2gmt                 replaces a numeric field representing seconds since the epoch with the
            seqgen                  produces a sequence of counters
            shuffle                 outputs records randomly permuted
            skip-trivial-records    passes through all records except those with zero fields
            sort                    sorts records primarily by the first specified field, secondarily by the second
            sort-within-records     outputs records sorted lexically ascending by keys
            sparkline               reduces numeric field(s), across all records in input order, to a compact
            sparsify                unsets fields for which the key is the empty string
            split                   options
            ssub                    replaces old string with new string in specified field(s), without regex support for
            stats1                  computes univariate statistics for one or more given fields, accumulated across
            stats2                  computes bivariate statistics for one or more given field-name pairs
            step                    computes values dependent on earlier/later records, optionally grouped by category
            sub                     replaces old string with new string in specified field(s), with regex support
            summary                 show summary statistics about the input data
            surv                    estimate Kaplan-Meier survival curve (right-censored)
            tac                     prints records in reverse order from the order in which they were encountered
            tail                    passes through the last n records, optionally by category
            tee                     options
            template                places input-record fields in the order specified by list of column names
            top                     options
            utf8-to-latin1          recursively converts record strings from UTF-8 to Latin-1
            unflatten               reverses flatten
            uniq                    prints distinct values for specified field names
            unspace                 replaces spaces in record keys and/or values with _. This is helpful for PPRINT output
            unsparsify              prints records with the union of field names over all input records
        `,
        sub_spec: "@extra-complete/science/miller:verb",
    }
}

fn sub_spec(name, sub) {
    switch sub {
        "altkv" => #{},
        "bar" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field names to convert to bars
                --lo VALUE                        lower-limit value for min-width bar: default '0.000000'
                --hi VALUE                        upper-limit value for max-width bar: default '100.000000'
                -w VALUE                          bar-field width: default '40'
                --auto                            automatically computes limits, ignoring --lo and --hi
                -c VALUE                          fill character: default '*'
                -x VALUE                          out-of-bounds character: default '#'
                -b VALUE                          blank character: default '.'
            `,
            values: #{
                "-f": "none", "--lo": "none", "--hi": "none", "-w": "none", "-c": "none", "-x": "none",
                "-b": "none",
            },
        },
        "bootstrap" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -n VALUE                          number of samples to output
            `,
            values: #{
                "-n": "none",
            },
        },
        "bootstrap-ci" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a VALUE                          names of statistics to bootstrap: one or more of the listed values, as in mlr stats1 -a
                -f VALUE                          value-field names on which to compute statistics
                -g VALUE                          optional group-by-field names
                -n VALUE                          number of bootstrap resamples
                -c VALUE                          confidence level, strictly between 0 and 1
                -i                                use interpolated percentiles, like R's type=7, for percentile statistics as well as for
            `,
            values: #{
                "-a": "none", "-f": "none", "-g": "none", "-n": "none", "-c": "none",
            },
        },
        "case" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -k                                case only keys, not keys and values
                -v                                case only values, not keys and values
                -f VALUE                          specify which field names to case
                -u                                convert to uppercase
                -l                                convert to lowercase
                -s                                convert to sentence case (capitalize first letter)
                -t                                convert to title case (capitalize words)
            `,
            values: #{
                "-f": "none",
            },
        },
        "cat" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -n                                prepend field "n" to each record with record-counter starting at 1
                -N VALUE                          prepend field {name} to each record with record-counter starting at 1
                -g VALUE                          optional group-by-field names for counters, e.g
                --filename                        prepend current filename to each record
                --filenum                         prepend current filenum (1-up) to each record
            `,
            values: #{
                "-N": "none", "-g": "none",
            },
        },
        "check" => #{},
        "clean-whitespace" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -k, --keys-only                   do not touch values
                -v, --values-only                 do not touch keys
            `,
            values: #{

            },
        },
        "count-distinct" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field names for distinct count (synonym for -g)
                -g VALUE                          field names for distinct count
                -x VALUE                          field names to exclude for distinct count; use each record's other fields instead
                -n                                show only the number of distinct values
                -o VALUE                          field name for output count
                -u                                do unlashed counts for multiple field names
            `,
            values: #{
                "-f": "none", "-g": "none", "-x": "none", "-o": "none",
            },
        },
        "count" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          optional group-by-field names for counts, e.g
                -n                                show only the number of distinct values
                -o VALUE                          field name for output-count
            `,
            values: #{
                "-g": "none", "-o": "none",
            },
        },
        "count-similar" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          group-by-field names for counts, e.g
                -o VALUE                          field name for output-counts
            `,
            values: #{
                "-g": "none", "-o": "none",
            },
        },
        "cut" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          comma-separated field names to include or exclude, e.g
                -o                                retain fields in the order specified by -f rather than in input-record order
                -x, --complement                  exclude, rather than include, the field names specified by -f
                -r                                treat field names as regular expressions
            `,
            values: #{
                "-f": "none",
            },
        },
        "decimate" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -b                                decimate by printing first of every n
                -e                                decimate by printing last of every n
                -g VALUE                          optional group-by-field names for decimate counts, e.g
                -n VALUE                          decimation factor
            `,
            values: #{
                "-g": "none", "-n": "none",
            },
        },
        "describe" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -n, --max-values VALUE            list a field's distinct values only if it has at most {n} of them; 0 suppresses the
            `,
            values: #{
                "-n": "none", "--max-values": "none",
            },
        },
        "fill-down" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                --all                             operate on all fields in the input
                -a, --only-if-absent              if a given record has a missing value for a given field, fill that from the corresponding
                -f VALUE                          field names for fill-down
            `,
            values: #{
                "-f": "none",
            },
        },
        "fill-empty" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -v VALUE                          fill-value: defaults to "N/A"
                -S                                don't infer type -- so '-v 0' would fill string 0 not int 0
            `,
            values: #{
                "-v": "none",
            },
        },
        "filter" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          file containing a DSL expression (see examples below)
                -e VALUE                          DSL expression to evaluate
                -s VALUE                          predefines out-of-stream variable @name to have the given value
                -x                                prints records for which {expression} evaluates to false, not true, i.e
                -q                                does not include the modified record in the output stream
                -S                                no-op in Miller 6 and above, since type-inferencing is now done by the record-readers
                -F                                no-op in Miller 6 and above, since type-inferencing is now done by the record-readers
                -w                                print warnings about things like uninitialized variables
                -W                                same as -w, but exit the process if there are any warnings
                -p                                prints the expression's AST (abstract syntax tree), which gives full transparency on the
                -d                                like -p but uses a parenthesized-expression format for the AST
                -D                                like -d but with output all on one line
                -E                                echo DSL expression before printing parse-tree
                -v                                same as -E -p
                -X                                exit after parsing but before stream-processing
                --explain                         parse and type-check the DSL expression, report whether it is valid, and exit without
            `,
            values: #{
                "-f": "files", "-e": "none", "-s": "none",
            },
        },
        "flatten" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f                                comma-separated list of field names to flatten
                -s VALUE                          separator, defaulting to mlr --flatsep value
            `,
            values: #{
                "-s": "none",
            },
        },
        "format-values" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -i VALUE                          integer format string; defaults to "%d". Examples: "%06lld", "%08llx". Note that Miller
                -f VALUE                          float format string; defaults to "%f". Examples: "%8.3lf", "%.6le". Note that Miller
                -s VALUE                          string format string; defaults to "%s". Examples: "_%s", "%08s". Note that you must use
                -n                                coerce field values autodetected as int to float, and then apply the float format
            `,
            values: #{
                "-i": "none", "-f": "none", "-s": "none",
            },
        },
        "fraction" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field name(s) for fraction calculation
                -g VALUE                          optional group-by-field name(s) for fraction counts
                -p                                produce percents [0..100], not fractions
                -c                                produce cumulative distributions, i.e
            `,
            values: #{
                "-f": "none", "-g": "none",
            },
        },
        "gap" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          print a gap whenever values of these fields
                -n VALUE                          print a gap every n records
            `,
            values: #{
                "-g": "none", "-n": "none",
            },
        },
        "grep" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -i                                use case-insensitive search
                -v                                invert: pass through records which do not match the regex
                -a                                only grep for values, not keys and values
            `,
            values: #{

            },
        },
        "group-by" => #{},
        "group-like" => #{},
        "gsub" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field names to apply substitution to
                -r VALUE                          regular expression for field names to apply substitution to
                -a                                apply substitution to all fields
            `,
            values: #{
                "-f": "none", "-r": "none",
            },
        },
        "having-fields" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                --at-least VALUE                  pass records that have at least these field names
                --which-are VALUE                 pass records whose field names are exactly these
                --at-most VALUE                   pass records that have at most these field names
                --all-matching VALUE              pass records where all field names match the regex
                --any-matching VALUE              pass records where any field name matches the regex
                --none-matching VALUE             pass records where no field name matches the regex
            `,
            values: #{
                "--at-least": "none", "--which-are": "none", "--at-most": "none", "--all-matching": "none",
                "--any-matching": "none", "--none-matching": "none",
            },
        },
        "head" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          optional group-by-field names for head counts, e.g
                -n VALUE                          head-count to print
            `,
            values: #{
                "-g": "none", "-n": "none",
            },
        },
        "histogram" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          value-field names for histogram counts
                --lo VALUE                        histogram low value
                --hi VALUE                        histogram high value
                --nbins VALUE                     number of histogram bins
                --auto                            automatically computes limits, ignoring --lo and --hi
                -o VALUE                          prefix for output field name
                -s                                print a one-line Unicode sparkline per field instead of per-bin counts
            `,
            values: #{
                "-f": "none", "--lo": "none", "--hi": "none", "--nbins": "none", "-o": "none",
            },
        },
        "json-parse" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          comma-separated list of field names to json-parse
                -k                                if supplied, then on parse fail for any cell, keep the (unparsable) input value for the
            `,
            values: #{
                "-f": "none",
            },
        },
        "json-stringify" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          comma-separated list of field names to json-stringify
                --jvstack                         produce multi-line JSON output
                --no-jvstack                      produce single-line JSON output per record
            `,
            values: #{
                "-f": "none",
            },
        },
        "join" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          left file name for join
                -j VALUE                          comma-separated join-field names for output
                -l VALUE                          comma-separated join-field names for left input file; defaults to -j values if omitted
                -r VALUE                          comma-separated join-field names for right input file(s); defaults to -j values if omitted
                --lk, --left-keep-field-names VALUE  if supplied, this means keep only the specified field names from the left file
                --lp VALUE                        additional prefix for non-join output field names from the left file
                --rp VALUE                        additional prefix for non-join output field names from the right file(s)
                --np                              do not emit paired records
                --ul                              emit unpaired records from the left file
                --ur                              emit unpaired records from the right file(s)
                --ignore-empty                    treat records with empty-string values in any join-field as if that join-field were
                -s, --sorted-input                require sorted input: records must be sorted lexically by their join-field names, else
                -u                                enable unsorted input
                --prepipe VALUE                   shell command to prepipe the left-file input through
                --prepipex VALUE                  shell command to prepipe the left-file input through (no shell quoting)
            `,
            values: #{
                "-f": "files", "-j": "none", "-l": "none", "-r": "none", "--lk": "none",
                "--left-keep-field-names": "none", "--lp": "none", "--rp": "none", "--prepipe": "none",
                "--prepipex": "none",
            },
        },
        "label" => #{},
        "latin1-to-utf8" => #{},
        "least-frequent" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          one or more comma-separated field names to group by
                -n VALUE                          maximum number of results to output
                -b                                suppress counts; show only field values
                -o VALUE                          field name for output count
            `,
            values: #{
                "-f": "none", "-n": "none", "-o": "none",
            },
        },
        "merge-fields" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a VALUE                          names of accumulators: one or more of the accumulators listed below
                -f VALUE                          value-field names on which to compute statistics
                -r VALUE                          regular expressions for value-field names on which to compute statistics
                -c VALUE                          substrings for collapse mode: all fields which have the same names after removing
                -i                                use interpolated percentiles, like R's type=7; default like type=1
                -o VALUE                          output field basename for -f/-r
                -k                                keep the input fields which contributed to the output statistics; the default is to omit
                -S                                no-op flag for backward compatibility with Miller 5
                -F                                no-op flag for backward compatibility with Miller 5
            `,
            values: #{
                "-a": "none", "-f": "none", "-r": "none", "-c": "none", "-o": "none",
            },
        },
        "most-frequent" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          one or more comma-separated field names to group by
                -n VALUE                          maximum number of results to output
                -b                                suppress counts; show only field values
                -o VALUE                          field name for output count
            `,
            values: #{
                "-f": "none", "-n": "none", "-o": "none",
            },
        },
        "nest" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                --explode                         explode field values into separate fields/records
                --implode                         reverse of --explode
                --values                          operate on field values
                --pairs                           operate on field key-value pairs
                --across-records                  explode/implode across records
                --across-fields                   explode/implode across fields
                -f VALUE                          required field name to operate on
                -r VALUE                          like -f but treat arguments as a regular expression
                --nested-fs VALUE                 field separator for nested values
                --nested-ps VALUE                 pair separator for nested key-value pairs
                --evar VALUE                      shorthand for --explode --values --across-records --nested-fs {string}
                --ivar VALUE                      shorthand for --implode --values --across-records --nested-fs {string}
            `,
            values: #{
                "-f": "none", "-r": "none", "--nested-fs": "none", "--nested-ps": "none", "--evar": "none",
                "--ivar": "none",
            },
        },
        "nothing" => #{},
        "put" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          file containing a DSL expression (see examples below)
                -e VALUE                          DSL expression to evaluate
                -s VALUE                          predefines out-of-stream variable @name to have the given value
                -x                                prints records for which {expression} evaluates to false, not true, i.e
                -q                                does not include the modified record in the output stream
                -S                                no-op in Miller 6 and above, since type-inferencing is now done by the record-readers
                -F                                no-op in Miller 6 and above, since type-inferencing is now done by the record-readers
                -w                                print warnings about things like uninitialized variables
                -W                                same as -w, but exit the process if there are any warnings
                -p                                prints the expression's AST (abstract syntax tree), which gives full transparency on the
                -d                                like -p but uses a parenthesized-expression format for the AST
                -D                                like -d but with output all on one line
                -E                                echo DSL expression before printing parse-tree
                -v                                same as -E -p
                -X                                exit after parsing but before stream-processing
                --explain                         parse and type-check the DSL expression, report whether it is valid, and exit without
            `,
            values: #{
                "-f": "files", "-e": "none", "-s": "none",
            },
        },
        "rank" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field name(s) to rank
                -g VALUE                          optional group-by-field name(s)
                --sorted                          promise that the input is already sorted by the field(s) being ranked
            `,
            values: #{
                "-f": "none", "-g": "none",
            },
        },
        "regularize" => #{},
        "remove-empty-columns" => #{},
        "rename" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -r                                treat old field names as regular expressions
                -g                                do global replacement within each field name rather than first-match replacement
            `,
            values: #{

            },
        },
        "reorder" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -e                                put specified field names at record end: default is to put them at record start
                -f VALUE                          field names to reorder
                -r VALUE                          treat field names as regular expressions
                -b VALUE                          put field names specified with -f before field name specified by {x}, if any
                -a VALUE                          put field names specified with -f after field name specified by {x}, if any
            `,
            values: #{
                "-f": "none", "-r": "none", "-b": "none", "-a": "none",
            },
        },
        "repeat" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -n VALUE                          repeat each input record this many times
                -f VALUE                          same as -n, but take the repeat count from the specified field name of each input record
            `,
            values: #{
                "-n": "none", "-f": "none",
            },
        },
        "reshape" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -i VALUE                          input field names for wide-to-long reshape
                -r VALUE                          input field regex for wide-to-long reshape
                -o VALUE                          output key-field and value-field names for wide-to-long reshape
                -s VALUE                          key-field and value-field names for long-to-wide reshape
                -S                                sort the newly-created wide-field keys for long-to-wide reshape (-s)
                -n                                with -S, sort the new wide-field keys naturally
            `,
            values: #{
                "-i": "none", "-r": "none", "-o": "none", "-s": "none",
            },
        },
        "sample" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          optional: group-by-field names for samples, e.g
                -k VALUE                          required: number of records to output in total, or by group if using -g
            `,
            values: #{
                "-g": "none", "-k": "none",
            },
        },
        "sec2gmtdate" => #{},
        "sec2gmt" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -1                                format seconds with 1 decimal place
                -2                                format seconds with 2 decimal places
                -3                                format seconds with 3 decimal places
                -4                                format seconds with 4 decimal places
                -5                                format seconds with 5 decimal places
                -6                                format seconds with 6 decimal places
                -7                                format seconds with 7 decimal places
                -8                                format seconds with 8 decimal places
                -9                                format seconds with 9 decimal places
                --millis                          input numbers are treated as milliseconds since the epoch
                --micros                          input numbers are treated as microseconds since the epoch
                --nanos                           input numbers are treated as nanoseconds since the epoch
            `,
            values: #{

            },
        },
        "seqgen" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field name for counters
                --start VALUE                     inclusive start value
                --step VALUE                      step value
                --stop VALUE                      inclusive stop value
            `,
            values: #{
                "-f": "none", "--start": "none", "--step": "none", "--stop": "none",
            },
        },
        "shuffle" => #{},
        "skip-trivial-records" => #{},
        "sort" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          lexical ascending sort on the specified field names
                -r VALUE                          lexical descending sort on the specified field names
                -c VALUE                          case-folded lexical ascending sort on the specified field names
                -cr VALUE                         case-folded lexical descending sort on the specified field names
                -n VALUE                          numerical ascending sort on the specified field names; nulls sort last
                -nf VALUE                         same as -n
                -nr VALUE                         numerical descending sort on the specified field names; nulls sort first
                -t VALUE                          natural ascending sort on the specified field names
                -b                                move sort fields to start of record, as in reorder -b
                -tr, -rt VALUE                    natural descending sort on the specified field names
            `,
            values: #{
                "-f": "none", "-r": "none", "-c": "none", "-cr": "none", "-n": "none", "-nf": "none",
                "-nr": "none", "-t": "none", "-tr": "none", "-rt": "none",
            },
        },
        "sort-within-records" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          sort only these keys; others preserve record order
                -r VALUE                          sort only keys matching this regex; others preserve record order
                -n                                sort field names naturally
            `,
            values: #{
                "-f": "none", "-r": "none",
            },
        },
        "sparkline" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field names to sparkline
            `,
            values: #{
                "-f": "none",
            },
        },
        "sparsify" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -s VALUE                          what values to remove
                -f VALUE                          specify field names to be operated on; any other fields won't be modified
            `,
            values: #{
                "-s": "none", "-f": "none",
            },
        },
        "split" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -n VALUE                          cap output file sizes at N records
                -m VALUE                          produce M files, round-robining records among them
                -g VALUE                          write separate files with records having distinct values for the specified field names
                --prefix VALUE                    output filename prefix
                --suffix VALUE                    output filename suffix
                --folder VALUE                    output directory
                -a                                append to existing files rather than overwriting
                -v                                send records downstream as well as splitting to files
                -e                                do NOT URL-escape names of output files
                -j VALUE                          string used to join filename parts
            `,
            values: #{
                "-n": "none", "-m": "none", "-g": "none", "--prefix": "none", "--suffix": "none",
                "--folder": "none", "-j": "none",
            },
        },
        "ssub" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field names to apply substitution to
                -r VALUE                          regular expression for field names to apply substitution to
                -a                                apply substitution to all fields
            `,
            values: #{
                "-f": "none", "-r": "none",
            },
        },
        "stats1" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a VALUE                          names of accumulators: one or more of the listed values
                -f VALUE                          value-field names on which to compute statistics
                --fr VALUE                        regex for value-field names on which to compute statistics
                --fx VALUE                        inverted regex for value-field names on which to compute statistics
                -g VALUE                          optional group-by-field names
                --gr VALUE                        regex for optional group-by-field names
                --gx VALUE                        inverted regex for optional group-by-field names
                --grfx VALUE                      shorthand for --gr {regex} --fx {that same regex}
                -i                                use interpolated percentiles, like R's type=7; default like type=1
                -s                                print iterative stats
                -w VALUE                          sliding-window mode: compute statistics over a trailing window of up to n records
                -S                                no-op flag for backward compatibility with Miller 5
                -F                                no-op flag for backward compatibility with Miller 5
            `,
            values: #{
                "-a": "none", "-f": "none", "--fr": "none", "--fx": "none", "-g": "none", "--gr": "none",
                "--gx": "none", "--grfx": "none", "-w": "none",
            },
        },
        "stats2" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a VALUE                          names of accumulators: one or more of the listed values
                -f VALUE                          value-field name-pairs on which to compute statistics
                -g VALUE                          optional group-by-field names
                -v                                print additional output for linreg-pca
                -s                                print iterative stats
                --fit                             rather than printing regression parameters, applies them to the input data to compute new
                -S                                no-op flag for backward compatibility with Miller 5
                -F                                no-op flag for backward compatibility with Miller 5
            `,
            values: #{
                "-a": "none", "-f": "none", "-g": "none",
            },
        },
        "step" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a VALUE                          names of steppers: comma-separated, one or more of the listed values
                -f VALUE                          value-field names on which to compute statistics
                -g VALUE                          optional group-by-field names
                -F                                computes integerable things
                -d VALUE                          weights for EWMA. 1 means current sample gets all weight (no smoothing), near under 1 is
                -o VALUE                          custom suffixes for EWMA output fields
            `,
            values: #{
                "-a": "none", "-f": "none", "-g": "none", "-d": "none", "-o": "none",
            },
        },
        "sub" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          field names to apply substitution to
                -r VALUE                          regular expression for field names to apply substitution to
                -a                                apply substitution to all fields
            `,
            values: #{
                "-f": "none", "-r": "none",
            },
        },
        "summary" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a VALUE                          use only the specified summarizers
                -x VALUE                          use all summarizers except the specified ones
                --all                             use all available summarizers
                --transpose                       show output with field names as column names
            `,
            values: #{
                "-a": "none", "-x": "none",
            },
        },
        "surv" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -d VALUE                          name of duration field (time-to-event or censoring)
                -s VALUE                          name of status field (0=censored, 1=event)
            `,
            values: #{
                "-d": "none", "-s": "none",
            },
        },
        "tac" => #{},
        "tail" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          optional group-by-field names for tail counts, e.g
                -n VALUE                          tail-count to print
            `,
            values: #{
                "-g": "none", "-n": "none",
            },
        },
        "tee" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -a                                append to existing file, if any, rather than overwriting
                -p                                treat filename as a pipe-to command
            `,
            values: #{

            },
        },
        "template" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          comma-separated field names for template, e.g
                -t VALUE                          CSV file whose header line will be used for template
                --fill-with VALUE                 what to fill absent fields with
            `,
            values: #{
                "-f": "none", "-t": "files", "--fill-with": "none",
            },
        },
        "top" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          value-field names for top counts
                -g VALUE                          optional group-by-field names for top counts
                -n VALUE                          how many records to print per category; default 1
                -a                                print all fields for top-value records; default is to print only value and group-by fields
                --max                             print top largest values
                --min                             print top smallest values; default is top largest values
                -F                                keep top values as floats even if they look like integers
                -o VALUE                          field name for output indices
            `,
            values: #{
                "-f": "none", "-g": "none", "-n": "none", "-o": "none",
            },
        },
        "utf8-to-latin1" => #{},
        "unflatten" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          comma-separated list of field names to unflatten
                -s VALUE                          separator, defaulting to mlr --flatsep value
            `,
            values: #{
                "-f": "none", "-s": "none",
            },
        },
        "uniq" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -g VALUE                          group-by field names for uniq counts
                -f VALUE                          synonym for -g
                -x VALUE                          field names to exclude for uniq; use each record's other fields instead
                -c                                show repeat counts in addition to unique values
                -n                                show only the number of distinct values
                -o VALUE                          field name for output count
                -a                                output each unique record only once
            `,
            values: #{
                "-g": "none", "-f": "none", "-x": "none", "-o": "none",
            },
        },
        "unspace" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                -f VALUE                          replace spaces with specified filler character
                -k                                unspace only keys, not keys and values
                -v                                unspace only values, not keys and values
            `,
            values: #{
                "-f": "none",
            },
        },
        "unsparsify" => #{
            single_dash: true,
            strict_eq: true,
            opts: `
                --fill-with VALUE                 what to fill absent fields with
                -f VALUE                          specify field names to be operated on; others are not modified and operation is streaming
            `,
            values: #{
                "--fill-with": "none", "-f": "none",
            },
        },
        _ => (),
    }
}
