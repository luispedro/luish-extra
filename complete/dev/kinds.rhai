// What the arguments and option values of development tools complete to, named
// `"@extra-complete/dev/kinds:NAME"` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;
import "@extra-complete/extra-lib/files" as lib_files;
import "@extra-complete/extra-lib/text" as lib_text;

// The name a line of Python defines, as `[kind, name]` (kind: "def" or
// "class"), or ().
fn defined(line) {
    let t = line;
    t.trim();
    if t.starts_with("async ") {
        t = t.sub_string(6);
        t.trim();
    }
    for kw in ["def ", "class "] {
        if t.starts_with(kw) {
            let rest = t.sub_string(kw.len());
            rest.trim();
            return [kw.sub_string(0, kw.len() - 1), lib_text::ident(rest)];
        }
    }
    ()
}

// The tests of a Python file (the text `text`) that pytest collects by
// default: the `test*` functions and the `Test*` classes at the top level,
// or, in the class `class` (`A::B` for a nested one), its `test*` methods
// and `Test*` classes.
fn tests_in(text, class) {
    let path = if class == "" { [] } else { class.split("::") };
    let depth = 0;      // how many classes of `path` the line is in
    let levels = [];    // the indentation of the `class` line of each
    let body = -1;      // the indentation of the body of the last one
    let out = [];
    for line in text.split("\n") {
        let t = line;
        t.trim();
        if t == "" || t.starts_with("#") {
            continue;
        }
        let n = lib_text::indent(line);
        while depth > 0 && n <= levels[depth - 1] {
            depth -= 1;
            levels.pop();
            body = -1;
        }
        let d = defined(line);
        if d == () {
            continue;
        }
        if depth < path.len() {
            if d[0] == "class" && d[1] == path[depth] && (if depth == 0 { n == 0 } else { n > levels[depth - 1] }) {
                levels.push(n);
                depth += 1;
            }
            continue;
        }
        if depth > 0 && body < 0 {
            body = n;
        }
        if n != (if depth == 0 { 0 } else { body }) || out.some(|o| o.value == d[1]) {
            continue;
        }
        if d[0] == "def" && d[1].starts_with("test") {
            out.push(#{value: d[1], desc: "test"});
        } else if d[0] == "class" && d[1].starts_with("Test") {
            out.push(#{value: d[1], desc: "class"});
        }
    }
    out
}

// pytest's arguments: test files (`test_*.py`, `*_test.py`; all `.py` files
// if `all_py`) and directories, and, after `FILE::`, the tests in the file
// (`test_x.py::TestY::test_z`).
fn pytest_tests(cur, all_py) {
    let k = cur.index_of("::");
    if k < 0 {
        let r = lib_files::with_suffix(cur, [".py"], ["__pycache__"]);
        if !all_py {
            r.candidates = r.candidates.filter(|c| type_of(c) == "map" || c.starts_with("test_") || c.ends_with("_test.py"));
        }
        return r;
    }
    let path = cur.sub_string(0, k);
    let rest = cur.sub_string(k + 2);
    let text = fs::read_file(std_kinds::tilde(path));
    if text == () {
        return [];
    }
    let j = lib_text::last_index(rest, "::");
    let class = if j < 0 { "" } else { rest.sub_string(0, j) };
    #{prefix: if class == "" { path + "::" } else { path + "::" + class + "::" }, candidates: tests_in(text, class)}
}

// The names of the markers a line of a `markers` setting registers
// (`slow: marks tests as slow`, or the strings of a TOML list), added to
// `out` (which is returned).
fn markers_of(line, toml, out) {
    let entries = [];
    if toml {
        // The quoted strings of the line.
        let q = ();
        let s = "";
        for c in line.chars() {
            if q == () {
                if c == '"' || c == '\'' {
                    q = c;
                    s = "";
                }
            } else if c == q {
                entries.push(s);
                q = ();
            } else {
                s += c;
            }
        }
    } else {
        entries.push(line);
    }
    for e in entries {
        e.trim();
        let name = lib_text::ident(e);
        if name != "" && !out.contains(name) {
            out.push(name);
        }
    }
    out
}

// The markers a pytest configuration file (the text `text`) registers: its
// `markers` setting, an INI one (the lines indented after it) or a TOML
// list.
fn markers_in(text, out) {
    let on = false;
    let toml = false;
    for line in text.split("\n") {
        let t = line;
        t.trim();
        if !on {
            let eq = t.index_of("=");
            if eq > 0 {
                let key = t.sub_string(0, eq);
                key.trim();
                if key == "markers" {
                    let rest = t.sub_string(eq + 1);
                    rest.trim();
                    toml = rest.starts_with("[");
                    on = !toml || !rest.contains("]");
                    if rest != "" {
                        out = markers_of(rest, toml, out);
                    }
                }
            }
            continue;
        }
        if toml {
            let end = t.index_of("]");
            out = markers_of(if end < 0 { t } else { t.sub_string(0, end) }, true, out);
            on = end < 0;
        } else if t != "" && lib_text::indent(line) == 0 {
            on = false;
        } else if t != "" && !t.starts_with("#") {
            out = markers_of(t, false, out);
        }
    }
    out
}

// The markers for `-m`: pytest's own and those the configuration files
// register, and the words of an expression, after the last word of the
// expression being typed (`slow and not ne`).
fn pytest_markers(cur) {
    let out = ["skip", "skipif", "xfail", "parametrize", "usefixtures", "filterwarnings"];
    for f in ["pytest.toml", ".pytest.toml", "pytest.ini", ".pytest.ini", "pyproject.toml", "tox.ini", "setup.cfg"] {
        let p = fs::find_up(f);
        if p != () {
            out = markers_in(fs::read_file(p) ?? "", out);
        }
    }
    let k = lib_text::last_of(cur, [' ', '(']);
    #{prefix: cur.sub_string(0, k + 1), candidates: out + ["not", "and", "or"]}
}

// The Python interpreters in `PATH` (`poetry env use`).
fn pythons(cur) {
    let r = std_kinds::commands(cur);
    if r == () { () } else { r.filter(|c| c.starts_with("python") || c.starts_with("pypy")) }
}

// The nearest pyproject.toml, read (a map of its tables), or an empty map.
fn pyproject() {
    let p = fs::find_up("pyproject.toml");
    if p == () { #{} } else { std_kinds::toml(fs::read_file(p) ?? "") }
}

// The part of the name of a table after `prefix` and before the next `.`
// (`tool.poetry.group.dev.dependencies` gives `dev`), or ().
fn table_part(name, prefix) {
    if !name.starts_with(prefix) {
        return ();
    }
    let rest = name.sub_string(prefix.len());
    let dot = rest.index_of(".");
    if dot == 0 || rest == "" { () } else if dot < 0 { rest } else { rest.sub_string(0, dot) }
}

// The dependency groups of the project: Poetry's and PEP 735's.
fn poetry_groups() {
    let t = pyproject();
    let out = ["main"];
    for name in t.keys() {
        let g = table_part(name, "tool.poetry.group.");
        if g != () && !out.contains(g) {
            out.push(g);
        }
    }
    for g in (t["dependency-groups"] ?? #{}).keys() {
        if !out.contains(g) {
            out.push(g);
        }
    }
    out
}

// The extras of the project.
fn poetry_extras() {
    let t = pyproject();
    (t["project.optional-dependencies"] ?? #{}).keys() + (t["tool.poetry.extras"] ?? #{}).keys()
}

// The dependencies of the project: those of `[project]`, of its groups and
// extras, and Poetry's own tables of dependencies.
fn poetry_deps() {
    import "@std/completion/langs" as langs;
    let t = pyproject();
    let out = langs::pyproject_deps();
    for name in t.keys() {
        if name == "tool.poetry.dependencies" || name == "tool.poetry.dev-dependencies"
            || name.starts_with("tool.poetry.group.") && name.ends_with(".dependencies") {
            for d in t[name].keys() {
                if d != "python" && !out.contains(d) {
                    out.push(d);
                }
            }
        }
    }
    out
}

// The packages of the nearest poetry.lock (the `name` of each `[[package]]`).
fn poetry_locked() {
    let p = fs::find_up("poetry.lock");
    if p == () {
        return [];
    }
    let out = [];
    let want = false;
    for line in (fs::read_file(p) ?? "").split("\n") {
        if line.starts_with("[[package]]") {
            want = true;
        } else if want && line.starts_with("name = ") {
            out.push(std_kinds::unquote(line.sub_string(7)));
            want = false;
        }
    }
    out
}

// `poetry run`: the scripts of the project, and the commands in `PATH`.
fn poetry_run(cur) {
    let t = pyproject();
    let out = [];
    for s in (t["project.scripts"] ?? #{}).keys() + (t["tool.poetry.scripts"] ?? #{}).keys() {
        out.push(#{value: s, desc: "script"});
    }
    let r = std_kinds::commands(cur);
    if r == () { () } else { out + r }
}

// The package sources of the project (`[[tool.poetry.source]]`).
fn poetry_sources() {
    let out = [];
    for s in pyproject()["tool.poetry.source"] ?? [] {
        if s.name != () {
            out.push(std_kinds::unquote(s.name));
        }
    }
    out
}

// The repositories of ~/.pypirc (its sections other than `distutils`), and
// PyPI's.
fn pypirc() {
    let out = ["pypi", "testpypi"];
    for line in (fs::read_file(std_kinds::home() + "/.pypirc") ?? "").split("\n") {
        let t = line;
        t.trim();
        if t.starts_with("[") && t.ends_with("]") {
            let name = t.sub_string(1, t.len() - 2);
            name.trim();
            if name != "distutils" && !out.contains(name) {
                out.push(name);
            }
        }
    }
    out
}

// ruff's rule selectors, in a comma-separated list: the prefixes of its
// linters (and categories, `E`, `PLC`), and, once a digit is typed, the
// rules whose codes start with the word, all asked of the installed ruff.
fn ruff_rules(cur) {
    let k = lib_text::last_of(cur, [',']);
    let w = cur.sub_string(k + 1);
    let out = [#{value: "ALL", desc: "all rules"}];
    let r = sh::capture(["ruff", "linter", "--output-format", "json"]);
    if r.status == 0 && r.out.starts_with("[") {
        for l in parse_json(`{"a": ${r.out}}`).a {
            if l.categories != () {
                for c in l.categories {
                    out.push(#{value: l.prefix + c.prefix, desc: `${l.name} (${c.name})`});
                }
            } else {
                out.push(#{value: l.prefix, desc: l.name});
            }
        }
    }
    let last = if w == "" { ' ' } else { w[w.len() - 1] };
    if last >= '0' && last <= '9' {
        // `ruff rule --all` gives each rule's "name", then its "code", on lines of their own.
        let r = sh::capture(["ruff", "rule", "--all", "--output-format", "json"]);
        let name = "";
        for line in r.out.split("\n") {
            if line.starts_with(`    "name": "`) {
                name = line.sub_string(13, line.len() - 15);
            } else if line.starts_with(`    "code": "`) {
                let code = line.sub_string(13, line.len() - 15);
                if code.starts_with(w) {
                    out.push(#{value: code, desc: name});
                }
            }
        }
    }
    #{prefix: cur.sub_string(0, k + 1), candidates: out}
}

// ruff's settings (`ruff config`), and after `SECTION.`, those of the section.
fn ruff_config_keys(cur) {
    let k = lib_text::last_of(cur, ['.']);
    let section = if k < 0 { "" } else { cur.sub_string(0, k) };
    if section != "" && !lib_text::is_name(section) {
        return [];
    }
    let out = [];
    for line in sh::capture(["ruff", "config"] + (if section == "" { [] } else { [section] })).out.split("\n") {
        let t = line;
        t.replace(" (deprecated)", "");
        t.trim();
        if t != "" && lib_text::is_name(t) {
            out.push(t);
        }
    }
    #{prefix: if k < 0 { "" } else { section + "." }, candidates: out}
}

// bat's program: `bat` or, on Debian, `batcat`.
fn bat(words) {
    if words[0] == "batcat" { "batcat" } else { "bat" }
}

// bat's languages (`--list-languages`: `NAME:EXT,EXT,...`), by name and by
// the extensions and file names they are for.
fn bat_languages(words) {
    let out = [];
    for line in sh::capture([bat(words), "--list-languages"]).out.split("\n") {
        let colon = line.index_of(":");
        if colon <= 0 {
            continue;
        }
        let name = line.sub_string(0, colon);
        out.push(#{value: name, desc: "language"});
        for e in line.sub_string(colon + 1).split(",") {
            if e != "" && lib_text::is_name(e) && !e.starts_with(".") {
                out.push(#{value: e, desc: name});
            }
        }
    }
    out
}

// bat's themes (`--list-themes`), and, for `--theme`, `auto`, `dark` and `light`.
fn bat_themes(words, special) {
    let out = if special {
        [
            #{value: "auto", desc: "a dark or light theme, from the terminal's colors"},
            #{value: "auto:always", desc: "auto, even when the output is redirected"},
            #{value: "auto:system", desc: "auto, from the system's preference (macOS)"},
            #{value: "dark", desc: "the theme of --theme-dark"},
            #{value: "light", desc: "the theme of --theme-light"},
        ]
    } else {
        []
    };
    for line in sh::capture([bat(words), "--list-themes", "--color=never"]).out.split("\n") {
        if line != "" {
            out.push(line);
        }
    }
    out
}

fn kind(name, cur, words) {
    switch name {
        "pytest_tests" => pytest_tests(cur, false),
        "pytest_modules" => pytest_tests(cur, true),
        "pytest_markers" => pytest_markers(cur),
        "python_files" => lib_files::with_suffix(cur, [".py", ".pyi"], ["__pycache__"]),
        "ruff_files" => lib_files::with_suffix(cur, [".py", ".pyi", ".ipynb"], ["__pycache__"]),
        "python_dists" => lib_files::with_suffix(cur, [".whl", ".tar.gz", ".zip", ".asc"], ["__pycache__"]),
        "pythons" => pythons(cur),
        "poetry_groups" => poetry_groups(),
        "poetry_extras" => poetry_extras(),
        "poetry_deps" => poetry_deps(),
        "poetry_locked" => poetry_locked(),
        "poetry_run" => poetry_run(cur),
        "poetry_sources" => poetry_sources(),
        "pypirc" => pypirc(),
        "ruff_rules" => ruff_rules(cur),
        "ruff_config_keys" => ruff_config_keys(cur),
        "bat_languages" => bat_languages(words),
        "bat_theme" => bat_themes(words, true),
        "bat_themes" => bat_themes(words, false),
        _ => throw `unknown kind: ${name}`,
    }
}
