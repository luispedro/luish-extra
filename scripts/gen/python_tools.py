"""What the generators of dev's Python tools read from the tools themselves, each run in the tool's environment.

For argparse_dump.py, the parsers that need a few lines to get at:

    python argparse_dump.py python_tools.py flake8_parser               # flake8's, with its plugins' options
    python argparse_dump.py --returned python_tools.py pylint_parser    # pylint's, with its checkers' options

As a program, the JSON of one of:

    python python_tools.py coverage                # coverage's commands, their usage and options (optparse)
    python python_tools.py flake8_codes            # [[code, message], ...] of pycodestyle, pyflakes and mccabe
    python python_tools.py autopep8_fixes          # [[code, description], ...]
    python python_tools.py pylint_messages         # {"messages": [[id, symbol, description], ...], "extensions",
                                                   #  "reporters", "confidence": [...]}
    python python_tools.py cython_directives       # [[name, [values]], ...] for `-X NAME=VALUE`
    python python_tools.py virtualenv_activators   # the names of `--activators`
"""
import json, re, sys


def flake8_parser():
    from flake8 import __version__
    from flake8.main import options
    from flake8.options import config, manager
    from flake8.plugins import finder
    cfg, cfg_dir = config.load_config(config=None, extra=[], isolated=True)
    plugin_opts = finder.parse_plugin_options(cfg, cfg_dir, enable_extensions=None, require_plugins=None)
    plugins = finder.load_plugins(finder.find_plugins(cfg, plugin_opts), plugin_opts)
    m = manager.OptionManager(version=__version__, plugin_versions=plugins.versions_str(),
                              parents=[options.stage1_arg_parser()], formatter_names=list(plugins.reporters))
    options.register_default_options(m)
    m.register_plugins(plugins)
    return m.parser


def pylint_linter():
    from pylint.lint import Run
    from pylint.lint.base_options import _make_run_options
    # (the options of `Run` call back into it: one that isn't initialised is enough to register them)
    run = object.__new__(Run)
    linter = Run.LinterClass(_make_run_options(run), option_groups=Run.option_groups)
    linter.load_default_plugins()
    return linter


def pylint_parser():
    return pylint_linter()._arg_parser


def coverage():
    from coverage import cmdline
    out = []
    for name, p in cmdline.COMMANDS.items():
        actions = []
        for o in p.option_list:
            names = o._short_opts + o._long_opts
            actions.append(dict(names=names, dest=o.dest, metavar=o.metavar, nargs=o.nargs if o.takes_value() else 0,
                                choices=list(o.choices) if o.choices else None, help=o.help,
                                hidden=o.help == "SUPPRESS" + "HELP", flag=not o.takes_value(), positional=False))
        out.append(dict(name=name, usage=p.usage, description=p.description, actions=actions))
    return out


def pycodestyle_messages(src):
    """The messages of pycodestyle's checks, in its source `src`: the strings that start with a code (`"E225 missing
    whitespace around operator"`), with their formatted parts as NAME and N."""
    import ast
    out = {}

    def text(node):
        if isinstance(node, ast.Constant) and isinstance(node.value, str):
            return node.value
        if isinstance(node, ast.JoinedStr):
            return "".join(text(v) if isinstance(v, ast.Constant) else "NAME" for v in node.values)
        if isinstance(node, ast.BinOp) and isinstance(node.op, ast.Mod):
            return text(node.left)
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute) and node.func.attr == "format":
            return text(node.func.value)
        return None

    for node in ast.walk(ast.parse(src)):
        t = text(node)
        m = t and re.match(r"([EWC]\d{3}) (.*)", t, re.S)
        if m:
            msg = re.sub(r"%[sr]|\{[^}]*\}", "NAME", m.group(2))
            out.setdefault(m.group(1), " ".join(re.sub(r"%d", "N", msg).split()))
    # the codes of the checks' docstrings (`E111: if a == 0:`), for those whose message is built
    for code in re.findall(r"^\s*([EW]\d{3}):", src, re.M):
        out.setdefault(code, "")
    return out


def flake8_codes():
    import inspect, pycodestyle, pyflakes.messages
    from flake8.plugins.pyflakes import FLAKE8_PYFLAKES_CODES
    codes = pycodestyle_messages(inspect.getsource(pycodestyle))
    for cls, code in FLAKE8_PYFLAKES_CODES.items():
        m = getattr(pyflakes.messages, cls, None)
        if m is not None:
            codes.setdefault(code, re.sub(r"%[rs]", "NAME", m.message))
    codes["C901"] = "function is too complex"
    return sorted(codes.items())


def autopep8_fixes():
    import autopep8
    return sorted(autopep8.supported_fixes())


def pylint_messages():
    import pkgutil, pylint.extensions
    from pylint.interfaces import CONFIDENCE_LEVEL_NAMES
    linter = pylint_linter()
    msgs = sorted([m.msgid, m.symbol, m.description] for m in linter.msgs_store.messages)
    ext = sorted("pylint.extensions." + m.name for m in pkgutil.iter_modules(pylint.extensions.__path__)
                 if not m.name.startswith("_"))
    return dict(messages=msgs, extensions=ext, reporters=sorted(linter._reporters), confidence=CONFIDENCE_LEVEL_NAMES)


def cython_directives():
    from Cython.Compiler import Options
    out = []
    for name, t in Options.directive_types.items():
        if t is bool:
            values = ["True", "False"]
        elif name == "language_level":
            values = ["2", "3", "3str"]
        elif t in (int, str):
            values = []
        elif callable(t) and getattr(t, "__qualname__", "").startswith("one_of."):
            values = [str(v) for v in t.__closure__[0].cell_contents]
        else:
            continue    # a decorator (cfunc), or a value that a command line can't give (locals)
        out.append([name, values])
    return sorted(out)


def virtualenv_activators():
    from importlib.metadata import entry_points
    return sorted(e.name for e in entry_points(group="virtualenv.activate"))


if __name__ == "__main__":
    json.dump(globals()[sys.argv[1]](), sys.stdout)
