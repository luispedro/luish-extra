// pathed: shows and edits PATH.
//
//   pathed [list]                                   PATH, numbered, with notes
//   pathed add [-afmnv] [--before E|--after E] DIR...
//   pathed rm [-nv] ENTRY...
//   pathed mv [-nv] ENTRY (N|first|last|--before E|--after E)
//   pathed clean [-nv] [--missing]
//   pathed edit                                     (pathed -e, vipath): PATH in $VISUAL or $EDITOR
//   pathed undo [-fn] | pathed undo -l
//   pathed which CMD...
//
// An ENTRY is a number (as `pathed` shows them), a directory, or a pattern (`'*conda*'`).
//
// The normalised form of an entry is absolute (a relative one is taken from the current directory, a leading `~`
// is the home directory), without `.`, `//` or a trailing `/`, and without `..` where taking it out names the same
// directory; symbolic links are left alone. The normalised PATH has each entry's normalised form, without the
// empty entries (which mean the current directory) and without duplicates (the first is kept). `pathed clean`
// makes PATH that.
//
// Each change keeps the PATH from before it (and the command that made it) in the shell variables
// __pathed_before, __pathed_after and __pathed_cmds, which `pathed undo` reads.

fn usage() {
    "usage: pathed [list]               PATH, numbered, with notes\n" +
        "       pathed add [-afmnv] [--before ENTRY|--after ENTRY] DIR...\n" +
        "       pathed rm [-nv] ENTRY...\n" +
        "       pathed mv [-nv] ENTRY (N|first|last|--before ENTRY|--after ENTRY)\n" +
        "       pathed clean [-nv] [--missing]\n" +
        "       pathed edit                 (or pathed -e, or vipath)\n" +
        "       pathed undo [-fn] | pathed undo -l\n" +
        "       pathed which CMD...\n" +
        "  An ENTRY is a number, a directory or a pattern ('*conda*')."
}

// Kinds and sub_specs are named by this module's absolute path, which doesn't depend on the name of the source.
fn own(name) { sh::plugin_dir() + "/" + name }

// How many changes undo keeps, the widest column of directories, and how many shadowed commands a note names.
fn undo_kept() { 100 }
fn column() { 40 }
fn shadows_shown() { 4 }

fn join(items, sep) {
    let out = "";
    let first = true;
    for x in items {
        if !first { out += sep; }
        out += x;
        first = false;
    }
    out
}

fn spaces(n) {
    let s = "";
    for i in 0..n { s += " "; }
    s
}

fn pad_to(s, width) {
    if s.len() >= width { s } else { s + spaces(width - s.len()) }
}

fn is_number(s) { s != "" && !sh::matches("*[!0-9]*", s) }

fn is_pattern(s) { s.contains('*') || s.contains('?') || s.contains('[') }

fn home() {
    let h = sh::getvar("HOME") ?? "";
    while h.len() > 1 && h.ends_with("/") { h = h.sub_string(0, h.len() - 1); }
    h
}

// PATH's entries, as they are.
fn entries() {
    let p = sh::getvar("PATH");
    if p == () || p == "" { [] } else { p.split(':') }
}

// A directory as it is shown: under the home directory, with `~`.
fn display(p) {
    if p == "" { return "''"; }
    let h = home();
    if h != "" && h != "/" && (p == h || p.starts_with(h + "/")) { "~" + p.sub_string(h.len()) } else { p }
}

fn is_exe(p) { fs::is_file(p) && fs::is_executable(p) }

// The normalised form of an entry (see the top); "" for the empty entry.
fn norm(e) {
    if e == "" { return ""; }
    let p = e;
    if p == "~" || p.starts_with("~/") { p = home() + p.sub_string(1); }
    if !p.starts_with("/") { p = sh::cwd() + "/" + p; }
    let parts = [];
    let dotdot = false;
    for part in p.split('/') {
        if part == "" || part == "." { continue; }
        if part == ".." { dotdot = true; }
        parts.push(part);
    }
    let kept = "/" + join(parts, "/");
    if !dotdot { return kept; }
    let out = [];
    for part in parts {
        if part == ".." {
            if !out.is_empty() { out.pop(); }
        } else {
            out.push(part);
        }
    }
    let collapsed = "/" + join(out, "/");
    // Through a symbolic link, `link/..` isn't the directory that holds `link`.
    if fs::realpath(kept) == fs::realpath(collapsed) { collapsed } else { kept }
}

