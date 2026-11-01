"""Generates ../../completion/dev/lint.rhai for pylint, flake8 and autopep8, from their argparse parsers at pinned
versions (pylint's with the options of its checkers, flake8's with those of pycodestyle, pyflakes and mccabe), with the
codes they take: pylint's messages, flake8's (pycodestyle's, pyflakes' and mccabe's) and autopep8's fixes
(python_tools.py).

    python3 scripts/gen/mk_lint.py
"""
import re
import gen
from gen import h

CHAN = "-c conda-forge"
PYLINT, FLAKE8, AUTOPEP8 = "pylint=4.1.3", "flake8=7.5.0", "autopep8=2.3.2"
K = lambda n: f'own("kinds:{n}")'
NONE, FILES, DIRS = '"none"', '"files"', '"dirs"'
lst = lambda xs: "[" + ", ".join(f'"{x}"' for x in xs) + "]"
PY = K("python_files")


def kind_in(table, tool):
    """kind_of for emit_argparse: an option's choices, or its kind in `table` (by one of its names, or by its
    metavar), else the generator stops."""
    def kind_of(names, mv, choices):
        choices = [c for c in choices or [] if c]
        if choices:
            return lst(choices)
        for k in names + [mv]:
            if k in table:
                return table[k]
        raise SystemExit(f"mk_lint.py: no kind for {tool} {names} ({mv}): add it to the table")
    return kind_of


# pylint [OPTIONS] MODULE_OR_PACKAGE...
info = gen.dump(PYLINT, "python_tools.py", "pylint_messages", CHAN)
MSGS = 'own("lint:pylint_messages")'
PL_KINDS = {
    # by name
    "--rcfile": FILES, "--output": FILES, "--init-hook": NONE, "--help-msg": MSGS, "--enable": MSGS,
    "--disable": MSGS, "--fail-on": MSGS, "--output-format": lst(info["reporters"]),
    "--confidence": 'own("lint:pylint_confidence")', "--load-plugins": 'own("lint:pylint_extensions")',
    "--source-roots": DIRS, "--spelling-private-dict-file": FILES,
    "--spelling-dict": NONE,    # (the dictionaries of the enchant that is installed: none in pylint's environment)
    # by metavar (as the table below writes it)
    "Y_OR_N": '["y", "n"]', "YN": '["y", "n"]', "FILE.GV": FILES,
}
NONE_METAVARS = {
    "INT", "NUM", "N", "N-PROCESSES", "NUMBER-OF-RESULTS", "SCORE", "REGEXP", "NAMES", "STRING", "TEMPLATE",
    "PYTHON_EXPRESSION", "PY_VERSION", "ARGUMENT_NAMES", "CALLBACKS", "COMMA_SEPARATED_LIST_OF_CLASS_NAMES",
    "COMMA_SEPARATED_LIST", "COMMA_SEPARATED_VALUES", "COMMA_SEPARATED_WORDS", "COMMA-SEPARATED_CLASS_NAMES",
    "DECORATOR_NAMES", "FILE[,FILE...]", "PATTERN[,PATTERN...]", "FUNCTION:SUGGESTION", "LIST_OF_MESSAGES_NAMES",
    "MEMBER_HINT_EDIT_DISTANCE", "MEMBER_HINT_MAX_CHOICES", "MEMBERS_NAMES", "METHOD_NAMES", "MISSING_MEMBER_HINT",
    "MODULE_NAMES", "MODULE:PREFERRED-MODULE", "MODULES", "NAME1:NAME2", "PKG[,PKG]", "PROTECTED_ACCESS_EXCLUSIONS",
    "DICT_NAME",
}
PL_KINDS.update({m: NONE for m in NONE_METAVARS})
PL_DESC = {
    "--output-format": "the output format (a reporter, or a comma-separated list of FORMAT:FILE)",
    "--enable": "enable the messages, categories or checkers MSG_IDS (comma-separated)",
    "--disable": "disable the messages, categories or checkers MSG_IDS (comma-separated; all: every message)",
    "--fail-on": "exit with an error if any of these messages or categories is emitted",
    "--help-msg": "show the help of the messages MSG_IDS and exit",
    "--load-plugins": "the plugins to load (comma-separated module names)",
    "--confidence": "only show warnings with these confidence levels (comma-separated)",
    "--list-msgs": "list pylint's messages, by whether they can be emitted with the configuration",
    "--list-msgs-enabled": "list the messages that are enabled, disabled and that can't be emitted",
    "--errors-only": "show only errors (and fatal messages), and no reports",
    "--from-stdin": "read the module to check from standard input (the argument is its file name)",
}

