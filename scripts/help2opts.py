#!/usr/bin/env python3
"""Draft the `opts:` and `values:` of a spec from a tool's --help text.

    PROG SUB --help 2>&1 </dev/null | scripts/help2opts.py [--indent N]

Prints Rhai for std's option-table format (names, value name, two spaces,
short lowercase description). It is a first draft to read and edit, never
the final spec: continuation lines, defaults and value lists need a human.
Options whose value name looks like a file get "files", the rest "none";
replace those with kinds or lists of values where there are any.
"""
import re, sys

# a line that starts an option: `-x`, `-x, --long ARG`, `--long=ARG`, `-long ARG`
start = re.compile(r"^\s{0,12}(-[A-Za-z0-9@-][^\s,]*(?:(?:,\s*|\s*[/|]\s*)-[A-Za-z0-9@-][^\s,]*)*)(.*)$")


def clean(d):
    d = d.strip().replace("`", "'").replace("${", "$ {")
    m = re.match(r"^(.*?(?<!i\.e)(?<!e\.g)(?<!\bie)(?<!\beg)(?<!etc)(?<!approx)(?<!vs)(?<!resp)[a-z0-9)\]])\.(?:\s|$)", d)
    if m:
        d = m.group(1)
    d = re.sub(r"\s*\([^()]*[<>][^()]*\)\s*$", "", d)
    d = re.sub(r"\s*\[(?:default[^\]]*|[-+0-9.,a-zA-Z_/]*)\]\s*$", "", d)
    d = re.sub(r"\s*\((?:default|by default)[^)]*\)\s*$", "", d, flags=re.I)
    d = d.rstrip(".").strip()
    if len(d) > 90:
        d = d[:90].rsplit(" ", 1)[0].rstrip(" ,;:(-")
    if d.count(")") > d.count("(") and d.endswith(")"):
        d = d[:-1].rstrip()
    if d.count("(") > d.count(")"):
        d = d[:d.rindex("(")].rstrip(" ,;:-")
    if d and d[0].isupper() and not (len(d) > 1 and (d[1].isupper() or d[1].isdigit())):
        d = d[0].lower() + d[1:]
    return d


def is_value_name(t):
    t = t.replace("\x00", "_")
    # FILE, INT, N, STR, <file>, [N], OPT[=VAL], file.fa: not prose
    return bool(re.match(r"^[\[<]?[A-Za-z0-9_.,:|/=\[\]<>*+-]*$", t)) and (
        t.isupper() or t[0] in "[<" or any(c in t for c in "=|_./,[") or t.lower() in
        ("int", "float", "str", "string", "file", "dir", "num", "n", "char", "path", "int,int", "double"))


def parse(text):
    lines = [re.sub(r"^(\s*)(?:Options?|Usage):\s+(-)", lambda m: m.group(1) + " " * 9 + m.group(2), l)
             for l in text.splitlines()]
    opts = []
    i = 0
    while i < len(lines):
        m = start.match(lines[i])
        if not m:
            i += 1
            continue
        indent = len(lines[i]) - len(lines[i].lstrip())
        names, rest = m.group(1), m.group(2).rstrip()
        # `<int or string>`: one value name
        rest = re.sub(r"<[^<>]*>", lambda mm: mm.group(0).replace(" ", "\x00"), rest)
        gap = re.search(r"\s{2,}", rest.strip())
        if gap:
            head, desc = rest.strip()[:gap.start()], rest.strip()[gap.end():]
        else:
            head, desc = rest.strip(), ""
        # words after the names that are prose (not value names) are the description
        toks = head.split()
        k = 0
        while k < len(toks) and is_value_name(toks[k]):
            k += 1
        if k < len(toks):
            desc, head = " ".join(toks[k:]) + (" " + desc if desc else ""), " ".join(toks[:k])
        head = head.replace("\x00", " ")
        desc = desc.replace("\x00", " ").lstrip(": ")
        # continuation lines: deeper than the option, not an option, not blank
        j = i + 1
        extra = []
        while j < len(lines) and len(extra) < 4 and lines[j].strip() and not start.match(lines[j]) \
                and len(lines[j]) - len(lines[j].lstrip()) > indent + 1:
            extra.append(lines[j].strip())
            j += 1
        if not desc and extra:
            desc = extra[0]
        elif desc and extra and not re.search(r"[.!]\s*$", desc):
            desc = desc + " " + " ".join(extra)
        opts.append((names.replace("/", ", "), head.strip(), clean(desc)))
        i += 1

    return opts


def value_kind(arg):
    """The values entry for an option whose value is named `arg`."""
    a = arg.upper()
    if arg in ("<f>", "<F>"):
        return '"files"'
    alts = re.match(r"^\{?([A-Za-z0-9_.+-]+(?:[|,][A-Za-z0-9_.+-]+)+)\}?$", arg)
    if alts and not re.search(r"INT|FLOAT|NUM", a):
        return "[" + ", ".join('"%s"' % v for v in re.split(r"[|,]", alts.group(1))) + "]"
    if re.search(r"DIR|PATH|FOLDER", a):
        return '"dirs"'
    if re.search(r"FILE|FASTA|FASTQ|BAM|VCF|BED|GFF|GTF|\.F|INDEX|DB|PREFIX|OUT", a):
        return '"files"'
    return '"none"'


def emit(opts, indent=12, values=None, tail=""):
    pad = " " * indent
    w = max((len(n) + (len(a) + 1 if a else 0) for n, a, _ in opts), default=0)
    out = [pad[:-4] + "opts: `"]
    for n, a, d in opts:
        spec = (n + (" " + a if a else "")).ljust(w + 2)
        out.append(f"{pad}{spec}{d}".rstrip())
    out.append(pad[:-4] + "`,")
    vals = []
    values = values or {}
    seen = set()
    for n, a, d in opts:
        if not a:
            continue
        kind = value_kind(a.split()[0])
        names = n.replace(",", " ").split()
        # an override on any name of the option applies to all its names
        for name in names:
            if name in values:
                kind = values[name]
        for name in names:
            vals.append(f'"{name}": {kind}')
            seen.add(name)
    for name, kind in values.items():
        if name not in seen:
            vals.append(f'"{name}": {kind}')
    if vals:
        out.append(pad[:-4] + "values: #{")
        line = pad
        for v in vals:
            if len(line) + len(v) + 2 > 116 and line.strip():
                out.append(line.rstrip())
                line = pad
            line += v + ", "
        out.append(line.rstrip())
        out.append(pad[:-4] + "},")
    if tail:
        out.append(tail)
    return "\n".join(out)


if __name__ == "__main__":
    indent = 12
    if "--indent" in sys.argv:
        indent = int(sys.argv[sys.argv.index("--indent") + 1])
    print(emit(parse(sys.stdin.read()), indent))
