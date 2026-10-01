// What the arguments and option values of science commands complete to, named
// `own("kinds:NAME")` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;
import "../extra-lib/files" as lib_files;
import "../extra-lib/text" as lib_text;

// The word after `keyword ` in a line of a workflow file (`rule NAME:`), or ().
fn declared(line, keyword) {
    if !line.starts_with(keyword + " ") {
        return ();
    }
    let rest = line.sub_string(keyword.len() + 1);
    rest.trim();
    let colon = rest.index_of(":");
    if colon > 0 {
        rest = rest.sub_string(0, colon);
        rest.trim();
    }
    if rest == "" || rest.contains(" ") { () } else { rest }
}

// The string literal after `include:` in a line of a Snakefile, or ().
fn included(line) {
    if !line.starts_with("include:") {
        return ();
    }
    let rest = line.sub_string(8);
    rest.trim();
    if rest == "" {
        return ();
    }
    let q = rest[0];
    if q != '"' && q != '\'' {
        return ();
    }
    let end = rest.sub_string(1).index_of(q.to_string());
    if end < 0 { () } else { rest.sub_string(1, end) }
}

// The rules and checkpoints of a Snakefile and of the files it includes
// (whose names are string literals), `depth` levels deep, added to `out`
// (which is returned: Rhai passes arrays by value).
fn snakemake_rules_in(path, depth, out) {
    let text = fs::read_file(path);
    if text == () {
        return out;
    }
    let dir = std_kinds::split_dir(path)[0];
    for line in text.split("\n") {
        let name = declared(line, "rule") ?? declared(line, "checkpoint");
        if name != () && name != "_" && !out.contains(name) {
            out.push(name);
        }
        let inc = included(line);
        if inc != () && depth > 0 {
            out = snakemake_rules_in(if inc.starts_with("/") { inc } else { dir + inc }, depth - 1, out);
        }
    }
    out
}

// The rules of the Snakefile that `-s` names, else of the usual ones.
fn snakemake_rules(words) {
    let f = std_kinds::option_value(words, "-s", "--snakefile");
    let files = if f != () { [std_kinds::tilde(f)] } else { ["Snakefile", "snakefile", "workflow/Snakefile", "workflow/snakefile"] };
    for p in files {
        if fs::is_file(p) {
            return snakemake_rules_in(p, 3, []);
        }
    }
    []
}

// Rules, and (for a target) the files of the directory.
fn snakemake_targets(cur, words) {
    let r = std_kinds::listing(cur, "", false);
    if !cur.contains("/") {
        for n in snakemake_rules(words) {
            if n.starts_with(cur) && !r.candidates.contains(n) {
                r.candidates.push(n);
            }
        }
    }
    r
}

// The directory of Nextflow's downloaded projects (`nextflow pull`).
fn nextflow_assets() {
    (sh::getvar("NXF_HOME") ?? (sh::getvar("HOME") ?? "") + "/.nextflow") + "/assets"
}

// The projects Nextflow has downloaded, as OWNER/REPO.
fn nextflow_projects() {
    let out = [];
    let base = nextflow_assets();
    for owner in fs::list_dir(base) ?? [] {
        for repo in fs::list_dir(base + "/" + owner) ?? [] {
            out.push(owner + "/" + repo);
        }
    }
    out
}

// The pipeline: `.nf` scripts, directories, and downloaded projects.
fn nextflow_pipeline(cur) {
    let r = lib_files::with_suffix(cur, [".nf"]);
    if !cur.starts_with(".") && !cur.starts_with("/") && !cur.starts_with("~") {
        for p in nextflow_projects() {
            if p.starts_with(cur) {
                let name = p.sub_string(r.prefix.len());
                if !r.candidates.contains(name) {
                    r.candidates.push(name);
                }
            }
        }
    }
    r
}

// The runs of `.nextflow/history`, by field (2: run name, 5: session id).
fn nextflow_history(field) {
    let out = [];
    for line in (fs::read_file(".nextflow/history") ?? "").split("\n") {
        let f = line.split("\t");
        if f.len() > field && !out.contains(f[field]) {
            out.push(f[field]);
        }
    }
    out
}

