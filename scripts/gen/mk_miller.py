"""Generates ../../complete/science/miller.rhai for Miller (mlr), from `mlr help flags`, `mlr help list-verbs` and
`mlr VERB --help` at a pinned version.

    python3 scripts/gen/mk_miller.py
"""
import re
import gen
import help2opts as h

PKG = "miller=6.22.0"
K = lambda n: f'own("kinds:{n}")'


def value_kind(names, meta):
    m = meta.lower()
    if re.search(r"filename|file name|\{file", m):
        return '"files"'
    if any(n in ("--ifs", "--ofs", "--fs", "--ips", "--ops", "--ps", "--irs", "--ors", "--rs", "--jflatsep", "--oflatsep", "--iflatsep", "--flatsep") for n in names):
        return K("miller_separator")
    return '"none"'


def parse_flags(text, header_re):
    """[(names, meta, desc)] from lines like `--a or -b {arg}   description`, description also on the next lines."""
    out = []
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        l = lines[i]
        m = re.match(r"^(-[-\w]+(?:(?: or |\|)-[-\w]+)*)(?: (\{[^}]*\}))?(?:\s+(.*))?$", l)
        if not m or not header_re(l):
            i += 1
            continue
        names = re.split(r" or |\|", m.group(1))
        desc = (m.group(3) or "").strip()
        i += 1
        while i < len(lines) and lines[i].startswith(" "):
            desc = (desc + " " + lines[i].strip()).strip()
            i += 1
        out.append((names, m.group(2) or "", h.clean(desc).rstrip(" ,;:")))
    return out


def emit(rows, indent):
    pad = " " * (indent + 4)
    lines, values = [], []
    seen = set()
    for names, meta, desc in rows:
        names = [n for n in names if n not in seen]
        if not names:
            continue
        seen.update(names)
        spec = ", ".join(names) + (" VALUE" if meta else "")
        lines.append(f"{pad}{spec}{' ' * max(2, 34 - len(spec))}{desc}".rstrip())
        if meta:
            k = value_kind(names, meta)
            values += [(n, k) for n in names]
    vals, line = [], pad
    for n, v in values:
        item = f'"{n}": {v}, '
        if len(line) + len(item) > 116:
            vals.append(line.rstrip())
            line = pad
        line += item
    vals.append(line.rstrip())
    return " " * indent + "opts: `\n" + "\n".join(lines) + "\n" + " " * indent + "`,\n" + " " * indent + "values: #{\n" + "\n".join(vals) + "\n" + " " * indent + "},\n"


flags = parse_flags(gen.helptext(PKG, "mlr help flags"), lambda l: True)
verbs = gen.helptext(PKG, "mlr help list-verbs").split()
allv = gen.helptext(PKG, "for v in $(mlr help list-verbs); do echo === $v; mlr $v --help; done")
verb_text = {}
for blk in re.split(r"^=== ", allv, flags=re.M)[1:]:
    name, _, body = blk.partition("\n")
    verb_text[name.strip()] = body
desc_of = {}
for name, body in verb_text.items():
    lines = body.splitlines()
    # the first line after `Usage: mlr VERB ...` is the description
    d = next((l.strip() for l in lines[1:] if l.strip() and not l.startswith("Usage")), "")
    desc_of[name] = h.clean(d).rstrip(" ,;:")

out = [f"""// Miller 6.22.0, from `mlr help flags`, `mlr help list-verbs` and `mlr VERB --help`: the main flags before the verb,
// and the flags of each verb. The values of the separator flags are asked of the installed mlr.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

fn spec(cmd) {{
    #{{
        single_dash: true,
        strict_eq: true,
{emit(flags, 8)}        commands: `"""]
for v in verbs:
    out.append(f"            {v}{' ' * max(2, 24 - len(v))}{desc_of.get(v, '')}".rstrip())
out.append("""        `,
        sub_spec: own("miller:verb"),
    }
}

fn sub_spec(name, sub) {
    switch sub {""")
for v in verbs:
    rows = parse_flags(verb_text[v], lambda l: not l.startswith("-h|"))
    rows = [r for r in rows if "-h" not in r[0] and "--help" not in r[0]]
    out.append(f'        "{v}" => #{{\n            single_dash: true,\n            strict_eq: true,\n{emit(rows, 12)}        }},' if rows else f'        "{v}" => #{{}},')
out.append("        _ => (),\n    }\n}\n")
open(gen.REPO + "/complete/science/miller.rhai", "w").write("\n".join(out))
print("ok", len(flags), len(verbs))
