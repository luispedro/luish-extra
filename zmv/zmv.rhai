// zsh's zmv (with zcp, zln and mmv), as a luish command.
//
//   zmv [-finnqQsvwW] [-C|-L|-M|-p PROG|-P PROG] [-o OPTS] SRCPAT DEST
//
// SRCPAT is a pattern whose parenthesised parts are groups, and DEST is evaluated for each file that it matches,
// as a string in double quotes, with `$1`, `$2`, ... the text of the groups and `$f` the file's name:
// `zmv '(*).txt' '$1.md'`. -w makes each wildcard of SRCPAT a group, and -W also turns the wildcards of DEST into
// `${1}`, `${2}`, ... in turn (`zmv -W '*.txt' '*.md'`); mmv is `zmv -W`.
//
// How it is done: SRCPAT is translated twice, into a pattern that `sh::glob` expands (without the groups; an
// alternation `(a|b)` becomes `{a,b}`) and into an anchored extended regular expression with the groups, which the
// shell's `[[ $f =~ $re ]]` matches against each file, in a shell function that then evaluates DEST with the groups
// as its positional parameters. Nothing is done unless every file has a target that no other file has and that
// doesn't exist (unless -f), as zmv does.

fn usage() {
    "usage: zmv [-finqQsvwW] [-C|-L|-M|-p PROG|-P PROG] [-o OPTS] SRCPAT DEST\n" +
        "  SRCPAT's groups (parenthesised) are $1, $2, ... in DEST, and $f is the file:\n" +
        "  zmv '(*).txt' '$1.md'      zmv -W '*.txt' '*.md'      mmv '*.txt' '*.md'"
}

// A literal character in an extended regular expression.
fn re_literal(c) {
    if ".[]()*+?{}|^$\\".contains(c) { "\\" + c } else { c.to_string() }
}

// A literal character in a pattern for `sh::glob`: braces and commas are escaped, as `sh::glob` expands braces.
fn glob_literal(c) {
    if "{},".contains(c) || c == '\\' || "*?[]()".contains(c) { "\\" + c } else { c.to_string() }
}

// The end of the bracket expression that starts at `cs[i]` (the index of its `]`), or -1 if it isn't one.
fn bracket_end(cs, i) {
    let n = cs.len();
    let j = i + 1;
    if j < n && (cs[j] == '!' || cs[j] == '^') { j += 1; }
    if j < n && cs[j] == ']' { j += 1; }
    while j < n && cs[j] != ']' {
        if cs[j] == '[' && j + 1 < n && cs[j + 1] == ':' {
            let k = j + 2;
            while k + 1 < n && !(cs[k] == ':' && cs[k + 1] == ']') { k += 1; }
            j = if k + 1 < n { k + 2 } else { j + 1 };
            continue;
        }
        if cs[j] == '\\' { j += 1; }
        j += 1;
    }
    if j < n { j } else { -1 }
}