// What is known of each entry: #{entry, norm, notes, dup (the index of the first with the same normalised form,
// or -1), real (its real path, for the first entry of each directory that exists), shadows}. With `deep`, the
// commands that each one shadows (those found again in a later directory) are looked for.
fn analyse(list, deep) {
    let info = [];
    let first_of = #{};
    let real_of = #{};
    for idx in 0..list.len() {
        let e = list[idx];
        let it = #{entry: e, norm: norm(e), notes: [], dup: -1, real: (), shadows: []};
        if e == "" {
            it.notes.push("empty: the current directory");
        } else {
            if e == "~" || e.starts_with("~/") {
                it.notes.push("a literal ~, which only bash expands");
            } else if !e.starts_with("/") {
                it.notes.push("relative: " + display(it.norm));
            } else if it.norm != e {
                it.notes.push("normalised: " + display(it.norm));
            }
            if first_of.contains(it.norm) {
                it.dup = first_of[it.norm];
                it.notes.push("duplicate of " + (it.dup + 1));
            } else {
                first_of[it.norm] = idx;
                if !fs::exists(it.norm) {
                    it.notes.push("missing");
                } else if !fs::is_dir(it.norm) {
                    it.notes.push("not a directory");
                } else {
                    let real = fs::realpath(it.norm);
                    if real_of.contains(real) {
                        it.notes.push("same directory as " + (real_of[real] + 1));
                    } else {
                        real_of[real] = idx;
                        it.real = real;
                    }
                }
            }
        }
        info.push(it);
    }
    if deep { info = find_shadows(info); }
    info
}

// The commands that each directory shadows: executables that a later directory also has.
fn find_shadows(info) {
    let owner = #{};
    for idx in 0..info.len() {
        let dir = info[idx].real;
        if dir == () { continue; }
        for name in fs::list_dir(dir) ?? [] {
            if !owner.contains(name) {
                owner[name] = idx;
                continue;
            }
            let o = owner[name];
            if is_exe(info[o].real + "/" + name) {
                if is_exe(dir + "/" + name) { info[o].shadows.push(name); }
            } else if is_exe(dir + "/" + name) {
                owner[name] = idx;
            }
        }
    }
    for idx in 0..info.len() {
        let names = info[idx].shadows;
        if names.is_empty() { continue; }
        names.sort();
        let unique = [];
        for n in names {
            if unique.is_empty() || unique[unique.len() - 1] != n { unique.push(n); }
        }
        let note = "shadows " + join(unique.extract(0, shadows_shown()), ", ");
        if unique.len() > shadows_shown() { note += " and " + (unique.len() - shadows_shown()) + " more"; }
        info[idx].notes.push(note);
    }
    info
}

// The normalised PATH (see the top), without the directories that don't exist if `drop_missing`.
fn normalised(info, drop_missing) {
    let out = [];
    for it in info {
        if it.norm == "" || it.dup >= 0 { continue; }
        if drop_missing && !fs::is_dir(it.norm) { continue; }
        out.push(it.norm);
    }
    out
}

// The numbered lines of a list of entries, with their notes after `sep` (for the editor's file, "# ").
fn table(info, sep) {
    let width = ("" + info.len()).len();
    let col = 0;
    for it in info {
        let l = display(it.entry).len();
        if l > col && l <= column() { col = l; }
    }
    let lines = [];
    for idx in 0..info.len() {
        let it = info[idx];
        let num = "" + (idx + 1);
        let line = spaces(width - num.len()) + num + "  ";
        let shown = display(it.entry);
        if it.notes.is_empty() {
            line += shown;
        } else {
            line += pad_to(shown, col) + "  " + sep + join(it.notes, "; ");
        }
        lines.push(line);
    }
    lines
}

fn numbered(list) {
    let width = ("" + list.len()).len();
    let lines = [];
    for idx in 0..list.len() {
        let num = "" + (idx + 1);
        lines.push(spaces(width - num.len()) + num + "  " + display(list[idx]));
    }
    lines
}

