// Editors: code (Visual Studio Code 1.140.0), meld (3.24.0), gedit (50.0) and kate (23.08.5).
import "qt" as qt;
import "@extra-complete/extra-lib/help" as help;

fn k(name) { "@extra-complete/gui/kinds:" + name }

// The encodings that are asked for most (kate's `-e`, gedit's `--encoding`).
fn encodings() {
    ["UTF-8", "UTF-16", "UTF-16LE", "UTF-16BE", "UTF-32", "ISO-8859-1", "ISO-8859-15", "windows-1252", "windows-1251",
     "KOI8-R", "Shift_JIS", "EUC-JP", "EUC-KR", "GB18030", "Big5"]
}

// The subcommands of code: `chat` is the editor's, and the others are those of its command-line program
// (`code-tunnel`, built with clap), whose help is read when Tab is pressed.
fn code_commands() {
    `
        chat                        open a chat session in the current directory
        serve-web                   run a server of the editor's UI for browsers
        agent                       start and interact with AI agent hosts
        tunnel                      make this machine reachable from vscode.dev through a tunnel
    `
}

// code [OPTIONS] [PATHS]: its options take their value as the next word; a path `-` is standard input.
fn code() {
    #{
        opts: `
            -d, --diff FILE FILE        compare two files
            -m, --merge PATH1 PATH2 BASE RESULT  three-way merge of two versions with their base, into RESULT
            -a, --add FOLDER            add folders to the last active window
            --remove FOLDER             remove folders from the last active window
            -g, --goto FILE:LINE[:CHARACTER]  open a file at a line and character
            -n, --new-window            open a new window
            -r, --reuse-window          open in the last active window
            --agents                    open the agents window
            -w, --wait                  wait for the files to be closed
            --locale LOCALE             the locale (en-US, zh-TW)
            --user-data-dir DIR         the directory of the user data
            --profile PROFILE           open with a profile (created if it doesn't exist)
            -h, --help                  show the help
            --extensions-dir DIR        the root of the extensions
            --list-extensions           list the installed extensions
            --show-versions             show their versions (--list-extensions)
            --category CATEGORY         list the extensions of a category (--list-extensions)
            --install-extension EXT-ID|PATH  install or update an extension (ID[@VERSION], or a .vsix)
            --pre-release               install the pre-release version (--install-extension)
            --uninstall-extension EXT-ID  uninstall an extension
            --update-extensions         update the installed extensions
            --enable-proposed-api EXT-ID  enable proposed API features for extensions
            --add-mcp JSON              add an MCP server to the user profile ({"name": ..., "command": ...})
            -v, --version               show the version
            --verbose                   print verbose output (implies --wait)
            --log LEVEL                 the log level (or EXT-ID:LEVEL)
            -s, --status                print process usage and diagnostics
            --prof-startup              run the CPU profiler during startup
            --disable-extensions        disable all extensions (in a new window)
            --disable-extension EXT-ID  disable an extension (in a new window)
            --sync on|off               turn sync on or off
            --inspect-extensions PORT   allow debugging and profiling of extensions
            --inspect-brk-extensions PORT  the same, with the extension host paused after start
            --disable-lcd-text          disable LCD font rendering
            --disable-gpu               disable GPU acceleration
            --disable-chromium-sandbox  disable Chromium's sandbox (as root on Linux)
            --locate-shell-integration-path SHELL  print the path of a shell integration script
            --telemetry                 show the telemetry events
            --transient                 run with temporary data and extension directories
        `,
        values: #{
            "--add": "dirs",
            "--remove": "dirs",
            "--locale": "none",
            "--user-data-dir": "dirs",
            "--profile": k("code_profiles"),
            "--extensions-dir": "dirs",
            "--category": ["AI", "Chat", "Data Science", "Debuggers", "Education", "Extension Packs", "Formatters",
                           "Keymaps", "Language Packs", "Linters", "Machine Learning", "Notebooks", "Other",
                           "Programming Languages", "SCM Providers", "Snippets", "Testing", "Themes",
                           "Visualization"],
            "--install-extension": k("code_install"),
            "--uninstall-extension": k("code_extensions"),
            "--enable-proposed-api": k("code_extensions"),
            "--disable-extension": k("code_extensions"),
            "--add-mcp": "none",
            "--log": ["critical", "error", "warn", "info", "debug", "trace", "off"],
            "--sync": ["on", "off"],
            "--inspect-extensions": "none",
            "--inspect-brk-extensions": "none",
            "--locate-shell-integration-path": ["bash", "pwsh", "zsh", "fish"],
        },
        args: [k("code_paths"), "files"],
    }
}

