"""The parameters of STAR, from `STAR --help`, whose format is its own: the name
of a parameter at the start of a line, then its default, then on the next line
`type: description` and, for some, the values it takes as `Value ... meaning`.

    opts, vals = star_params()

`opts` are the lines of an option table (`--name VALUE  description`) and
`vals` the pairs (name, Rhai expression for `values:`).
"""
import re
import gen

FILEISH = {
    "genomeFastaFiles": 'k("fasta")', "readFilesIn": 'k("sequences")', "sjdbGTFfile": 'k("gff")',
    "genomeDir": '"dirs"', "sjdbFileChrStartEnd": '"files"', "outFileNamePrefix": '"files"', "outTmpDir": '"dirs"',
    "readFilesPrefix": '"files"', "genomeChainFiles": '"files"', "inputBAMfile": 'k("bam")',
    "readFilesManifest": '"files"', "parametersFiles": '"files"', "sysShell": '"files"', "soloCBwhitelist": '"files"',
}


def short(d):
    d = d.strip()
    m = re.match(r"^(.*?(?<!e\.g)(?<!i\.e)[a-z0-9)\]])\.(?:\s|$)", d)
    if m:
        d = m.group(1)
    d = re.sub(r"\s+", " ", d).replace("`", "'").rstrip(".")
    if len(d) > 90:
        d = d[:87].rsplit(" ", 1)[0].rstrip(" ,;:(-") + "..."
    if d and d[0].isupper() and not (len(d) > 1 and d[1].isupper()):
        d = d[0].lower() + d[1:]
    return d


def star_params(pkg="star=2.7.11b"):
    t = gen.helptext(pkg, "STAR --version; STAR --help")
    params = []
    cur = None
    for line in t.splitlines():
        if re.match(r"^[A-Za-z][A-Za-z0-9]+\s{2,}\S", line) and not line.startswith(("Usage", "Spliced", "STAR", "For more")):
            cur = {"name": line.split()[0], "type": "", "desc": "", "vals": []}
            params.append(cur)
        elif cur is not None:
            m = re.match(r"^\s{4}(\S[^:]*):\s*(.*)$", line)
            if m and not cur["type"]:
                cur["type"], cur["desc"] = m.group(1).strip(), m.group(2).strip()
                continue
            m = re.match(r"^\s{10,}(\S+)\s+\.\.\.\s+(.*)$", line)
            if m:
                cur["vals"].append((m.group(1), m.group(2).strip()))
                continue
            if not cur["desc"] and line.strip() and cur["type"]:
                cur["desc"] = line.strip()
    opts, vals = [], []
    for p in params:
        n = p["name"]
        opts.append(f"--{n} VALUE  {short(p['desc'])}")
        if n in FILEISH:
            vals.append((n, FILEISH[n]))
        elif p["vals"]:
            items = ", ".join('#{value: "%s", desc: "%s"}' % (v, short(d).replace('"', "'")) for v, d in p["vals"])
            vals.append((n, "[" + items + "]"))
        elif re.search(r"path|file", p["desc"].lower()) and p["type"].startswith("string"):
            vals.append((n, '"files"'))
        else:
            vals.append((n, '"none"'))
    return opts, vals