// The profiles a Nextflow config file defines: the blocks directly inside `profiles { ... }`.
fn nextflow_profiles_in(path) {
    let text = fs::read_file(path) ?? "";
    let out = [];
    let depth = 0;
    let in_profiles = -1;   // the depth of the `profiles` block, once inside it
    for line in text.split("\n") {
        let l = line;
        l.trim();
        if l.starts_with("//") {
            continue;
        }
        if in_profiles < 0 && depth == 0 && l.starts_with("profiles") && l.contains("{") {
            in_profiles = depth;
        } else if in_profiles >= 0 && depth == in_profiles + 1 {
            let brace = l.index_of("{");
            if brace > 0 {
                let name = l.sub_string(0, brace);
                name.trim();
                if name.starts_with("'") || name.starts_with("\"") {
                    name = name.sub_string(1, name.len() - 2);
                }
                if name != "" && !name.contains(" ") && !name.contains(".") && !out.contains(name) {
                    out.push(name);
                }
            }
        }
        for c in l.chars() {
            if c == '{' {
                depth += 1;
            } else if c == '}' {
                depth -= 1;
            }
        }
        if in_profiles >= 0 && depth <= in_profiles {
            break;
        }
    }
    out
}

// The directory of the pipeline in a `nextflow run` line: a script, a directory or
// a downloaded project named in `words`, else the current directory.
fn nextflow_pipeline_dir(words) {
    for j in 2..words.len() - 1 {
        let w = std_kinds::tilde(words[j]);
        if w.starts_with("-") {
            continue;
        }
        if w.ends_with(".nf") && fs::is_file(w) {
            return std_kinds::split_dir(w)[0] + ".";
        }
        if fs::is_dir(w) {
            return w;
        }
        if fs::is_dir(nextflow_assets() + "/" + w) {
            return nextflow_assets() + "/" + w;
        }
    }
    "."
}

// The profiles of the configuration files: `-c`, and the pipeline's.
fn nextflow_profiles(cur, words) {
    let out = [];
    let files = [];
    for j in 1..words.len() - 1 {
        if (words[j] == "-c" || words[j] == "-config") && j + 1 < words.len() - 1 {
            files.push(std_kinds::tilde(words[j + 1]));
        }
    }
    files.push(nextflow_pipeline_dir(words) + "/nextflow.config");
    files.push("nextflow.config");
    for f in files {
        for p in nextflow_profiles_in(f) {
            if !out.contains(p) {
                out.push(p);
            }
        }
    }
    // several, separated by commas
    let comma = cur.index_of(",");
    let prefix = "";
    while comma >= 0 {
        prefix += cur.sub_string(0, comma + 1);
        cur = cur.sub_string(comma + 1);
        comma = cur.index_of(",");
    }
    #{prefix: prefix, candidates: out.filter(|p| !("," + prefix).contains("," + p + ","))}
}

// The parameters of the pipeline's `nextflow_schema.json` (nf-core's), as `--name` options
// (a table for the engine, and the values by name).
fn nextflow_params(words) {
    let text = fs::read_file(nextflow_pipeline_dir(words) + "/nextflow_schema.json");
    let opts = "";
    let values = #{};
    if text == () {
        return #{opts: opts, values: values};
    }
    let schema = parse_json(text);
    let groups = [schema];
    for key in ["$defs", "definitions"] {
        let defs = schema[key];
        if type_of(defs) == "map" {
            for g in defs.values() {
                groups.push(g);
            }
        }
    }
    for g in groups {
        let props = g.properties;
        if type_of(props) != "map" {
            continue;
        }
        for name in props.keys() {
            let p = props[name];
            let desc = p.description ?? "";
            desc.replace("\n", " ");
            let dot = desc.index_of(". ");
            if dot > 0 {
                desc = desc.sub_string(0, dot);
            }
            if desc.len() > 80 {
                desc = desc.sub_string(0, 80);
            }
            if p["type"] == "boolean" {
                opts += "--" + name + "  " + desc + "\n";
            } else {
                opts += "--" + name + " VALUE  " + desc + "\n";
                let fmt = p.format ?? "";
                if p["enum"] != () {
                    values["--" + name] = p["enum"].map(|e| e.to_string());
                } else if fmt == "directory-path" {
                    values["--" + name] = "dirs";
                } else if fmt == "file-path" || fmt == "path" || fmt == "file-path-pattern" {
                    values["--" + name] = "files";
                } else {
                    values["--" + name] = "none";
                }
            }
        }
    }
    #{opts: opts, values: values}
}

