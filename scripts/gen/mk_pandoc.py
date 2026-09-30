"""Generates ../../complete/science/pandoc.rhai for pandoc, from its --help and its man page at a pinned version.

    python3 scripts/gen/mk_pandoc.py

The options come from `pandoc --help` (conda-forge), the descriptions from the man page of the same tag,
which is downloaded from GitHub into $HELP_CACHE.
"""
import os, re, subprocess, sys
import gen
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

VERSION = "3.11"
K = lambda n: f'"@extra-complete/science/kinds:{n}"'
FORMATS_IN, FORMATS_OUT = K("pandoc_input_format"), K("pandoc_output_format")
BY_NAME = {
    "--from": FORMATS_IN, "-f": FORMATS_IN, "--read": FORMATS_IN, "-r": FORMATS_IN,
    "--to": FORMATS_OUT, "-t": FORMATS_OUT, "--write": FORMATS_OUT, "-w": FORMATS_OUT,
    "--print-default-template": FORMATS_OUT, "-D": FORMATS_OUT,
    "--defaults": K("pandoc_defaults"), "-d": K("pandoc_defaults"),
    "--pdf-engine": K("pdf_engine"), "--filter": '"files"', "-F": '"files"', "--lua-filter": K("lua"), "-L": K("lua"),
    "--bibliography": K("bibliography"), "--csl": K("csl"), "--citation-abbreviations": '"files"',
    "--syntax-highlighting": K("pandoc_syntax_highlighting"),
    "--highlight-style": K("pandoc_highlight_style"), "--print-highlight-style": K("pandoc_highlight_style"),
    "--syntax-definition": '"files"', "--metadata-file": '"files"', "--css": '"files"', "-c": '"files"',
    "--list-extensions": K("pandoc_output_format"), "--print-default-data-file": '"none"',
    "--extract-media": '"dirs"', "--resource-path": '"dirs"',
}


def man_descriptions():
    """{option name: first sentence of its description} from the man page of the pinned version."""
    path = os.path.join(gen.CACHE, f"pandoc-{VERSION}.1")
    if not os.path.exists(path):
        url = f"https://raw.githubusercontent.com/jgm/pandoc/{VERSION}/pandoc-cli/man/pandoc.1"
        subprocess.run(["curl", "-fsSL", "--max-time", "120", "-o", path, url], check=True)

    def plain(t):
        t = re.sub(r"\\f\[[A-Z]+\]", "", t)
        t = t.replace("\\-", "-").replace("\\[cq]", "'").replace("\\[oq]", "'").replace("\\[lq]", '"').replace("\\[rq]", '"')
        return t.replace("\\[aq]", "'").replace("\\&", "").replace("\\f", "")
    out = {}
    lines = open(path).read().splitlines()
    for i, l in enumerate(lines):
        if l != ".TP":
            continue
        head = plain(lines[i + 1])
        body = []
        for m in lines[i + 2:]:
            if m.startswith("."):
                break
            body.append(plain(m))
        desc = " ".join(body)
        for name in re.findall(r"(?<![\w-])(--?[A-Za-z][\w-]*)", head):
            out.setdefault(name, desc)
    return out


def clean(d):
    """The first sentence of a description, short, in lower case."""
    d = re.sub(r"\s+", " ", d).strip().rstrip("\\").strip()
    for m in re.finditer(r"\.(?:\s|$)", d):
        head = d[:m.start()]
        if re.search(r"(?:e\.g|i\.e|etc|vs)$", head) or not re.match(r"^\s*[A-Z]|^$", d[m.end():]):
            continue
        d = head
        break
    d = d.rstrip(".").replace("*", "").replace("`", "'").replace("${", "$ {")
    if len(d) > 72:
        d = d[:72].rsplit(" ", 1)[0].rstrip(" ,;:(-")
    if d.count("(") > d.count(")"):
        d = d[:d.rindex("(")].rstrip(" ,;:-")
    if d and d[0].isupper() and not (len(d) > 1 and (d[1].isupper() or d[1].isdigit())):
        d = d[0].lower() + d[1:]
    return d


def parse_help(text):
    """[(names, metavar, values, optional)] from pandoc --help."""
    rows = []
    for line in text.splitlines()[1:]:
        if not line.startswith("  "):
            continue
        names, meta, vals, optional = [], None, None, False
        for tok in re.split(r",\s+|\s{2,}", line.strip()):
            m = re.match(r"^(-{1,2}[A-Za-z][\w-]*)(.*)$", tok)
            if not m:
                # `-f FORMAT`
                m2 = re.match(r"^(-[A-Za-z]) (\S+)$", tok)
                if m2:
                    names.append(m2.group(1))
                    meta = m2.group(2)
                continue
            names.append(m.group(1))
            rest = m.group(2)
            if rest.startswith("[=") or rest.startswith("["):
                inner = rest.strip("[]").lstrip("=")
                if inner in ("true|false", ""):
                    continue            # a switch that may be given true or false
                optional, meta = True, inner
            elif rest.startswith("="):
                meta = rest[1:]
            elif rest.startswith(" "):
                meta = rest.strip()
        if names:
            if meta and "|" in meta and not re.search(r"STYLE|FILE", meta):
                vals = [v for v in meta.split("|") if re.match(r"^\w+$", v)]
            rows.append((names, meta, vals, optional))
    return rows


text = gen.helptext(f"pandoc={VERSION}", "pandoc --help", chan="-c conda-forge")
descs = man_descriptions()
lines, values = [], []
for names, meta, vals, optional in parse_help(text):
    names = sorted(set(names), key=lambda n: (n.startswith("--"), names.index(n)))
    desc = ""
    for n in names[::-1]:
        if n in descs:
            desc = clean(descs[n])
            break
    spec = ", ".join(names)
    if meta:
        if optional:
            spec = ", ".join(names[:-1] + [names[-1] + f"[={meta}]"])
        else:
            spec += " " + meta.split("|")[0].replace("<", "").replace(">", "") if not vals else " VALUE"
    lines.append((spec, desc))
    if meta:
        kind = None
        for n in names:
            kind = kind or BY_NAME.get(n)
        if not kind and vals:
            kind = "[" + ", ".join(f'"{v}"' for v in vals) + "]"
        if not kind:
            m = meta.upper()
            kind = '"dirs"' if re.search(r"DIR|PATH$", m) and "TEMPLATE" not in m else (
                '"files"' if re.search(r"FILE|SCRIPTPATH", m) else '"none"')
        for n in names:
            values.append((n, kind))
    elif names[0] in BY_NAME:
        pass

w = min(max(len(s) for s, _ in lines), 44)
out = ["            " + s + " " * max(2, w + 2 - len(s)) + d for s, d in lines]
vals = ", ".join(f'"{n}": {k}' for n, k in values)
# wrap the values table
wrapped, line = [], "            "
for n, k in values:
    v = f'"{n}": {k}, '
    if len(line) + len(v) > 116:
        wrapped.append(line.rstrip())
        line = "            "
    line += v
wrapped.append(line.rstrip())
body = "\n".join(l.rstrip() for l in out)
open(gen.REPO + "/complete/science/pandoc.rhai", "w").write(f"""// pandoc {VERSION}, from `pandoc --help`, with the descriptions of its man page. The formats are asked of the
// installed pandoc (`--list-input-formats`), so that they follow the version in use.

fn spec() {{
    #{{
        opts: `
{body}
        `,
        values: #{{
{chr(10).join(wrapped)}
        }},
    }}
}}
""")
print("ok", len(lines))
