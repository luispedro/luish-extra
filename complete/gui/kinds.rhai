// What the arguments and option values of desktop programs complete to, named
// `"@extra-complete/gui/kinds:NAME"` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;

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

fn kind(name, cur, words) {
    switch name {
        "lo_convert" => lo_convert(cur, words),
        "lo_import_filters" => lo_import_filters(words),
        "lo_bootstrap" => lo_bootstrap(),
        "printers" => printers(),
        _ => throw `unknown kind: ${name}`,
    }
}
