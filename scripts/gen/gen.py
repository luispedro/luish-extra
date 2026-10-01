"""Helpers of the generators: the help text of a tool at a pinned version.

    helptext("bowtie2=2.5.5", "bowtie2 --help")

runs the command in a temporary pixi environment (Bioconda, conda-forge) and
caches its output in $HELP_CACHE (default: a directory in the system temporary
directory), so that a generator can be rerun without the network. Delete the
cache to read the help again.
"""
import os, re, subprocess, sys, hashlib, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
CACHE = os.environ.get("HELP_CACHE", os.path.join(__import__("tempfile").gettempdir(), "luish-extra-help-cache"))
os.makedirs(CACHE, exist_ok=True)

def helptext(pkg, cmd, chan="-c conda-forge -c bioconda"):
    key = hashlib.md5((pkg + "|" + cmd).encode()).hexdigest()
    f = os.path.join(CACHE, key)
    if os.path.exists(f):
        return open(f).read()
    specs = " ".join(f"-s '{p}'" for p in pkg.split())    # several packages: separated by spaces
    r = subprocess.run(f"pixi exec {chan} {specs} -- sh -c '{cmd} 2>&1' </dev/null", shell=True,
                       capture_output=True, text=True, timeout=300)
    open(f, "w").write(r.stdout)
    return r.stdout

def spec_body(pkg, cmd, values=None, args=None, extra="", indent=12, opts_extra="", drop=(), single_dash=False, text=None, edit=None):
    t = text if text is not None else helptext(pkg, cmd)
    opts = h.parse(t)
    opts = [o for o in opts if o[0].split(",")[0].strip() not in drop and not any(x in drop for x in o[0].replace(",", " ").split())]
    if edit:
        opts = edit(opts)
    tail = ""
    if args:
        tail += " " * (indent - 4) + f"args: {args},\n"
    if single_dash:
        tail += " " * (indent - 4) + "single_dash: true,\n"
    tail += extra
    return h.emit(opts, indent, values, tail.rstrip("\n"))


def wrap_list(items, indent):
    """A Rhai list of strings, one row of items per line if it doesn't fit on one."""
    one = "[" + ", ".join(f'"{x}"' for x in items) + "]"
    if indent + len(one) < 112:
        return one
    pad, rows, row = " " * (indent + 4), [], ""
    for it in items:
        if row and len(pad) + len(row) + len(it) + 4 > 116:
            rows.append(pad + row.rstrip())
            row = ""
        row += f'"{it}", '
    rows.append(pad + row.rstrip())
    return "[\n" + "\n".join(rows) + "\n" + " " * indent + "]"


def dump(pkg, script, args, chan="-c conda-forge -c bioconda", python=None):
    """The JSON that scripts/gen/SCRIPT prints with ARGS, run in a temporary environment with the packages `pkg`
    (separated by spaces), or with the interpreter `python` for a program that is not packaged (then `pkg` only names
    the version, for the cache); cached as helptext() is."""
    key = hashlib.md5((pkg + "|" + script + "|" + args).encode()).hexdigest()
    f = os.path.join(CACHE, key)
    if not os.path.exists(f):
        specs = " ".join(f"-s '{p}'" for p in pkg.split())
        run = python if python else f"pixi exec {chan} {specs} -- python"
        # (PYTHONHASHSEED: choices that a program keeps in a set come out in the same order each time.)
        r = subprocess.run(f"PYTHONHASHSEED=0 {run} {HERE}/{script} {args}", shell=True, capture_output=True,
                           text=True, timeout=600, stdin=subprocess.DEVNULL)
        if r.returncode:
            sys.exit(r.stderr)
        try:
            json.loads(r.stdout)
        except ValueError:
            sys.exit(f"{script} {args}: not JSON:\n{r.stdout[:2000]}")
        open(f, "w").write(r.stdout)
    return json.load(open(f))


def argparse_dump(pkg, module, function, chan="-c conda-forge -c bioconda", tree=False, python=None):
    """The options of a Python program's argparse parser (scripts/gen/argparse_dump.py), at a pinned version:
    a list of dicts (names, metavar, nargs, choices, help, flag, positional), cached as helptext() is. With `tree`,
    {"actions": [...], "commands": [...]}, the subcommands with their own actions and subcommands. MODULE can be a
    file of scripts/gen (`pytest_parser.py`), or `bin/PROG`, a Python script of the environment (`bin/k2`). FUNCTION can
    be followed by the words of a command line (`main predict`); see argparse_dump.py."""
    if module.endswith(".py") and not module.startswith("bin/"):
        module = os.path.join(HERE, module)
    return dump(pkg, "argparse_dump.py", ("--tree " if tree else "") + f"{module} {function}", chan, python)


def cleo_dump(pkg, module, cls, chan="-c conda-forge"):
    """The commands of a program built with Cleo (scripts/gen/cleo_dump.py), at a pinned version."""
    return dump(pkg, "cleo_dump.py", f"{module} {cls}", chan)


def emit_argparse(actions, kind_of, indent=12, extra=""):
    """A spec body (`opts`, `values`) from argparse_dump()'s actions. kind_of(names, metavar, choices) gives the
    Rhai expression of an option's values (a list, a kind), or None for filenames; flags have none."""
    pad = " " * indent
    rows, vals = [], []
    for a in actions:
        if not a["names"] or a["hidden"]:
            continue
        names = sorted(a["names"], key=lambda n: (n.startswith("--"), a["names"].index(n)))
        mv = a["metavar"]
        mv = " ".join(mv) if isinstance(mv, list) else mv
        if not mv:
            mv = (a["choices"] and "|".join(a["choices"]) or a["dest"]).upper()
        mv = mv.split()[0]
        desc = h.clean(" ".join((a["help"] or "").replace("e.g.", "e.g").replace("i.e.", "i.e").split()))
        if a["flag"]:
            rows.append((", ".join(names), desc))
            continue
        if a["nargs"] == "?":
            rows.append((", ".join(names[:-1] + [names[-1] + "[=" + mv + "]"]), desc))
        else:
            rows.append((", ".join(names) + " " + mv, desc))
        k = kind_of(names, mv, a["choices"])
        for n in names:
            vals.append(f'"{n}": {k if k else chr(34) + "files" + chr(34)}')
    w = min(max(len(r[0]) for r in rows), 44)
    out = [pad[:-4] + "opts: `"]
    out += [f"{pad}{n}{' ' * max(2, w + 2 - len(n))}{d}".rstrip() for n, d in rows]
    out.append(pad[:-4] + "`,")
    if not vals:
        return "\n".join(out + ([extra] if extra else []))
    out.append(pad[:-4] + "values: #{")
    line = pad
    for v in vals:
        if len(pad) + len(v) + 2 > 116:
            # a long list of values: one per line
            if line.strip():
                out.append(line.rstrip())
            head, items = v.split("[", 1)
            out.append(pad + head + "[")
            items = items.rstrip("]").split(", ")
            row = pad + "    "
            for it in items:
                if len(row) + len(it) + 2 > 116:
                    out.append(row.rstrip())
                    row = pad + "    "
                row += it + ", "
            out.append(row.rstrip())
            line = pad + "], "
            continue
        if len(line) + len(v) + 2 > 116:
            out.append(line.rstrip())
            line = pad
        line += v + ", "
    out.append(line.rstrip())
    out.append(pad[:-4] + "},")
    if extra:
        out.append(extra)
    return "\n".join(out)
