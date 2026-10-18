// git-annex completes itself, as its own bash completion does: it is built with optparse-applicative, which,
// given `--bash-completion-index N` and the words of the line as `--bash-completion-word W`, prints the
// candidates for the word N, one per line (with `--bash-completion-enriched`, an option's description after a
// tab). Its remotes, backends and files come from the git-annex that is installed, so nothing here follows its
// releases. What bash does for its completion script is done here: `--to=REMOTE` is split for git-annex, which
// completes the value only as a word of its own; the files it lists (with compgen, so without the `/` of a
// directory) are listed again by luish; and a word for which it has nothing is a filename (bash's `-o
// default`), as are the values of options such as `--content-of PATH`, which it doesn't complete.

import "@std/completion/kinds" as kinds;

// The descriptions of the commands, from `git-annex --help`, which the protocol doesn't give: its lines
// `  NAME DESCRIPTION` (with a single space after the longest names).
fn command_descs(prog) {
    let out = #{};
    for line in sh::capture_cached(300, [prog, "--help"]).out.split("\n") {
        if !line.starts_with("  ") || line.starts_with("   ") {
            continue;
        }
        let t = line.sub_string(2);
        let gap = t.index_of(" ");
        if gap > 0 {
            let d = t.sub_string(gap);
            d.trim();
            if d != "" {
                out[t.sub_string(0, gap)] = d;
            }
        }
    }
    out
}

fn complete(words, i) {
    let cur = words[i];
    if i == 2 && words[1] == "help" {
        return complete([words[0], cur], 1);
    }
    let line = words.extract(0, i);
    let prefix = "";
    let w = cur;
    let eq = cur.index_of("=");
    if cur.starts_with("--") && eq > 0 {
        prefix = cur.sub_string(0, eq + 1);
        line.push(cur.sub_string(0, eq));
        w = cur.sub_string(eq + 1);
    }
    line.push(w);
    let argv = [
        words[0], "--bash-completion-enriched", "--bash-completion-option-desc-length", "200",
        "--bash-completion-index", `${line.len() - 1}`,
    ];
    for x in line {
        argv += ["--bash-completion-word", x];
    }
    let r = sh::capture(argv);
    if r.status != 0 {
        return ();
    }
    let opts = [];
    let others = [];
    let seen = #{};
    let descs = if i == 1 { command_descs(words[0]) } else { #{} };
    for l in r.out.split("\n") {
        if l == "" {
            continue;
        }
        let tab = l.index_of('\t');
        let c = if tab < 0 { #{value: l} } else { #{value: l.sub_string(0, tab), desc: l.sub_string(tab + 1)} };
        // (Its help gives `-d` to both --debug and --explain, and `-N` to --numcopies and --mincopies.)
        if seen.contains(c.value) {
            continue;
        }
        seen[c.value] = true;
        if c.value.starts_with("-") {
            opts.push(c);
        } else {
            if descs.contains(c.value) {
                c.desc = descs[c.value];
            }
            others.push(c);
        }
    }
    if prefix != "" {
        return if others.is_empty() { () } else { #{prefix: prefix, candidates: others} };
    }
    if w.starts_with("-") {
        return opts;
    }
    if others.is_empty() {
        return if opts.is_empty() { () } else { [] };
    }
    if !others.some(|c| fs::exists(c.value)) {
        return others;
    }
    // Files, with the other candidates (remotes, for `git-annex enableremote`) if the word has no directory.
    let files = kinds::files(w, "");
    if files.prefix == "" {
        files.candidates += others.filter(|c| !fs::exists(c.value));
    }
    files
}
