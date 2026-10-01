// String helpers that Rhai's library lacks, for the extra-complete plugins:
// `import "@extra-complete/extra-lib/text" as lib_text;`.

// Whether `s` is a name to pass to a program: letters, digits, `_`, `-` and
// `.`, not starting with `-` (the words come from the command line, and a
// program is only asked about names).
fn is_name(s) {
    s != "" && !s.starts_with("-") && !sh::matches("*[!A-Za-z0-9._-]*", s)
}

// The index of the last of the characters `chars` in `s`, or -1.
fn last_of(s, chars) {
    let k = -1;
    let j = 0;
    for c in s.chars() {
        if chars.contains(c) {
            k = j;
        }
        j += 1;
    }
    k
}

// The index of the last `sep` in `s`, or -1.
fn last_index(s, sep) {
    let k = -1;
    let j = s.index_of(sep);
    while j >= 0 {
        k = j;
        j = s.index_of(sep, j + 1);
    }
    k
}

// The number of spaces and tabs a line starts with.
fn indent(line) {
    let n = 0;
    for c in line.chars() {
        if c != ' ' && c != '\t' {
            break;
        }
        n += 1;
    }
    n
}

// The identifier `s` starts with (letters, digits and `_`).
fn ident(s) {
    let n = 0;
    for c in s.chars() {
        if !(c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '_') {
            break;
        }
        n += 1;
    }
    s.sub_string(0, n)
}
