// What the arguments and option values of system tools complete to, named
// `own("kinds:NAME")` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;

// The mount points of FUSE file systems (sshfs, borg mount, ...): for a word
// that isn't a path yet, those under the current directory (relative to it),
// and all of them, and for a relative path, those under the current directory.
fn fuse_mounts(cur) {
    let pwd = sh::getvar("PWD") ?? "";
    let out = [];
    for m in std_kinds::mount_table() {
        if !(m.type == "fuse" || m.type.starts_with("fuse.") || m.type == "fuseblk") {
            continue;
        }
        let p = m.point;
        if pwd != "" && p.starts_with(pwd + "/") && !cur.starts_with("/") {
            out.push(p.sub_string(pwd.len() + 1));
        }
        if cur == "" || cur.starts_with("/") || cur.starts_with("~") {
            out.push(p);
        }
    }
    out
}

// A borg repository (a directory, or `HOST:PATH`) or archive (`REPO::NAME`, or `::NAME` with BORG_REPO). The
// names of archives are not completed: borg would have to open the repository (and ask for its passphrase).
fn borg_location(cur) {
    if cur.contains("::") {
        return [];
    }
    let r = std_kinds::remote(cur);
    if (sh::getvar("BORG_REPO") ?? "") != "" && (cur == "" || cur == ":") {
        let repo = #{value: "::", suffix: "", desc: "an archive of BORG_REPO"};
        if type_of(r) == "map" { r.candidates.push(repo); } else { r.push(repo); }
    }
    r
}

// borg's compression specs (`borg help compression`): an algorithm, or one
// followed by `,LEVEL` (`zstd,10`), or `auto,` or `obfuscate,` before one.
fn borg_compression() {
    [
        #{value: "lz4", desc: "very high speed, very low compression (default)"},
        #{value: "zstd", desc: "modern wide-range algorithm (level 3)"},
        #{value: "zstd,", suffix: "", desc: "zstd with a level (1-22)"},
        #{value: "zlib", desc: "medium speed, medium compression (level 6)"},
        #{value: "zlib,", suffix: "", desc: "zlib with a level (0-9)"},
        #{value: "lzma", desc: "low speed, high compression (level 6)"},
        #{value: "lzma,", suffix: "", desc: "lzma with a level (0-9)"},
        #{value: "none", desc: "no compression"},
        #{value: "auto,", suffix: "", desc: "compress only data that lz4 finds compressible"},
        #{value: "obfuscate,", suffix: "", desc: "obfuscate the sizes of the compressed chunks"},
    ]
}

// borg's chunker parameters: `default`, or `buzhash,...` or `fixed,...`.
fn borg_chunker_params() {
    [
        #{value: "default", desc: "buzhash,19,23,21,4095"},
        #{value: "buzhash,", suffix: "", desc: "CHUNK_MIN_EXP,CHUNK_MAX_EXP,HASH_MASK_BITS,HASH_WINDOW_SIZE"},
        #{value: "fixed,", suffix: "", desc: "BLOCK_SIZE[,HEADER_SIZE]"},
    ]
}

fn kind(name, cur, words) {
    switch name {
        "fuse_mounts" => fuse_mounts(cur),
        "borg_location" => borg_location(cur),
        "borg_compression" => borg_compression(),
        "borg_chunker_params" => borg_chunker_params(),
        _ => throw `unknown kind: ${name}`,
    }
}
