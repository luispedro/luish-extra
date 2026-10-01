"""Generates ../../complete/bio/hmmer.rhai for HMMER (hmmer.rhai), from the --help of the pinned versions.

    python3 scripts/gen/mk_hmmer.py
"""
import os
import sys
import gen
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h
K = lambda n: f'k("{n}")'
HMM, SEQ, MSA = K("hmm"), K("sequences"), K("msa")
MX = '["PAM30", "PAM70", "PAM120", "PAM240", "BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90"]'
AFMT = '["stockholm", "pfam", "a2m", "psiblast", "selex", "afa", "clustal", "clustallike", "phylip", "phylips"]'
SFMT = '["fasta", "embl", "genbank", "ddbj", "uniprot", "ncbi", "daemon", "hmmpgmd"]'
PROGS = [
    ("hmmsearch", f"[{HMM}, {SEQ}]", {"--tformat": SFMT}),
    ("hmmscan", f"[{HMM}, {SEQ}]", {"--tformat": SFMT}),
    ("phmmer", f"[{SEQ}, {SEQ}]", {"--qformat": SFMT, "--tformat": SFMT, "--mx": MX}),
    ("jackhmmer", f"[{SEQ}, {SEQ}]", {"--qformat": SFMT, "--tformat": SFMT, "--mx": MX}),
    ("nhmmer", f"[{HMM}, {SEQ}]", {"--qformat": SFMT, "--tformat": SFMT}),
    ("nhmmscan", f"[{HMM}, {SEQ}]", {"--qformat": SFMT, "--tformat": SFMT}),
    ("hmmbuild", f'["files", {MSA}]', {"--informat": AFMT, "--mx": MX}),
    ("hmmalign", f"[{HMM}, {SEQ}]", {"--informat": AFMT + "", "--outformat": AFMT}),
    ("hmmpress", f"[{HMM}]", {}),
    ("hmmfetch", f'[{HMM}, "none"]', {}),
    ("hmmemit", f"[{HMM}]", {}),
    ("hmmconvert", f"[{HMM}]", {}),
    ("hmmstat", f"[{HMM}]", {}),
]
out = ['''// HMMER 3.4, from `PROGRAM -h`.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }
''']
for prog, args, vals in PROGS:
    t = gen.helptext("hmmer=3.4", f"{prog} -h")
    opts = [o for o in h.parse(t) if o[0].split(",")[0].strip() != "-h"]
    opts.insert(0, ("-h", "", "show brief help on version and usage"))
    v = dict(vals)
    b = h.emit(opts, 12, v, f"        args: {args},")
    out.append(f"fn {prog}() {{\n    #{{\n{b}\n    }}\n}}\n")
out.append("fn spec(cmd) {\n    switch cmd {")
for prog, _, _ in PROGS:
    out.append(f'        "{prog}" => {prog}(),')
out.append("        _ => #{},\n    }\n}\n")
open(gen.REPO + "/complete/bio/hmmer.rhai", "w").write("\n".join(out))
print("ok")
