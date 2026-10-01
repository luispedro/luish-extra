// What the arguments and option values of desktop programs complete to, named
// `"@extra-complete/gui/kinds:NAME"` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;
import "@extra-complete/extra-lib/files" as lib_files;
import "@extra-complete/extra-lib/text" as lib_text;

// LibreOffice's configuration registry, whose `.xcd` files define its filters
// and file types, found from the `soffice` (or `libreoffice`) that the command
// line runs: `/usr/bin/soffice` is a link to `/usr/lib/libreoffice/program/soffice`,
// and the registry is `/usr/lib/libreoffice/share/registry` (`Contents/Resources/registry`
// on macOS, from `Contents/MacOS/soffice`). () if there is none.
fn lo_registry(words) {
    let names = [words[0], "soffice", "libreoffice"];
    names.push("/Applications/LibreOffice.app/Contents/MacOS/soffice");
    for name in names {
        let p = sh::which(name);
        if p == () {
            continue;
        }
        let bin = std_kinds::split_dir(fs::realpath(p))[0];
        for r in [bin + "../share/registry", bin + "../Resources/registry"] {
            if fs::is_dir(r) {
                return r;
            }
        }
    }
    ()
}

// XML's escapes, and the character references that the names of filters and types use (Rhai can't make a
// character from its code).
fn unescape_xml(s) {
    for e in [["&lt;", "<"], ["&gt;", ">"], ["&quot;", "\""], ["&apos;", "'"], ["&#x2013;", "–"], ["&#x2014;", "—"],
              ["&amp;", "&"]] {
        s.replace(e[0], e[1]);
    }
    s
}

// The value of the property `name` of a node of the registry (`<prop oor:name="NAME"><value>...</value></prop>`),
// or () if it has none.
fn prop(node, name) {
    let k = node.index_of(`<prop oor:name="${name}"`);
    if k < 0 {
        return ();
    }
    let p = node.sub_string(k);
    let end = p.index_of("</prop>");
    let close = p.index_of(">");
    if close < 1 || p.sub_string(close - 1, 1) == "/" || end < 0 {
        return ();
    }
    p = p.sub_string(0, end);
    let v = p.index_of("<value");
    if v < 0 {
        return ();
    }
    p = p.sub_string(v);
    let gt = p.index_of(">");
    if p.sub_string(gt - 1, 1) == "/" {
        return "";
    }
    let e = p.index_of("</value>");
    unescape_xml(p.sub_string(gt + 1, e - gt - 1))
}

