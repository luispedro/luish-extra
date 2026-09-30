// Command-line utilities: fzf (fzf 0.74) and bat (bat 0.26.1; `batcat` on Debian).

fn k(name) { "@extra-complete/dev/kinds:" + name }

// fzf [OPTIONS] (its `--help`; `+x`, `+i`, `+s` and `+m` are given by their long names only, and `--reverse`,
// `--no-multi` and `--no-mouse`, which the help leaves out, are from its man page).
fn fzf() {
    let borders = [
        "rounded", "sharp", "bold", "block", "thinblock", "double", "dashed", "horizontal", "vertical", "top", "bottom",
        "left", "right", "line", "none",
    ];
    #{
        opts: `
            -e, --exact                  enable exact-match
            --no-extended                disable extended-search mode
            -i, --ignore-case            case-insensitive match
            --no-ignore-case             case-sensitive match
            --smart-case                 smart-case match (default)
            --scheme=SCHEME              scoring scheme
            -n, --nth=N[,..]             fields to limit the search to (field index expressions)
            --with-nth=N[,..]            fields to show of each line
            --accept-nth=N[,..]          fields to print on accept
            -d, --delimiter=STR          field delimiter regex
            --no-sort                    do not sort the result
            --literal                    do not normalize latin script letters
            --tail=NUM                   maximum number of items to keep in memory
            --disabled                   do not perform search
            --tiebreak=CRI[,..]          sort criteria to apply when the scores are tied
            --read0                      read input delimited by ASCII NUL characters
            --print0                     print output delimited by ASCII NUL characters
            --ansi                       enable processing of ANSI color codes
            --sync                       synchronous search for multi-staged filtering
            --style=PRESET               apply a style preset
            --color=COLSPEC              base scheme (dark|light|base16|bw) and/or custom colors
            --no-color                   disable colors
            --no-bold                    do not use bold text
            --height=HEIGHT              height of the window below the cursor, instead of fullscreen
            --min-height=HEIGHT          minimum height when --height is given as a percentage
            --popup[=OPTS]               start fzf in a floating pane (tmux 3.3+ or Zellij 0.44+)
            --tmux[=OPTS]                alias for --popup
            --layout=LAYOUT              choose layout
            --reverse                    alias for --layout=reverse
            --margin=MARGIN              screen margin (TRBL | TB,RL | T,RL,B | T,R,B,L)
            --padding=PADDING            padding inside border (TRBL | TB,RL | T,RL,B | T,R,B,L)
            --border[=STYLE]             draw border around the finder
            --border-label=LABEL         label to print on the border
            --border-label-pos=COL       position of the border label
            -m, --multi[=MAX]            enable multi-select with tab/shift-tab
            --no-multi                   disable multi-select
            --highlight-line             highlight the whole current line
            --cycle                      enable cyclic scroll
            --wrap[=MODE]                enable line wrap
            --wrap-sign=STR              indicator for wrapped lines
            --no-multi-line              disable multi-line display of items when using --read0
            --raw                        enable raw mode (show non-matching items)
            --track                      track the current selection when the result is updated
            --id-nth=N[,..]              item identity fields for cross-reload operations
            --tac                        reverse the order of the input
            --gap[=N]                    render empty lines between each item
            --gap-line[=STR]             draw horizontal line on each gap using the string
            --freeze-left=N              number of fields to freeze on the left
            --freeze-right=N             number of fields to freeze on the right
            --keep-right                 keep the right end of the line visible on overflow
            --scroll-off=LINES           number of screen lines to keep above or below when scrolling
            --no-hscroll                 disable horizontal scroll
            --hscroll-off=COLS           number of screen columns to keep to the right of the highlighted substring
            --jump-labels=CHARS          label characters for jump mode
            --gutter=CHAR                character used for the gutter column
            --gutter-raw=CHAR            character used for the gutter column in raw mode
            --pointer=STR                pointer to the current line
            --marker=STR                 multi-select marker
            --marker-multi-line=STR      multi-select marker for multi-line entries
            --ellipsis=STR               ellipsis to show when line is truncated
            --tabstop=SPACES             number of spaces for a tab character
            --scrollbar[=C1[C2]]         scrollbar character(s)
            --no-scrollbar               hide scrollbar
            --no-mouse                   disable mouse
            --list-border[=STYLE]        draw border around the list section
            --list-label=LABEL           label to print on the list border
            --list-label-pos=COL         position of the list label
            --no-input                   disable and hide the input section
            --prompt=STR                 input prompt
            --info=STYLE                 finder info style
            --info-command=COMMAND       command to generate info line
            --separator=STR              draw horizontal separator on info line using the string
            --no-separator               hide info line separator
            --ghost=TEXT                 ghost text to display when the input is empty
            --filepath-word              make word-wise movements respect path separators
            --input-border[=STYLE]       draw border around the input section
            --input-label=LABEL          label to print on the input border
            --input-label-pos=COL        position of the input label
            --preview=COMMAND            command to preview highlighted line ({})
            --preview-window=OPT         preview window layout
            --preview-border[=STYLE]     short for --preview-window=border-STYLE
            --preview-label=LABEL        label to print on the preview border
            --preview-label-pos=N        position of the preview label
            --preview-wrap-sign=STR      indicator for wrapped lines in the preview window
            --header=STR                 string to print as header
            --header-lines=N             the first N lines of the input are treated as header
            --header-first               print header before the prompt line
            --header-border[=STYLE]      draw border around the header section
            --header-lines-border[=STYLE]  display header from --header-lines with a separate border
            --header-label=LABEL         label to print on the header border
            --header-label-pos=COL       position of the header label
            --footer=STR                 string to print as footer
            --footer-border[=STYLE]      draw border around the footer section
            --footer-label=LABEL         label to print on the footer border
            --footer-label-pos=COL       position of the footer label
            -q, --query=STR              start the finder with the given query
            -1, --select-1               automatically select the only match
            -0, --exit-0                 exit immediately when there's no match
            -f, --filter=STR             print matches for the initial query and exit
            --print-query                print query as the first line
            --expect=KEYS                comma-separated list of keys to complete fzf
            --bind=BINDINGS              custom key/event bindings
            --with-shell=STR             shell command and flags to start child processes with
            --listen[=[ADDR:]PORT]       start HTTP server to receive actions (a port, or a socket)
            --listen-unsafe[=[ADDR:]PORT]  like --listen, and allow remote process execution
            --walker=OPTS                what to walk when FZF_DEFAULT_COMMAND is not set
            --walker-root=DIR            directories to walk
            --walker-skip=DIRS           comma-separated list of directory names to skip
            --history=FILE               file to store fzf search history
            --history-size=N             maximum number of entries to keep in the file
            --bash                       print script to set up Bash shell integration
            --zsh                        print script to set up Zsh shell integration
            --fish                       print script to set up Fish shell integration
            --nushell                    print script to set up Nushell integration
            --version                    display version information and exit
            --help                       show this message
            --man                        show man page
        `,
        values: #{
            "--scheme": ["default", "path", "history"],
            "--tiebreak": ["length", "chunk", "pathname", "begin", "end", "index"],
            "--style": ["default", "minimal", "full"],
            "--color": ["dark", "light", "base16", "bw", "16"],
            "--layout": ["default", "reverse", "reverse-list"],
            "--border": borders, "--list-border": borders, "--input-border": borders, "--preview-border": borders,
            "--header-border": borders + ["inline"], "--header-lines-border": borders + ["inline"],
            "--footer-border": borders + ["inline"],
            "--wrap": ["char", "word"],
            "--info": ["default", "right", "hidden", "inline", "inline-right"],
            "--popup": ["center", "top", "bottom", "left", "right"], "--tmux": ["center", "top", "bottom", "left", "right"],
            "--preview-window": ["up", "down", "left", "right", "next", "hidden", "wrap", "follow", "border-rounded"],
            "--walker": ["file", "dir", "follow", "hidden", "file,follow,hidden", "dir,follow,hidden"],
            "--walker-root": "dirs", "--history": "files", "--preview": "commands", "--info-command": "commands",
            "--with-shell": "commands",
        },
        guess_values: true,
        args: ["none"],
    }
}

