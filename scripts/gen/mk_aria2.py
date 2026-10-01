"""Generates ../../complete/science/aria2.rhai for aria2c, from `aria2c --help=#all` at a pinned version.

    python3 scripts/gen/mk_aria2.py
"""
import re
import gen
import help2opts as h

PKG = "aria2=1.37.0"
K = lambda n: f'"@extra-complete/science/kinds:{n}"'
BY_NAME = {"--torrent-file": K("torrent"), "-T": K("torrent"), "--metalink-file": K("metalink"), "-M": K("metalink"),
           "--input-file": '"files"', "-i": '"files"', "--conf-path": '"files"', "--out": '"files"', "-o": '"files"',
           "--dir": '"dirs"', "-d": '"dirs"', "--log": '"files"', "-l": '"files"'}

text = gen.helptext(PKG, "aria2c --help=#all")
blocks = re.split(r"\n(?= -)", text)
rows, values = [], []
for b in blocks:
    lines = b.splitlines()
    m = re.match(r"^ (?:(-\w), )?(--[\w-]+)(?:\[=([^\]]+)\]|=(\S+))?(?:\s+(\S.*))?$", lines[0])
    if not m:
        continue
    short, long_, optional, meta, desc = m.groups()
    if not desc:      # the description starts on the next line
        desc = next((l.strip() for l in lines[1:] if l.strip()), "")
    poss = next((re.sub(r"^\s*Possible Values:\s*", "", l) for l in lines if "Possible Values:" in l), "")
    names = [n for n in (short, long_) if n]
    desc = h.clean(desc).rstrip(" ,;:")
    if optional:
        if optional == "true|false":
            rows.append((", ".join(names[:-1] + [long_ + "[=BOOL]"]), desc))
            values += [(n, '["true", "false"]') for n in names]
            continue
        rows.append((", ".join(names[:-1] + [long_ + f"[={optional}]"]), desc))
        values += [(n, '"none"') for n in names]
        continue
    if not meta:
        rows.append((", ".join(names), desc))
        continue
    rows.append((", ".join(names) + " " + meta, desc))
    kind = next((BY_NAME[n] for n in names if n in BY_NAME), None)
    if not kind:
        items = [t.strip() for t in poss.split(",")]
        if poss.startswith("/path/to/directory"):
            kind = '"dirs"'
        elif poss.startswith("/path/to/file") or poss.startswith("/path/to/command"):
            kind = '"files"'
        elif items and all(re.match(r"^[A-Za-z][\w.-]*$", t) for t in items) and len(items) > 1:
            kind = "[" + ", ".join(f'"{t}"' for t in items) + "]"
        else:
            kind = '"none"'
    values += [(n, kind) for n in names]

w = min(max(len(r[0]) for r in rows), 44)
opts = "\n".join(f"            {n}{' ' * max(2, w + 2 - len(n))}{d}".rstrip() for n, d in rows)
vals, line = [], "            "
for n, v in values:
    item = f'"{n}": {v}, '
    if len(line) + len(item) > 116:
        vals.append(line.rstrip())
        line = "            "
    line += item
vals.append(line.rstrip())
open(gen.REPO + "/complete/science/aria2.rhai", "w").write(f"""// aria2c 1.37.0, from `aria2c --help=#all`. The arguments are URIs, or torrent and metalink files.

fn spec(cmd) {{
    #{{
        opts: `
{opts}
        `,
        values: #{{
{chr(10).join(vals)}
        }},
        args: [{K("aria2_input")}],
    }}
}}
""")
print("ok", len(rows))
