// Files by their names, for the kinds of the extra-completion plugins:
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
    std_kinds::files_matching(cur, std_kinds::ending_with(suffixes))
}

// The same, without the directories named in `skip` (`["__pycache__"]`).
fn with_suffix(cur, suffixes, skip) {
    let r = with_suffix(cur, suffixes);
    r.candidates = r.candidates.filter(|c| type_of(c) == "string" || !skip.contains(c.value.sub_string(0, c.value.len() - 1)));
    r
}