// What changed from `old` to `updated`, as lines. The entries are lined up by their normalised forms (a longest
// common subsequence), so that one replaced by its normalised form is "normalised"; one that is both removed and
// added is "moved".
fn diff(old, updated) {
    let n = old.len();
    let m = updated.len();
    let ko = [];
    for e in old { ko.push(norm(e)); }
    let ku = [];
    for e in updated { ku.push(norm(e)); }
    let w = m + 1;
    let dp = [];
    dp.pad((n + 1) * w, 0);
    let i = n - 1;
    while i >= 0 {
        let j = m - 1;
        while j >= 0 {
            if ko[i] == ku[j] {
                dp[i * w + j] = dp[(i + 1) * w + j + 1] + 1;
            } else {
                let down = dp[(i + 1) * w + j];
                let right = dp[i * w + j + 1];
                dp[i * w + j] = if down >= right { down } else { right };
            }
            j -= 1;
        }
        i -= 1;
    }
    let lines = [];
    let removed = [];
    let added = [];
    let i = 0;
    let j = 0;
    while i < n && j < m {
        if ko[i] == ku[j] {
            if old[i] != updated[j] {
                let how = if updated[j] == ko[i] { " as " } else { " by " };
                let verb = if updated[j] == ko[i] { "normalised " } else { "replaced " };
                lines.push(verb + display(old[i]) + how + display(updated[j]) + ` (${j + 1})`);
            }
            i += 1;
            j += 1;
        } else if dp[(i + 1) * w + j] >= dp[i * w + j + 1] {
            removed.push(i);
            i += 1;
        } else {
            added.push(j);
            j += 1;
        }
    }
    while i < n { removed.push(i); i += 1; }
    while j < m { added.push(j); j += 1; }
    let moved = [];
    let used = [];
    for r in removed {
        let found = -1;
        for a in added {
            if ku[a] == ko[r] && !used.contains(a) { found = a; break; }
        }
        if found >= 0 {
            used.push(found);
            moved.push(`moved   ${display(old[r])} (${r + 1} -> ${found + 1})`);
        } else {
            lines.push(`removed ${display(old[r])} (${r + 1})`);
        }
    }
    lines += moved;
    for a in added {
        if !used.contains(a) { lines.push(`added   ${display(updated[a])} (${a + 1})`); }
    }
    lines
}

// A word as it would be typed: quoted only if it needs to be.
fn shown_word(word) {
    if word != "" && !sh::matches("*[!A-Za-z0-9_./+:,@%=~-]*", word) { word } else { sh::quote(word) }
}

fn command_line(argv) {
    let words = [];
    for w in argv { words.push(shown_word(w)); }
    join(words, " ")
}

// Make PATH `updated` (unless `opt.n`), keeping the old one for `pathed undo`, and say what changed if `show` (or
// `opt.v` or `opt.n`), after `notes`.
fn apply(old, updated, argv, opt, notes, show) {
    let talk = show || opt.v || opt.n;
    let lines = diff(old, updated);
    if talk {
        for l in notes { print(l); }
        for l in lines { print(l); }
        if lines.is_empty() && notes.is_empty() { print("PATH unchanged"); }
    }
    let before = join(old, ":");
    let after = join(updated, ":");
    if opt.n || before == after { return 0; }
    sh::setvar("PATH", after);
    let bs = sh::getarray("__pathed_before") ?? [];
    let as_ = sh::getarray("__pathed_after") ?? [];
    let cs = sh::getarray("__pathed_cmds") ?? [];
    bs.push(before);
    as_.push(after);
    cs.push(command_line(argv));
    if bs.len() > undo_kept() {
        let k = bs.len() - undo_kept();
        bs = bs.extract(k);
        as_ = as_.extract(k);
        cs = cs.extract(k);
    }
    sh::setvar("__pathed_before", bs);
    sh::setvar("__pathed_after", as_);
    sh::setvar("__pathed_cmds", cs);
    0
}

