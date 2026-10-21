#!/usr/bin/env python3
"""Count what each completion plugin completes, as the table in README.md's "What is supported" shows it.

    scripts/counts.py            # print the table, and the sentence before it
    scripts/counts.py --check    # check that README.md has them (CI runs this)

Commands are those that each plugin's extension.rhai registers a completer for: the keys of `module_of`, the lists
of `for cmd in [...]` and the names given to `sh::completer("NAME", ...)`. Tools are the boxes of
completion-todo.md, ticked and in all, in the sections of each plugin ("Possible later plugins" is left out).
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PLUGINS = ["bio", "science", "gui", "dev", "system", "media", "hpc"]


def commands(plugin):
    with open(os.path.join(ROOT, "completion", plugin, "extension.rhai")) as f:
        src = re.sub(r"//.*", "", f.read())
    names = set()
    table = re.search(r"for m in \[(.*?)\n\] \{", src, re.S)
    if table:
        for group in re.finditer(r'\["\w+", \[(.*?)\]\]', table.group(1), re.S):
            names.update(re.findall(r'"([^"]+)"', group.group(1)))
    for group in re.finditer(r"for cmd in \[(.*?)\] \{", src, re.S):
        names.update(re.findall(r'"([^"]+)"', group.group(1)))
    names.update(re.findall(r'sh::completer\("([^"]+)"', src))
    return names


def tools():
    done, listed = {}, {}
    plugin = None
    with open(os.path.join(ROOT, "completion-todo.md")) as f:
        for line in f:
            if line.startswith("## "):
                m = re.match(r"## `(\w+)`", line)
                plugin = m.group(1) if m else None
            elif plugin and line.startswith("- ["):
                listed[plugin] = listed.get(plugin, 0) + 1
                if line.startswith("- [x]"):
                    done[plugin] = done.get(plugin, 0) + 1
    return done, listed


def render():
    done, listed = tools()
    rows = [(f"`{p}`", str(len(commands(p))), f"{done.get(p, 0)} / {listed.get(p, 0)}") for p in PLUGINS]
    n_commands = sum(int(r[1]) for r in rows)
    n_done, n_listed = sum(done.get(p, 0) for p in PLUGINS), sum(listed.get(p, 0) for p in PLUGINS)
    rows.append(("**Total**", f"**{n_commands}**", f"**{n_done} / {n_listed}**"))
    lines = ["| Plugin    | Commands | Tools done / listed |",
             "|-----------|---------:|--------------------:|"]
    lines += [f"| {a:<9} | {b:>8} | {c:>19} |" for a, b, c in rows]
    sentence = f"{n_commands} commands are completed so far, by {n_done} tools"
    return sentence, "\n".join(lines) + "\n"


def squeeze(text):
    return re.sub(r" +", " ", text)


def main():
    sentence, table = render()
    if sys.argv[1:] != ["--check"]:
        print(sentence)
        print()
        print(table, end="")
        return
    with open(os.path.join(ROOT, "README.md")) as f:
        readme = f.read()
    ok = True
    if sentence not in " ".join(readme.split()):
        print(f"README.md: expected \"{sentence}\"", file=sys.stderr)
        ok = False
    # The table's cells, whatever their padding.
    if squeeze(table) not in squeeze(readme):
        print("README.md: expected the table\n" + table, file=sys.stderr)
        ok = False
    if not ok:
        print("(scripts/counts.py prints them)", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