// LibreOffice's filters (`name`, `ty` (the type), `desc`, `flags`) and file types (by name: `ext`, the extensions, and
// `desc`), from the `org.openoffice.TypeDetection` sections of the registry's `.xcd` files.
fn lo_filters(words) {
    let out = #{filters: [], types: #{}};
    let reg = lo_registry(words);
    if reg == () {
        return out;
    }
    for f in fs::list_dir(reg) ?? [] {
        if !f.ends_with(".xcd") {
            continue;
        }
        for section in (fs::read_file(reg + "/" + f) ?? "").split("<oor:component-data ") {
            let head = section.sub_string(0, section.index_of(">"));
            if !head.contains(`"org.openoffice.TypeDetection"`) {
                continue;
            }
            let filters = head.contains(`oor:name="Filter"`);
            if !filters && !head.contains(`oor:name="Types"`) {
                continue;
            }
            for node in section.split(`<node oor:name="`) {
                let q = node.index_of(`"`);
                if q < 1 || node.starts_with("<") {
                    continue;
                }
                let name = unescape_xml(node.sub_string(0, q));
                if filters {
                    let t = prop(node, "Type");
                    if t != () {
                        let flags = (prop(node, "Flags") ?? "").split();
                        out.filters.push(#{name: name, ty: t, desc: prop(node, "UIName") ?? "", flags: flags});
                    }
                } else {
                    let ext = prop(node, "Extensions");
                    if ext != () && out.types[name] == () {
                        out.types[name] = #{ext: ext.split(), desc: prop(node, "UIName") ?? ""};
                    }
                }
            }
        }
    }
    out
}

// Whether `e` is an extension: letters and digits.
fn is_ext(e) {
    for ch in e.chars() {
        if !((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9')) {
            return false;
        }
    }
    e != ""
}

// What `--convert-to` converts to, `EXT[:FILTER[:OPTIONS]]`: the extensions of the types that an export filter
// writes, and after `EXT:`, those filters. Without a registry, common extensions.
fn lo_convert(cur, words) {
    let lo = lo_filters(words);
    let c = cur.index_of(":");
    if c >= 0 {
        let ext = cur.sub_string(0, c);
        if cur.sub_string(c + 1).contains(":") {
            return [];   // the filter's options
        }
        let out = [];
        for f in lo.filters {
            let t = lo.types[f.ty];
            if f.flags.contains("EXPORT") && t != () && t.ext.contains(ext) {
                out.push(#{value: f.name, desc: f.desc});
            }
        }
        return #{prefix: cur.sub_string(0, c + 1), candidates: out};
    }
    if lo.filters.is_empty() {
        return ["pdf", "odt", "docx", "doc", "rtf", "txt", "html", "epub", "ods", "xlsx", "xls", "csv", "odp", "pptx",
                "ppt", "odg", "png", "jpg", "svg"];
    }
    let seen = #{};
    let out = [];
    for f in lo.filters {
        let t = lo.types[f.ty];
        if !f.flags.contains("EXPORT") || t == () {
            continue;
        }
        for e in t.ext {
            // (Some types have patterns, such as `*` or `uop;uof`, rather than extensions.)
            if seen[e] == () && is_ext(e) {
                seen[e] = true;
                out.push(#{value: e, desc: t.desc});
            }
        }
    }
    out
}

// The input filters, for `--infilter=` (not LibreOffice's internal ones, such as that of its help pages).
fn lo_import_filters(words) {
    lo_filters(words).filters
        .filter(|f| f.flags.contains("IMPORT") && !f.flags.contains("INTERNAL"))
        .map(|f| #{value: f.name, desc: f.desc})
}

// The bootstrap variables that `-env:` sets most often.
fn lo_bootstrap() {
    [#{value: "UserInstallation=", suffix: "", desc: "the user profile, as a URL (file:///...)"}]
}

// The printers of CUPS (`lpstat -e`).
fn printers() {
    let r = sh::capture(["lpstat", "-e"]);
    if r.status != 0 || r.out == "" { [] } else { r.out.split("\n") }
}

// The directory of a program's configuration under `$XDG_CONFIG_HOME` (`~/.config`), or under `$XDG_DATA_HOME`
// (`~/.local/share`) with `data`.
fn xdg_dir(data, name) {
    let home = std_kinds::home();
    let base = if data {
        sh::getvar("XDG_DATA_HOME") ?? (home + "/.local/share")
    } else {
        sh::getvar("XDG_CONFIG_HOME") ?? (home + "/.config")
    };
    base + "/" + name
}

// `name` with the percent escapes of ASCII punctuation decoded (`my%20notes`), as QUrl writes them in file names.
fn unescape_url(name) {
    if !name.contains("%") {
        return name;
    }
    for e in [["%20", " "], ["%21", "!"], ["%22", "\""], ["%23", "#"], ["%24", "$"], ["%26", "&"], ["%27", "'"],
              ["%28", "("], ["%29", ")"], ["%2A", "*"], ["%2B", "+"], ["%2C", ","], ["%2F", "/"], ["%3A", ":"],
              ["%3B", ";"], ["%3C", "<"], ["%3D", "="], ["%3E", ">"], ["%3F", "?"], ["%40", "@"], ["%5B", "["],
              ["%5C", "\\"], ["%5D", "]"], ["%5E", "^"], ["%60", "`"], ["%7B", "{"], ["%7C", "|"], ["%7D", "}"],
              ["%25", "%"]] {
        name.replace(e[0], e[1]);
    }
    name
}

// kate's sessions: the `.katesession` files of `$XDG_DATA_HOME/kate/sessions`, named with their names
// percent-encoded.
fn kate_sessions() {
    let out = [];
    for f in fs::list_dir(xdg_dir(true, "kate/sessions")) ?? [] {
        if f.ends_with(".katesession") {
            out.push(unescape_url(f.sub_string(0, f.len() - 12)));
        }
    }
    out
}

// The pids of the running kates.
fn kate_pids() {
    std_kinds::processes(false).filter(|p| p.desc == "kate")
}

// GIMP's session files, `sessionrc.NAME` in the directory of each version (`~/.config/GIMP/3.0`, or `$GIMP3_DIRECTORY`
// and `$GIMP2_DIRECTORY`).
fn gimp_sessions() {
    let dirs = [];
    for v in ["GIMP3_DIRECTORY", "GIMP2_DIRECTORY"] {
        let d = sh::getvar(v);
        if d != () {
            dirs.push(d);
        }
    }
    let base = xdg_dir(false, "GIMP");
    for v in fs::list_dir(base) ?? [] {
        dirs.push(base + "/" + v);
    }
    let out = [];
    for d in dirs {
        for f in fs::list_dir(d) ?? [] {
            if f.starts_with("sessionrc.") && f.len() > 10 && !out.contains(f.sub_string(10)) {
                out.push(f.sub_string(10));
            }
        }
    }
    out
}

// The candidates `items` after the last `sep` of `cur`, for a list (`png,pdf`).
fn after_last(cur, sep, items) {
    let c = lib_text::last_of(cur, [sep]);
    #{prefix: cur.sub_string(0, c + 1), candidates: items}
}

// The SVG files on the command line (not the word being completed).
fn svg_files(words) {
    let out = [];
    for j in 1..words.len() - 1 {
        let w = std_kinds::tilde(words[j]);
        if w.to_lower().ends_with(".svg") && fs::is_file(w) {
            out.push(w);
        }
    }
    out
}

// The value of the attribute `name` in the start tag `tag`, or ().
fn attribute(tag, name) {
    let k = 0;
    loop {
        k = tag.index_of(name + "=\"", k);
        if k < 0 {
            return ();
        }
        let before = if k == 0 { " " } else { tag.sub_string(k - 1, 1) };
        k += name.len() + 2;
        if before == " " || before == "\n" || before == "\t" || before == "\r" {
            let end = tag.index_of("\"", k);
            return if end < 0 { () } else { unescape_xml(tag.sub_string(k, end - k)) };
        }
    }
}

// The IDs of the objects of the SVG files on the command line, with their elements (and Inkscape's labels) as
// descriptions, for `--export-id` (`sep` `;`), `--query-id` and `--select` (`,`).
fn inkscape_ids(sep, cur, words) {
    let out = [];
    for f in svg_files(words) {
        for e in (fs::read_file(f) ?? "").split("<") {
            if e.starts_with("?") || e.starts_with("!") || e.starts_with("/") {
                continue;
            }
            let gt = e.index_of(">");
            let tag = if gt < 0 { e } else { e.sub_string(0, gt) };
            let id = attribute(tag, "id");
            if id == () || id == "" {
                continue;
            }
            let name = tag.split()[0];
            let label = attribute(tag, "inkscape:label");
            out.push(#{value: id, desc: if label == () { name } else { `${name}: ${label}` }});
        }
    }
    after_last(cur, sep, out)
}

// Inkscape's actions, from `inkscape --action-list` (`NAME   :  DESCRIPTION`), for `--actions` (`ACTION:ARG;...`):
// an action's argument completes to nothing.
fn inkscape_actions(cur, words) {
    let c = lib_text::last_of(cur, [';']);
    if cur.sub_string(c + 1).contains(":") {
        return [];
    }
    let out = [];
    let r = sh::capture([words[0], "--action-list"]);
    if r.status == 0 {
        for line in r.out.split("\n") {
            let k = line.index_of(":  ");
            if k <= 0 {
                continue;
            }
            let name = line.sub_string(0, k);
            name.trim();
            let desc = line.sub_string(k + 3);
            desc.trim();
            out.push(#{value: name, desc: desc});
        }
    }
    #{prefix: cur.sub_string(0, c + 1), candidates: out}
}

// OBS's configuration directories: `$XDG_CONFIG_HOME/obs-studio`, and that of its Flatpak.
fn obs_dirs() {
    [xdg_dir(false, "obs-studio"), std_kinds::home() + "/.var/app/com.obsproject.Studio/config/obs-studio"]
        .filter(|d| fs::is_dir(d))
}

// The value of `key` in the `.ini` text `text` (the first one, in any section), or ().
fn ini_value(text, key) {
    for line in text.split("\n") {
        if line.starts_with(key + "=") {
            let v = line.sub_string(key.len() + 1);
            v.trim();
            return v;
        }
    }
    ()
}

// OBS's profiles, by the `Name` of each `basic/profiles/DIR/basic.ini`.
fn obs_profiles() {
    let out = [];
    for d in obs_dirs() {
        let base = d + "/basic/profiles";
        for p in fs::list_dir(base) ?? [] {
            let n = ini_value(fs::read_file(`${base}/${p}/basic.ini`) ?? "", "Name");
            if n != () && !out.contains(n) {
                out.push(n);
            }
        }
    }
    out
}

// OBS's scene collections: for each `basic/scenes/FILE.json`, `file` (FILE) and `data` (its contents).
fn obs_collection_files() {
    let out = [];
    for d in obs_dirs() {
        let base = d + "/basic/scenes";
        for f in fs::list_dir(base) ?? [] {
            if !f.ends_with(".json") {
                continue;
            }
            let text = fs::read_file(`${base}/${f}`) ?? "";
            let data = if text.starts_with("{") { parse_json(text) } else { #{} };
            out.push(#{dir: d, file: f.sub_string(0, f.len() - 5), data: data});
        }
    }
    out
}

// The names of the scene collections.
fn obs_collections() {
    let out = [];
    for c in obs_collection_files() {
        let n = c.data.name;
        if type_of(n) == "string" && !out.contains(n) {
            out.push(n);
        }
    }
    out
}

// The scenes of the collection that `--collection` names, or of the current one (`SceneCollectionFile` of
// `user.ini`, or of `global.ini` before OBS 31), or of all of them.
fn obs_scenes(words) {
    let all = obs_collection_files();
    let named = std_kinds::option_value(words, "", "--collection");
    let chosen = if named != () {
        all.filter(|c| c.data.name == named)
    } else {
        let current = [];
        for c in all {
            for ini in ["user.ini", "global.ini"] {
                if ini_value(fs::read_file(`${c.dir}/${ini}`) ?? "", "SceneCollectionFile") == c.file {
                    current.push(c);
                    break;
                }
            }
        }
        current
    };
    if chosen.is_empty() {
        chosen = all;
    }
    let out = [];
    for c in chosen {
        for s in c.data.scene_order ?? [] {
            let n = s.name;
            if type_of(n) == "string" && !out.contains(n) {
                out.push(n);
            }
        }
    }
    out
}

fn kind(name, cur, words) {
    switch name {
        "lo_convert" => lo_convert(cur, words),
        "lo_import_filters" => lo_import_filters(words),
        "lo_bootstrap" => lo_bootstrap(),
        "printers" => printers(),
        "kate_sessions" => kate_sessions(),
        "kate_pids" => kate_pids(),
        "gimp_sessions" => gimp_sessions(),
        "inkscape_export_types" => after_last(cur, ',', ["svg", "png", "ps", "eps", "pdf", "emf", "wmf", "xaml"]),
        "inkscape_ids;" => inkscape_ids(';', cur, words),
        "inkscape_ids," => inkscape_ids(',', cur, words),
        "inkscape_actions" => inkscape_actions(cur, words),
        "obs_profiles" => obs_profiles(),
        "obs_collections" => obs_collections(),
        "obs_scenes" => obs_scenes(words),
        "cys" => lib_files::with_suffix(cur, [".cys"]),
        _ => throw `unknown kind: ${name}`,
    }
}
