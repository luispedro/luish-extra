"""Dumps the options of a Python program's argparse parser as JSON, to be run inside its environment:

    python argparse_dump.py MODULE FUNCTION      # FUNCTION() returns the ArgumentParser

For a program that builds its parser in a function (snakemake.cli:get_argument_parser). Prints a list with, for
each action, its option strings, metavar, nargs, choices, help and whether it is a flag.
"""
import argparse, importlib, json, sys

mod, fn = sys.argv[1:3]
parser = getattr(importlib.import_module(mod), fn)()
out = []
for a in parser._actions:
    metavar = list(a.metavar) if isinstance(a.metavar, tuple) else a.metavar
    nargs = a.nargs if a.nargs is None or isinstance(a.nargs, (int, str)) else str(a.nargs)
    out.append(dict(
        names=a.option_strings, dest=a.dest, metavar=metavar, nargs=nargs,
        choices=[str(c) for c in a.choices] if a.choices else None,
        help=None if a.help in (None, argparse.SUPPRESS) else a.help % {"default": a.default, "prog": "prog"}
        if "%(" in a.help else a.help,
        hidden=a.help == argparse.SUPPRESS, flag=a.nargs == 0,
        positional=not a.option_strings))
json.dump(out, sys.stdout)
