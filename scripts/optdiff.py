#!/usr/bin/env python3
"""Compare the options a tool's --help mentions with those its spec completes.

    PROG SUB --help 2>&1 </dev/null | scripts/optdiff.py "PROG SUB"

Reads help text on standard input, asks luish to complete the line given as
the argument followed by `-` and by `--`, and prints the options that only one of them
has: `missing` (in the help, not completed) and `extra` (completed, not in the
help). A spec written from the real --help should print neither, apart from
options that --help leaves out on purpose. This is a development aid, not a
test: run it with the tool at the version named in completion-todo.md.

Environment: LUISH (default: luish), STD_PLUGINS (default: ../luish/luish-std-plugins),
PLUGIN (the plugin to load, default: complete/bio).
"""
import os, re, subprocess, sys, tempfile

here = os.path.dirname(os.path.abspath(__file__))
extra = os.path.dirname(here)
luish = os.environ.get("LUISH", "luish")
std = os.path.abspath(os.environ.get("STD_PLUGINS", os.path.join(extra, "..", "luish", "luish-std-plugins")))
plugin = os.environ.get("PLUGIN", os.path.join(extra, "complete", "bio"))

line = sys.argv[1]
help_text = sys.stdin.read()
# `-x`, `--long`, `--long=VAL`, `-long` (single-dash tools) at the start of a
# word or after `,`, `|`, `[`, `(` or `/`.
found = set(re.findall(r"(?:(?<=[\s,|\[(/])|^)(--?[A-Za-z0-9@][A-Za-z0-9_.@-]*)", help_text, re.M))
found = {o.rstrip(".,:;") for o in found}

with tempfile.TemporaryDirectory() as d:
    os.makedirs(f"{d}/.config/luish")
    with open(f"{d}/.config/luish/config.toml", "w") as f:
        f.write(f'[plugins.available]\nstd = {{ path = "{std}" }}\n')
    script = f"""__luish_internal plugin load "{std}/completion"
__luish_internal plugin load "{plugin}"
__luish_internal complete "{line} -"
echo ====
__luish_internal complete "{line} --"
"""
    with open(f"{d}/t.sh", "w") as f:
        f.write(script)
    r = subprocess.run([luish, "t.sh"], cwd=d, capture_output=True, text=True,
                       env={"PATH": os.environ["PATH"], "HOME": d, "LC_ALL": "C", "STD_PLUGINS": std})
if r.stderr.strip():
    print(r.stderr, file=sys.stderr)
done = set()
for l in r.stdout.splitlines():
    c = l.split("\t")[0].strip()
    if c.startswith("-"):
        done.add(c.rstrip("=").split("=")[0])
ignore = {"-", "--", "--help", "-h", "--version", "-V", "-v"}
missing = sorted(found - done - ignore)
extra_ = sorted(done - found - ignore)
print("missing:", " ".join(missing) or "-")
print("extra:  ", " ".join(extra_) or "-")
