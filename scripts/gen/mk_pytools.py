"""Generates ../../completion/dev/pytools.rhai for coverage (from its optparse parsers, python_tools.py) and Cython's
cython and cythonize (from their argparse parsers), at pinned versions, with Cython's compiler directives.

    python3 scripts/gen/mk_pytools.py
"""
import re
import gen
from gen import h

CHAN = "-c conda-forge"
COVERAGE, CYTHON = "coverage=7.17.0", "cython=3.3.0"
K = lambda n: f'own("kinds:{n}")'
NONE, FILES, DIRS = '"none"', '"files"', '"dirs"'
lst = lambda xs: "[" + ", ".join(f'"{x}"' for x in xs) + "]"
PY = K("python_files")


def kind_in(table, tool):
    """kind_of for emit_argparse: an option's choices, or its kind in `table` by one of its names, by `COMMAND
    NAME` or NAME (else the generator stops)."""
    def kind_of(cmd, names, mv, choices):
        if choices:
            return lst(choices)
        for k in [f"{cmd} {n}".strip() for n in names] + names:
            if k in table:
                return table[k]
        raise SystemExit(f"mk_pytools.py: no kind for {tool} {cmd} {names}: add it to the table")
    return kind_of


def listed(help_text, values):
    """`values`, after checking that the help text names each (so that a new version's are looked at)."""
    for v in values:
        if not re.search(rf"\b{re.escape(v)}\b", help_text, re.I):
            raise SystemExit(f"mk_pytools.py: {v} is not in the help any more: {help_text}")
    return values


# coverage COMMAND [OPTIONS] [ARGS]: the commands' descriptions are those of `coverage help`.
cov = gen.dump(COVERAGE, "python_tools.py", "coverage", CHAN)
top = gen.helptext(COVERAGE, "coverage help", CHAN)
helps = dict(re.findall(r"^    (\w+) +(.*)$", top.split("Commands:")[1], re.M))
by_name = {c["name"]: c for c in cov}
opt = lambda cmd, name: next(a for a in by_name[cmd]["actions"] if name in a["names"])
CONCURRENCY = re.search(r"Valid values are: (.*?), or a comma-list",
                        " ".join(opt("run", "--concurrency")["help"].split())).group(1).split(", ")
C_KINDS = {
    "--data-file": FILES, "--rcfile": FILES, "-d": DIRS, "--include": NONE, "--omit": NONE, "--debug": NONE,
    "--contexts": NONE, "--fail-under": NONE, "--precision": NONE, "--title": NONE, "-o": FILES,
    "--format": lst(listed(opt("report", "--format")["help"], ["text", "markdown", "total"])),
    "--sort": lst(listed(opt("report", "--sort")["help"], ["name", "stmts", "miss", "branch", "brpart", "cover"])),
    "--concurrency": 'own("pytools:concurrency")', "--context": NONE, "--source": DIRS,
}
C_DESC = {
    "--include": "only the files whose paths match these patterns (comma-separated, shell-style)",
    "--omit": "omit the files whose paths match these patterns (comma-separated, shell-style)",
    "--concurrency": "measure code that uses these concurrency libraries (comma-separated)",
    "--debug": "debug options (comma-separated)",
    "--fail-under": "exit with 2 if the total coverage is less than MIN",
    "--contexts": "only the lines covered in these contexts (comma-separated regular expressions)",
    "--source": "the directories or importable names of the code to measure (comma-separated)",
    "--rcfile": "the configuration file to read",
    "-m": "the program is a module, to run as python -m does",
    "-p": "add a unique suffix to the data file's name (for the data of several processes)",
}
# The topics of `coverage debug`, from its description (`'data [filenames]' to summarize data files.`).
topics = re.findall(r"'(\w+)[^']*' to ([^.]*)\.", " ".join(by_name["debug"]["description"].split()))
C_ARGS = {
    "annotate": [PY], "html": [PY], "json": [PY], "lcov": [PY], "report": [PY], "xml": [PY], "combine": [FILES],
    "debug": ['own("pytools:debug_topics")', FILES], "erase": [NONE], "help": [lst(c["name"] for c in cov)],
    "run": [PY, FILES],
}
tree = []
for c in cov:
    for a in c["actions"]:
        d = next((C_DESC[n] for n in a["names"] if n in C_DESC), None)
        if d:
            a["help"] = d
    tree.append(dict(name=c["name"], aliases=[], help=helps[c["name"]], hidden=False, commands=[],
                     actions=[a for a in c["actions"] if not a["hidden"]]))
c_body = gen.emit_tree(tree, kind_in(C_KINDS, "coverage"), lambda cmd, pos: C_ARGS[cmd], 8,
                       extra=lambda cmd: 'args_if: #{"-m": ["dev:python_modules", "files"], '
                                         '"--module": ["dev:python_modules", "files"]},' if cmd == "run" else None)

