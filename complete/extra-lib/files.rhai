// Files by their names, for the kinds of the extra-complete plugins:
// `import "../extra-lib/files" as lib_files;`.
import "@std/completion/kinds" as std_kinds;

// `suffixes` and the same with each compression a data file may have.
fn compressed(suffixes) {
    let out = [];
    for s in suffixes {
        out.push(s);
        for z in [".gz", ".bz2", ".xz", ".zst"] {
            out.push(s + z);
        }
    }
    out
}

// The files of the directory of `cur` whose names end in one of `suffixes`,
// and the directories.
fn with_suffix(cur, suffixes) {
    let r = std_kinds::listing(cur, "", false);
    r.candidates = r.candidates.filter(|c| type_of(c) == "map" || suffixes.some(|s| c.ends_with(s)));
    r
}

// The same, without the directories named in `skip` (`["__pycache__"]`).
fn with_suffix(cur, suffixes, skip) {
    let r = std_kinds::listing(cur, "", false);
    let out = [];
    for c in r.candidates {
        if type_of(c) == "map" {
            if !skip.contains(c.value.sub_string(0, c.value.len() - 1)) {
                out.push(c);
            }
        } else if suffixes.some(|s| c.ends_with(s)) {
            out.push(c);
        }
    }
    r.candidates = out;
    r
}
