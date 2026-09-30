"""Generates ../../complete/bio/blast.rhai for the BLAST+ programs (blast.rhai), from the --help of the pinned versions.

    python3 scripts/gen/mk_blast.py
"""
import os
import re, sys
import gen, blastparse as bp
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

APPS = ["blastn", "blastp", "blastx", "tblastn", "tblastx", "psiblast", "rpsblast", "rpstblastn", "deltablast",
        "makeblastdb", "blastdbcmd", "blast_formatter", "blastdb_aliastool", "dustmasker", "segmasker",
        "windowmasker", "makeprofiledb", "blastdbcheck"]
OUTFMT = {"0": "pairwise", "1": "query-anchored showing identities", "2": "query-anchored, no identities",
          "3": "flat query-anchored showing identities", "4": "flat query-anchored, no identities", "5": "BLAST XML",
          "6": "tabular", "7": "tabular with comment lines", "8": "seqalign (text ASN.1)", "9": "seqalign (binary ASN.1)",
          "10": "comma-separated values", "11": "BLAST archive (ASN.1)", "12": "seqalign (JSON)",
          "13": "multiple-file BLAST JSON", "14": "multiple-file BLAST XML2", "15": "single-file BLAST JSON",
          "16": "single-file BLAST XML2", "17": "SAM", "18": "organism report", "19": "single-file BLAST tabular",
          "20": "comma-separated values with header lines"}
OV = {"db": 'k("blast_db")', "query": 'k("fasta")', "subject": 'k("fasta")', "in": 'k("fasta")', "out": '"files"',
      "dbtype": '["nucl", "prot"]', "input_type": '["fasta", "blastdb", "asn1_bin", "asn1_txt"]',
      "matrix": '["BLOSUM45", "BLOSUM50", "BLOSUM62", "BLOSUM80", "BLOSUM90", "PAM250", "PAM30", "PAM70"]',
      "comp_based_stats": '["0", "1", "2", "3", "D", "F", "T"]', "taxidlist": '"files"', "negative_taxidlist": '"files"', "gilist": '"files"', "negative_gilist": '"files"',
      "seqidlist": '"files"', "negative_seqidlist": '"files"', "mask_data": '"files"', "gi_mask_name": '"none"',
      "in_pssm": '"files"', "in_msa": '"files"',
      "out_pssm": '"files"', "out_ascii_pssm": '"files"', "phi_pattern": '"files"', "archive": '"files"',
      "entry_batch": '"files"', "logfile": '"files"', "dbdir": '"dirs"', "tmpdir": '"dirs"'}

def sentence(d):
    return bp.sentence(d)

def app_spec(app):
    t = gen.helptext("blast=2.17.0", f"{app} -help")
    opts = bp.parse_blast(t)
    lines = []
    vals = []
    for name, ty, values, d in opts:
        d = sentence(d)
        if name == "outfmt" and app != "blastdbcmd":
            d = "alignment view options (6 is tabular)"
        arg = {"Boolean": "BOOL", "Integer": "INT", "Real": "FLOAT", "Int8": "INT", "String": "STR",
               "File_In": "FILE", "File_Out": "FILE"}.get(ty, ty.upper() if ty else "")
        if ty and ty.startswith("File"):
            arg = "FILE"
        lines.append((f"-{name}", arg, d))
        if name == "outfmt" and app != "blastdbcmd":
            v = "[" + ", ".join('#{value: "%s", desc: "%s"}' % (n, dd) for n, dd in OUTFMT.items()) + "]"
        elif name in OV:
            v = OV[name]
        elif values:
            v = "[" + ", ".join('"%s"' % x for x in values) + "]"
        elif ty == "Boolean":
            v = '["true", "false"]'
        elif ty and ty.startswith("File"):
            v = '"files"'
        elif ty:
            v = '"none"'
        else:
            v = None
        if arg and v:
            vals.append((f"-{name}", v))
    return lines, vals

out = ['''// The NCBI BLAST+ programs, from `PROGRAM -help` (BLAST+ 2.17.0): the options
// of blastn, blastp, blastx, tblastn, tblastx, psiblast, rpsblast, rpstblastn,
// deltablast, makeblastdb, blastdbcmd, blast_formatter, blastdb_aliastool,
// the maskers, makeprofiledb and blastdbcheck.

fn k(name) { "@extra-complete/bio/kinds:" + name }
''']
for app in APPS:
    lines, vals = app_spec(app)
    w = max(len(n) + len(a) + 1 for n, a, d in lines)
    body = "\n".join("            " + (n + (" " + a if a else "")).ljust(w + 2) + d for n, a, d in lines)
    vtxt = []
    cur = "            "
    for n, v in vals:
        e = f'"{n}": {v}, '
        if v.startswith("[#"):
            if cur.strip(): vtxt.append(cur.rstrip()); cur = "            "
            vtxt.append("            " + e.rstrip()); continue
        if len(cur) + len(e) > 118:
            vtxt.append(cur.rstrip()); cur = "            "
        cur += e
    if cur.strip(): vtxt.append(cur.rstrip())
    fn = app.replace("-", "_")
    out.append(f'''fn {fn}() {{
    #{{
        opts: `
{body}
        `,
        values: #{{
{chr(10).join(vtxt)}
        }},
        single_dash: true,
        args: ["none"],
    }}
}}
''')
# update_blastdb.pl
out.append('''fn update_blastdb() {
    #{
        opts: `
            --source LOCATION           where to download the databases from (ncbi, aws or gcp)
            --decompress                decompress the archives and delete them after downloading
            --showall[=FORMAT]          show all the available pre-formatted databases
            --blastdb_version N         the BLAST database version to download (4 or 5)
            --timeout SECONDS           timeout on the connection to NCBI
            --force                     download even if there is already an archive locally
            --verbose                   increase the verbosity
            --quiet                     produce no output
            --force_ftp                 use FTP instead of HTTPS
            --passive                   use passive FTP
            --num_threads N             number of threads to use for the download
            --legacy_exit_code          use the legacy exit codes
            --version                   print the version and exit
            --help                      print the help and exit
        `,
        values: #{
            "--source": ["ncbi", "aws", "gcp"], "--showall": ["tsv", "pretty"], "--blastdb_version": ["4", "5"],
        },
        args: ["none"],
    }
}
''')
out.append('''fn spec(cmd) {
    switch cmd {''')
for app in APPS:
    out.append(f'        "{app}" => {app.replace("-", "_")}(),')
out.append('''        "update_blastdb.pl" => update_blastdb(),
        _ => #{},
    }
}
''')
open(gen.REPO + "/complete/bio/blast.rhai", "w").write("\n".join(out))
print("ok")