// pandoc's input or output formats (`direction` is "input" or "output"), or, after a `+` or `-`, the extensions
// of the format before it (`markdown+smart-raw_html`), all asked of the installed pandoc.
fn pandoc_formats(cur, direction) {
    let cut = -1;
    let last = -1;
    let i = 0;
    for c in cur.chars() {
        if c == '+' || c == '-' {
            if cut < 0 {
                cut = i;
            }
            last = i;
        }
        i += 1;
    }
    if cut < 0 {
        return sh::capture(["pandoc", "--list-" + direction + "-formats"]).out.split("\n").filter(|l| l != "");
    }
    let base = cur.sub_string(0, cut);
    if !lib_text::is_name(base) {
        return [];
    }
    let out = [];
    for l in sh::capture(["pandoc", "--list-extensions=" + base]).out.split("\n") {
        let name = if l.starts_with("+") || l.starts_with("-") { l.sub_string(1) } else { l };
        if name != "" && !(cur + "+").contains("+" + name + "+") && !(cur + "-").contains("-" + name + "-") {
            out.push(name);
        }
    }
    #{prefix: cur.sub_string(0, last + 1), candidates: out}
}

// A highlight style: one of pandoc's (`--list-highlight-styles`, and `extra`), or a `.theme` file.
fn pandoc_highlight_style(cur, extra) {
    let r = lib_files::with_suffix(cur, [".theme"]);
    if !cur.contains("/") {
        for n in extra + sh::capture(["pandoc", "--list-highlight-styles"]).out.split("\n") {
            if n != "" && n.starts_with(cur) && !r.candidates.contains(n) {
                r.candidates.push(n);
            }
        }
    }
    r
}

// ipython's arguments: a script, or, first, a subcommand (`profile create`, `history trim`).
fn ipython_args(cur, words) {
    let positional = [];
    for j in 1..words.len() - 1 {
        if !words[j].starts_with("-") {
            positional.push(words[j]);
        }
    }
    if positional.len() == 1 && positional[0] == "profile" {
        return ["create", "list", "locate"];
    }
    if positional.len() == 1 && positional[0] == "history" {
        return ["trim", "clear"];
    }
    let r = lib_files::with_suffix(cur, [".py", ".ipy", ".ipynb"]);
    if positional.is_empty() && !cur.contains("/") {
        for n in ["profile", "kernel", "locate", "history"] {
            if n.starts_with(cur) {
                r.candidates.push(n);
            }
        }
    }
    r
}

// datamash's operations (the first argument, and then `OPERATION FIELD ...`).
fn datamash_operations() {
    [
        "groupby", "crosstab", "transpose", "reverse", "check", "rmdup", "base64", "debase64", "md5", "sha1", "sha224",
        "sha256", "sha384", "sha512", "bin", "strbin", "round", "floor", "ceil", "trunc", "frac", "dirname", "basename",
        "barename", "extname", "getnum", "cut", "sum", "min", "max", "absmin", "absmax", "range", "count", "first",
        "last", "rand", "unique", "collapse", "countunique", "mean", "geomean", "harmmean", "trimmean", "median", "q1",
        "q3", "iqr", "perc", "mode", "antimode", "pstdev", "sstdev", "pvar", "svar", "ms", "rms", "mad", "madraw",
        "pskew", "sskew", "pkurt", "skurt", "dpo", "jarque", "scov", "pcov", "spearson", "ppearson", "dotprod",
    ]
}

// parallel's arguments after the command: the separators of the argument lists, and files.
fn parallel_args(cur) {
    if cur.starts_with(":") {
        return [":::", "::::", ":::+", "::::+"];
    }
    ()
}

