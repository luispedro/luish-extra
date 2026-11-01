"""Generates ../../completion/dev/envs.rhai for virtualenv, tox and pipx, from their argparse parsers at pinned
versions: virtualenv's as it builds it for the environment's interpreter, tox's with its subcommands (and the options of
`legacy`, which `tox` runs without one, at the top), pipx's with its subcommands.

    python3 scripts/gen/mk_envs.py
"""
import gen

CHAN = "-c conda-forge"
VIRTUALENV, TOX, PIPX = "virtualenv=21.15.2", "tox=4.67.4", "pipx=1.18.4"
K = lambda n: f'own("kinds:{n}")'
NONE, FILES, DIRS = '"none"', '"files"', '"dirs"'
PYTHONS = K("pythons")
lst = lambda *xs: "[" + ", ".join(f'"{x}"' for x in xs) + "]"


def choices_or(table, tool):
    """kind_of for emit_argparse: an option's choices, or its kind in `table`, by `COMMAND NAME` or by one of its
    names (the generator stops at an option that is in neither)."""
    def kind_of(cmd, names, mv, choices):
        if choices:
            return lst(*choices)
        k = next((table[k] for k in [f"{cmd} {n}".strip() for n in names] + names if k in table), None)
        if k is None:
            raise SystemExit(f"mk_envs.py: no kind for {tool} {cmd} {names}: add it to the table")
        return k
    return kind_of


def args_or(table, tool):
    """args_of for emit_tree: the kinds of the arguments, by COMMAND, `COMMAND DEST` or DEST (none if there are
    none)."""
    def args_of(cmd, positionals):
        if cmd in table:
            return table[cmd]
        kinds = []
        for a in positionals:
            k = table.get(f"{cmd} {a['dest']}", table.get(a["dest"]))
            if k is None:
                raise SystemExit(f"mk_envs.py: no kind for the argument {a['dest']} of {tool} {cmd}: add it to ARGS")
            kinds.append(k)
        return kinds or [NONE]
    return args_of


# virtualenv DEST
ACTIVATORS = gen.dump(VIRTUALENV, "python_tools.py", "virtualenv_activators", CHAN)
V_KINDS = {
    "--app-data": DIRS, "-p": PYTHONS, "--try-first-with": FILES, "--extra-search-dir": DIRS,
    "--activators": 'own("envs:activators")', "--pip": lst("embed", "bundle", "none"),
    "--setuptools": lst("embed", "bundle", "none"), "--prompt": NONE,
}
V_DESC = {
    "-p": "the interpreter to create the environment with (a path, an identifier or a version specifier)",
    "--creator": "create the environment with (builtin: cpython3-posix)",
    "--activators": "the activators to generate (comma-separated; default: all supported)",
    "--prompt": "an alternative prompt prefix for the environment (.: the name of the current directory)",
    "--no-download": "don't download the latest pip/setuptools/wheel from PyPI",
    "--download": "download the latest pip/setuptools/wheel from PyPI",
}
venv = [a for a in gen.argparse_dump(VIRTUALENV, "virtualenv.run", "build_parser", CHAN, returned=True)
        if not a["positional"]]
gen.name_choices(venv)
for a in venv:
    if a["names"] and a["names"][0] in V_DESC:
        a["help"] = V_DESC[a["names"][0]]
v_body = gen.emit_argparse(venv, lambda n, mv, ch: choices_or(V_KINDS, "virtualenv")("", n, mv, ch), 12,
                           "        args: [\"dirs\"],")