// code chat [OPTIONS] [PROMPT]: a word `-` reads the prompt's context from standard input.
fn code_chat() {
    #{
        opts: `
            -m, --mode MODE             the mode of the chat (or a custom mode's id; agent)
            -a, --add-file PATH         add files as context
            --maximize                  maximize the chat view
            -r, --reuse-window          use the last active window
            -n, --new-window            open an empty window
            --profile PROFILE           open with a profile (created if it doesn't exist)
            -h, --help                  show the help
        `,
        values: #{"--mode": ["ask", "edit", "agent"], "--profile": k("code_profiles")},
        args: ["none"],
    }
}

fn code_how() {
    #{sub_spec: "@extra-complete/gui/editors", help_command: true}
}

// code's completer: its subcommands only as the first word, and then their specs.
fn complete_code(words, i) {
    import "@std/completion/lib" as lib;
    let s = code();
    if i > 1 && lib::parse_commands(code_commands()).some(|c| c.names[0] == words[1]) {
        s.commands = code_commands();
        s.sub_spec = "@extra-complete/gui/editors:code";
    }
    lib::complete(s, words, i)
}

// meld [OPTIONS] [FILE1 FILE2 [FILE3]] | [DIR1 DIR2 [DIR3]]: files or directories, or one directory under version
// control. `--diff` takes the files or directories after it, up to the next option.
fn meld() {
    #{
        opts: `
            -h, --help                  show the help
            --help-all                  show all the help
            --help-gapplication         show GApplication's options
            --help-gtk                  show GTK's options
            --version                   show the version
            -L, --label LABEL           a label to use instead of a file's name (once for each)
            -n, --newtab                open a new tab in the running meld
            -a, --auto-compare          compare all differing files on startup
            -u, --unified               ignored, for compatibility
            -o, --output FILE           the file to save a merge to
            --auto-merge                merge the files automatically
            --comparison-file FILE      load a saved comparison (.meldcmp)
            --diff                      a diff tab for the files or directories after it
        `,
        values: #{"--label": "none", "--comparison-file": k("meldcmp")},
    }
}

// gedit [OPTIONS] [FILES] [+LINE[:COLUMN]]
fn gedit() {
    #{
        opts: `
            -h, --help                  show the help
            --help-all                  show all the help
            --help-gapplication         show GApplication's options
            -V, --version               show the version
            --list-encodings            list the values of --encoding
            --encoding=ENCODING         the encoding of the files on the command line
            --new-window                open a new window in the running gedit
            --new-document              create a new document in the running gedit
            -w, --wait                  wait for the files to be closed
            -s, --standalone            run a gedit of its own
        `,
        values: #{"--encoding": encodings()},
    }
}

// kate [OPTIONS] [FILES]
fn kate() {
    qt::with_kde(#{
        opts: `
            -s, --start SESSION       start with a session
            --startanon               start with a new anonymous session (implies -n)
            -n, --new                 start a new kate, even if one is running
            -b, --block               wait for the running kate to close the files
            -p, --pid PID             reuse only the kate with this pid
            -e, --encoding ENCODING   the encoding of the files to open
            -l, --line LINE           go to this line
            -c, --column COLUMN       go to this column
            -i, --stdin               read the contents of standard input
            --tempfile                delete the files after use
        `,
        values: #{
            "--start": k("kate_sessions"),
            "--pid": k("kate_pids"),
            "--encoding": encodings(),
            "--line": "none",
            "--column": "none",
        },
    })
}

fn spec(cmd) {
    switch cmd {
        "code" => code(),
        "meld" => meld(),
        "gedit" => gedit(),
        "kate" => kate(),
        _ => #{},
    }
}

// The subcommands of code, from the help of its command-line program (`code tunnel user`), but `chat`.
fn sub_spec(name, sub) {
    if name == "code" && sub == "chat" {
        return code_chat();
    }
    let s = help::sub(name, sub, code_how());
    if s != () {
        s.args = s.args ?? ["none"];
    }
    s
}
