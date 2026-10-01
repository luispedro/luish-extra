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

// The pids of the running instances of a program.
fn pids_of(prog) {
    std_kinds::processes(false).filter(|p| p.desc == prog)
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

// The directories of a Mozilla program's profiles (with `profiles.ini`): Firefox's `~/.mozilla/firefox`, or
// `$XDG_CONFIG_HOME/mozilla/firefox` since 147, those of its Snap and Flatpak and that of macOS, and Thunderbird's.
fn mozilla_dirs(cmd) {
    let home = std_kinds::home();
    let dirs = if cmd.contains("thunderbird") {
        [home + "/.thunderbird", xdg_dir(false, "thunderbird"), home + "/snap/thunderbird/common/.thunderbird",
         home + "/.var/app/org.mozilla.Thunderbird/.thunderbird", home + "/Library/Thunderbird"]
    } else {
        [home + "/.mozilla/firefox", xdg_dir(false, "mozilla/firefox"), home + "/snap/firefox/common/.mozilla/firefox",
         home + "/.var/app/org.mozilla.firefox/.mozilla/firefox", home + "/Library/Application Support/Firefox"]
    };
    dirs.filter(|d| fs::is_file(d + "/profiles.ini"))
}

// The profiles of Firefox or Thunderbird (`-P`), by the `Name` of each `[ProfileN]` section of `profiles.ini`, with
// their directories as descriptions.
fn mozilla_profiles(words) {
    let out = [];
    let seen = [];
    for d in mozilla_dirs(std_kinds::split_dir(words[0])[1]) {
        let name = ();
        let path = "";
        let lines = (fs::read_file(d + "/profiles.ini") ?? "").split("\n");
        lines.push("[");
        for line in lines {
            line.trim();
            if line.starts_with("[") {
                if name != () && !seen.contains(name) {
                    seen.push(name);
                    out.push(#{value: name, desc: path});
                }
                name = ();
                path = "";
            } else if line.starts_with("Name=") {
                name = line.sub_string(5);
            } else if line.starts_with("Path=") {
                path = line.sub_string(5);
            }
        }
    }
    out
}

// The user data directory of Chrome or Chromium: that of `--user-data-dir`, or the program's own under
// `$CHROME_CONFIG_HOME` (or `$XDG_CONFIG_HOME`): `google-chrome` (`-beta`, `-unstable`) and `chromium`, or that of
// the Snap.
fn chrome_dir(words) {
    let d = std_kinds::option_value(words, "", "--user-data-dir");
    if d != () {
        return std_kinds::tilde(d);
    }
    let cmd = std_kinds::split_dir(words[0])[1];
    let base = sh::getvar("CHROME_CONFIG_HOME") ?? sh::getvar("XDG_CONFIG_HOME") ?? (std_kinds::home() + "/.config");
    if cmd.starts_with("chromium") {
        let snap = std_kinds::home() + "/snap/chromium/common/chromium";
        return if fs::is_dir(base + "/chromium") || !fs::is_dir(snap) { base + "/chromium" } else { snap };
    }
    for c in ["beta", "unstable"] {
        if cmd.ends_with(c) {
            return base + "/google-chrome-" + c;
        }
    }
    base + "/google-chrome"
}

// The profiles of Chrome (`--profile-directory`): the directories of `profile.info_cache` in `Local State`, with
// their names as descriptions.
fn chrome_profiles(words) {
    let text = fs::read_file(chrome_dir(words) + "/Local State") ?? "";
    if !text.starts_with("{") {
        return [];
    }
    let cache = parse_json(text).profile?.info_cache ?? #{};
    let out = [];
    for dir in cache.keys() {
        out.push(#{value: dir, desc: cache[dir].name ?? ""});
    }
    out
}

// The directory of VS Code's extensions: that of `--extensions-dir`, or `$VSCODE_EXTENSIONS`, or `~/.vscode/extensions`.
fn code_extensions_dir(words) {
    let d = std_kinds::option_value(words, "", "--extensions-dir") ?? sh::getvar("VSCODE_EXTENSIONS");
    if d != () { std_kinds::tilde(d) } else { std_kinds::home() + "/.vscode/extensions" }
}

// The installed extensions of VS Code, from the `extensions.json` of their directory (as `code --list-extensions`,
// which starts the editor), with their versions as descriptions.
fn code_extensions(words) {
    let text = fs::read_file(code_extensions_dir(words) + "/extensions.json") ?? "";
    if !text.starts_with("[") {
        return [];
    }
    let out = [];
    for e in parse_json(`{"a": ${text}}`).a {
        let id = e.identifier?.id;
        if type_of(id) == "string" {
            out.push(#{value: id, desc: e.version ?? ""});
        }
    }
    out
}

// The profiles of VS Code (`--profile`): Default, and the `userDataProfiles` of `User/globalStorage/storage.json`
// in the user data directory (that of `--user-data-dir`, or `~/.config/Code`).
fn code_profiles(words) {
    let d = std_kinds::option_value(words, "", "--user-data-dir");
    let dir = if d != () { std_kinds::tilde(d) } else { xdg_dir(false, "Code") };
    let out = ["Default"];
    let text = fs::read_file(dir + "/User/globalStorage/storage.json") ?? "";
    if text.starts_with("{") {
        for p in parse_json(text).userDataProfiles ?? [] {
            if type_of(p.name) == "string" && !out.contains(p.name) {
                out.push(p.name);
            }
        }
    }
    out
}

// The first argument of code: a path or, as the first word, a subcommand.
fn code_paths(cur, words) {
    let r = std_kinds::listing(cur, "", false);
    if words.len() == 2 && !cur.contains("/") {
        for c in ["chat", "serve-web", "agent", "tunnel"] {
            if c.starts_with(cur) {
                r.candidates.push(#{value: c, desc: "subcommand"});
            }
        }
    }
    r
}

// Krita's resources of a kind, by the names of the files with the suffix `suffix` in their directory of
// `$XDG_DATA_HOME/krita` (`workspaces/*.kws`, `windowlayouts/*.kwl`, `sessions/*.ksn`).
fn krita_resources(dir, suffix) {
    let out = [];
    for f in fs::list_dir(xdg_dir(true, "krita/" + dir)) ?? [] {
        if f.ends_with(suffix) {
            out.push(f.sub_string(0, f.len() - suffix.len()));
        }
    }
    out
}

// Java's system properties that set Artemis's options (`-DNAME=VALUE`, after `-D`): their names, then their values
// (true or false, or files, after the last `,` of a list). act numbers the properties of each sequence (`bam1=`).
fn artemis_props(cur) {
    let eq = cur.index_of("=");
    if eq < 0 {
        let out = [];
        for p in [["black_belt_mode=", "keep warnings to a minimum"], ["offset=", "the base position to open at"],
                  ["userplot=", "userplot files (,-separated)"], ["loguserplot=", "userplot files, of log(data)"],
                  ["bam=", "BAM, CRAM, VCF or BCF files (,-separated; bam1=, bam2=: in separate panels)"],
                  ["bamClone=", "open the BAM files in N panels"], ["show_forward_lines=", "show the forward frame lines"],
                  ["show_reverse_lines=", "show the reverse frame lines"], ["chado=", "a Chado database (host:port/db?user)"]] {
            out.push(#{value: p[0], suffix: "", desc: p[1]});
        }
        for p in [["show_snps", "show SNP marks in BamView"], ["show_snp_plot", "open the SNP plot in BamView"],
                  ["show_cov_plot", "open the coverage plot in BamView"], ["read_only", "open the Chado database read-only"]] {
            out.push(#{value: p[0], desc: p[1]});
        }
        return out;
    }
    let name = cur.sub_string(0, eq);
    let v = cur.sub_string(eq + 1);
    if ["black_belt_mode", "show_forward_lines", "show_reverse_lines"].contains(name) {
        return #{prefix: cur.sub_string(0, eq + 1), candidates: ["true", "false"]};
    }
    if name.starts_with("bam") && name != "bamClone" || name.starts_with("userplot") || name.starts_with("loguserplot") {
        let c = lib_text::last_of(v, [',']);
        return std_kinds::listing(v.sub_string(c + 1), cur.sub_string(0, eq + 2 + c), false);
    }
    []
}

// The outputs of `xrandr --query` (`NAME connected ...`), with their states as descriptions; `-d DISPLAY` is passed
// on.
fn xrandr_query(words) {
    let argv = ["xrandr"];
    let d = std_kinds::option_value(words, "-d", "--display");
    if d != () {
        argv += ["--display", d];
    }
    sh::capture(argv + ["--query"]).out
}

fn xrandr_outputs(words) {
    let out = [];
    for line in xrandr_query(words).split("\n") {
        let f = line.split(" ");
        if f.len() > 1 && (f[1] == "connected" || f[1] == "disconnected") {
            out.push(#{value: f[0], desc: f[1]});
        }
    }
    out
}

// The modes of the output of the last `--output` (or of all outputs), with their rates as descriptions.
fn xrandr_modes(words) {
    let output = std_kinds::option_value(words, "", "--output");
    let out = [];
    let seen = [];
    let current = ();
    for line in xrandr_query(words).split("\n") {
        if !line.starts_with(" ") {
            current = line.split(" ")[0];
            continue;
        }
        if output != () && current != output {
            continue;
        }
        let t = line;
        t.trim();
        let gap = t.index_of(" ");
        if gap <= 0 {
            continue;
        }
        let mode = t.sub_string(0, gap);
        let rates = t.sub_string(gap);
        rates.trim();
        if !seen.contains(mode) && !mode.contains(":") {
            seen.push(mode);
            out.push(#{value: mode, desc: rates});
        }
    }
    out
}

// gsettings with the `--schemadir` of the line, and the words after its command (`[SCHEMA, KEY, ...]`).
fn gsettings_line(words) {
    let argv = ["gsettings"];
    let j = 1;
    while j < words.len() - 1 && words[j].starts_with("-") {
        if words[j] == "--schemadir" && j + 1 < words.len() - 1 {
            argv += ["--schemadir", std_kinds::tilde(words[j + 1])];
            j += 1;
        }
        j += 1;
    }
    #{argv: argv, args: words.extract(j + 1)}
}

fn gsettings_schemas(words) {
    let g = gsettings_line(words);
    let r = sh::capture(g.argv + ["list-schemas"]);
    if r.status != 0 || r.out == "" { [] } else { r.out.split("\n") }
}

fn gsettings_keys(words) {
    let g = gsettings_line(words);
    if g.args.is_empty() {
        return [];
    }
    // (A relocatable schema is SCHEMA:PATH.)
    let name = g.args[0];
    name.replace(":", "");
    name.replace("/", "");
    if !lib_text::is_name(name) {
        return [];
    }
    let r = sh::capture(g.argv + ["list-keys", g.args[0]]);
    if r.status != 0 || r.out == "" { [] } else { r.out.split("\n") }
}

// The values of a key for `set`: those of an enum or flags, or true and false (`gsettings range`).
fn gsettings_values(words) {
    let g = gsettings_line(words);
    if g.args.len() < 2 {
        return [];
    }
    let r = sh::capture(g.argv + ["range", g.args[0], g.args[1]]);
    let lines = r.out.split("\n");
    if r.status != 0 || lines.is_empty() {
        return [];
    }
    if lines[0] == "type b" {
        return ["true", "false"];
    }
    if lines[0] != "enum" && lines[0] != "flags" {
        return [];
    }
    let out = [];
    for l in lines.extract(1) {
        l.trim();
        if l.starts_with("'") && l.ends_with("'") && l.len() > 1 {
            out.push(l.sub_string(1, l.len() - 2));
        }
    }
    out
}

// The keys and directories of dconf's database under the directory of `cur` (`dconf list`); only the directories
// with `dirs_only`.
fn dconf_paths(cur, dirs_only) {
    if !cur.starts_with("/") {
        return [#{value: "/", suffix: ""}];
    }
    let dir = cur.sub_string(0, lib_text::last_index(cur, "/") + 1);
    let r = sh::capture(["dconf", "list", dir]);
    let out = [];
    if r.status == 0 && r.out != "" {
        for e in r.out.split("\n") {
            if e.ends_with("/") {
                out.push(#{value: e, suffix: ""});
            } else if !dirs_only {
                out.push(e);
            }
        }
    }
    #{prefix: dir, candidates: out}
}

// The value of the key of `dconf write` (the last word before this one), to edit.
fn dconf_value(words) {
    let key = words[words.len() - 2];
    if !key.starts_with("/") || key.ends_with("/") {
        return [];
    }
    let r = sh::capture(["dconf", "read", key]);
    if r.status != 0 || r.out == "" { [] } else { [r.out] }
}

// The notification categories of the Desktop Notifications specification.
fn notify_categories(cur) {
    after_last(cur, ',', ["call", "call.ended", "call.incoming", "call.unanswered", "device", "device.added",
                          "device.error", "device.removed", "email", "email.arrived", "email.bounced", "im",
                          "im.error", "im.received", "network", "network.connected", "network.disconnected",
                          "network.error", "presence", "presence.offline", "presence.online", "transfer",
                          "transfer.complete", "transfer.error"])
}

// The windows of `wmctrl -l` (`ID DESKTOP HOST TITLE`): their titles, or their IDs with `-i` on the line (with the
// titles as descriptions), and the special windows.
fn wmctrl_windows(words) {
    let ids = words.extract(1, words.len() - 2).some(|w| w.starts_with("-") && !w.starts_with("--") && w.contains("i"));
    let out = [#{value: ":ACTIVE:", desc: "the active window"}, #{value: ":SELECT:", desc: "the window clicked on"}];
    let r = sh::capture(["wmctrl", "-l"]);
    if r.status != 0 {
        return out;
    }
    for line in r.out.split("\n") {
        let f = line.split();
        if f.len() < 4 {
            continue;
        }
        let title = f.extract(3).reduce(|a, w| if a == () { w } else { a + " " + w });
        out.push(if ids { #{value: f[0], desc: title} } else { #{value: title, desc: f[0]} });
    }
    out
}

// wmctrl's -b: `(remove|add|toggle),PROP1[,PROP2]`.
fn wmctrl_states(cur) {
    if !cur.contains(",") {
        return ["remove,", "add,", "toggle,"].map(|v| #{value: v, suffix: ""});
    }
    after_last(cur, ',', ["modal", "sticky", "maximized_vert", "maximized_horz", "shaded", "skip_taskbar",
                          "skip_pager", "hidden", "fullscreen", "above", "below"])
}

// Key sequences of xdotool (`ctrl+alt+Delete`): modifiers and common keysyms, after the last `+`.
fn xdotool_keys(cur) {
    let keys = ["ctrl", "alt", "shift", "super", "meta", "Return", "Escape", "Tab", "BackSpace", "Delete", "Insert",
                "Home", "End", "Page_Up", "Page_Down", "Left", "Right", "Up", "Down", "space", "Print", "Menu",
                "Caps_Lock", "Control_L", "Control_R", "Alt_L", "Alt_R", "Shift_L", "Shift_R", "Super_L",
                "Super_R", "XF86AudioRaiseVolume", "XF86AudioLowerVolume", "XF86AudioMute", "XF86AudioPlay",
                "XF86AudioNext", "XF86AudioPrev", "XF86MonBrightnessUp", "XF86MonBrightnessDown"];
    for n in 1..=12 {
        keys.push("F" + n);
    }
    after_last(cur, '+', keys)
}

// The commands of sway that `swaymsg` sends most.
fn sway_commands() {
    ["exec", "exec_always", "kill", "reload", "exit", "focus", "move", "workspace", "layout", "split", "splith",
     "splitv", "splitt", "fullscreen", "floating", "sticky", "resize", "mark", "unmark", "scratchpad", "output",
     "input", "seat", "bar", "mode", "border", "gaps", "opacity", "rename", "swap", "title_format", "urgent",
     "inhibit_idle", "nop", "bindsym", "unbindsym", "set", "for_window", "[", "create_output"]
}

fn kind(name, cur, words) {
    switch name {
        "lo_convert" => lo_convert(cur, words),
        "lo_import_filters" => lo_import_filters(words),
        "lo_bootstrap" => lo_bootstrap(),
        "printers" => printers(),
        "kate_sessions" => kate_sessions(),
        "kate_pids" => pids_of("kate"),
        "zathura_pids" => pids_of("zathura"),
        "gimp_sessions" => gimp_sessions(),
        "inkscape_export_types" => after_last(cur, ',', ["svg", "png", "ps", "eps", "pdf", "emf", "wmf", "xaml"]),
        "inkscape_ids;" => inkscape_ids(';', cur, words),
        "inkscape_ids," => inkscape_ids(',', cur, words),
        "inkscape_actions" => inkscape_actions(cur, words),
        "obs_profiles" => obs_profiles(),
        "obs_collections" => obs_collections(),
        "obs_scenes" => obs_scenes(words),
        "mozilla_profiles" => mozilla_profiles(words),
        "chrome_profiles" => chrome_profiles(words),
        "code_extensions" => code_extensions(words),
        "code_install" => lib_files::with_suffix(cur, [".vsix"]),
        "code_profiles" => code_profiles(words),
        "code_paths" => code_paths(cur, words),
        "meldcmp" => lib_files::with_suffix(cur, [".meldcmp"]),
        "krita_workspaces" => krita_resources("workspaces", ".kws"),
        "krita_windowlayouts" => krita_resources("windowlayouts", ".kwl"),
        "krita_sessions" => krita_resources("sessions", ".ksn"),
        "blend" => lib_files::with_suffix(cur, [".blend"]),
        "py" => lib_files::with_suffix(cur, [".py"]),
        "artemis_props" => artemis_props(cur),
        "bam" => lib_files::with_suffix(cur, [".bam", ".cram"]),
        "fasta" => lib_files::with_suffix(cur, lib_files::compressed([".fa", ".fasta", ".fna", ".faa", ".ffn", ".fas"])),
        "bandage_graph" => lib_files::with_suffix(cur, lib_files::compressed([".gfa", ".gfa1", ".gfa2", ".fastg",
                                                                              ".gv", ".dot", ".asqg", ".lastgraph",
                                                                              ".fa", ".fasta", ".fna"])),
        "xrandr_outputs" => xrandr_outputs(words),
        "xrandr_modes" => xrandr_modes(words),
        "gsettings_schemas" => gsettings_schemas(words),
        "gsettings_keys" => gsettings_keys(words),
        "gsettings_values" => gsettings_values(words),
        "dconf_paths" => dconf_paths(cur, false),
        "dconf_dirs" => dconf_paths(cur, true),
        "dconf_value" => dconf_value(words),
        "notify_categories" => notify_categories(cur),
        "wmctrl_windows" => wmctrl_windows(words),
        "wmctrl_states" => wmctrl_states(cur),
        "xdotool_keys" => xdotool_keys(cur),
        "xdotool_states" => ["MODAL", "STICKY", "MAXIMIZED_VERT", "MAXIMIZED_HORZ", "SHADED", "SKIP_TASKBAR",
                             "SKIP_PAGER", "HIDDEN", "FULLSCREEN", "ABOVE", "BELOW", "DEMANDS_ATTENTION"],
        "sway_commands" => sway_commands(),
        // (Filenames as candidates, for a `skip` prefix: a kind that gives () can't be put after one.)
        "listing" => std_kinds::listing(cur, "", false),
        "cys" => lib_files::with_suffix(cur, [".cys"]),
        _ => throw `unknown kind: ${name}`,
    }
}
