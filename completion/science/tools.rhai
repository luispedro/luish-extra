// Small tools, from their `--help` (duckdb 1.5.6, datamash 1.9, pigz 2.8, gnuplot 6.0 patchlevel 5,
// R and Rscript 4.6.1). Written by hand: their help formats have nothing in common.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

fn duckdb() {
    #{
        single_dash: true,
        opts: `
            -ascii                set output mode to 'ascii'
            -bail                 stop after hitting an error
            -batch                force batch I/O
            -box                  set output mode to 'box'
            -column               set output mode to 'column'
            -cmd COMMAND          run COMMAND before reading stdin
            -csv                  set output mode to 'csv'
            -c COMMAND            run COMMAND and exit
            -dark-mode            use dark mode colors
            -echo                 print commands before execution
            -f FILENAME           read and process the named file and exit
            -init FILENAME        read and process the named file
            -header               turn headers on
            -h                    show help message
            -help                 show help message
            -html                 set output mode to HTML
            -interactive          force interactive I/O
            -json                 set output mode to 'json'
            -jsonlines            set output mode to 'jsonlines'
            -light-mode           use light mode colors
            -line                 set output mode to 'line'
            -list                 set output mode to 'list'
            -markdown             set output mode to 'markdown'
            -newline SEP          set output row separator
            -no-init              skip processing the init file
            -no-stdin             exit after processing options instead of reading stdin
            -noheader             turn headers off
            -nullvalue TEXT       set text string for NULL values
            -quote                set output mode to 'quote'
            -readonly             open the database read-only
            -s COMMAND            run COMMAND and exit
            -safe                 enable safe-mode
            -separator SEP        set output column separator
            -storage-version VER  database storage compatibility version to use
            -table                set output mode to 'table'
            -ui                   launch a web interface using the ui extension
            -unredacted           allow printing unredacted secrets
            -unsigned             allow loading of unsigned extensions
            -version              show DuckDB version
        `,
        values: #{
            "-cmd": "none", "-c": "none", "-f": "files", "-init": "files", "-newline": "none", "-nullvalue": "none",
            "-s": "none", "-separator": "none", "-storage-version": "none",
        },
        // FILENAME [SQL]: a database
        args: [k("duckdb_database")],
    }
}

fn datamash() {
    #{
        opts: `
            -C, --skip-comments          skip comment lines (starting with '#' or ';' and optional whitespace)
            -f, --full                   print the entire input line before the operation results
            -g, --group X[,Y,Z]          group by fields X,[Y,Z]; the same as the primary operation 'groupby'
            --header-in                  the first input line is column headers
            --header-out                 print column headers as the first line
            -H, --headers                the same as '--header-in --header-out'
            --vnlog                      read and write data in the vnlog format
            -i, --ignore-case            ignore upper/lower case when comparing text
            -s, --sort                   sort the input before grouping
            -S, --seed N                 set a seed for operations that use randomization
            -c, --collapse-delimiter X   use X to separate elements in collapse and unique lists
            --no-strict                  allow lines with varying number of fields
            --filler X                   fill missing values with X
            -t, --field-separator X      use X instead of TAB as field delimiter
            --format FORMAT              print numeric values with printf style floating-point FORMAT
            --output-delimiter X         use X instead as output field delimiter
            --narm                       skip NA/NaN values
            -R, --round N                round numeric output to N decimal places
            -W, --whitespace             use whitespace (one or more spaces and/or tabs) for field delimiters
            -z, --zero-terminated        end lines with a 0 byte, not newline
            --sort-cmd PATH              alternative sort(1) to use
            -h, --help                   display the help and exit
            -V, --version                output version information and exit
        `,
        values: #{
            "-g": "none", "--group": "none", "-S": "none", "--seed": "none", "-c": "none", "--collapse-delimiter": "none",
            "--filler": "none", "-t": "none", "--field-separator": "none", "--format": "none",
            "--output-delimiter": "none", "-R": "none", "--round": "none", "--sort-cmd": "files",
        },
        // OPERATION [FIELD] ...
        args: [k("datamash_operations")],
    }
}

