"""Generates ../../complete/system/borg.rhai for BorgBackup, from its argparse parser (borg_parser.py): the commands
(`key export` is `export` under `key`), their options and arguments, and the options common to all of them.

borgbackup is not in conda-forge, and its PyPI package needs a C toolchain and libacl to build, so this runs the
parser of the installed borg (Debian's borgbackup 1.2.8), with the system's Python.

    python3 scripts/gen/mk_borg.py
"""
import re
import gen

PKG = "borgbackup=1.2.8"
PYTHON = "/usr/bin/python3"
K = lambda n: f'"@extra-complete/system/kinds:{n}"'
NONE, FILES, DIRS = '"none"', '"files"', '"dirs"'

t = gen.argparse_dump(PKG, "borg_parser.py", "parser", tree=True, python=PYTHON)


def fix_help(t, cmd):
    """The help of each action without argparse's markup (``--stats``, **(required)**), or from DESC."""
    for a in t["actions"]:
        d = a["names"] and (DESC.get(f"{cmd} {a['names'][0]}") or DESC.get(a["names"][0]))
        if d:
            a["help"] = d
        elif a["help"]:
            a["help"] = a["help"].replace("``", "").replace("**(required)**", "").strip()
    for c in t["commands"]:
        fix_help(c, (cmd + " " + c["name"]).strip())

# The values of options, by name, and by `COMMAND NAME` where they differ between commands. The generator stops at an
# option that is in neither.
VALUES = {
    "--debug-topic": NONE, "--lock-wait": NONE, "--umask": NONE, "--remote-path": NONE, "--remote-ratelimit": NONE,
    "--upload-ratelimit": NONE, "--remote-buffer": NONE, "--upload-buffer": NONE, "--debug-profile": FILES,
    "--rsh": NONE,
    "--max-duration": NONE, "-P": NONE, "-a": NONE, "--sort-by": '["timestamp", "archive", "name", "id"]', "--first": NONE,
    "--last": NONE, "--threshold": NONE, "--filter": NONE, "--stdin-name": NONE, "--stdin-user": '"users"',
    "--stdin-group": '"groups"', "--stdin-mode": NONE, "--paths-delimiter": NONE, "-e": NONE,
    "--exclude-from": FILES, "--pattern": NONE, "--patterns-from": FILES, "--exclude-if-present": NONE,
    "--files-cache": '["ctime,size,inode", "mtime,size,inode", "ctime,size", "mtime,size", "rechunk,ctime", '
                     '"rechunk,mtime", "size", "disabled"]',
    "--comment": NONE, "--timestamp": NONE, "-c": NONE, "--chunker-params": K("borg_chunker_params"),
    "-C": K("borg_compression"),
    "--segment": NONE, "--offset": NONE, "--tar-filter": '["auto", "gzip", "bzip2", "xz", "lzma", "lz4", "zstd"]',
    "--strip-components": NONE, "--storage-quota": NONE, "--format": NONE,
    "-o": '["versions", "allow_damaged_files", "ignore_permissions", "allow_other", "allow_root"]',
    "--keep-within": NONE, "--keep-last": NONE, "--keep-minutely": NONE, "-H": NONE, "-d": NONE, "-w": NONE,
    "-m": NONE, "-y": NONE, "--target": NONE, "--restrict-to-path": DIRS, "--restrict-to-repository": DIRS,
    "--key-file": FILES,
}

# The kinds of the arguments, by the argument's name (its `dest`), and by `COMMAND DEST`.
ARGS = {
    "location": K("borg_location"), "paths": NONE, "create paths": FILES, "path": FILES,
    "benchmark crud path": DIRS, "name": NONE, "value": NONE, "archives": NONE, "archive2": NONE,
    "tarfile": FILES, "mountpoint": DIRS, "umount mountpoint": K("fuse_mounts"), "wanted": NONE, "id": NONE,
    "ids": NONE, "input": FILES, "output": FILES, "command": '"commands"', "args": FILES,
}

# Descriptions that the first sentence of the help doesn't give well, by option name, or `COMMAND NAME`.
DESC = {
    "--debug-profile": "write an execution profile into FILE",
    "--max-duration": "do only a partial repository check, for at most SECONDS",
    "-x": "stay in the same file system",
    "delete --force": "force the deletion of corrupted archives (twice: even if that fails)",
    "prune --force": "force the pruning of corrupted archives (twice: even if that fails)",
    "upgrade --inplace": "rewrite the repository in place (with no going back to older versions)",
    "-C": "the compression algorithm (see borg help compression)",
    "--recompress": "recompress data chunks according to MODE and --compression",
    "--restrict-to-path": "restrict repository access to PATH (can be repeated)",
    "--epilog-only": "show only the epilog",
    "--usage-only": "show only the usage",
}

