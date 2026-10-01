"""Generates ../../complete/bio/diamond.rhai for diamond (diamond.rhai), from the --help of the pinned versions.

    python3 scripts/gen/mk_diamond.py
"""
import os
import re, sys
import gen
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

SUBS = ["makedb", "blastp", "blastx", "cluster", "linclust", "realign", "recluster", "reassign", "view", "merge-daa",
        "getseq", "dbinfo", "makeidx", "greedy-vertex-cover", "countdistinct"]
FLAGS = set("""--log --quiet --keep-temp-files --faster --fast --mid-sensitive --linclust-20 --shapes-6x10 --shapes-30x10
--sensitive --more-sensitive --very-sensitive --ultra-sensitive --range-culling --swipe --long-reads --salltitles
--sallseqid --no-self-hits --skip-missing-seqids --symmetrize-evalue --no-unlink --ignore-warnings --no-parse-seqids
--include-lineage --no-ranking --no-auto-append --oid-output --hit-membuf --fpu-compat --no-mempool --new-ext
--linsearch --lin-stage1 --reseek-diags --multiprocessing --mp-init --mp-recover --xml-blord-format --sam-query-len
--target-indexed --self --no-reorder --verbose --single-step --no-reassign --forwardonly --symmetric""".split())
SHORT = {"--db": "-d", "--query": "-q", "--out": "-o", "--threads": "-p", "--evalue": "-e", "--max-target-seqs": "-k",
         "--outfmt": "-f", "--block-size": "-b", "--index-chunks": "-c", "--tmpdir": "-t", "--frameshift": "-F",
         "--memory-limit": "-M", "--verbose": "-v"}
KIND = {"--db": None, "--in": 'k("sequences")', "--query": 'k("sequences")', "--out": '"files"', "--daa": '"files"',
        "--taxonmap": '"files"', "--taxonnodes": '"files"', "--taxonnames": '"files"', "--taxdump": '"dirs"',
        "--tmpdir": '"dirs"', "--parallel-tmpdir": '"dirs"', "--custom-matrix": '"files"', "--un": '"files"', "--al": '"files"',
        "--seqidlist": '"files"', "--clusters": '"files"', "--edges": '"files"', "--aln-out": '"files"', "--reps": '"files"',
        "--centroid-out": '"files"',
        "--matrix": '["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM70", "PAM30"]',
        "--outfmt": '[#{value: "0", desc: "BLAST pairwise"}, #{value: "5", desc: "BLAST XML"}, #{value: "6", desc: "BLAST tabular"}, #{value: "100", desc: "DIAMOND alignment archive (DAA)"}, #{value: "101", desc: "SAM"}, #{value: "102", desc: "taxonomic classification"}, #{value: "103", desc: "PAF"}, #{value: "104", desc: "JSON (flat)"}]'}

def descs(text):
    """[(name, desc)] from a diamond COMMAND help."""
    out = []
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        m = re.match(r"^(--[A-Za-z0-9][\w-]*)\s{2,}(\S.*)$", lines[i]) or re.match(r"^(--[A-Za-z0-9][\w-]*)\s+(\S.*)$", lines[i]) if lines[i].startswith("--") else None
        if m:
            name, d = m.group(1), m.group(2).strip()
            for bad, good, dd in [("--relative-entropy-tolerancetolerance", "--relative-entropy-tolerance", "tolerance for matrix adjust relative entropy"),
                                  ("--query-match-distance-thresholdMatrix", "--query-match-distance-threshold", "matrix adjust threshold"),
                                  ("--short-query-ungapped-bitscoreBit", "--short-query-ungapped-bitscore", "bit score threshold for ungapped alignments for short queries")]:
                if name == bad:
                    name, d = good, dd
            out.append((name, d))
        i += 1
    return out

