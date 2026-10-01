// Editors: kate (23.08.5).
import "qt" as qt;

fn k(name) { "@extra-complete/gui/kinds:" + name }

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
            "--encoding": ["UTF-8", "UTF-16", "UTF-16LE", "UTF-16BE", "UTF-32", "ISO-8859-1", "ISO-8859-15",
                           "windows-1252", "windows-1251", "KOI8-R", "Shift_JIS", "EUC-JP", "EUC-KR", "GB18030",
                           "Big5"],
            "--line": "none",
            "--column": "none",
        },
    })
}

fn spec(cmd) {
    switch cmd {
        "kate" => kate(),
        _ => #{},
    }
}