pylint = gen.argparse_dump(PYLINT, "python_tools.py", "pylint_parser", CHAN, returned=True)
pl = []
for a in pylint:
    if a["positional"] or a["names"] == ["--files"]:    # (the files, which can also be given without it)
        continue
    if a["metavar"] == "" and not a["flag"]:
        a["flag"] = True    # a flag that pylint reads before argparse does (--verbose)
    a["choices"] = [c for c in a["choices"] or [] if c] or None    # (`--expected-line-ending-format ''`: any)
    if a["choices"] and " " in (a["metavar"] or ""):
        a["metavar"] = None    # `<old (%) or new ({)>`: the choices
    if a["metavar"]:
        a["metavar"] = re.sub(r"\s+", "_", a["metavar"].replace("<", "").replace(">", "")).upper()
    elif not a["choices"] and not a["flag"]:
        a["metavar"] = {"--help-msg": "MSG_IDS", "--init-hook": "CODE"}.get(a["names"][0], "FILE")
    a["names"] = sorted(a["names"], key=lambda n: (n.startswith("--"), n))
    d = PL_DESC.get(a["names"][-1])
    if d:
        a["help"] = d
    elif a["help"]:
        a["help"] = a["help"].replace("e.g.", "e.g").replace("i.e.", "i.e")
    pl.append(a)
gen.name_choices(pl)
pl_body = gen.emit_argparse(pl, kind_in(PL_KINDS, "pylint"), 12, f"        args: [{PY}],")

CATEGORIES = [("C", "convention"), ("R", "refactor"), ("W", "warning"), ("E", "error"), ("F", "fatal"),
              ("I", "informational")]


def text(s):
    """`s` in a Rhai string: `'` for `"`, and a backslash escaped."""
    return s.replace("\\", "\\\\").replace('"', "'").replace("`", "'")


def first_sentence(d):
    return h.clean(" ".join(d.replace("e.g.", "e.g").replace("i.e.", "i.e").split()))


msgs = "\n".join(f'        ["{i}", "{s}", "{text(first_sentence(d))}"],' for i, s, d in info["messages"])

# flake8 [OPTIONS] FILE...
codes = gen.dump(FLAKE8, "python_tools.py", "flake8_codes", CHAN)
# The messages that pycodestyle builds as it runs ("E11%d %s"), or that its source gives in part, as its
# documentation gives them (the generator stops at a code with no message).
PYCODESTYLE = {
    "E111": "indentation is not a multiple of four", "E112": "expected an indented block",
    "E113": "unexpected indentation", "E114": "indentation is not a multiple of four (comment)",
    "E115": "expected an indented block (comment)", "E116": "unexpected indentation (comment)",
    "E121": "continuation line under-indented for hanging indent",
    "E122": "continuation line missing indentation or outdented",
    "E125": "continuation line with same indent as next logical line",
    "E126": "continuation line over-indented for hanging indent",
    "E127": "continuation line over-indented for visual indent",
    "E129": "visually indented line with same indent as next logical line",
    "E131": "continuation line unaligned for hanging indent",
    "E202": "whitespace before ')'", "E203": "whitespace before ':'",
    "E226": "missing whitespace around arithmetic operator",
    "E227": "missing whitespace around bitwise or shift operator", "E228": "missing whitespace around modulo operator",
    "E231": "missing whitespace after ',', ';', or ':'",
    "E711": "comparison to None should be 'if cond is None:'",
    "E712": "comparison to True should be 'if cond is True:' or 'if cond:'",
    "E721": "do not compare types, use isinstance()", "E901": "SyntaxError or IndentationError",
    "E902": "IOError",
}
codes = [(c, PYCODESTYLE.get(c, m)) for c, m in codes]
for c, m in codes:
    if not m:
        raise SystemExit(f"mk_lint.py: no message for {c}: add it to PYCODESTYLE")