// SRCPAT translated: #{glob, re, groups, wild}, with `groups` the indexes in the regular expression's groups of
// SRCPAT's, in order, and `wild` the number of groups that -w made. Throws an error for unbalanced parentheses.
fn translate(pat, wrap) {
    let cs = pat.to_chars();
    let n = cs.len();
    let re = "";
    let glob = "";
    let groups = [];
    let ere = 0;          // the regular expression's groups so far
    let wild = 0;
    // The glob of each enclosing group: what came before it, and its alternatives so far.
    let stack = [];
    let i = 0;
    while i < n {
        let c = cs[i];
        let depth = stack.len();
        if c == '\\' && i + 1 < n {
            re += re_literal(cs[i + 1]);
            glob += "\\" + cs[i + 1];
            i += 2;
            continue;
        }
        if c == '(' {
            ere += 1;
            groups.push(ere);
            re += "(";
            stack.push(#{before: glob, alts: []});
            glob = "";
            i += 1;
            continue;
        }
        if c == '|' && depth > 0 {
            re += "|";
            stack[depth - 1].alts.push(glob);
            glob = "";
            i += 1;
            continue;
        }
        if c == ')' && depth > 0 {
            re += ")";
            let top = stack.pop();
            top.alts.push(glob);
            let alts = top.alts.reduce(|s, a| if s == () { a } else { s + "," + a });
            glob = top.before + if top.alts.len() == 1 { alts } else { "{" + alts + "}" };
            i += 1;
            continue;
        }
        if c == ')' {
            throw "unbalanced ) in " + pat;
        }
        // A wildcard: its glob and regular expression, and its length.
        let w = ();
        if c == '*' {
            let at_start = i == 0 || "/(|".contains(cs[i - 1]);
            let stars = 1;
            while i + stars < n && cs[i + stars] == '*' { stars += 1; }
            if at_start && stars >= 2 && stars <= 3 && i + stars < n && cs[i + stars] == '/' {
                // `**/` (and `***/`, which follows links): any number of directories.
                let text = pat.sub_string(i, stars + 1);
                w = #{glob: text, re: "(.*/)?", len: stars + 1, inner: 1};
            } else {
                w = #{glob: "*", re: "[^/]*", len: stars, inner: 0};
            }
        } else if c == '?' {
            w = #{glob: "?", re: "[^/]", len: 1, inner: 0};
        } else if c == '[' {
            let end = bracket_end(cs, i);
            if end > 0 {
                let body = "";
                let j = i + 1;
                if cs[j] == '!' || cs[j] == '^' { body += "^"; j += 1; }
                while j < end {
                    if cs[j] == '\\' && j + 1 < end { j += 1; }
                    body += cs[j];
                    j += 1;
                }
                w = #{glob: pat.sub_string(i, end + 1 - i), re: "[" + body + "]", len: end + 1 - i, inner: 0};
            }
        }
        if w == () {
            re += re_literal(c);
            glob += glob_literal(c);
            i += 1;
            continue;
        }
        if wrap && depth == 0 {
            ere += 1;
            groups.push(ere);
            wild += 1;
            re += "(" + w.re + ")";
        } else {
            re += w.re;
        }
        ere += w.inner;
        glob += w.glob;
        i += w.len;
    }
    if stack.len() > 0 {
        throw "unbalanced ( in " + pat;
    }
    #{glob: glob, re: "^" + re + "$", groups: groups, wild: wild}
}

// DEST with its wildcards (`**/`, `*`, `?`) made into `${1}`, `${2}`, ... in turn, for -W. Throws an error if it
// has more of them than SRCPAT had.
fn number_wildcards(dest, count) {
    let cs = dest.to_chars();
    let n = cs.len();
    let out = "";
    let k = 0;
    let i = 0;
    while i < n {
        let c = cs[i];
        if c == '\\' && i + 1 < n {
            out += c + cs[i + 1];
            i += 2;
            continue;
        }
        let len = 0;
        if c == '*' {
            len = 1;
            while i + len < n && cs[i + len] == '*' { len += 1; }
            if len >= 2 && i + len < n && cs[i + len] == '/' { len += 1; }
        } else if c == '?' {
            len = 1;
        }
        if len == 0 {
            out += c;
            i += 1;
            continue;
        }
        k += 1;
        if k > count {
            throw `${dest}: more wildcards than in the pattern`;
        }
        out += "${" + k + "}";
        i += len;
    }
    out
}

// A word as zmv shows it in commands: quoted only if it needs to be.
fn shown(word) {
    if word != "" && !sh::matches("*[!A-Za-z0-9_./+:,@%=-]*", word) { word } else { sh::quote(word) }
}

fn show_command(argv) {
    let out = [];
    for w in argv { out.push(shown(w)); }
    out.reduce(|s, w| if s == () { w } else { s + " " + w })
}

// The words of a string split at blanks.
fn words_of(text) {
    let out = [];
    for w in text.split(' ') {
        w.trim();
        if w != "" { out.push(w); }
    }
    out
}

fn main(argv) {
    let name = argv[0];
    let action = switch name { "zcp" => ["cp"], "zln" => ["ln"], _ => ["mv"] };
    let opt = #{f: false, i: false, n: false, Q: false, s: false, v: false, w: false, W: name == "mmv"};
    let program = ();
    let dashdash = true;
    let extra = [];
    let k = 1;
    while k < argv.len() {
        let a = argv[k];
        if a == "--" { k += 1; break; }
        if a.len() < 2 || !a.starts_with("-") { break; }
        let cs = a.to_chars();
        let j = 1;
        while j < cs.len() {
            let c = cs[j];
            j += 1;
            switch c.to_string() {
                "f" | "i" | "n" | "Q" | "s" | "v" | "w" | "W" => { opt[c.to_string()] = true; }
                "q" => { opt.Q = false; }
                "C" => { action = ["cp"]; }
                "L" => { action = ["ln"]; }
                "M" => { action = ["mv"]; }
                "p" | "P" | "o" => {
                    // The value is the rest of the word, or the next word.
                    let value = if j < cs.len() { a.sub_string(j) } else {
                        k += 1;
                        if k >= argv.len() { throw "option requires an argument: -" + c + "\n" + usage(); }
                        argv[k]
                    };
                    j = cs.len();
                    if c == 'o' { extra += words_of(value); } else {
                        program = words_of(value);
                        dashdash = c == 'p';
                    }
                }
                _ => { throw "bad option: -" + c + "\n" + usage(); }
            }
        }
        k += 1;
    }
    let args = argv.extract(k);
    if args.len() != 2 {
        throw usage();
    }
    let pat = args[0];
    let dest = args[1];
    if program != () {
        if program.is_empty() { throw "-p and -P need a program"; }
        action = program;
    } else if opt.s && action[0] == "ln" {
        action.push("-s");
    }
    action += extra;

    // A qualifier: `(#q...)` at the end, or with -Q a final group.
    let qual = "";
    let q = pat.index_of("(#q");
    if q >= 0 && pat.ends_with(")") {
        qual = "(" + pat.sub_string(q + 3, pat.len() - q - 4) + ")";
        pat = pat.sub_string(0, q);
    } else if opt.Q && pat.ends_with(")") {
        let open = pat.index_of('(', 0);
        let last = -1;
        while open >= 0 { last = open; open = pat.index_of('(', open + 1); }
        if last >= 0 {
            qual = pat.sub_string(last);
            pat = pat.sub_string(0, last);
        }
    }
    // `~` and `~/...`: the home directory, quoted.
    if pat == "~" || pat.starts_with("~/") {
        let home = "";
        for c in (sh::getvar("HOME") ?? "").to_chars() { home += "\\" + c; }
        pat = home + pat.sub_string(1);
    }

    let t = translate(pat, opt.w || opt.W);
    if opt.W {
        dest = number_wildcards(dest, t.wild);
    }
    let files = sh::glob(t.glob + qual);
    if files.is_empty() {
        throw "no files matched: " + args[0];
    }

    // The targets, from DEST evaluated in a shell function for each file, with the groups as its positional
    // parameters (so that the shell's own are left alone).
    let positional = "";
    for g in t.groups { positional += " \"${BASH_REMATCH[" + g + "]}\""; }
    sh::setvar("__zmv_files", files);
    sh::setvar("__zmv_re", t.re);
    sh::setvar("__zmv_to", []);
    sh::unsetvar("__zmv_done");
    let script = "__zmv_eval() {\n" +
        "local f\n" +
        "for f in \"${__zmv_files[@]}\"; do\n" +
        "if [[ $f =~ $__zmv_re ]]; then set --" + positional + "; else set --; fi\n" +
        "__zmv_to+=(\"" + dest + "\")\n" +
        "done\n" +
        "__zmv_done=1\n" +
        "}\n" +
        "__zmv_eval";
    sh::run(script);
    let done = sh::getvar("__zmv_done") == "1";
    let targets = sh::getarray("__zmv_to") ?? [];
    sh::run("unset -f __zmv_eval; unset __zmv_files __zmv_re __zmv_to __zmv_done");
    if !done || targets.len() != files.len() {
        throw "error in the replacement: " + args[1];
    }

    // What to do, and what is wrong with it: zmv does nothing if anything is.
    let errors = [];
    let todo = [];
    let from = #{};
    for idx in 0..files.len() {
        let f = files[idx];
        let g = targets[idx];
        if g == "" {
            errors.push(`${f} has an empty target`);
            continue;
        }
        if f == g { continue; }
        let same = fs::exists(g) && fs::realpath(f) == fs::realpath(g);
        if from.contains(g) && !fs::is_dir(g) {
            errors.push(`${f} and ${from[g]} both map to ${g}`);
        } else if fs::is_file(g) && !opt.f && !(same && action[0] == "mv" && program == ()) {
            errors.push(`file exists: ${g}`);
        }
        if !from.contains(g) { from[g] = f; }
        todo.push([f, g]);
    }
    if !errors.is_empty() {
        let text = name + ": error(s) in substitution:\n";
        for e in errors { text += e + "\n"; }
        sh::write(2, text);
        return 1;
    }

    let failed = 0;
    for p in todo {
        let cmd = action + (if dashdash { ["--"] } else { [] }) + p;
        if opt.n {
            print(show_command(cmd));
            continue;
        }
        if opt.i {
            sh::write(2, show_command(cmd) + "? ");
            let answer = sh::read_line() ?? "";
            if !answer.starts_with("y") && !answer.starts_with("Y") { continue; }
        } else if opt.v {
            print(show_command(cmd));
        }
        if sh::run(sh::quote(cmd)) != 0 { failed += 1; }
    }
    if failed > 0 { 1 } else { 0 }
}

// Completion: the options, the programs of -p and -P, and else files.
fn options() { [
    #{value: "-f", desc: "overwrite existing targets"},
    #{value: "-i", desc: "ask before each command"},
    #{value: "-n", desc: "show the commands without running them"},
    #{value: "-v", desc: "show each command as it runs"},
    #{value: "-w", desc: "make each wildcard of the pattern a group"},
    #{value: "-W", desc: "-w, and the wildcards of the target are the groups"},
    #{value: "-Q", desc: "a final group of the pattern is a glob qualifier"},
    #{value: "-q", desc: "no glob qualifiers (the default)"},
    #{value: "-s", desc: "symbolic links (with ln)"},
    #{value: "-C", desc: "copy (cp)"},
    #{value: "-L", desc: "link (ln)"},
    #{value: "-M", desc: "move (mv)"},
    #{value: "-p", desc: "run a program instead of mv, cp or ln"},
    #{value: "-P", desc: "-p, for a program that doesn't take --"},
    #{value: "-o", desc: "options for the program"},
] }

fn complete(words, i) {
    let prev = if i > 1 { words[i - 1] } else { "" };
    if prev == "-p" || prev == "-P" {
        return sh::commands(words[i]);
    }
    if prev == "-o" {
        return [];
    }
    if words[i].starts_with("-") {
        return options();
    }
    ()
}
