"""Generates ../../complete/gui/bandage.rhai for BandageNG, from the `--help` of BandageNG and of its subcommands at a
pinned version (CLI11's format).

    python3 scripts/gen/mk_bandage.py
"""
import re
import gen
import help2opts as h

PKG = "bandage_ng=2026.9.1"
K = lambda n: f'own("kinds:{n}")'
# Descriptions that the help's are too long for.
DESC = {"--scope": "the graph's scope", "--exact": "match node names exactly", "--partial": "match node names partially",
        "--aa": "enable antialiasing", "--noaa": "disable antialiasing", "--double": "draw the graph in double mode",
        "--single": "draw the graph in single mode",
        "--blastp": "parameters of blastn and tblastn, as on their command line (quoted)",
        "--minhitcov": "minimum fraction of a BLAST query covered by the BLAST hits of a query path",
        "--minlendis": "minimum length discrepancy (in bases) between a BLAST query and its path",
        "--maxlendis": "maximum length discrepancy (in bases) between a BLAST query and its path",
        "--jumps-as-links": "treat GFA 1.2 jumps as links"}
# The positional arguments of each subcommand, by their names in its usage.
ARGS = {"graph": K("bandage_graph"), "inputgraph": K("bandage_graph"), "queries": K("fasta"),
        "output_file": '"files"', "outputgraph": '"files"', "output_prefix": '"files"', "layout": '"files"'}


def helptext(sub):
    return gen.helptext(PKG, f"QT_QPA_PLATFORM=offscreen BandageNG {sub} --help".replace("  ", " "))


def parse(text):
    """The options of a CLI11 help: (names, meta, desc, kind) for each, `names` a list."""
    out = []
    lines = text.splitlines()
    for j, line in enumerate(lines):
        m = re.match(r"^ {2,4}(-[-\w,]+(?:\{\w+\})?)", line)
        if not m or lines[j - 1].strip() == "Positionals:":
            continue
        names = re.sub(r"\{\w+\}$", "", m.group(1)).split(",")
        # The description starts in the column of descriptions (after two spaces or more, at column 28 or more), on
        # the line or on the next one; the type and default are before it.
        rest = line[m.end(1):]
        cut = next((k.end() for k in re.finditer(r"\s{2,}(?=\S)", rest) if m.end(1) + k.end() >= 28), None)
        meta, desc = (rest[:cut], rest[cut:]) if cut is not None else (rest, "")
        meta = meta.strip()
        if not desc and j + 1 < len(lines) and re.match(r"^ {20,}\S", lines[j + 1]):
            desc = lines[j + 1].strip()
        if names == ["--helpall"]:
            desc = "show the help of all options"
        out.append((names, meta.strip(), h.clean(desc).rstrip("."), kind(meta)))
    return out


def kind(meta):
    if not meta:
        return None
    m = re.search(r"value in \{([^}]*)\}", meta)
    if m:
        return "[" + ", ".join(f'"{c.split("->")[0]}"' for c in m.group(1).split(",")) + "]"
    if meta.startswith("TEXT:FILE"):
        return '"files"'
    return '"none"'


def first_lower(d):
    return d[:1].lower() + d[1:] if d[:2] != d[:2].upper() else d


def table(opts, indent):
    rows = []
    for names, meta, desc, _ in opts:
        # (A pair `--aa,--noaa` is two flags.)
        groups = [names] if meta or names[0] == "-h" else [[n] for n in names]
        for g in groups:
            argname = ""
            if meta:
                argname = " " + re.split(r"[:\s]", meta)[0] if re.match(r"^[A-Z]", meta) else " VALUE"
            rows.append((", ".join(g) + argname, DESC.get(g[-1], first_lower(desc))))
    w = min(max(len(r[0]) for r in rows), 30)
    return "\n".join(f"{' ' * indent}{n}{' ' * max(2, w + 2 - len(n))}{d}".rstrip() for n, d in rows)


def values(opts, indent):
    items = [(n, k) for names, _, _, k in opts if k for n in names if n.startswith("--")]
    out, line = [], " " * indent
    for n, v in items:
        item = f'"{n}": {v}, '
        if len(line) + len(item) > 116:
            out.append(line.rstrip())
            line = " " * indent
        line += item
    out.append(line.rstrip())
    return "\n".join(out)


main = helptext("")
version = re.search(r"Version: (\S+)", main).group(1)
main = main[main.index("Usage:"):]
common = [o for o in parse(main[main.index("[Option Group"):main.index("Subcommands:")])]
top = [o for o in parse(main[:main.index("[Option Group")]) if o[0] != ["--helpall"]]
commands = re.findall(r"^  (\w+)\s{2,}(.*)$", main[main.index("Subcommands:"):], re.M)

subs = []
for name, _ in commands:
    t = helptext(name)
    usage = re.search(r"Usage: BandageNG \w+ \[OPTIONS\]((?: <\w+>)*)", t).group(1)
    args = [ARGS[a] for a in re.findall(r"<(\w+)>", usage)]
    opts = [o for o in parse(t[t.index("Options:"):]) if o[0] not in (["-h", "--help"], ["--helpall"])]
    body = ""
    if opts:
        body += f"                opts: `\n{table(opts, 20)}\n                `,\n"
        if any(o[3] for o in opts):
            body += f"                values: #{{\n{values(opts, 20)}\n                }},\n"
    body += f"                args: [{', '.join(args + ['\"none\"'])}],\n"
    subs.append(f'            "{name}": #{{\n{body}            }},')

cmd_rows = "\n".join(f"            {n}{' ' * max(2, 14 - len(n))}{first_lower(d)}" for n, d in commands)
open(gen.REPO + "/complete/gui/bandage.rhai", "w").write(f"""// BandageNG {version} (Bioconda's bandage_ng), generated by scripts/gen/mk_bandage.py from its `--help` and that of
// its subcommands. The options of the graph's scope, size, appearance and BLAST search are also taken after a
// subcommand (`BandageNG image graph.gfa out.png --scope aroundnodes --nodes 1`); without a subcommand, BandageNG opens
// its GUI.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

fn spec(cmd) {{
    #{{
        opts: `
{table(top, 12)}
        `,
        common: `
{table(common, 12)}
        `,
        values: #{{
{values(common, 12)}
        }},
        commands: `
{cmd_rows}
        `,
        subs: #{{
{chr(10).join(subs)}
        }},
    }}
}}
""")
print("ok", len(top) + len(common), "options,", len(commands), "subcommands")