# cython [OPTIONS] SOURCE... and cythonize [OPTIONS] SOURCE...
DIRECTIVES = 'own("pytools:directives")'
X_KINDS = {
    "-I": DIRS, "-o": FILES, "--cleanup": NONE, "-w": DIRS, "--gdb-outdir": DIRS, "--annotate-coverage": FILES,
    "--embed": NONE, "--embed-modules": NONE, "-X": DIRECTIVES, "-E": NONE, "--module-name": NONE, "--shared": NONE,
    "--generate-shared": FILES, "-s": NONE, "-x": NONE, "--timeit": NONE, "--setup": NONE, "-j": NONE,
}
X_DESC = {
    "--embed": "generate a main() function (or NAME()) that embeds the Python interpreter",
    "--embed-modules": "the modules to embed with --embed (comma-separated)",
    "-X": "override compiler directives (NAME=VALUE, comma-separated)",
    "-E": "set compile-time constants, as DEF would (NAME=VALUE, comma-separated)",
    "--cleanup": "release interned objects at exit, for memory debugging (LEVEL: how far; 0: nothing)",
    "-s": "set an option of cythonize (NAME=VALUE)",
    "-p": "embed the positions of the definitions in the Cython files in their docstrings",
    "--annotate-coverage": "annotate, with the coverage of the XML report FILE",
}
# The names of values that argparse makes from their `dest` (INCLUDE_PATH).
METAVARS = {
    "-I": "DIR", "-o": "FILE", "--cleanup": "LEVEL", "-w": "DIR", "--gdb-outdir": "DIR", "--annotate-coverage": "FILE",
    "--embed-modules": "MODULES", "--module-name": "NAME", "--shared": "MODULE", "--generate-shared": "FILE",
}


def cython_actions(actions):
    out = []
    for a in actions:
        if a["positional"] or a["hidden"]:
            continue
        if a["names"] == ["--embed"]:
            a.update(flag=False, nargs="?", metavar="NAME")    # `--embed=NAME`, which cython reads itself
        d = next((X_DESC[n] for n in a["names"] if n in X_DESC), None)
        if d:
            a["help"] = d
        a["metavar"] = next((METAVARS[n] for n in a["names"] if n in METAVARS), a["metavar"])
        out.append(a)
    return out


x_kind = kind_in(X_KINDS, "cython")
SOURCES = K("cython_sources")
cython_body = gen.emit_argparse(
    cython_actions(gen.argparse_dump(CYTHON, "Cython.Compiler.CmdLine", "create_cython_argparser", CHAN)),
    lambda n, mv, ch: x_kind("", n, mv, ch), 12, f"        args: [{SOURCES}],")
cythonize_body = gen.emit_argparse(
    cython_actions(gen.argparse_dump(CYTHON, "Cython.Build.Cythonize", "create_args_parser", CHAN)),
    lambda n, mv, ch: x_kind("", n, mv, ch), 12, f"        args: [{SOURCES}],")
directives = gen.dump(CYTHON, "python_tools.py", "cython_directives", CHAN)
d_rows = "\n".join(f'        ["{n}", {lst(v)}],' for n, v in directives)

text = f"""// Python tools: coverage 7.17.0 (from its optparse parsers) and Cython 3.3.0's cython and cythonize (from their
// argparse parsers), with Cython's compiler directives for `-X`. Generated by scripts/gen/mk_pytools.py.
import "../extra-lib/text" as lib_text;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

// coverage COMMAND [OPTIONS] [ARGS]
fn coverage() {{
    #{{
        opts: `
            --version   show the version
            -h, --help  show help
        `,
{c_body}
    }}
}}

// cython [OPTIONS] SOURCE...
fn cython() {{
    #{{
{cython_body}
    }}
}}

// cythonize [OPTIONS] SOURCE...
fn cythonize() {{
    #{{
{cythonize_body}
    }}
}}

fn spec(cmd) {{
    switch cmd {{
        "coverage" => coverage(),
        "cython" => cython(),
        "cythonize" => cythonize(),
        _ => #{{}},
    }}
}}

// Cython's compiler directives that a command line can set: [NAME, VALUES] (no values: any).
fn directive_list() {{
    [
{d_rows}
    ]
}}

// `-X NAME=VALUE,...`: the names of the directives, and after `NAME=`, its values.
fn directives(cur) {{
    let k = lib_text::last_of(cur, [',']);
    let w = cur.sub_string(k + 1);
    let eq = w.index_of("=");
    let out = [];
    for d in directive_list() {{
        if eq < 0 {{
            out.push(#{{value: d[0] + "=", suffix: ""}});
        }} else if d[0] == w.sub_string(0, eq) {{
            out = d[1];
        }}
    }}
    #{{prefix: cur.sub_string(0, k + 1 + if eq < 0 {{ 0 }} else {{ eq + 1 }}), candidates: out}}
}}

fn kind(name, cur, words) {{
    switch name {{
        "directives" => directives(cur),
        "concurrency" => lib_text::comma_list(cur, {lst(CONCURRENCY)}),
        "debug_topics" => [
{chr(10).join(f'            #{{value: "{t}", desc: "{d}"}},' for t, d in topics)}
        ],
        _ => throw `unknown kind: ${{name}}`,
    }}
}}
"""
# (the text is built first: a failure leaves the module as it was)
open(gen.REPO + "/completion/dev/pytools.rhai", "w").write(text)
print("ok")
