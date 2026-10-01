// The TeX engines and their helpers, from TeX Live 2026 (pdfTeX 3.141592653-2.6-1.40.29, XeTeX, LuaHBTeX,
// bibtex, latexmk 4.87). Their options start with one `-` (the engines also take `--`, and latexmk always
// does), so the specs are `single_dash`. A `[-no]-shell-escape` is written as its two options.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

// The options that pdfTeX and XeTeX have in common.
fn common() {
    `
        -cnf-line=STRING         parse STRING as a configuration file line
        -etex                    enable e-TeX extensions
        -file-line-error         enable file:line:error style messages
        -no-file-line-error      disable file:line:error style messages
        -fmt=FMTNAME             use FMTNAME instead of program name or a %& line
        -halt-on-error           stop processing at the first error
        -ini                     be an initex, for dumping formats
        -interaction=STRING      set interaction mode
        -jobname=STRING          set the job name to STRING
        -kpathsea-debug=NUMBER   set path searching debugging flags according to the bits of NUMBER
        -mktex=FMT               enable mktexFMT generation
        -no-mktex=FMT            disable mktexFMT generation
        -mltex                   enable MLTeX extensions
        -output-comment=STRING   use STRING for the file comment instead of the date
        -output-directory=DIR    use existing DIR as the directory to write files in
        -parse-first-line        enable parsing of the first line of the input file
        -no-parse-first-line     disable parsing of the first line of the input file
        -progname=STRING         set program (and fmt) name to STRING
        -recorder                enable filename recorder
        -shell-escape            enable the write18 shell escape
        -no-shell-escape         disable the write18 shell escape
        -shell-restricted        enable restricted write18
        -src-specials[=WHERE]    insert source specials into the output file, in certain places
        -synctex=NUMBER          generate SyncTeX data for previewers according to bits of NUMBER
        -translate-file=TCXNAME  use the TCX file TCXNAME
        -8bit                    make all characters printable
        -help                    display the help and exit
        -version                 output version information and exit
    `
}

fn values() {
    #{
        "-cnf-line": "none", "-fmt": "none", "-interaction": ["batchmode", "nonstopmode", "scrollmode", "errorstopmode"],
        "-jobname": "none", "-kpathsea-debug": "none", "-mktex": ["tex", "tfm", "pk"], "-no-mktex": ["tex", "tfm", "pk"],
        "-output-comment": "none", "-output-directory": "dirs", "-progname": "none",
        "-src-specials": ["cr", "display", "hbox", "math", "par", "parend", "vbox"], "-synctex": "none",
        "-translate-file": "files", "-output-format": ["dvi", "pdf"], "-output-driver": "none", "-papersize": "none",
        "-min-crossrefs": "none",
    }
}

fn tex_spec(extra) {
    #{
        single_dash: true,
        opts: common() + extra,
        values: values(),
        args: [k("tex")],
    }
}

fn pdflatex() {
    tex_spec(`
        -draftmode               switch on draft mode (generates no output PDF)
        -enc                     enable encTeX extensions
        -output-format=FORMAT    use FORMAT for job output (dvi or pdf)
    `)
}

fn xelatex() {
    tex_spec(`
        -output-driver=CMD       use CMD as the XDV-to-PDF driver instead of xdvipdfmx
        -no-pdf                  generate XDV (extended DVI) output rather than PDF
        -papersize=STRING        set PDF media size to STRING
    `)
}

fn lualatex() {
    let v = values();
    v["-lua"] = "files";
    #{
        single_dash: true,
        opts: `
            -cnf-line=STRING         parse STRING as a configuration file line
            -credits                 display credits and exit
            -debug-format            enable format debugging
            -draftmode               switch on draft mode (generates no output PDF)
            -file-line-error         enable file:line:error style messages
            -no-file-line-error      disable file:line:error style messages
            -fmt=FORMAT              load the format file FORMAT
            -halt-on-error           stop processing at the first error
            -help                    display help and exit
            -ini                     be iniluahbtex, for dumping formats
            -interaction=STRING      set interaction mode
            -jobname=STRING          set the job name to STRING
            -kpathsea-debug=NUMBER   set path searching debugging flags according to the bits of NUMBER
            -lua=FILE                load and execute a lua initialization script
            -mktex=FMT               enable mktexFMT generation
            -no-mktex=FMT            disable mktexFMT generation
            -nosocket                disable the lua socket library
            -no-socket               disable the lua socket library
            -socket                  enable the lua socket library
            -output-comment=STRING   use STRING for DVI file comment instead of date
            -output-directory=DIR    use existing DIR as the directory to write files in
            -output-format=FORMAT    use FORMAT for job output (dvi or pdf)
            -progname=STRING         set the program name to STRING
            -recorder                enable filename recorder
            -safer                   disable easily exploitable lua commands
            -shell-escape            enable system commands
            -no-shell-escape         disable system commands
            -shell-restricted        restrict system commands to a list of commands given in texmf.cnf
            -synctex=NUMBER          enable synctex
            -utc                     init time to UTC
            -version                 display version and exit
            -luaonly                 run a lua file, then exit
            -luaconly                byte-compile a lua file, then exit
            -luahashchars            the bits used by the current Lua interpreter for strings hashing
        `,
        values: v,
        args: [k("tex")],
    }
}

