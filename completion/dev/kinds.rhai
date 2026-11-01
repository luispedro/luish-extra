// What the arguments and option values of development tools complete to, named
// `own("kinds:NAME")` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;
import "../extra-lib/files" as lib_files;
import "../extra-lib/text" as lib_text;

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
    let r = sh::capture_cached(300, ["ruff", "linter", "--output-format", "json"]);
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
        // (The rules are kept, keyed by the text they are read from, as each Tab would read the same text again.)
        let text = sh::capture_cached(300, ["ruff", "rule", "--all", "--output-format", "json"]).out;
        let key = "ruff_rules:" + text;
        for rule in sh::cache_get(key) ?? sh::cache_put(key, 3600, ruff_rule_list(text)) {
            if rule.value.starts_with(w) {
                out.push(rule);
            }
        }
    }
    #{prefix: cur.sub_string(0, k + 1), candidates: out}
}

// The rules of `ruff rule --all` (`text`), as candidates: it gives each rule's "name", then its "code", on lines of
// their own.
fn ruff_rule_list(text) {
    let out = [];
    let name = "";
    for line in text.split("\n") {
        if line.starts_with(`    "name": "`) {
            name = line.sub_string(13, line.len() - 15);
        } else if line.starts_with(`    "code": "`) {
            out.push(#{value: line.sub_string(13, line.len() - 15), desc: name});
        }
    }
    out
}

// ruff's settings (`ruff config`), and after `SECTION.`, those of the section.
fn ruff_config_keys(cur) {
    let k = lib_text::last_of(cur, ['.']);
    let section = if k < 0 { "" } else { cur.sub_string(0, k) };
    if section != "" && !lib_text::is_name(section) {
        return [];
    }
    let out = [];
    let argv = ["ruff", "config"] + (if section == "" { [] } else { [section] });
    for line in sh::capture_cached(300, argv).out.split("\n") {
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
    for line in sh::capture_cached(300, [bat(words), "--list-languages"]).out.split("\n") {
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
    for line in sh::capture_cached(300, [bat(words), "--list-themes", "--color=never"]).out.split("\n") {
        if line != "" {
            out.push(line);
        }
    }
    out
}

// The names of the `.md` files in the directory `dir`, added to `out`.
fn md_names(dir, out) {
    for f in fs::list_dir(dir) ?? [] {
        if f.ends_with(".md") {
            let name = f.sub_string(0, f.len() - 3);
            if !out.contains(name) {
                out.push(name);
            }
        }
    }
    out
}

// The agents of claude's `--agent`: the files of `.claude/agents` in the nearest directory that has one
// (the project's), and of `~/.claude/agents`.
fn claude_agents() {
    let out = [];
    let project = fs::find_up(".claude");
    if project != () {
        out = md_names(project + "/agents", out);
    }
    md_names(std_kinds::home() + "/.claude/agents", out)
}

// The profiles of codex's `--profile`: the `NAME.config.toml` of `$CODEX_HOME` (`~/.codex`), and the
// `[profiles.NAME]` of its `config.toml` that earlier versions read.
fn codex_profiles() {
    let dir = sh::getvar("CODEX_HOME") ?? (std_kinds::home() + "/.codex");
    let out = [];
    for f in fs::list_dir(dir) ?? [] {
        if f.ends_with(".config.toml") {
            out.push(f.sub_string(0, f.len() - 12));
        }
    }
    for line in (fs::read_file(dir + "/config.toml") ?? "").split("\n") {
        let t = line;
        t.trim();
        if t.starts_with("[profiles.") && t.ends_with("]") {
            let name = t.sub_string(10, t.len() - 11);
            name.replace("\"", "");
            if name != "" && !name.contains(".") && !out.contains(name) {
                out.push(name);
            }
        }
    }
    out
}

// The names that a generative name of tox stands for: `py3{11,12}-django{50,51}` (the product of the
// alternatives in braces), and `py3{10-13}` (a range).
fn tox_expand(name) {
    let open = name.index_of("{");
    let close = if open < 0 { -1 } else { name.index_of("}", open) };
    if close < 0 {
        return [name];
    }
    let head = name.sub_string(0, open);
    let tails = tox_expand(name.sub_string(close + 1));
    let out = [];
    for a in name.sub_string(open + 1, close - open - 1).split(",") {
        a.trim();
        let items = [a];
        let dash = a.index_of("-");
        if dash > 0 {
            let lo = a.sub_string(0, dash);
            let hi = a.sub_string(dash + 1);
            if !sh::matches("*[!0-9]*", lo + hi) && hi != "" && lo.len() < 6 && hi.len() < 6
                && lo.parse_int() <= hi.parse_int() && hi.parse_int() - lo.parse_int() < 100 {
                items = [];
                for n in lo.parse_int()..=hi.parse_int() {
                    items.push(`${n}`);
                }
            }
        }
        for x in items {
            for t in tails {
                out.push(head + x + t);
            }
        }
    }
    out
}

// The environments of a list of tox (`env_list`, `-e`): names separated by commas, spaces or lines, but not
// inside braces, each expanded with `tox_expand`.
fn tox_names(list) {
    let out = [];
    let word = "";
    let depth = 0;
    for c in (list + ",").chars() {
        if depth == 0 && (c == ',' || c == ' ' || c == '\n' || c == '\t') {
            if word != "" && !word.starts_with("#") {
                out += tox_expand(word);
            }
            word = "";
            continue;
        }
        if c == '{' {
            depth += 1;
        } else if c == '}' && depth > 0 {
            depth -= 1;
        }
        word += c;
    }
    out
}

// The sections of an INI file, as a map from each section's name to a map from its keys to their values (the
// lines of a value, those indented after its key, separated by `\n`).
fn ini(text) {
    let out = #{"": #{}};
    let sec = "";
    let key = ();
    for line in text.split("\n") {
        let t = line;
        t.trim();
        if t == "" || t.starts_with("#") || t.starts_with(";") {
            continue;
        }
        if line.starts_with(" ") || line.starts_with("\t") {
            if key != () {
                out[sec][key] += "\n" + t;
            }
        } else if t.starts_with("[") && t.ends_with("]") {
            sec = t.sub_string(1, t.len() - 2);
            sec.trim();
            if out[sec] == () {
                out[sec] = #{};
            }
            key = ();
        } else {
            let eq = t.index_of("=");
            if eq > 0 {
                key = t.sub_string(0, eq);
                key.trim();
                let v = t.sub_string(eq + 1);
                v.trim();
                out[sec][key] = v;
            }
        }
    }
    out
}

// The keys of a TOML inline table (`{ test = ["py312"], lint = ["ruff"] }`).
fn inline_keys(v) {
    let out = [];
    let depth = 0;
    let word = "";
    for c in v.chars() {
        if c == '{' || c == '[' {
            depth += 1;
        } else if c == '}' || c == ']' {
            depth -= 1;
        } else if depth == 1 && c == '=' {
            out.push(std_kinds::unquote(word));
            word = "";
        } else if depth == 1 && c == ',' {
            word = "";
        } else if depth == 1 {
            word += c;
        }
    }
    out
}

// tox's configuration: `#{envs, labels}`, its environments (as candidates, with their descriptions; those of
// `env_list` first) and labels, from the file that tox reads, the first in the current directory or the nearest
// parent of tox.ini, setup.cfg (with `[tox:tox]`), pyproject.toml (with `[tool.tox]`, or `legacy_tox_ini`) and
// tox.toml.
fn tox_config() {
    let dir = sh::cwd();
    loop {
        for f in ["tox.ini", "setup.cfg", "pyproject.toml", "tox.toml"] {
            let p = dir + "/" + f;
            let text = fs::read_file(p);
            if text == () || f == "setup.cfg" && !text.contains("[tox:tox]")
                || f == "pyproject.toml" && !text.contains("[tool.tox") {
                continue;
            }
            let key = "tox_config:" + p;
            return sh::cache_get(key, [p]) ?? sh::cache_put(key, 3600, [p], tox_parse(f, text));
        }
        let k = lib_text::last_index(dir, "/");
        if k < 0 || dir == "/" {
            return #{envs: [], labels: []};
        }
        dir = if k == 0 { "/" } else { dir.sub_string(0, k) };
    }
}

// The environments and labels of the tox configuration `text`, in the file named `f`.
fn tox_parse(f, text) {
    let envs = [];
    let desc = #{};
    let labels = [];
    let legacy = text.index_of("legacy_tox_ini");
    if f.ends_with(".toml") && legacy < 0 {
        let t = std_kinds::toml(text);
        let p = if f == "pyproject.toml" { "tool.tox" } else { "" };
        let core = t[p] ?? #{};
        // (the strings of the list: a `{ product = [...] }` isn't one)
        envs = std_kinds::toml_list(core.env_list ?? "").filter(|x| lib_text::is_name(x));
        labels = inline_keys(core.labels ?? "") + (t[if p == "" { "labels" } else { p + ".labels" }] ?? #{}).keys();
        let prefix = if p == "" { "env." } else { p + ".env." };
        for name in t.keys() {
            if name.starts_with(prefix) && !name.sub_string(prefix.len()).contains(".") {
                let e = std_kinds::unquote(name.sub_string(prefix.len()));
                for x in tox_expand(e) {
                    desc[x] = std_kinds::unquote(t[name].description ?? "");
                    envs.push(x);
                }
            }
        }
    } else {
        if legacy >= 0 {
            let open = text.index_of("\"\"\"", legacy);
            let close = if open < 0 { -1 } else { text.index_of("\"\"\"", open + 3) };
            text = if close < 0 { "" } else { text.sub_string(open + 3, close - open - 3) };
        }
        let t = ini(text);
        let core = t[if f == "setup.cfg" { "tox:tox" } else { "tox" }] ?? #{};
        envs = tox_names(core.env_list ?? core.envlist ?? "");
        for line in (core.labels ?? "").split("\n") {
            let eq = line.index_of("=");
            if eq > 0 {
                let l = line.sub_string(0, eq);
                l.trim();
                labels.push(l);
            }
        }
        for name in t.keys() {
            if name.starts_with("testenv:") {
                for x in tox_expand(name.sub_string(8)) {
                    desc[x] = (t[name].description ?? "").split("\n")[0];
                    envs.push(x);
                }
            }
        }
    }
    let out = [#{value: "ALL", desc: "all environments"}];
    let seen = [];
    for e in envs {
        e.trim();
        if e != "" && !e.starts_with(".") && !seen.contains(e) {
            seen.push(e);
            out.push(#{value: e, desc: desc[e] ?? ""});
        }
    }
    #{envs: out, labels: labels}
}

// pipx's home: `$PIPX_HOME`, or, with `--global`, `$PIPX_GLOBAL_HOME` (by default /opt/pipx); otherwise
// ~/.local/pipx if it exists (pipx's old default, which it keeps using), or `$XDG_DATA_HOME/pipx`.
fn pipx_home(words) {
    if words.contains("--global") {
        return sh::getvar("PIPX_GLOBAL_HOME") ?? "/opt/pipx";
    }
    let h = sh::getvar("PIPX_HOME");
    if h != () && h != "" {
        return h;
    }
    let home = std_kinds::home();
    if fs::is_dir(home + "/.local/pipx") {
        home + "/.local/pipx"
    } else {
        (sh::getvar("XDG_DATA_HOME") ?? (home + "/.local/share")) + "/pipx"
    }
}

// The environments that pipx manages.
fn pipx_venvs(words) {
    let dir = pipx_home(words) + "/venvs";
    (fs::list_dir(dir) ?? []).filter(|v| !v.starts_with(".") && fs::is_dir(dir + "/" + v))
}

// The metadata of the pipx environment named after `cmd` on the line (the first word after it that isn't an
// option), or an empty map.
fn pipx_metadata(words, cmd) {
    let k = words.index_of(cmd);
    let venv = ();
    if k >= 0 {
        for w in words.extract(k + 1) {
            if !w.starts_with("-") {
                venv = w;
                break;
            }
        }
    }
    if venv == () || !lib_text::is_name(venv) {
        return #{};
    }
    let p = pipx_home(words) + "/venvs/" + venv + "/pipx_metadata.json";
    let key = "pipx_metadata:" + p;
    sh::cache_get(key, [p]) ?? sh::cache_put(key, 3600, [p], read_json(p))
}

// The JSON object in the file `p`, or an empty map if it isn't one.
fn read_json(p) {
    let text = fs::read_file(p) ?? "";
    if lib_text::is_json_object(text) { parse_json(text) } else { #{} }
}

// The packages injected into the environment of `pipx uninject ENV`.
fn pipx_injected(words) {
    (pipx_metadata(words, "uninject").injected_packages ?? #{}).keys()
}

// The apps of the environment of `pipx exec ENV`: its main package's and those of the packages injected into it.
fn pipx_apps(words) {
    let m = pipx_metadata(words, "exec");
    let out = m.main_package?.apps ?? [];
    for p in (m.injected_packages ?? #{}).values() {
        for a in p.apps ?? [] {
            if !out.contains(a) {
                out.push(a);
            }
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
        "cython_sources" => lib_files::with_suffix(cur, [".pyx", ".py"], ["__pycache__"]),
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
        "claude_agents" => claude_agents(),
        "codex_profiles" => codex_profiles(),
        "tox_envs" => lib_text::comma_list(cur, tox_config().envs),
        "tox_labels" => tox_config().labels,
        "pipx_venvs" => pipx_venvs(words),
        "pipx_injected" => pipx_injected(words),
        "pipx_apps" => pipx_apps(words),
        _ => throw `unknown kind: ${name}`,
    }
}
