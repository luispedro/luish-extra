"""Dumps the commands of a program built with Cleo (poetry) as JSON, to be run inside its environment:

    python cleo_dump.py MODULE CLASS      # CLASS() is the cleo Application

Prints {"options": [...], "commands": {NAME: {"description", "options", "arguments"}}}, where each option has its
name, shortcut, description, whether it takes a value (and whether that value is optional) and whether it is a list,
and each argument its name, description, whether it is required and whether it is a list. The global options are
left out of the commands'.
"""
import importlib, json, sys

mod, cls = sys.argv[1:3]
app = getattr(importlib.import_module(mod), cls)()


def option(o):
    return dict(name=o.name, shortcut=o.shortcut, description=o.description, flag=o.is_flag(),
                optional=not o.is_flag() and not o.requires_value(), list=o.is_list())


def argument(a):
    return dict(name=a.name, description=a.description, required=a.is_required(), list=a.is_list())


glob = [option(o) for o in app.definition.options]
names = {o["name"] for o in glob}
cmds = {}
for name in sorted(app.all()):
    c = app.find(name)
    if c.hidden or name != c.name:
        continue
    cmds[name] = dict(description=c.description,
                      options=[option(o) for o in c.definition.options if o.name not in names],
                      arguments=[argument(a) for a in c.definition.arguments])
json.dump(dict(options=glob, commands=cmds), sys.stdout, indent=1)