// The options of a subcommand: `flags` maps an option (`-n`, `--dry-run`) to its key, and `valued` maps one that
// takes a value (`--before`) to its key. Short flags can be grouped (`-nv`). Returns #{opt, args}.
fn parse(sub, words, flags, valued) {
    let opt = #{n: false, v: false};
    for k in flags.values() { opt[k] = false; }
    for k in valued.values() { opt[k] = (); }
    let args = [];
    let only_args = false;
    let k = 0;
    while k < words.len() {
        let w = words[k];
        k += 1;
        if only_args || w == "-" || !w.starts_with("-") {
            args.push(w);
            continue;
        }
        if w == "--" {
            only_args = true;
            continue;
        }
        if w.starts_with("--") {
            let name = w;
            let value = ();
            let eq = w.index_of('=');
            if eq > 0 {
                name = w.sub_string(0, eq);
                value = w.sub_string(eq + 1);
            }
            if flags.contains(name) && value == () {
                opt[flags[name]] = true;
            } else if valued.contains(name) {
                if value == () {
                    if k >= words.len() { throw `${sub}: ${name} needs a value`; }
                    value = words[k];
                    k += 1;
                }
                opt[valued[name]] = value;
            } else {
                throw `${sub}: unknown option ${w}` + "\n" + usage();
            }
            continue;
        }
        for c in w.sub_string(1).to_chars() {
            let name = "-" + c;
            if !flags.contains(name) { throw `${sub}: unknown option ${name}` + "\n" + usage(); }
            opt[flags[name]] = true;
        }
    }
    #{opt: opt, args: args}
}

// The indexes of the entries of `list` that `which` names: a number, a pattern, or a directory (compared in
// normalised form). Throws an error if it names none.
fn resolve(which, list) {
    if is_number(which) {
        let n = parse_int(which);
        if n < 1 || n > list.len() { throw `no entry ${which} (PATH has ${list.len()})`; }
        return [n - 1];
    }
    let found = [];
    if is_pattern(which) {
        for i in 0..list.len() {
            let e = list[i];
            let n = norm(e);
            if sh::matches(which, e) || sh::matches(which, n) || sh::matches(which, display(n)) { found.push(i); }
        }
    } else {
        let target = norm(which);
        for i in 0..list.len() {
            if norm(list[i]) == target { found.push(i); }
        }
    }
    if found.is_empty() { throw `not in PATH: ${which}`; }
    found
}

// As resolve, for exactly one entry.
fn resolve_one(which, list) {
    let found = resolve(which, list);
    if found.len() > 1 {
        let nums = [];
        for i in found { nums.push("" + (i + 1)); }
        throw `${which} is ${found.len()} entries (${join(nums, ", ")}): give its number`;
    }
    found[0]
}

fn cmd_list(args) {
    if !args.is_empty() { throw "list: no arguments\n" + usage(); }
    let list = entries();
    if list.is_empty() {
        print("PATH is empty");
        return 0;
    }
    let info = analyse(list, true);
    for l in table(info, "") { print(l); }
    let norm = normalised(info, false);
    if join(norm, ":") != join(list, ":") {
        print("");
        print("normalised (pathed clean):");
        for l in numbered(norm) { print(l); }
    }
    0
}

fn cmd_add(argv, words) {
    let p = parse("add", words,
        #{"-a": "a", "--append": "a", "-m": "m", "--move": "m", "-f": "f", "--force": "f",
          "-n": "n", "--dry-run": "n", "-v": "v", "--verbose": "v"},
        #{"--before": "before", "--after": "after"});
    let opt = p.opt;
    if p.args.is_empty() { throw "add: no directory\n" + usage(); }
    let placed = (if opt.a { 1 } else { 0 }) + (if opt.before != () { 1 } else { 0 }) +
        (if opt.after != () { 1 } else { 0 });
    if placed > 1 { throw "add: -a, --before and --after go alone"; }
    let old = entries();
    let updated = old;
    let notes = [];
    let dirs = [];
    for d in p.args {
        if d == "" { throw "add: an empty directory"; }
        let n = norm(d);
        if !opt.f && !fs::is_dir(n) {
            throw `add: no such directory: ${d} (-f adds it anyway)`;
        }
        if dirs.contains(n) { continue; }
        let at = -1;
        for i in 0..old.len() {
            if norm(old[i]) == n { at = i; break; }
        }
        if at >= 0 && !opt.m {
            notes.push(`${display(n)} is already in PATH (${at + 1}); -m moves it`);
            continue;
        }
        dirs.push(n);
    }
    // With -m, the directories leave their places first.
    let kept = [];
    for e in updated {
        if !dirs.contains(norm(e)) { kept.push(e); }
    }
    updated = kept;
    let at = 0;
    if opt.a {
        at = updated.len();
    } else if opt.before != () || opt.after != () {
        let which = opt.before ?? opt.after;
        let i = resolve_one(which, old);
        if dirs.contains(norm(old[i])) { throw `add: ${which} is one of the directories added`; }
        // Its index once the moved directories are out.
        at = 0;
        for j in 0..i {
            if !dirs.contains(norm(old[j])) { at += 1; }
        }
        if opt.after != () { at += 1; }
    }
    let result = updated.extract(0, at) + dirs + updated.extract(at);
    apply(old, result, argv, opt, notes, false)
}