# tox [COMMAND]: the options of the parser are those of every command (`common`), and `legacy`'s are also the
# top level's.
ENVS, LABELS = K("tox_envs"), K("tox_labels")
T_KINDS = {
    "--exit-and-dump-after": NONE, "-c": FILES, "--workdir": DIRS, "--root": DIRS, "--no-provision": FILES,
    "-x": NONE, "--result-json": FILES, "--hashseed": NONE, "--discover": FILES, "-e": ENVS, "-m": LABELS,
    "-f": NONE, "--skip-env": NONE, "-s": lst("config", "true", "false"), "--installpkg": K("python_dists"),
    "-p": lst("all", "auto", "0"), "-k": NONE, "-o": FILES, "--devenv": DIRS, "--force-dep": NONE,
}
T_DESC = {
    "-e": "the environments to run (comma-separated; ALL: all of them; default: env_list)",
    "-x": "override a setting of the configuration (testenv:NAME.KEY=VALUE)",
    "-s": "don't fail for missing interpreters",
    "-p": "run the environments in parallel, at most VAL at a time (all, auto: the number of CPUs, 0: not in parallel)",
    "--hashseed": "set PYTHONHASHSEED to SEED (notset: don't set it)",
    "devenv -e": "the environment to set up",
    "exec -e": "the environment to run the command in",
    "--colored": "whether to colour the output",
    "--no-provision": "don't provision tox, fail (and write the provision's metadata as JSON to REQ_JSON)",
    "--exit-and-dump-after": "dump tox's threads after SECONDS and exit (0: never)",
    "-c": "the configuration file or folder of tox",
    "--force-dep": "force a version of a dependency (REQ: a requirement, such as pytest<8)",
    "--installpkg": "install this package instead of packaging the project",
    "--devenv": "set up a development environment at ENVDIR",
}
# The arguments of the commands: after `--`, those of the commands (`run`) or the command to run (`exec`).
T_ARGS = {
    "devenv_path": DIRS, "quickstart_root": DIRS,
    "run": [FILES], "run-parallel": [FILES], "legacy": [FILES], "exec": ['"commands"', FILES],
}


def fix(t, cmd, desc):
    for a in t["actions"]:
        if a["names"]:
            d = next((desc[k] for k in [f"{cmd} {n}".strip() for n in a["names"]] + a["names"] if k in desc), None)
            if d:
                a["help"] = d
    for c in t["commands"]:
        fix(c, (cmd + " " + c["name"]).strip(), desc)


tox = gen.argparse_dump(TOX, "tox.config.cli.parse", "_get_parser_doc", CHAN, tree=True)
fix(tox, "", T_DESC)
gen.name_choices(tox)
t_common = {n for a in tox["actions"] for n in a["names"]}
t_kind = choices_or(T_KINDS, "tox")
legacy = next(c for c in tox["commands"] if c["name"] == "legacy")


def parts(text):
    """The `opts:` table of emit_argparse's output, and the lines of its `values:` map."""
    if "values: #{\n" not in text:
        return text, ""
    opts, values = text.split("\n" + " " * 8 + "values: #{\n", 1)
    return opts, values.rsplit("\n", 1)[0]


legacy_opts = [a for a in legacy["actions"] if a["names"] and not set(a["names"]) & t_common]
t_opts, t_vals = parts(gen.emit_argparse(legacy_opts, lambda n, mv, ch: t_kind("", n, mv, ch), 12))
c_opts, c_vals = parts(gen.emit_argparse(tox["actions"], lambda n, mv, ch: t_kind("", n, mv, ch), 12))
t_body = "\n".join([
    t_opts,
    c_opts.replace("opts: `", "common: `", 1),
    "        values: #{",
    c_vals,
    t_vals,
    "        },",
    gen.emit_tree(tox["commands"], t_kind, args_or(T_ARGS, "tox"), 8, skip=t_common,
                  desc=lambda cmd, d: {"man": "set up tox's man page for the current shell",
                                       "schema": "generate the schema of tox's configuration",
                                       "quickstart": "create a tox config file for a Python project",
                                       "devenv": "set up a development environment"}.get(cmd)
                  or gen.h.clean(d or "")),
    "        args: [\"files\"],",
])