// The names Miller has for separators (`--ifs semicolon`), asked of the installed mlr.
fn miller_separator() {
    let out = [];
    for line in sh::capture(["mlr", "help", "list-separator-aliases"]).out.split("\n") {
        let t = line;
        t.trim();
        let sp = t.index_of(" ");
        if sp > 0 {
            out.push(t.sub_string(0, sp));
        }
    }
    out
}

fn kind(name, cur, words) {
    switch name {
        "snakefile" => lib_files::with_suffix(cur, [".smk", "Snakefile", "snakefile"]),
        "config" => lib_files::with_suffix(cur, [".yaml", ".yml", ".json"]),
        "snakemake_rules" => snakemake_rules(words),
        "snakemake_targets" => snakemake_targets(cur, words),
        "jugfile" => lib_files::with_suffix(cur, [".py"]),
        "nextflow_pipeline" => nextflow_pipeline(cur),
        "nextflow_project" => nextflow_projects(),
        "nextflow_config" => lib_files::with_suffix(cur, [".config"]),
        "nextflow_profiles" => nextflow_profiles(cur, words),
        "nextflow_runs" => nextflow_history(2),
        "params_file" => lib_files::with_suffix(cur, [".json", ".yaml", ".yml"]),
        "pandoc_input_format" => pandoc_formats(cur, "input"),
        "pandoc_output_format" => pandoc_formats(cur, "output"),
        "pandoc_defaults" => lib_files::with_suffix(cur, [".yaml", ".yml"]),
        "pandoc_highlight_style" => pandoc_highlight_style(cur, []),
        "pandoc_syntax_highlighting" => pandoc_highlight_style(cur, ["none", "default", "idiomatic"]),
        "pdf_engine" => [
            "pdflatex", "lualatex", "xelatex", "latexmk", "tectonic", "wkhtmltopdf", "weasyprint", "pagedjs-cli",
            "prince", "context", "pdfroff", "typst",
        ],
        "tex" => lib_files::with_suffix(cur, [".tex", ".ltx", ".latex", ".dtx"]),
        "aux" => lib_files::with_suffix(cur, [".aux"]),
        "quarto_source" => lib_files::with_suffix(cur, [".qmd", ".ipynb", ".md", ".Rmd", ".rmd", ".jl"]),
        "quarto_convertible" => lib_files::with_suffix(cur, [".qmd", ".ipynb"]),
        "quarto_script" => lib_files::with_suffix(cur, [".ts", ".R", ".py", ".lua"]),
        "notebook" => lib_files::with_suffix(cur, [".ipynb"]),
        "ipython_args" => ipython_args(cur, words),
        "python_script" => lib_files::with_suffix(cur, [".py", ".ipy", ".ipynb"]),
        "aria2_input" => lib_files::with_suffix(cur, [".torrent", ".metalink", ".meta4"]),
        "torrent" => lib_files::with_suffix(cur, [".torrent"]),
        "metalink" => lib_files::with_suffix(cur, [".metalink", ".meta4"]),
        "datamash_operations" => datamash_operations(),
        "parallel_args" => parallel_args(cur),
        "duckdb_database" => lib_files::with_suffix(cur, [".duckdb", ".db", ".ddb", ".wal"]),
        "gnuplot_script" => lib_files::with_suffix(cur, [".gp", ".gnuplot", ".plt", ".gpi"]),
        "r_script" => lib_files::with_suffix(cur, [".R", ".r"]),
        "nftest" => lib_files::with_suffix(cur, [".nf.test", ".nf"]),
        "nextflow_script" => lib_files::with_suffix(cur, [".nf"]),
        "miller_separator" => miller_separator(),
        "cwl" => lib_files::with_suffix(cur, [".cwl", ".yaml", ".yml", ".json"]),
        "lua" => lib_files::with_suffix(cur, [".lua"]),
        "bibliography" => lib_files::with_suffix(cur, [".bib", ".bibtex", ".biblatex", ".json", ".yaml", ".yml", ".ris", ".xml", ".enl"]),
        "csl" => lib_files::with_suffix(cur, [".csl"]),
        _ => throw `unknown kind: ${name}`,
    }
}