fn bibtex() {
    #{
        single_dash: true,
        opts: `
            -min-crossrefs=NUMBER    include item after NUMBER cross-refs
            -terse                   do not print progress reports
            -help                    display this help and exit
            -version                 output version information and exit
        `,
        values: values(),
        args: [k("aux")],
    }
}

fn latexmk() {
    #{
        single_dash: true,
        opts: `
            -aux-directory=DIR       set name of directory for auxiliary files
            -auxdir=DIR              set name of directory for auxiliary files
            -bibtex                  use bibtex when needed (default)
            -bibtex-                 never use bibtex
            -bibtex-cond             use bibtex when needed, but only if the bib file exists
            -bibtex-cond1            like -bibtex-cond, and on cleanup delete the bbl file only if the bib file exists
            -bibfudge                change directory to output directory when running bibtex
            -bibfudge-               do not change directory when running bibtex
            -commands                list commands used by latexmk for processing files
            -c                       clean up all nonessential files, except dvi, ps and pdf files
            -C                       clean up all nonessential files, including dvi, ps and pdf files
            -CA                      clean up all nonessential files (same as -C)
            -CF                      remove the file database before doing other actions
            -cd                      change to the directory of the source file when processing it
            -cd-                     do not change to the directory of the source file
            -dependents              show the list of dependent files after processing
            -deps                    show the list of dependent files after processing
            -dependents-             do not show the list of dependent files
            -deps-out=FILE           name of the output file for the dependency list
            -deps-escape=KIND        kind of escaping of spaces in names in the deps file
            -dF FILTER               filter to apply to the dvi file
            -dir-report              report aux and out dir settings before processing a tex file
            -dir-report-only         report aux and out dir settings without compiling
            -dvi                     generate dvi by latex
            -dvilua                  generate dvi by dvilualatex
            -dvi-                    turn off required dvi
            -e CODE                  execute the specified Perl code as part of the start-up code
            -emulate-aux-dir         emulate the -aux-directory option for *latex
            -f                       force continued processing past errors
            -f-                      turn off forced continuing processing past errors
            -g                       process at least one run of all rules
            -g-                      turn off -g and -gg
            -gg                      clean out generated files, then process regardless of timestamps
            -gt                      require at least one run of *latex independently of file state
            -h                       print help
            -help                    print help
            -hnt                     generate hnt by hilatex
            -indexfudge              change directory to output directory when running makeindex
            -jobname=STRING          set basename of output files to STRING
            -l                       force landscape mode
            -l-                      turn off -l
            -latex=PROGRAM           set program used for latex
            -latexoption=OPTION      add the given option to the *latex command
            -logfilewarnings         give a list of warnings after a run of *latex
            -logfilewarnings-        do not give a list of warnings after a run of *latex
            -lualatex                use lualatex for processing files to pdf
            -M                       show the list of dependent files after processing
            -MF FILE                 name of the file to receive the list of dependent files
            -MP                      the list of dependent files includes a phony target for each source
            -new-viewer              in -pvc mode, always start a new viewer
            -new-viewer-             in -pvc mode, start a new viewer only if needed
            -nobibtex                never use bibtex
            -nodependents            do not show the list of dependent files
            -norc                    omit automatic reading of system, user and project rc files
            -output-directory=DIR    set name of directory for output files
            -outdir=DIR              set name of directory for output files
            -out2dir=DIR             set name of directory for final output files
            -output-format=FORMAT    dvi or pdf: turn on that output, turn off others
            -pdf                     generate pdf by pdflatex
            -pdfdvi                  generate pdf by latex + dvipdf
            -pdfps                   generate pdf by latex + dvips + ps2pdf
            -pdflatex=PROGRAM        set program used for pdflatex
            -pdflualatex=PROGRAM     set program used for lualatex
            -pdflua                  generate pdf by lualatex
            -pdfxe                   generate pdf by xelatex
            -pdfxelatex=PROGRAM      set program used for xelatex
            -pdf-                    turn off pdf
            -pF FILTER               filter to apply to the postscript file
            -p                       print document after generating postscript
            -pretex=CODE             TeX code to be executed before inputting the source file
            -print=TYPE              which file to print when a file is to be printed
            -ps                      generate postscript
            -ps-                     turn off postscript
            -pv                      preview document
            -pv-                     turn off preview mode
            -pvc                     preview document and continuously update
            -pvc-                    turn off -pvc
            -pvctimeout              timeout in pvc mode after a period of inactivity
            -pvctimeoutmins=TIME     period of inactivity (minutes) for the pvc timeout
            -quiet                   silence progress messages from called programs
            -r FILE                  read a custom RC file
            -rc-report               after initialization, report the names of rc files read
            -recorder                use the -recorder option for *latex
            -rules                   show the list of rules after processing
            -showextraoptions        show other allowed options that are passed as is to latex and pdflatex
            -silent                  silence progress messages from called programs
            -stdtexcmds              set standard commands for *latex
            -time                    show CPU time used
            -use-make                use the make program to try to make missing files
            -usepretex               set commands for *latex to use extra code before inputting the source file
            -v                       display program version
            -verbose                 display usual progress messages from called programs
            -version                 display program version
            -view=VIEWER             which viewer to use
            -Werror                  treat warnings from called programs as errors
            -xdv                     generate xdv by xelatex
            -xdv-                    turn off required xdv
            -xelatex                 use xelatex for processing files to pdf
            -bibtexfudge             same as -bibfudge
            -bibtexfudge-            same as -bibfudge-
            -deps-                   do not show the list of dependent files
            -dir-report-             do not report aux and out dir settings before processing a tex file
            -dvilualatex=PROGRAM     set program used for dvilualatex
            -emulate-aux-dir-        use the -aux-directory option with *latex
            -indexfudge-             do not change directory when running makeindex
            -logfilewarninglist      same as -logfilewarnings
            -logfilewarninglist-     same as -logfilewarnings-
            -makeindexfudge          same as -indexfudge
            -makeindexfudge-         same as -indexfudge-
            -nobibfudge              do not change directory when running bibtex
            -nobibtexfudge           do not change directory when running bibtex
            -noemulate-aux-dir       use the -aux-directory option with *latex
            -noindexfudge            do not change directory when running makeindex
            -nomakeindexfudge        do not change directory when running makeindex
            -pvctimeout-             do not timeout in pvc mode after inactivity
            -rc-report-              after initialization, do not report the names of rc files read
            -recorder-               do not use the -recorder option for *latex
            -rules-                  do not show the list of rules after processing
            -time-                   do not show CPU time used
            -use-make-               do not use the make program to try to make missing files
            -MSWinBackSlash          under MSWin use backslash for directory separators in file names given to programs
            -MSWinBackSlash-         under MSWin use forward slash for directory separators
        `,
        values: #{
            "-aux-directory": "dirs", "-auxdir": "dirs", "-output-directory": "dirs", "-outdir": "dirs", "-out2dir": "dirs",
            "-deps-out": "files", "-deps-escape": ["nmake", "none", "unix"], "-jobname": "none",
            "-output-format": ["dvi", "pdf"], "-print": ["dvi", "ps", "pdf"],
            "-view": ["default", "dvi", "hnt", "none", "ps", "pdf"], "-MF": "files", "-r": "files",
            "-dF": "none", "-pF": "none", "-e": "none", "-latex": "none", "-latexoption": "none", "-pretex": "none",
            "-pdflatex": "none", "-dvilualatex": "none", "-pdflualatex": "none", "-pdfxelatex": "none", "-pvctimeoutmins": "none",
        },
        args: [k("tex")],
    }
}

fn spec(cmd) {
    switch cmd {
        "pdflatex" | "pdftex" => pdflatex(),
        "xelatex" | "xetex" => xelatex(),
        "lualatex" | "luatex" | "luahbtex" => lualatex(),
        "bibtex" => bibtex(),
        "latexmk" => latexmk(),
        _ => #{},
    }
}
