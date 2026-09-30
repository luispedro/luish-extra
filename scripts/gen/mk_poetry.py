"""Generates ../../complete/dev/poetry.rhai for Poetry, from its Cleo application at a pinned version (cleo_dump.py):
the commands (`cache clear` is `clear` under `cache`), their options and arguments, and the global options.

    python3 scripts/gen/mk_poetry.py
"""
import re
import gen
from gen import h

PKG = "poetry=2.5.1"
K = lambda n: f'"@extra-complete/dev/kinds:{n}"'
NONE, FILES, DIRS = '"none"', '"files"', '"dirs"'

d = gen.cleo_dump(PKG, "poetry.console.application", "Application")

# The namespaces, which are not commands themselves.
GROUPS = {
    "cache": "manage Poetry's caches", "debug": "debug Poetry", "env": "manage the project's virtual environments",
    "python": "manage the Python versions Poetry installs", "self": "manage Poetry's own installation",
    "source": "manage the package sources of the project",
}

# The values of options, by name, and by `COMMAND --name` where they differ between commands. The generator stops at
# an option that is in neither.
VALUES = {
    "group": K("poetry_groups"), "with": K("poetry_groups"), "without": K("poetry_groups"), "only": K("poetry_groups"),
    "extras": K("poetry_extras"), "optional": K("poetry_extras"), "source": K("poetry_sources"),
    "python": NONE, "platform": '["linux", "darwin", "win32"]', "markers": NONE, "local-version": NONE,
    "output": DIRS, "config-settings": NONE, "name": NONE, "description": NONE, "author": NONE, "dependency": NONE,
    "dev-dependency": NONE, "license": NONE, "readme": '["md", "rst"]', "repository": NONE, "username": NONE,
    "password": NONE, "cert": FILES, "client-cert": FILES, "dist-dir": DIRS, "implementation": '["cpython", "pypy"]',
    "priority": '["primary", "supplemental", "explicit"]',
    "build --format": '["sdist", "wheel"]', "show --format": '["json", "text"]', "self show --format": '["json", "text"]',
    "project": DIRS, "directory": DIRS,
}

# The arguments of the commands that have some.
ARGS = {
    "add": [NONE], "cache clear": [NONE], "config": ['"@extra-complete/dev/poetry:config_keys"', NONE],
    "debug resolve": [NONE], "env remove": [K("pythons")], "env use": [K("pythons")],
    "help": ['"@extra-complete/dev/poetry:commands"'],
    "list": ["[" + ", ".join(f'"{g}"' for g in GROUPS) + "]"], "new": [DIRS], "python install": [NONE],
    "python list": [NONE], "python remove": [NONE], "remove": [K("poetry_deps")],
    "run": [K("poetry_run"), FILES], "search": [NONE], "self add": [NONE], "self remove": [NONE],
    "self show": [NONE], "self update": [NONE], "show": [K("poetry_locked")], "source add": [NONE],
    "source remove": [K("poetry_sources")], "source show": [K("poetry_sources")], "update": [K("poetry_deps")],
    "version": ['["patch", "minor", "major", "prepatch", "preminor", "premajor", "prerelease"]'],
}


# Descriptions that the first sentence of the help doesn't give well, by option name.
DESC = {
    "verbose": "increase the verbosity of messages (-vv, -vvv: more)",
    "dependency": "package to require, with an optional version constraint",
    "dev-dependency": "package to require for development, with an optional version constraint",
    "why": "show whether packages are direct dependencies or required by others",
    "no-directory": "do not install any directory path dependencies",
    "local": "set or get from the project's local configuration",
    "config-settings": "config settings to pass to the backend (KEY=VALUE)",
}


def desc(s):
    # Cleo's style tags (<info>, <comment>, </>), not <path> or <key>=<value>
    s = re.sub(r"</?(?:info|comment|question|error|b|c1|c2|fg=[^>]*|options=[^>]*)?>", "", s or "").replace("`", "'")
    return h.clean(re.sub(r"\s*\((?:multiple values allowed|shortcut for[^)]*)\)", "", s))


def table(opts, pad):
    rows = []
    for o in opts:
        names = []
        if o["shortcut"]:
            names.append("-" + o["shortcut"].split("|")[0])    # `v|vv|vvv`: -v
        long = "--" + o["name"]
        if o["optional"]:
            long += f"[={o['name'].upper()}]"
        names.append(long)
        spec = ", ".join(names) + ("" if o["flag"] or o["optional"] else " " + o["name"].upper())
        rows.append((spec, DESC.get(o["name"]) or desc(o["description"])))
    w = max(len(r[0]) for r in rows)
    return "\n".join(f"{pad}{n}{' ' * (w + 2 - len(n))}{t}".rstrip() for n, t in rows)