fn cmd_rm(argv, words) {
    let p = parse("rm", words, #{"-n": "n", "--dry-run": "n", "-v": "v", "--verbose": "v"}, #{});
    if p.args.is_empty() { throw "rm: no entry\n" + usage(); }
    let old = entries();
    let gone = [];
    for which in p.args {
        for i in resolve(which, old) {
            if !gone.contains(i) { gone.push(i); }
        }
    }
    let updated = [];
    for i in 0..old.len() {
        if !gone.contains(i) { updated.push(old[i]); }
    }
    apply(old, updated, argv, p.opt, [], false)
}

fn cmd_mv(argv, words) {
    let p = parse("mv", words, #{"-n": "n", "--dry-run": "n", "-v": "v", "--verbose": "v"},
        #{"--before": "before", "--after": "after"});
    let opt = p.opt;
    let relative = opt.before != () || opt.after != ();
    if opt.before != () && opt.after != () { throw "mv: --before and --after go alone"; }
    if p.args.len() != (if relative { 1 } else { 2 }) { throw "mv: an entry and where to put it\n" + usage(); }
    let old = entries();
    let i = resolve_one(p.args[0], old);
    let rest = old.extract(0, i) + old.extract(i + 1);
    let at = 0;
    if relative {
        let which = opt.before ?? opt.after;
        let j = resolve_one(which, old);
        if j == i { throw `mv: ${p.args[0]} can't go next to itself`; }
        at = if j > i { j - 1 } else { j };
        if opt.after != () { at += 1; }
    } else {
        let to = p.args[1];
        if to == "first" || to == "start" {
            at = 0;
        } else if to == "last" || to == "end" {
            at = rest.len();
        } else if is_number(to) {
            let n = parse_int(to);
            if n < 1 || n > old.len() { throw `mv: no position ${to} (PATH has ${old.len()})`; }
            at = n - 1;
        } else {
            throw `mv: ${to} isn't a position: a number, first or last`;
        }
    }
    let updated = rest.extract(0, at) + [old[i]] + rest.extract(at);
    apply(old, updated, argv, opt, [], false)
}

fn cmd_clean(argv, words) {
    let p = parse("clean", words,
        #{"-n": "n", "--dry-run": "n", "-v": "v", "--verbose": "v", "--missing": "missing"}, #{});
    if !p.args.is_empty() { throw "clean: no arguments\n" + usage(); }
    let old = entries();
    apply(old, normalised(analyse(old, false), p.opt.missing), argv, p.opt, [], false)
}

// The file that `pathed edit` gives the editor, and what it means.
fn edit_text(info) {
    let text = "# PATH, one directory per line: the first is searched first. Move a line to move\n" +
        "# the directory, delete it to take it out of PATH, add one to add it (~ is your\n" +
        "# home; '' is the empty entry, the current directory). A line that starts with #\n" +
        "# is ignored, and so is a note after \"  #\".\n" +
        "# Save and quit to apply; leave the file as it is, or empty it, to leave PATH alone.\n";
    let col = 0;
    for it in info {
        let l = display(it.entry).len();
        if l > col && l <= column() { col = l; }
    }
    for it in info {
        let shown = display(it.entry);
        if it.notes.is_empty() {
            text += shown + "\n";
        } else {
            text += pad_to(shown, col) + "  # " + join(it.notes, "; ") + "\n";
        }
    }
    text
}

fn parse_edit(text) {
    let out = [];
    for line in text.split('\n') {
        let note = line.index_of("  #");
        if note >= 0 { line = line.sub_string(0, note); }
        line.trim();
        if line == "" || line.starts_with("#") { continue; }
        if line == "''" { line = ""; }
        if line == "~" || line.starts_with("~/") { line = home() + line.sub_string(1); }
        out.push(line);
    }
    out
}

fn cmd_edit(argv, words) {
    if !words.is_empty() { throw "edit: no arguments\n" + usage(); }
    let old = entries();
    let text = edit_text(analyse(old, true));
    // Without mktemp, and rm found even if PATH has lost it: PATH may be what is broken.
    sh::setvar("__pathed_text", text);
    let made = sh::run("__pathed_file=${TMPDIR:-/tmp}/pathed.$$.$RANDOM; " +
        "(set -C; printf '%s' \"$__pathed_text\" >\"$__pathed_file\") 2>/dev/null");
    let file = sh::getvar("__pathed_file");
    sh::run("unset __pathed_text __pathed_file");
    if made != 0 || file == () { throw "edit: can't make a temporary file"; }
    let editor = sh::getvar("VISUAL") ?? "";
    if editor == "" { editor = sh::getvar("EDITOR") ?? ""; }
    if editor == "" { editor = "vi"; }
    // As git does, the editor is shell code, so that it can have arguments (`code -w`).
    let status = sh::run(editor + " " + sh::quote(file));
    let edited = fs::read_file(file);
    sh::capture([sh::which("rm") ?? "/bin/rm", "-f", file]);
    if status != 0 { throw `edit: the editor failed (status ${status}); PATH left alone`; }
    if edited == () { throw "edit: can't read the edited file; PATH left alone"; }
    if edited == text {
        print("PATH unchanged");
        return 0;
    }
    let updated = parse_edit(edited);
    if updated.is_empty() {
        print("no directories: PATH left alone");
        return 0;
    }
    apply(old, updated, argv, #{n: false, v: false}, [], true)
}

fn cmd_undo(argv, words) {
    let p = parse("undo", words,
        #{"-f": "f", "--force": "f", "-l": "l", "--list": "l", "-n": "n", "--dry-run": "n"}, #{});
    if !p.args.is_empty() { throw "undo: no arguments\n" + usage(); }
    let bs = sh::getarray("__pathed_before") ?? [];
    let as_ = sh::getarray("__pathed_after") ?? [];
    let cs = sh::getarray("__pathed_cmds") ?? [];
    if p.opt.l {
        if cs.is_empty() { print("nothing to undo"); }
        let k = cs.len();
        while k > 0 {
            k -= 1;
            print(cs[k]);
        }
        return 0;
    }
    if bs.is_empty() || as_.len() != bs.len() || cs.len() != bs.len() { throw "undo: nothing to undo"; }
    let last = bs.len() - 1;
    let now = sh::getvar("PATH") ?? "";
    if now != as_[last] && !p.opt.f {
        throw "undo: PATH has changed since " + cs[last] + ", not by pathed: -f undoes that too";
    }
    let old = entries();
    let updated = if bs[last] == "" { [] } else { bs[last].split(':') };
    print("undo " + cs[last]);
    for l in diff(old, updated) { print(l); }
    if p.opt.n { return 0; }
    sh::setvar("PATH", bs[last]);
    sh::setvar("__pathed_before", bs.extract(0, last));
    sh::setvar("__pathed_after", as_.extract(0, last));
    sh::setvar("__pathed_cmds", cs.extract(0, last));
    0
}

fn cmd_which(words) {
    if words.is_empty() { throw "which: no command\n" + usage(); }
    let info = analyse(entries(), false);
    let width = ("" + info.len()).len();
    let status = 0;
    for name in words {
        if name == "" || name.contains('/') { throw `which: not a command name: ${name}`; }
        if words.len() > 1 { print(name + ":"); }
        let found = false;
        for idx in 0..info.len() {
            let it = info[idx];
            if it.real == () { continue; }
            let file = it.norm + "/" + name;
            if !is_exe(file) { continue; }
            let num = "" + (idx + 1);
            let line = spaces(width - num.len()) + num + "  " + display(file);
            let target = fs::readlink(file);
            if target != () { line += " -> " + target; }
            if !found { line += "  (runs)"; }
            print(line);
            found = true;
        }
        if !found {
            sh::write(2, "pathed: " + name + ": not in PATH\n");
            status = 1;
        }
    }
    status
}

fn main(argv) {
    if argv[0] == "vipath" {
        return cmd_edit(argv, argv.extract(1));
    }
    if argv.len() < 2 { return cmd_list([]); }
    let sub = argv[1];
    let words = argv.extract(2);
    switch sub {
        "list" | "ls" => cmd_list(words),
        "add" => cmd_add(argv, words),
        "rm" | "remove" => cmd_rm(argv, words),
        "mv" | "move" => cmd_mv(argv, words),
        "clean" => cmd_clean(argv, words),
        "edit" | "-e" => cmd_edit(argv, words),
        "undo" => cmd_undo(argv, words),
        "which" => cmd_which(words),
        "help" | "-h" | "--help" => { print(usage()); 0 }
        _ => { throw `unknown subcommand: ${sub}` + "\n" + usage(); }
    }
}

// Completion, by std's engine.

fn spec() {
    let dry = `
        -n, --dry-run  show what would change, without changing PATH
        -v, --verbose  show what changed
    `;
    #{
        opts: `
            -e          edit PATH in $VISUAL or $EDITOR
            -h, --help  show the usage
        `,
        commands: `
            list, ls      PATH, numbered, with notes
            add           add directories (at the front)
            rm, remove    remove entries
            mv, move      move an entry
            clean         normalise PATH: absolute, no duplicates or empty entries
            edit          edit PATH in $VISUAL or $EDITOR
            undo          undo the last change
            which         every copy of a command in PATH
            help          show the usage
        `,
        args: ["none"],
        subs: #{
            list: #{args: ["none"]},
            add: #{
                opts: `
                    -a, --append     add at the end
                    -m, --move       move directories that are already in PATH
                    -f, --force      add directories that don't exist
                    --before ENTRY   add before an entry
                    --after ENTRY    add after an entry
                ` + dry,
                values: #{"--before": own("pathed:entries"), "--after": own("pathed:entries")},
                args: ["dirs"],
            },
            rm: #{opts: dry, args: [own("pathed:entries")]},
            mv: #{
                opts: `
                    --before ENTRY   move it before an entry
                    --after ENTRY    move it after an entry
                ` + dry,
                values: #{"--before": own("pathed:entries"), "--after": own("pathed:entries")},
                args: [own("pathed:entries"), own("pathed:positions"), "none"],
            },
            clean: #{
                opts: `
                    --missing      also remove directories that don't exist
                ` + dry,
                args: ["none"],
            },
            edit: #{args: ["none"]},
            undo: #{
                opts: `
                    -l, --list     list the changes that can be undone, the last first
                    -f, --force    undo even if PATH has changed since, not by pathed
                    -n, --dry-run  show what would change, without changing PATH
                `,
                args: ["none"],
            },
            which: #{args: ["commands"]},
            help: #{args: ["none"]},
        },
    }
}

// PATH's entries (as numbers, once a digit is typed; with ~ once it is typed), and the positions of mv.
fn kind(name, cur, words) {
    let list = entries();
    let out = [];
    if name == "positions" {
        out.push(#{value: "first", desc: "the front of PATH"});
        out.push(#{value: "last", desc: "the end of PATH"});
    }
    if is_number(cur) || name == "positions" {
        for i in 0..list.len() {
            out.push(#{value: "" + (i + 1), desc: display(list[i])});
        }
        return out;
    }
    let seen = [];
    for i in 0..list.len() {
        let e = list[i];
        if e == "" { continue; }
        let value = if cur.starts_with("~") { display(norm(e)) } else { e };
        if seen.contains(value) { continue; }
        seen.push(value);
        out.push(#{value: value, desc: "" + (i + 1)});
    }
    out
}