def enum(desc):
    """The values a description lists: '(a/b/c)', '(none, seg, tantan=default)', '(0=no, 1=yes)'."""
    m = re.search(r"\(([^()]*)\)", desc)
    if not m:
        return None
    body = m.group(1)
    if re.match(r"^default", body) or " " in body.strip() and "," not in body and "/" not in body:
        return None
    parts = [p.strip() for p in re.split(r"[/,]", body)]
    vals = []
    for p in parts:
        p = re.sub(r"=default$", "", p)
        p = p.split("=")[0].strip()
        if not re.match(r"^[\w.-]+$", p):
            return None
        vals.append(p)
    return vals if len(vals) >= 2 else None

def sub_spec(sub):
    text = gen.helptext("diamond=2.2.8", f"diamond {sub}")
    rows = descs(text)
    lines = []
    vals = []
    for name, d in rows:
        d = h.clean(d)
        short = SHORT.get(name)
        names = f"{short}, {name}" if short else name
        arg = "" if name in FLAGS else "VALUE"
        lines.append((names, arg, d))
        if arg:
            v = KIND.get(name, "")
            if name == "--db":
                v = '"files"' if sub == "makedb" else 'k("diamond_db")'
            elif v == "":
                e = enum(d)
                v = "[" + ", ".join('"%s"' % x for x in e) + "]" if e else '"none"'
            elif v is None:
                v = '"files"'
            for n in ([short] if short else []) + [name]:
                vals.append((n, v))
    return lines, vals

out = ['''// DIAMOND, from `diamond COMMAND` (2.2.8). diamond does not say which options
// take a value, so the switches are listed in the generator of this file.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }
''']
out.append('''fn diamond() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: `
            makedb               build a DIAMOND database from a FASTA file
            blastp               align amino acid query sequences against a protein reference database
            blastx               align DNA query sequences against a protein reference database
            cluster              cluster protein sequences
            linclust             cluster protein sequences in linear time
            realign              realign clustered sequences against their centroids
            recluster            recompute the clustering to fix errors
            reassign             reassign clustered sequences to the closest centroid
            view                 view a DIAMOND alignment archive (DAA) file
            merge-daa            merge DAA files
            help                 produce a help message
            version              display the version information
            getseq               retrieve sequences from a DIAMOND database file
            dbinfo               print information about a DIAMOND database file
            test                 run the regression tests
            makeidx              make a database index
            greedy-vertex-cover  compute a greedy vertex cover
            countdistinct        count the distinct sequences in a FASTA file
        `,
        sub_spec: own("diamond:diamond"),
    }
}
''')
cases = []
for sub in SUBS:
    lines, vals = sub_spec(sub)
    if not lines:
        continue
    w = max(len(n) + (len(a) + 1 if a else 0) for n, a, d in lines)
    body = "\n".join("                " + (n + (" " + a if a else "")).ljust(w + 2) + d for n, a, d in lines)
    vtxt, cur = [], "                "
    for n, v in vals:
        e = f'"{n}": {v}, '
        if v.startswith("[#"):
            if cur.strip(): vtxt.append(cur.rstrip()); cur = "                "
            vtxt.append("                " + e.rstrip()); continue
        if len(cur) + len(e) > 118:
            vtxt.append(cur.rstrip()); cur = "                "
        cur += e
    if cur.strip(): vtxt.append(cur.rstrip())
    args = 'args: ["none"]'
    cases.append(f'''        "{sub}" => #{{
            opts: `
{body}
            `,
            values: #{{
{chr(10).join(vtxt)}
            }},
            {args},
        }},''')
out.append("fn diamond_sub(sub) {\n    switch sub {\n" + "\n".join(cases) + "\n        _ => (),\n    }\n}\n")
out.append('''fn spec(cmd) {
    switch cmd {
        "diamond" => diamond(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "diamond" => diamond_sub(sub),
        _ => (),
    }
}
''')
open(gen.REPO + "/complete/bio/diamond.rhai", "w").write("\n".join(out))
print("ok")
