"""Dumps the options of a Python program's argparse parser as JSON, to be run inside its environment:

    python argparse_dump.py [--tree] MODULE FUNCTION      # FUNCTION() returns the ArgumentParser

For a program that builds its parser in a function (snakemake.cli:get_argument_parser). MODULE can also be the path
of a `.py` file, for a program whose parser needs a few lines to get at (pytest_parser.py). If FUNCTION returns a
tuple, the parser is its first element (mypy.main:define_options). Prints a list with, for each action, its option
strings, metavar, nargs, choices, help and whether it is a flag.

With `--tree`, for a program with subcommands (borg), prints {"actions": [...], "commands": [...]}, where each command
has its name, aliases, help and the same map for its own actions and subcommands.
"""
import argparse, importlib, importlib.util, json, sys

args = sys.argv[1:]
tree = args[:1] == ["--tree"]
if tree:
    args = args[1:]
mod, fn = args[:2]
if mod.endswith(".py"):
    spec = importlib.util.spec_from_file_location("parser_helper", mod)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
else:
    module = importlib.import_module(mod)
parser = getattr(module, fn)()
if isinstance(parser, tuple):
    parser = parser[0]


def action(a):
    metavar = list(a.metavar) if isinstance(a.metavar, tuple) else a.metavar
    nargs = a.nargs if a.nargs is None or isinstance(a.nargs, (int, str)) else str(a.nargs)
    return dict(
        names=a.option_strings, dest=a.dest, metavar=metavar, nargs=nargs,
        choices=[str(c) for c in a.choices] if a.choices and not isinstance(a, argparse._SubParsersAction) else None,
        help=None if a.help in (None, argparse.SUPPRESS) else a.help % {"default": a.default, "prog": "prog"}
        if "%(" in a.help else a.help,
        hidden=a.help == argparse.SUPPRESS, flag=a.nargs == 0,
        positional=not a.option_strings)


def walk(p):
    out = dict(actions=[], commands=[])
    for a in p._actions:
        if not isinstance(a, argparse._SubParsersAction):
            out["actions"].append(action(a))
            continue
        helps = {c.dest: c.help for c in a._choices_actions}
        seen = {}
        for name, sub in a.choices.items():
            if id(sub) in seen:
                seen[id(sub)]["aliases"].append(name)
                continue
            c = dict(name=name, aliases=[], help=helps.get(name), hidden=name not in helps, **walk(sub))
            seen[id(sub)] = c
            out["commands"].append(c)
    return out


json.dump(walk(parser) if tree else [action(a) for a in parser._actions], sys.stdout)