def values(cmd, opts):
    out = []
    for o in opts:
        if o["flag"]:
            continue
        v = VALUES.get(f"{cmd} --{o['name']}", VALUES.get(o["name"]))
        if v is None:
            raise SystemExit(f"mk_poetry.py: no values for {cmd} --{o['name']}: add them to VALUES")
        if o["shortcut"]:
            out.append(f'"-{o["shortcut"].split("|")[0]}": {v}')
        out.append(f'"--{o["name"]}": {v}')
    return out


def wrap(items, pad, width=116):
    lines, line = [], pad
    for it in items:
        if len(line) + len(it) + 2 > width and line.strip():
            lines.append(line.rstrip())
            line = pad
        line += it + ", "
    lines.append(line.rstrip())
    return "\n".join(lines)


# The tree of commands: `self show plugins` is `plugins` under `show` under `self`.
tree = {}
for name, c in d["commands"].items():
    node = tree
    for w in name.split():
        node = node.setdefault(w, {"cmd": None, "path": None, "subs": {}})
        last = node
        node = node["subs"]
    last["cmd"], last["path"] = c, name


def emit(node_subs, cmd, pad):
    """The fields of the spec of a command (`cmd`, or None) with the subcommands `node_subs`, at indentation `pad`."""
    out = []
    if cmd is not None:
        c = d["commands"][cmd]
        if c["options"]:
            out.append(f"{pad}opts: `\n{table(c['options'], pad + '    ')}\n{pad}`,")
            v = values(cmd, c["options"])
            if v:
                out.append(f"{pad}values: #{{\n{wrap(v, pad + '    ')}\n{pad}}},")
        if c["arguments"] and cmd not in ARGS:
            raise SystemExit(f"mk_poetry.py: no kinds for the arguments of {cmd}: add them to ARGS")
        out.append(f"{pad}args: [{', '.join(ARGS.get(cmd, [NONE]))}],")
    if node_subs:
        rows = [(w, desc(n["cmd"]["description"]) if n["cmd"] else GROUPS[w]) for w, n in sorted(node_subs.items())]
        width = max(len(w) for w, _ in rows)
        out.append(f"{pad}commands: `\n" + "\n".join(f"{pad}    {w}{' ' * (width + 2 - len(w))}{t}" for w, t in rows)
                   + f"\n{pad}`,")
        subs = []
        for w, n in sorted(node_subs.items()):
            body = emit(n["subs"], n["path"], pad + "        ")
            subs.append(f'{pad}    "{w}": #{{\n{body}\n{pad}    }},')
        out.append(f"{pad}subs: #{{\n" + "\n".join(subs) + f"\n{pad}}},")
    return "\n".join(out)


pad = " " * 8
top = emit(tree, None, pad)
common = table(d["options"], pad + "    ")
glob_values = wrap(values("", d["options"]), pad + "    ")
# (Not the repositories, tokens and certificates of whoever runs this: their prefixes are added by hand below.)
keys = [line.split(" = ")[0] for line in gen.helptext(PKG, "poetry config --list", "-c conda-forge").splitlines()
        if " = " in line and not line.startswith(("repositories.", "http-basic.", "pypi-token.", "certificates."))]
command_rows = wrap([f'"{c}"' for c in sorted(set(n.split()[0] for n in d["commands"]))], "        ")
key_rows = "\n".join(f'        "{k}",' for k in keys)
open(gen.REPO + "/complete/dev/poetry.rhai", "w").write(f"""// Poetry 2.5.1, from its Cleo application (`poetry list`, `poetry COMMAND --help`): the commands, their options and
// arguments, and the global options. Generated by scripts/gen/mk_poetry.py.

fn spec() {{
    #{{
        common: `
{common}
        `,
        values: #{{
{glob_values}
        }},
{top}
    }}
}}

// The commands, for `poetry help`.
fn commands() {{
    [
{command_rows}
    ]
}}

// The settings of `poetry config`, and the prefixes of those that name a repository.
fn config_keys() {{
    [
{key_rows}
        #{{value: "repositories.", suffix: ""}},
        #{{value: "http-basic.", suffix: ""}},
        #{{value: "pypi-token.", suffix: ""}},
        #{{value: "certificates.", suffix: ""}},
    ]
}}

fn kind(name, cur, words) {{
    switch name {{
        "config_keys" => config_keys(),
        "commands" => commands(),
        _ => throw `unknown kind: ${{name}}`,
    }}
}}
""")
print("ok")
