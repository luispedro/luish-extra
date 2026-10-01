"""Generates ../../complete/science/jupyter.rhai for ipython and the Jupyter applications, from their --help
(traitlets: an option is `--name` or `--name=<Type>` at the start of a line, its description and `Choices:` below).

    python3 scripts/gen/mk_jupyter.py
"""
import re
import gen
import help2opts as h

IPYTHON = "ipython=9.9.0"
JUPYTER = "jupyterlab=4.5.2 notebook=7.5.2 nbconvert=7.16.6 jupyter_client=8.8.0 jupyter_server=2.17.0 jupyter_core=5.9.1 ipython"
K = lambda n: f'own("kinds:{n}")'

# what runs, by program: (package, command, kind of the arguments)
PROGS = [
    ("ipython", IPYTHON, "ipython", K("python_script")),
    ("nbconvert", JUPYTER, "jupyter nbconvert", K("notebook")),
    ("lab", JUPYTER, "jupyter lab", K("notebook")),
    ("notebook", JUPYTER, "jupyter notebook", K("notebook")),
    ("server", JUPYTER, "jupyter server", '"dirs"'),
    ("console", JUPYTER, "jupyter console", '"files"'),
    ("execute", JUPYTER, "jupyter execute", K("notebook")),
    ("trust", JUPYTER, "jupyter trust", K("notebook")),
    ("kernelspec", JUPYTER, "jupyter kernelspec", '"files"'),
]
# options whose values the help gives in prose
OVERRIDE = {("ipython", "--colors"): '["nocolor", "neutral", "linux", "lightbg"]',
            ("ipython", "--theme"): '["nocolor", "neutral", "linux", "lightbg"]', ("ipython", "--profile"): '"none"'}


def parse(text):
    lines = text.splitlines()
    rows = []
    i = 0
    while i < len(lines):
        m = re.match(r"^(-{1,2}[A-Za-z][\w-]*)(?:=<([^>]*)>)?$", lines[i])
        if not m:
            i += 1
            continue
        name, typ = m.group(1), m.group(2)
        body = []
        i += 1
        while i < len(lines) and (lines[i].startswith(" ") or lines[i] == ""):
            body.append(lines[i].strip())
            i += 1
        desc = next((b for b in body if b and not b.startswith(("Choices:", "Default:", "Equivalent to:"))), "")
        choices = None
        for b in body:
            c = re.match(r"^Choices:\s*(?:any of\s*)?\[(.*)\]$", b)
            if c:
                choices = [v.strip().strip("'\"") for v in c.group(1).split(", ") if v.strip()]
        if choices is None and typ:
            text_ = " ".join(b for b in body if not b.startswith("Equivalent to:"))
            lst = re.search(r"\[('[^']*'(?:,\s*'[^']*')*)\]", text_)
            if lst:
                choices = [v.strip().strip("'") for v in lst.group(1).split(",")]
        rows.append((name, typ, h.clean(desc).rstrip(" ,;:"), choices))
    return rows


def spec(rows, args, prog, indent=8):
    pad = " " * (indent + 4)
    out = []
    values = []
    for name, typ, desc, choices in rows:
        w = name + (" VALUE" if typ else "")
        out.append(f"{pad}{w}{' ' * max(2, 30 - len(w))}{desc}".rstrip())
        if typ:
            if (prog, name) in OVERRIDE:
                v = OVERRIDE[(prog, name)]
            elif choices:
                v = "[" + ", ".join(f'"{c}"' for c in choices) + "]"
            elif re.search(r"dir", name):
                v = '"dirs"'
            elif re.search(r"(?<!pro)file|path|config", name):
                v = '"files"'
            else:
                v = '"none"'
            values.append((name, v))
    vals = []
    line = pad
    for n, v in values:
        item = f'"{n}": {v}, '
        if len(pad) + len(item) > 116:
            # a long list of values: several lines
            if line.strip():
                vals.append(line.rstrip())
            vals.append(f'{pad}"{n}": [')
            row = pad + "    "
            for it in v[1:-1].split(", "):
                if len(row) + len(it) + 2 > 116:
                    vals.append(row.rstrip())
                    row = pad + "    "
                row += it + ", "
            vals.append(row.rstrip())
            line = pad + "], "
            continue
        if len(line) + len(item) > 116:
            vals.append(line.rstrip())
            line = pad
        line += item
    vals.append(line.rstrip())
    return (" " * indent + "opts: `\n" + "\n".join(out) + "\n" + " " * indent + "`,\n" + " " * indent + "values: #{\n"
            + "\n".join(vals) + "\n" + " " * indent + "},\n" + " " * indent + f"args: [{args}],\n")


text = ['''// ipython and the Jupyter applications, from their `--help` (traitlets; ipython 9.9.0, jupyterlab 4.5.2,
// notebook 7.5.2, nbconvert 7.16.6, jupyter_client 8.8.0, jupyter_server 2.17.0, jupyter_core 5.9.1). They take
// seconds to start, which is why the tables are written out. The options of the classes (`--Application.log_level`)
// are not offered: they are in `--help-all`.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }
''']
names = []
for name, pkg, cmd, args in PROGS:
    rows = parse(gen.helptext(pkg, cmd + " --help"))
    rows = [r for r in rows if r[0] != "--help"]
    if name == "kernelspec":
        rows = []
    text.append(f"fn {name}() {{\n    #{{\n{spec(rows, args, name) if rows else '        args: [' + args + '],' + chr(10)}    }}\n}}\n")
    names.append(name)
text.append("fn sub_spec(name) {\n    switch name {")
for n in names:
    text.append(f'        "{n}" => {n}(),')
text.append("        _ => (),\n    }\n}\n")
open(gen.REPO + "/complete/science/jupyter_specs.rhai", "w").write("\n".join(text))
print("ok", names)