// bat [OPTIONS] [FILE]... (its `--help`; `bat cache`, which would take the place of a file named `cache`, is
// left out).
fn bat() {
    let when = ["auto", "never", "always"];
    #{
        opts: `
            -A, --show-all                   show non-printable characters like space, tab or newline
            --nonprintable-notation NOTATION  notation for non-printable characters
            --binary BEHAVIOR                how to treat binary content
            -p, --plain                      only show plain style, no decorations (-pp: also no paging)
            -l, --language LANGUAGE          the language for syntax highlighting (a name or an extension)
            -H, --highlight-line N:M         highlight the specified line ranges
            --file-name NAME                 the name to display for a file (and to detect its syntax)
            -d, --diff                       only show lines that have been changed with respect to the Git index
            --diff-context N                 include N lines of context around changed lines with --diff
            --tabs T                         set the tab width to T spaces
            --wrap MODE                      the text-wrapping mode
            -S, --chop-long-lines            truncate all lines longer than screen width
            --terminal-width WIDTH           the width of the terminal (or, with + or -, an offset to it)
            -n, --number                     only show line numbers, no other decorations
            --color WHEN                     when to use colored output
            --italic-text WHEN               when to use ANSI sequences for italic text
            --decorations WHEN               when to use the decorations of --style
            -f, --force-colorization         alias for --decorations=always --color=always
            --paging WHEN                    when to use the pager
            -P                               disable paging (--paging=never)
            --pager COMMAND                  the pager to use
            -m, --map-syntax GLOB:SYNTAX     map a glob pattern to an existing syntax name
            --ignored-suffix SUFFIX          ignore an extension
            --theme THEME                    the theme for syntax highlighting
            --theme-light THEME              the theme for a light background
            --theme-dark THEME               the theme for a dark background
            --list-themes                    display a list of supported themes for syntax highlighting
            -s, --squeeze-blank              squeeze consecutive empty lines into a single empty line
            --squeeze-limit N                the maximum number of consecutive empty lines to be printed
            --strip-ansi WHEN                when to strip ANSI escape sequences from the input
            --style COMPONENTS               which elements to display (comma-separated)
            -r, --line-range N:M             only print the specified range of lines for each file
            -L, --list-languages             display a list of supported languages for syntax highlighting
            -u, --unbuffered                 ignored (for POSIX compliance)
            --completion SHELL               show shell completion for a certain shell
            --diagnostic                     show diagnostic information for bug reports
            --acknowledgements               show acknowledgements
            --set-terminal-title             set the terminal title to the filenames when using a pager
            -h, --help                       print help
            -V, --version                    print version
        `,
        values: #{
            "--nonprintable-notation": ["unicode", "caret"], "--binary": ["no-printing", "as-text"],
            "-l": k("bat_languages"), "--language": k("bat_languages"), "-H": "none", "--highlight-line": "none",
            "--file-name": "none", "--diff-context": "none", "--tabs": "none",
            "--wrap": ["auto", "never", "character"], "--terminal-width": "none",
            "--color": when, "--italic-text": ["always", "never"], "--decorations": when, "--paging": when,
            "--pager": "commands", "-m": "none", "--map-syntax": "none", "--ignored-suffix": "none",
            "--theme": k("bat_theme"), "--theme-light": k("bat_themes"), "--theme-dark": k("bat_themes"),
            "--squeeze-limit": "none", "--strip-ansi": when,
            "--style": [
                "default", "full", "auto", "plain", "changes", "header", "header-filename", "header-filesize", "grid",
                "rule", "numbers", "snip",
            ],
            "-r": "none", "--line-range": "none", "--completion": ["bash", "fish", "zsh", "ps1"],
        },
    }
}

fn spec(cmd) {
    switch cmd {
        "fzf" => fzf(),
        "bat" | "batcat" => bat(),
        _ => #{},
    }
}
