// String helpers that Rhai's library lacks, for the extra-completion plugins:
// `import "../extra-lib/text" as lib_text;`.

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

// Whether `t` is a JSON number.
fn is_json_number(t) {
    // 1: after the sign, 2: in the integer part, 3: after the point, 4: in the fraction, 5: after the `e`, 6: after
    // its sign, 7: in the exponent
    let s = 0;
    for c in t.chars() {
        let d = c >= '0' && c <= '9';
        s = if d {
            switch s { 0 | 1 | 2 => 2, 3 | 4 => 4, _ => 7 }
        } else if c == '-' && (s == 0 || s == 5) {
            s + 1
        } else if c == '+' && s == 5 {
            6
        } else if c == '.' && s == 2 {
            3
        } else if (c == 'e' || c == 'E') && (s == 2 || s == 4) {
            5
        } else {
            return false;
        };
    }
    s == 2 || s == 4 || s == 7
}

// Whether `text` is a JSON object. parse_json throws a syntax error for anything else, which Rhai's `try` doesn't
// catch, and a file being edited often isn't one.
fn is_json_object(text) {
    let stack = [];     // the open containers, '{' or '['
    // 0: a value, 1: a key or '}', 2: ':', 3: ',' or the end of the container, 4: the end of the text, 5: a key,
    // 6: a value or ']'
    let state = 0;
    let in_str = false;
    let esc = false;
    let tok = "";       // a number, true, false or null
    for c in text.chars() {
        if in_str {
            if esc {
                esc = false;
            } else if c == '\\' {
                esc = true;
            } else if c == '"' {
                in_str = false;
            } else if c < ' ' {
                return false;
            }
            continue;
        }
        if tok != "" {
            if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '+' || c == '-'
                || c == '.' {
                tok += c;
                continue;
            }
            if !["true", "false", "null"].contains(tok) && !is_json_number(tok) {
                return false;
            }
            tok = "";
        }
        if c == ' ' || c == '\n' || c == '\t' || c == '\r' {
            continue;
        }
        if state == 6 && c == ']' || state == 1 && c == '}' {
            stack.pop();
            state = if stack.is_empty() { 4 } else { 3 };
        } else if state == 0 || state == 6 {
            if stack.is_empty() && c != '{' {
                return false;
            }
            if c == '{' || c == '[' {
                stack.push(c);
                state = if c == '{' { 1 } else { 6 };
            } else if c == '"' {
                in_str = true;
                state = 3;
            } else if (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' {
                tok = c.to_string();
                state = 3;
            } else {
                return false;
            }
        } else if state == 1 || state == 5 {
            if c != '"' {
                return false;
            }
            in_str = true;
            state = 2;
        } else if state == 2 {
            if c != ':' {
                return false;
            }
            state = 0;
        } else if state == 3 {
            let top = stack[-1];
            if c == ',' {
                state = if top == '{' { 5 } else { 0 };
            } else if c == '}' && top == '{' || c == ']' && top == '[' {
                stack.pop();
                state = if stack.is_empty() { 4 } else { 3 };
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
    state == 4 && !in_str
}

// The completion of the item after the last comma of `cur`, a comma-separated list, among `candidates` (strings or
// candidate maps), but those already in the list: a completer's result, `#{prefix, candidates}`.
fn comma_list(cur, candidates) {
    let k = last_of(cur, [',']);
    let given = cur.sub_string(0, k + 1).split(",");
    #{
        prefix: cur.sub_string(0, k + 1),
        candidates: candidates.filter(|c| !given.contains(if type_of(c) == "map" { c.value } else { c })),
    }
}