# pipx COMMAND: the options of every command are `common`.
VENVS = K("pipx_venvs")
P_KINDS = {
    "--include-resources-from": NONE, "--suffix": NONE, "--python": PYTHONS, "--preinstall": NONE, "--app": NONE,
    "--lock": FILES, "--index-url": NONE, "--pip-args": NONE, "--cooldown": NONE, "-r": FILES, "--skip": VENVS,
    "--python-args": NONE, "--with": NONE, "--spec": NONE,
}
P_ARGS = {
    "package_spec": FILES, "spec_metadata_file": FILES, "package": VENVS, "packages": VENVS,
    "uninject dependencies": K("pipx_injected"), "inject dependencies": NONE, "manifest": FILES,
    "run": [NONE, FILES], "exec": [VENVS, K("pipx_apps"), FILES], "runpip": [VENVS, FILES],
}
P_DESC = {
    "--python": "the Python to install with (a version, such as 3.12, or a path)",
    "--index-url": "the base URL of the Python package index",
    "--pip-args": "arguments to pass to pip (quoted, as one word)",
    "--cooldown": "ignore files uploaded to the index less than DAYS days ago",
    "-f": "modify an existing environment and the files in PIPX_BIN_DIR and PIPX_MAN_DIR",
    "-U": "upgrade or downgrade an installed package whose version doesn't satisfy the spec",
    "--preinstall": "a package to install into the environment before the main package",
    "-r": "a file of packages to inject (one per line)",
    "ensurepath -f": "add to the shell's config file even if PATH seems to have the directories",
}
pipx = gen.argparse_dump(PIPX, "pipx.main", "get_command_parser", CHAN, tree=True)
fix(pipx, "", P_DESC)
gen.name_choices(pipx)
for c in pipx["commands"]:
    if c["name"] == "run":
        c["help"] = "run an app from a package in a temporary environment"
cmds = [c for c in pipx["commands"] if not c["hidden"]]
p_common = set.intersection(*({n for a in c["actions"] for n in a["names"]} for c in cmds))
common = [a for a in cmds[0]["actions"] if set(a["names"]) & p_common and a["names"] != ["-h", "--help"]]
P_ARGS["help"] = ["[" + ", ".join(f'"{c["name"]}"' for c in cmds) + "]"]
p_body = "\n".join([
    gen.emit_argparse(pipx["actions"], lambda n, mv, ch: None, 12),
    gen.emit_argparse(common + [next(a for a in cmds[0]["actions"] if a["names"] == ["-h", "--help"])],
                      lambda n, mv, ch: None, 12).replace("opts: `", "common: `", 1),
    gen.emit_tree(cmds, choices_or(P_KINDS, "pipx"), args_or(P_ARGS, "pipx"), 8, skip=p_common),
])

text = f"""// Python environments: virtualenv 21.15.2, tox 4.67.4 and pipx 1.18.4, from their argparse parsers. tox's
// environments and labels are read from its configuration, and pipx's environments from its home. Generated by
// scripts/gen/mk_envs.py.

import "../extra-lib/text" as lib_text;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

// virtualenv [OPTIONS] DEST
fn virtualenv() {{
    #{{
{v_body}
    }}
}}

// tox [COMMAND] [OPTIONS] [-- ARGS]: without a command, `legacy`.
fn tox() {{
    #{{
{t_body}
    }}
}}

// pipx COMMAND [OPTIONS] ...
fn pipx() {{
    #{{
{p_body}
    }}
}}

fn spec(cmd) {{
    switch cmd {{
        "virtualenv" => virtualenv(),
        "tox" => tox(),
        "pipx" => pipx(),
        _ => #{{}},
    }}
}}

fn kind(name, cur, words) {{
    switch name {{
        // virtualenv's activation scripts, in a comma-separated list
        "activators" => lib_text::comma_list(cur, {lst(*ACTIVATORS)}),
        _ => throw `unknown kind: ${{name}}`,
    }}
}}
"""
# (the text is built first: a failure leaves the module as it was)
open(gen.REPO + "/completion/dev/envs.rhai", "w").write(text)
print("ok")