CODES = 'own("lint:flake8_codes")'
F_KINDS = {
    "--output-file": FILES, "--append-config": FILES, "--config": FILES, "--enable-extensions": NONE,
    "--require-plugins": NONE, "--exclude": NONE, "--extend-exclude": NONE, "--filename": NONE,
    "--stdin-display-name": NONE, "--format": '["default", "pylint", "quiet-filename", "quiet-nothing"]',
    "--ignore": CODES, "--extend-ignore": CODES, "--select": CODES, "--extend-select": CODES,
    "--per-file-ignores": NONE, "--max-line-length": NONE, "--max-doc-length": NONE, "--indent-size": NONE,
    "-j": '["auto"]', "--max-complexity": NONE, "--builtins": NONE,
}
F_DESC = {
    "--format": "the format of the errors: a formatter, or a %-style format string",
    "--per-file-ignores": "the codes to ignore in files (FILES:CODES ..., as in the configuration)",
    "--select": "report only the codes that these prefixes match (comma-separated)",
    "--extend-select": "add these code prefixes to the default --select (comma-separated)",
    "--ignore": "ignore the codes that these prefixes match (comma-separated)",
    "--extend-ignore": "add these code prefixes to --ignore (comma-separated)",
    "-j": "the number of processes to check files in (auto: one per CPU)",
    "--max-complexity": "the McCabe complexity threshold",
    "--disable-noqa": "report errors on the lines that end in '# noqa' too",
}
flake8 = [a for a in gen.argparse_dump(FLAKE8, "python_tools.py", "flake8_parser", CHAN) if not a["positional"]]
for a in flake8:
    d = next((F_DESC[n] for n in a["names"] if n in F_DESC), None)
    if d:
        a["help"] = d
f_body = gen.emit_argparse(flake8, kind_in(F_KINDS, "flake8"), 12, f"        args: [{PY}],")
PREFIXES = [("E", "pycodestyle errors"), ("W", "pycodestyle warnings"), ("F", "pyflakes"), ("C90", "mccabe")]
f_codes = "\n".join(f'        ["{c}", "{text(m)}"],' for c, m in codes)

# autopep8 [OPTIONS] FILE...
fixes = gen.dump(AUTOPEP8, "python_tools.py", "autopep8_fixes", CHAN)
FIXES = 'own("lint:autopep8_fixes")'
A_KINDS = {
    "--global-config": FILES, "-j": NONE, "-p": NONE, "--exclude": NONE, "--ignore": FIXES, "--select": FIXES,
    "--max-line-length": NONE, "--line-range": NONE,
}
A_DESC = {
    "--ignore": "don't fix these codes (comma-separated prefixes)",
    "--select": "fix only these codes (comma-separated prefixes, such as E4,W)",
    "--exit-code": "exit with 2 if there are differences (and 0 without, 1 on an error)",
    "--line-range": "fix only the errors between the lines LINE and LINE (1 99)",
    "--ignore-local-config": "don't apply the configuration files in the project's root directory",
}
autopep8 = [a for a in gen.argparse_dump(AUTOPEP8, "autopep8", "create_parser", CHAN) if not a["positional"]]
for a in autopep8:
    d = next((A_DESC[n] for n in a["names"] if n in A_DESC), None)
    if d:
        a["help"] = d
a_body = gen.emit_argparse(autopep8, kind_in(A_KINDS, "autopep8"), 12, f"        args: [{PY}],")
# (a fix with no docstring: the message of pycodestyle's code that it fixes)
a_fixes = "\n".join(f'        ["{c}", "{text(first_sentence(m) or dict(codes)[c])}"],' for c, m in fixes)