fn pigz() {
    #{
        opts: `
            -0                   compression level 0 (-1 to -9, -11 are the others)
            --fast               compression level 1
            --best               compression level 9
            -A, --alias NAME     use NAME as the name for any --zip entry from stdin
            -b, --blocksize KB   set compression block size to KB kilobytes
            -c, --stdout         write all processed output to stdout (won't delete)
            -C, --comment TEXT   put TEXT in the gzip or zip header
            -d, --decompress     decompress the compressed input
            -f, --force          force overwrite, compress .gz, links, and to terminal
            -F, --first          do iterations first, before block split for -11
            -h, --help           display a help screen and quit
            -H, --huffman        use only Huffman coding for compression
            -i, --independent    compress blocks independently for damage recovery
            -I, --iterations N   number of iterations for -11 optimization
            -J, --maxsplits N    maximum number of split blocks for -11
            -k, --keep           do not delete original file after processing
            -K, --zip            compress to PKWare zip (.zip) single entry format
            -l, --list           list the contents of the compressed input
            -L, --license        display the pigz license and quit
            -m, --no-time        do not store or restore mod time
            -M, --time           store or restore mod time
            -n, --no-name        do not store or restore file name or mod time
            -N, --name           store or restore file name and mod time
            -O, --oneblock       do not split into smaller blocks for -11
            -p, --processes N    allow up to N compression threads
            -q, --quiet          print no messages, even on error
            -r, --recursive      process the contents of all subdirectories
            -R, --rsyncable      input-determined block locations for rsync
            -S, --suffix SUFFIX  use SUFFIX instead of .gz (for compression)
            -t, --test           test the integrity of the compressed input
            -U, --rle            use run-length encoding for compression
            -v, --verbose        provide more verbose output
            -V, --version        show the version of pigz
            -Y, --synchronous    force output file write to permanent storage
            -z, --zlib           compress to zlib (.zz) instead of gzip format
        `,
        values: #{
            "-A": "none", "--alias": "none", "-b": "none", "--blocksize": "none", "-C": "none", "--comment": "none",
            "-I": "none", "--iterations": "none", "-J": "none", "--maxsplits": "none", "-p": "none",
            "--processes": "none", "-S": [".gz", ".zz", ".zip"], "--suffix": [".gz", ".zz", ".zip"],
        },
    }
}

fn gnuplot() {
    #{
        opts: `
            -V, --version           show the version
            -h, --help              show help
            -p, --persist           keep the plot windows open after the script ends
            -s, --slow              wait for the terminal to close before exiting
            -d, --default-settings  ignore the initialization file
            -c FILE                 run the script FILE, with its arguments ARG1 ARG2 ...
            -e COMMANDS             run the commands
        `,
        values: #{"-c": k("gnuplot_script"), "-e": "none"},
        args: [k("gnuplot_script")],
    }
}

// The options of `R --help`, that Rscript also passes on.
fn r_opts() {
    `
        --save                  do save workspace at the end of the session
        --no-save               do not save it
        --no-environ            do not read the site and user environment files
        --no-site-file          do not read the site-wide Rprofile
        --no-init-file          do not read the user R profile
        --restore               do restore previously saved objects at startup
        --no-restore-data       do not restore previously saved objects
        --no-restore-history    do not restore the R history file
        --no-restore            do not restore anything
        --vanilla               combine --no-save, --no-restore, --no-site-file, --no-init-file and --no-environ
        --max-connections N     set max number of connections to N
        --max-ppsize N          set max size of protect stack to N
        --min-nsize N           set min number of fixed size objects to N
        --min-vsize N           set vector heap minimum to N bytes
        -q, --quiet             do not print startup message
        --silent                the same as --quiet
        --interactive           force an interactive session
        --verbose               print more information about progress
        -d, --debugger NAME     run R through debugger NAME
        --debugger-args ARGS    pass ARGS as arguments to the debugger
        -g, --gui TYPE          use TYPE as GUI
        --arch NAME             specify a sub-architecture
        --args                  skip the rest of the command line
    `
}

fn r_values() {
    #{
        "--max-connections": "none", "--max-ppsize": "none", "--min-nsize": "none", "--min-vsize": "none",
        "-d": "commands", "--debugger": "commands", "--debugger-args": "none", "-g": ["X11", "Tk"], "--gui": ["X11", "Tk"],
        "--arch": "none", "--encoding": "none", "--default-packages": "none", "-e": "none", "-f": k("r_script"),
        "--file": k("r_script"),
    }
}

fn rscript() {
    #{
        opts: `
            --help                    print usage and exit
            --version                 print version and exit
            --verbose                 print information on progress
            --default-packages LIST   attach these packages on startup: a comma-separated LIST, or NULL
            -e EXPR                   run the expression EXPR instead of a file
        ` + r_opts(),
        values: r_values(),
        // FILE [ARGUMENTS...]
        args: [k("r_script"), "files"],
    }
}

fn r() {
    #{
        opts: `
            -h, --help                print short help message and exit
            --version                 print version info and exit
            --encoding ENC            specify encoding to be used for stdin
            -s, --no-echo             make R run as quietly as possible
            -f, --file FILE           take input from FILE
            -e EXPR                   execute EXPR and exit
        ` + r_opts(),
        values: r_values(),
        args: [["CMD"], "files"],
    }
}

fn spec(cmd) {
    switch cmd {
        "duckdb" => duckdb(),
        "datamash" => datamash(),
        "pigz" => pigz(),
        "gnuplot" => gnuplot(),
        "Rscript" => rscript(),
        "R" => r(),
        _ => #{},
    }
}