# Commands with no help of their own.
HELP = {"help": "show help on a command or a topic"}
TOPICS = ["patterns", "placeholders", "compression"]

fix_help(t, "")
common_names = {n for a in t["actions"] for n in a["names"]}


def kind_of_in(cmd):
    def kind_of(names, mv, choices):
        if choices:
            return "[" + ", ".join(f'"{c}"' for c in choices) + "]"
        v = VALUES.get(f"{cmd} {names[0]}", VALUES.get(names[0]))
        if v is None:
            raise SystemExit(f"mk_borg.py: no values for {cmd} {names}: add them to VALUES")
        return v
    return kind_of


def fields(actions, cmd, pad, args=None):
    """`opts:` and `values:` (none if there are no options, or none that take a value), and `args:`."""
    opts = [a for a in actions if not a["positional"] and not a["hidden"]]
    out = []
    if opts:
        body = gen.emit_argparse(opts, kind_of_in(cmd), len(pad) + 4)
        out.append(re.sub(r"\n *values: #\{\n *\n *\},", "", body))
    if args is not None:
        out.append(f"{pad}args: [{', '.join(args)}],")
    return "\n".join(out)


def arg_kinds(cmd, actions):
    if cmd == "help":
        return ['"@extra-complete/system/borg:topics"']
    kinds = []
    for a in actions:
        if a["positional"]:
            k = ARGS.get(f"{cmd} {a['dest']}", ARGS.get(a["dest"]))
            if k is None:
                raise SystemExit(f"mk_borg.py: no kind for the argument {a['dest']} of {cmd}: add it to ARGS")
            kinds.append(k)
    return kinds or [NONE]


def desc(c):
    d = HELP.get(c["name"]) or gen.h.clean(c["help"] or "")
    return re.sub(r"\s*\((?:debug|not intended for normal use)\)$", "", d)


def emit(cmds, path, pad):
    rows = [(c["name"], desc(c)) for c in cmds]
    w = max(len(n) for n, _ in rows)
    out = [f"{pad}commands: `"] + [f"{pad}    {n}{' ' * (w + 2 - len(n))}{d}" for n, d in rows] + [f"{pad}`,"]
    out.append(f"{pad}subs: #{{")
    for c in cmds:
        cmd = " ".join(path + [c["name"]])
        actions = [a for a in c["actions"] if not set(a["names"]) & common_names]
        body = fields(actions, cmd, pad + "        ", None if c["commands"] else arg_kinds(cmd, actions))
        if c["commands"]:
            body = "\n".join(x for x in [body, emit(c["commands"], path + [c["name"]], pad + "        ")] if x)
        out.append(f'{pad}    "{c["name"]}": #{{\n{body}\n{pad}    }},')
    out.append(f"{pad}}},")
    return "\n".join(out)


words = [f'"{x}"' for x in TOPICS + sorted(c["name"] for c in t["commands"])]
topics, line = [], " " * 8
for w in words:
    if len(line) + len(w) + 2 > 116:
        topics.append(line.rstrip())
        line = " " * 8
    line += w + ", "
topics = "\n".join(topics + [line.rstrip()])
common = [a for a in t["actions"] if a["names"] != ["-V", "--version"]]
top = fields(common, "", " " * 8).replace("opts: `", "common: `", 1)
open(gen.REPO + "/complete/system/borg.rhai", "w").write(f"""// BorgBackup 1.2.8, from its argparse parser (`borg COMMAND --help`): the commands, their options and arguments,
// and the options common to all of them. Repositories are directories or `HOST:PATH`, and archives `REPO::NAME` (or
// `::NAME`, with BORG_REPO). Generated by scripts/gen/mk_borg.py.

fn spec() {{
    #{{
        opts: `
            -V, --version  show version number and exit
        `,
{top}
{emit(t["commands"], [], " " * 8)}
    }}
}}

// What `borg help` shows help on: its topics, and the commands.
fn topics() {{
    [
{topics}
    ]
}}

fn kind(name, cur, words) {{
    switch name {{
        "topics" => topics(),
        _ => throw `unknown kind: ${{name}}`,
    }}
}}
""")
print("ok")