text = f"""// Python linters: pylint 4.1.3 (with the options of its checkers), flake8 7.5.0 (with those of pycodestyle,
// pyflakes and mccabe) and autopep8 2.3.2, from their argparse parsers, with the codes they take: pylint's messages
// and extensions, the codes of flake8's checkers and autopep8's fixes. Generated by scripts/gen/mk_lint.py.
import "../extra-lib/text" as lib_text;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

// pylint [OPTIONS] MODULE_OR_PACKAGE...
fn pylint() {{
    #{{
{pl_body}
    }}
}}

// flake8 [OPTIONS] FILE...
fn flake8() {{
    #{{
{f_body}
    }}
}}

// autopep8 [OPTIONS] FILE...
fn autopep8() {{
    #{{
{a_body}
    }}
}}

fn spec(cmd) {{
    switch cmd {{
        "pylint" => pylint(),
        "flake8" => flake8(),
        "autopep8" => autopep8(),
        _ => #{{}},
    }}
}}

// pylint's messages: [ID, SYMBOL, DESCRIPTION].
fn messages() {{
    [
{msgs}
    ]
}}

// What pylint's `--enable` and `--disable` take, in a comma-separated list: `all`, the categories and the messages
// by symbol, or, once a category's letter and a digit are typed, by ID.
fn pylint_messages(cur) {{
    let w = cur.sub_string(lib_text::last_of(cur, [',']) + 1);
    let ids = w.len() >= 2 && "CRWEFI".contains(w[0]) && w[1] >= '0' && w[1] <= '9';
    let out = if ids {{ [] }} else {{
        [#{{value: "all", desc: "all messages"}}, {", ".join(f'#{{value: "{c}", desc: "{d}"}}' for c, d in CATEGORIES)}]
    }};
    for m in messages() {{
        out.push(if ids {{ #{{value: m[0], desc: m[1]}} }} else {{ #{{value: m[1], desc: m[0] + ": " + m[2]}} }});
    }}
    lib_text::comma_list(cur, out)
}}

// The codes of flake8's checkers: [CODE, MESSAGE].
fn flake8_code_list() {{
    [
{f_codes}
    ]
}}

// autopep8's fixes: [CODE, DESCRIPTION].
fn autopep8_fix_list() {{
    [
{a_fixes}
    ]
}}

// Codes in a comma-separated list (flake8's `--select`, autopep8's): the prefixes `prefixes`, and, once a digit is
// typed, the codes of `codes` that start with the word.
fn codes(cur, prefixes, list) {{
    let w = cur.sub_string(lib_text::last_of(cur, [',']) + 1);
    let last = if w == "" {{ ' ' }} else {{ w[w.len() - 1] }};
    let out = prefixes;
    if last >= '0' && last <= '9' {{
        for c in list {{
            if c[0].starts_with(w) {{
                out.push(#{{value: c[0], desc: c[1]}});
            }}
        }}
    }}
    lib_text::comma_list(cur, out)
}}

fn kind(name, cur, words) {{
    switch name {{
        "pylint_messages" => pylint_messages(cur),
        "pylint_confidence" => lib_text::comma_list(cur, {lst(info["confidence"])}),
        "pylint_extensions" => lib_text::comma_list(cur, {gen.wrap_list(info["extensions"], 8)}),
        "flake8_codes" => codes(cur, [{", ".join(f'#{{value: "{c}", desc: "{d}"}}' for c, d in PREFIXES)}],
                                flake8_code_list()),
        "autopep8_fixes" => codes(cur, [
            #{{value: "E", desc: "pycodestyle errors"}}, #{{value: "W", desc: "pycodestyle warnings"}},
        ], autopep8_fix_list()),
        _ => throw `unknown kind: ${{name}}`,
    }}
}}
"""
# (the text is built first: a failure leaves the module as it was)
open(gen.REPO + "/completion/dev/lint.rhai", "w").write(text)
print("ok")
