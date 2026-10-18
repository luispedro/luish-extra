// ffmpeg, whose command line is a list of inputs and outputs, each after its own options:
//
//    ffmpeg [GLOBAL OPTIONS] {[INPUT OPTIONS] -i INPUT}... {[OUTPUT OPTIONS] OUTPUT}...
//
// The options are those of ffmpeg_opts.rhai (ffmpeg's own and the generic options of libavcodec and libavformat, at
// the version it was generated from): for an input before the first `-i`, and for an output after it (the inputs
// usually come first), with the private options of the codecs and the format chosen for the same input or output
// (`-c:v libx264 -preset`, `-f mp4 -movflags`), read from the installed ffmpeg's `-h encoder=libx264` when Tab is
// pressed, as are the codecs, formats, filters and pixel formats that values complete to. An option can be followed
// by a stream specifier (`-c:v`, `-b:a:0`) or a metadata specifier (`-metadata:s:a`), and `-/NAME FILE` reads the
// value of `-NAME` from FILE. `-map` completes to the streams of the inputs, read with ffprobe; the values of `-vf`,
// `-af` and `-filter_complex` are filtergraphs (`[0:v]scale=w=1280:h=-1,format=yuv420p[out]`).

import "ffmpeg_opts" as opts;
import "../extra-lib/text" as lib_text;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("ffmpeg:") + name }

fn is_option(w) { w.len() > 1 && w.starts_with("-") }

// The words of a line (none for an empty one, which `split` gives as `[""]`).
fn words_of(line) {
    let t = line;
    t.trim();
    if t == "" { [] } else { t.split() }
}

// The option of an option word: `-c` for `-c:v:0`, `-vf` for `-/vf`.
fn base(w) {
    let b = if w.starts_with("-/") { "-" + w.sub_string(2) } else { w };
    let c = b.index_of(":");
    if c > 0 { b.sub_string(0, c) } else { b }
}

// Where the word `words[i]` is: `inputs`, the values of `-i` before it; `side`, "in" for the options of an input
// (before the first `-i`) and "out" for those of an output (after it); `expect`, the option word whose value it is
// (or ()); and `codecs` and `format`, the values of `-c` and `-f` among the options of the same input or output. An
// option takes a value unless it is one of ffmpeg's switches; a word that is neither an option nor a value is an
// output.
fn scan(words, i) {
    let switches = opts::switches();
    let s = #{inputs: [], expect: (), codecs: [], format: ()};
    let j = 1;
    while j < i {
        let w = words[j];
        if !is_option(w) {
            s.codecs = [];
            s.format = ();
        } else if switches[base(w)] == () {
            if j + 1 == i {
                s.expect = w;
                break;
            }
            let b = base(w);
            let v = words[j + 1];
            if b == "-i" {
                s.inputs.push(v);
                s.codecs = [];
                s.format = ();
            } else if b in ["-c", "-codec", "-vcodec", "-acodec", "-scodec", "-dcodec"] {
                s.codecs.push(v);
            } else if b == "-f" {
                s.format = v;
            }
            j += 1;
        }
        j += 1;
    }
    s.side = if s.inputs.is_empty() { "in" } else { "out" };
    s
}

// Whether `s` is the column of AVOption flags of ffmpeg's help (`E..V.......`).
fn is_flags(s) {
    s.len() == 11 && !sh::matches("*[!A-Z.]*", s)
}

// The text of `line` after its word `f[k]` (`f` being its words).
fn after(line, f, k) {
    let p = 0;
    for j in 0..=k {
        p = line.index_of(f[j], p) + f[j].len();
    }
    let r = line.sub_string(p);
    r.trim();
    r
}

// A short description from ffmpeg's: its first sentence, without `(default ...)` at its end, starting in lower case.
fn clean(d) {
    // (A sentence ends at `. ` before a capital, but not after `cf.` or `e.g.`.)
    let p = d.index_of(". ");
    while p > 0 {
        let next = d.sub_string(p + 2, 1);
        let before = d.sub_string(0, p);
        if next >= "A" && next <= "Z" && !["cf", "e.g", "i.e", "etc", "vs"].some(|a| before.ends_with(a)) {
            d = before;
            break;
        }
        p = d.index_of(". ", p + 2);
    }
    let p = lib_text::last_index(d, " (default ");
    if p >= 0 && d.ends_with(")") {
        d = d.sub_string(0, p);
    }
    if d.ends_with(".") {
        d = d.sub_string(0, d.len() - 1);
    }
    if d.len() > 1 && d[0] >= 'A' && d[0] <= 'Z' && d[1] >= 'a' && d[1] <= 'z' {
        d = d[0].to_lower() + d.sub_string(1);
    }
    d
}

// The AVOptions of a help text of ffmpeg (`-h encoder=libx264`, `-h filter=scale`): for each, `name`, `ty` (its
// type), `desc` and `consts`, its named values (`#{value, desc}`). An option's line is
// `  -preset  <string>  E..V.......  DESCRIPTION` (without `-` for a filter), and its constants are on the lines
// below it, indented further: `     variance  1  E..V.......  DESCRIPTION`.
fn avoptions(text) {
    let out = [];
    let indent = -1;
    for line in text.split("\n") {
        if !line.starts_with(" ") {
            indent = -1;
            continue;
        }
        let f = words_of(line);
        if f.len() < 3 {
            continue;
        }
        let n = lib_text::indent(line);
        if f[1].starts_with("<") || f[1].starts_with("[<") {
            // (`[<int>     ].D.V.......`: a list)
            let ty = f[1];
            for c in ["[", "<", ">"] {
                ty.replace(c, "");
            }
            let name = if f[0].starts_with("-") { f[0].sub_string(1) } else { f[0] };
            out.push(#{name: name, ty: ty, desc: clean(after(line, f, 2)), consts: []});
            indent = n;
        } else if indent >= 0 && n > indent {
            if !is_flags(f[1]) && !is_flags(f[2]) {
                continue;
            }
            let d = if is_flags(f[1]) { after(line, f, 1) } else { after(line, f, 2) };
            let c = #{value: f[0]};
            if d != "" {
                c.desc = clean(d);
            }
            out[out.len() - 1].consts.push(c);
        }
    }
    out
}

// The private options of a codec, format or filter (`ty`: encoder, decoder, muxer, demuxer or filter), from
// `ffmpeg -h TYPE=NAME`. What is parsed from ffmpeg's lists and help (here, and in `codecs`, `formats` and `filters`)
// is kept, keyed by the text, since each Tab would parse the same text again.
fn own_options(prog, ty, name) {
    if !lib_text::is_name(name) {
        return [];
    }
    let text = sh::capture_cached(300, [prog, "-hide_banner", "-h", `${ty}=${name}`]).out;
    let key = "avoptions:" + text;
    sh::cache_get(key) ?? sh::cache_put(key, 3600, avoptions(text))
}

// What the value of an AVOption completes to (as `type_kind` of scripts/gen/mk_ffmpeg.py): its constants, or for
// flags, `flags:SRC:NAME` (`SRC`: where the option is from, as `encoder:libx264`), or a kind by its type.
fn type_kind(o, src) {
    if !o.consts.is_empty() {
        return if o.ty == "flags" { k(`flags:${src}:${o.name}`) } else { o.consts };
    }
    switch o.ty {
        "image_size" => k("sizes"),
        "video_rate" => k("rates"),
        "pix_fmt" => k("pix_fmts"),
        "sample_fmt" => k("sample_fmts"),
        "channel_layout" => k("layouts"),
        "color" => k("colors"),
        "boolean" => ["true", "false"],
        _ => "none",
    }
}

// The type of stream of a specifier (`v` for `v:0`, or "" for a stream index).
fn stream_type(spec) {
    let t = spec.sub_string(0, 1).to_lower();
    if t in ["v", "a", "s", "d", "t"] { t } else { "" }
}

// The spec for the word `words[i]`, where it is being `s` (from `scan`).
fn spec(words, i, s) {
    let side = s.side;
    let table = opts::opts(side);
    let values = opts::values(side);
    let switches = opts::switches();
    let ty = if side == "in" { ["decoder", "demuxer"] } else { ["encoder", "muxer"] };
    let sources = [];
    for c in s.codecs {
        if c != "copy" {
            sources.push([ty[0], c]);
        }
    }
    if s.format != () {
        sources.push([ty[1], s.format]);
    }
    // The private options, of which those that are also generic (`-profile`, `-level`) only give their values.
    for src in sources {
        for o in own_options(words[0], src[0], src[1]) {
            let name = "-" + o.name;
            if switches[name] != () {
                continue;
            }
            let kind = type_kind(o, src[0] + ":" + src[1]);
            if values[name] == () {
                let desc = if o.desc == "" { o.ty } else { o.desc };
                table += `${name} ${o.ty.to_upper()}  ${desc} (${src[1]})` + "\n";
                values[name] = kind;
            } else if type_of(kind) != "string" || kind != "none" {
                values[name] = kind;
            }
        }
    }
    if words[i].starts_with("-no") {
        table += opts::negations(side);
    }
    // The value of an option with a stream specifier is of that type of stream (`-c:v`: a video codec), and that of
    // an option after `-/` is a file.
    if s.expect != () {
        let b = base(s.expect);
        let v = values[b];
        if s.expect.starts_with("-/") {
            values[b] = "files";
        } else if type_of(v) == "string" && v.ends_with(":") && s.expect.contains(":") {
            values[b] = v + stream_type(s.expect.sub_string(s.expect.index_of(":") + 1));
        }
    }
    #{opts: table, values: values, single_dash: true, strict_eq: true}
}

// The types of stream of a stream specifier.
fn stream_types() {
    [
        #{value: "v", desc: "video streams"},
        #{value: "V", desc: "video streams that aren't attached pictures"},
        #{value: "a", desc: "audio streams"},
        #{value: "s", desc: "subtitle streams"},
        #{value: "d", desc: "data streams"},
        #{value: "t", desc: "attachments"},
    ]
}

// The specifiers of an option that takes them, for a word `-OPTION:...`: the stream specifiers (`-c:v`), or the
// metadata specifiers (`-metadata:s`, and `-metadata:s:a`).
fn specifier(words, s, cur) {
    let name = base(cur).sub_string(1);
    let what = opts::specifiers()[name];
    if what == () && s.side == "out" {
        // (Those of the private options of codecs.)
        for c in s.codecs {
            if own_options(words[0], "encoder", c).some(|o| o.name == name) {
                what = "stream";
            }
        }
    }
    let rest = cur.sub_string(cur.index_of(":") + 1);
    let c = lib_text::last_index(cur, ":");
    let candidates = if what == "stream" && !rest.contains(":") {
        stream_types()
    } else if what == "meta" && !rest.contains(":") {
        [
            #{value: "g", desc: "global metadata"},
            #{value: "s", desc: "the metadata of streams (s:a, s:v:0...)"},
            #{value: "c", desc: "the metadata of a chapter (c:0)"},
            #{value: "p", desc: "the metadata of a program (p:0)"},
        ]
    } else if what == "meta" && rest.starts_with("s:") && rest.index_of(":", 2) < 0 {
        stream_types()
    } else {
        []
    };
    #{prefix: cur.sub_string(0, c + 1), candidates: candidates}
}

fn complete(words, i) {
    import "@std/completion/lib" as lib;
    let cur = words[i];
    let s = scan(words, i);
    if s.expect == () && is_option(cur) && cur.contains(":") {
        return specifier(words, s, cur);
    }
    // The engine gets the options without their specifiers.
    let plain = [words[0]];
    for j in 1..i {
        plain.push(if is_option(words[j]) { base(words[j]) } else { words[j] });
    }
    plain.push(cur);
    lib::complete(spec(words, i, s), plain, i)
}

// The output of `ffmpeg -hide_banner OPTION`, kept for a few minutes.
fn listing(prog, option) {
    sh::capture_cached(300, [prog, "-hide_banner", option]).out
}

// The lines of `text` after the first one that starts with `mark` (after spaces), but for empty ones.
fn rows(text, mark) {
    let out = [];
    let on = false;
    for line in text.split("\n") {
        let t = line;
        t.trim();
        if on && t != "" {
            out.push(line);
        } else if !on && t.starts_with(mark) {
            on = true;
        }
    }
    out
}

// The encoders (for an output, with `copy`) or decoders (for an input) of the type of stream `t` (v, a, s, d, t; ""
// for all), from `ffmpeg -encoders`: ` V....D libx264  libx264 H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10`.
fn codecs(prog, side, t) {
    let text = listing(prog, if side == "out" { "-encoders" } else { "-decoders" });
    let key = `codecs:${side}:${t}:` + text;
    sh::cache_get(key) ?? sh::cache_put(key, 3600, codec_rows(text, side, t))
}

fn codec_rows(text, side, t) {
    let out = if side == "out" { [#{value: "copy", desc: "copy the stream without reencoding"}] } else { [] };
    for line in rows(text, "---") {
        let f = words_of(line);
        if f.len() >= 2 && (t == "" || f[0].sub_string(0, 1).to_lower() == t) {
            out.push(#{value: f[1], desc: after(line, f, 1)});
        }
    }
    out
}

// The formats that can be demuxed (`which`: "D") or muxed ("E"), from `ffmpeg -demuxers` or `-muxers`, whose flags
// are the first 5 columns (` D d lavfi  Libavfilter virtual input device`, ` D   matroska,webm  Matroska / WebM`), or
// the devices, from `ffmpeg -devices`, whose flags are the first 4 (` DE alsa  ALSA audio output`).
fn formats(prog, option, which) {
    let text = listing(prog, option);
    let key = `formats:${option}:${which}:` + text;
    sh::cache_get(key) ?? sh::cache_put(key, 3600, format_rows(text, option, which))
}

fn format_rows(text, option, which) {
    let w = if option == "-devices" { 4 } else { 5 };
    let out = [];
    for line in rows(text, "---") {
        let f = words_of(line.sub_string(w));
        if f.len() >= 1 && line.sub_string(0, w).contains(which) {
            for n in f[0].split(",") {
                out.push(#{value: n, desc: after(line.sub_string(w), f, 0)});
            }
        }
    }
    out
}

// The filters for a filtergraph of the type of stream `t` (v or a: those with inputs and outputs of that type; ""
// for all), from `ffmpeg -filters`: ` TSC aap  AA->A  Apply Affine Projection algorithm to first audio stream.`
fn filters(prog, t) {
    let text = listing(prog, "-filters");
    let key = `filters:${t}:` + text;
    sh::cache_get(key) ?? sh::cache_put(key, 3600, filter_rows(text, t))
}

fn filter_rows(text, t) {
    let out = [];
    let want = t.to_upper();
    for line in text.split("\n") {
        let f = words_of(line);
        if f.len() < 3 || !f[2].contains("->") {
            continue;
        }
        let io = f[2].split("->");
        if t == "" || io.all(|x| x.contains(want) || x.contains("N")) {
            out.push(#{value: f[1], desc: clean(after(line, f, 2))});
        }
    }
    out
}

// The labels of a filtergraph that aren't streams of inputs (`[0:v]`): with `once`, those that appear only once
// (the outputs of a complex filtergraph, for `-map`).
fn labels(graph, once) {
    let count = #{};
    let order = [];
    let p = graph.index_of("[");
    while p >= 0 {
        let e = graph.index_of("]", p);
        if e < 0 {
            break;
        }
        let l = graph.sub_string(p + 1, e - p - 1);
        if l != "" && !l.contains(":") && !(l[0] >= '0' && l[0] <= '9') {
            if count[l] == () {
                order.push(l);
                count[l] = 0;
            }
            count[l] += 1;
        }
        p = graph.index_of("[", e);
    }
    if once { order.filter(|l| count[l] == 1) } else { order }
}

// The constants of an AVOption, as candidates after `prefix`: those of flags combine (`+faststart+frag_keyframe`,
// `-autobsf`), and the others don't.
fn constants(consts, flags, prefix, cur) {
    if flags {
        let c = lib_text::last_of(cur, "+-");
        prefix += cur.sub_string(0, c + 1);
    }
    let candidates = consts.map(|c| if type_of(c) == "string" { #{value: c, suffix: ""} } else { c + #{suffix: ""} });
    #{prefix: prefix, candidates: candidates}
}

// A filtergraph of the type of stream `t` ("" for a complex one): after the last `,` or `;`, the input labels of a
// filter (`[0:v]`), its name, the names of its options after `=` or `:` (from `ffmpeg -h filter=NAME`), and the
// constants of an option after its `=`.
fn graph(words, t, cur) {
    let prog = words[0];
    let p = lib_text::last_of(cur, ",;") + 1;
    let seg = cur.sub_string(p);
    while seg.starts_with("[") {
        let e = seg.index_of("]");
        if e < 0 {
            let out = [];
            let n = 0;
            for f in scan(words, words.len() - 1).inputs {
                for st in ["v", "a"] {
                    out.push(#{value: `[${n}:${st}]`, desc: f, suffix: ""});
                }
                n += 1;
            }
            for l in labels(cur.sub_string(0, p), false) {
                out.push(#{value: `[${l}]`, suffix: ""});
            }
            return #{prefix: cur.sub_string(0, p), candidates: out};
        }
        p += e + 1;
        seg = seg.sub_string(e + 1);
    }
    let eq = seg.index_of("=");
    if eq < 0 {
        return #{prefix: cur.sub_string(0, p), candidates: filters(prog, t).map(|f| { let x = f; x.suffix = ""; x })};
    }
    let args = seg.sub_string(eq + 1);
    let c = lib_text::last_index(args, ":") + 1;
    let item = args.sub_string(c);
    let start = p + eq + 1 + c;
    let options = own_options(prog, "filter", seg.sub_string(0, eq));
    let ie = item.index_of("=");
    if ie < 0 {
        if item.contains("[") {
            return [];
        }
        let candidates = options.map(|o| #{value: o.name + "=", desc: if o.desc == "" { o.ty } else { o.desc }, suffix: ""});
        return #{prefix: cur.sub_string(0, start), candidates: candidates};
    }
    // The value of an option: its constants, or what its type completes to (`format=pix_fmts=`).
    let name = item.sub_string(0, ie);
    let prefix = cur.sub_string(0, start + ie + 1);
    for o in options {
        if o.name != name {
            continue;
        }
        let v = if o.name == "pix_fmts" && o.consts.is_empty() {
            k("pix_fmts")
        } else {
            type_kind(o, "filter:" + seg.sub_string(0, eq))
        };
        if type_of(v) == "array" {
            return constants(v, false, prefix, item.sub_string(ie + 1));
        }
        if v == "none" {
            return [];
        }
        let r = kind(v.sub_string(k("").len()), item.sub_string(ie + 1), words);
        return if type_of(r) == "map" { r.prefix = prefix + r.prefix; r } else { #{prefix: prefix, candidates: r} };
    }
    []
}

// The topics of `-h`: `long`, `full`, and `TYPE=NAME`, for a codec, format, filter, bitstream filter or protocol.
fn help(prog, cur) {
    let eq = cur.index_of("=");
    if eq < 0 {
        let out = [#{value: "long", desc: "more options"},
                   #{value: "full", desc: "all the options, also of formats and codecs"}];
        for t in [["decoder", "a decoder"], ["encoder", "an encoder"], ["demuxer", "a demuxer"], ["muxer", "a muxer"],
                  ["filter", "a filter"], ["bsf", "a bitstream filter"], ["protocol", "a protocol"]] {
            out.push(#{value: t[0] + "=", desc: "the options of " + t[1], suffix: ""});
        }
        return out;
    }
    let candidates = switch cur.sub_string(0, eq) {
        "decoder" => codecs(prog, "in", ""),
        "encoder" => codecs(prog, "out", "").filter(|c| c.value != "copy"),
        "demuxer" => formats(prog, "-demuxers", "D"),
        "muxer" => formats(prog, "-muxers", "E"),
        "filter" => filters(prog, ""),
        "bsf" => names(rows(listing(prog, "-bsfs"), "Bitstream filters:")),
        "protocol" => protocols(prog),
        _ => [],
    };
    #{prefix: cur.sub_string(0, eq + 1), candidates: candidates}
}

// The first word of each line.
fn names(lines) {
    let out = [];
    for line in lines {
        let f = words_of(line);
        if !f.is_empty() && !f[0].ends_with(":") {
            out.push(f[0]);
        }
    }
    out
}

// The protocols of `ffmpeg -protocols`, for input and output.
fn protocols(prog) {
    let out = [];
    for n in names(rows(listing(prog, "-protocols"), "Supported file protocols:")) {
        if !(n in out) {
            out.push(n);
        }
    }
    out
}

// The candidates of a list separated by `sep` (`-bsf h264_mp4toannexb,dump_extra`), after its last separator.
fn list(candidates, cur, sep) {
    #{prefix: cur.sub_string(0, lib_text::last_of(cur, sep) + 1), candidates: candidates}
}

// The channel layouts (`5.1`) of `ffmpeg -layouts`, or after `+`, the channels (`FL+FR`).
fn layouts(prog, cur) {
    let channels = [];
    let layouts = [];
    let section = "";
    for line in listing(prog, "-layouts").split("\n") {
        let f = words_of(line);
        if f.is_empty() {
            section = "";
        } else if f[0] == "NAME" {
            section = f[1];
        } else if section == "DESCRIPTION" {
            channels.push(#{value: f[0], desc: after(line, f, 0)});
        } else if section == "DECOMPOSITION" && f.len() > 1 {
            layouts.push(#{value: f[0], desc: f[1]});
        }
    }
    if cur.contains("+") { list(channels, cur, "+") } else { layouts }
}

// The streams of an input, from ffprobe (`index=1|codec_name=aac|codec_type=audio|tag:language=eng`): for each,
// `index`, `ty` (v, a, s, d or t) and `desc`.
fn streams(probe, file) {
    let r = sh::capture_cached(30, [probe, "-v", "error", "-show_entries",
                                    "stream=index,codec_type,codec_name:stream_tags=language,title", "-of",
                                    "compact=p=0", file]);
    let out = [];
    for line in r.out.split("\n") {
        let x = #{};
        for kv in line.split("|") {
            let eq = kv.index_of("=");
            if eq > 0 {
                x[kv.sub_string(0, eq)] = kv.sub_string(eq + 1);
            }
        }
        if x.index == () || x.codec_type == () {
            continue;
        }
        let desc = x.codec_type + " " + (x.codec_name ?? "");
        let lang = x["tag:language"] ?? "";
        if lang != "" && lang != "und" {
            desc += ` (${lang})`;
        }
        if (x["tag:title"] ?? "") != "" {
            desc += ": " + x["tag:title"];
        }
        let ty = if x.codec_type == "attachment" { "t" } else { x.codec_type.sub_string(0, 1) };
        out.push(#{index: x.index, ty: ty, desc: desc});
    }
    out
}

// The streams of the inputs, for `-map`: `0` (all the streams of the first input), `0:1` (its second stream) and
// `0:a` (its audio streams), from ffprobe, and the outputs of `-filter_complex` (`[out]`); after `-` (which leaves
// streams out), the same.
fn map(words, cur) {
    let s = scan(words, words.len() - 1);
    let probe = sh::which("ffprobe");
    let out = [];
    let n = 0;
    for f in s.inputs {
        out.push(#{value: `${n}`, desc: f});
        let streams = if probe != () && !f.starts_with("-") && fs::is_file(f) { streams(probe, f) } else { [] };
        let types = #{};
        for st in streams {
            out.push(#{value: `${n}:${st.index}`, desc: st.desc});
            types[st.ty] = true;
        }
        for t in stream_types() {
            if t.value != "V" && (streams.is_empty() || types[t.value] != ()) {
                out.push(#{value: `${n}:${t.value}`, desc: t.desc});
            }
        }
        n += 1;
    }
    for j in 1..(words.len() - 1) {
        if words[j] in ["-filter_complex", "-lavfi"] {
            for l in labels(words[j + 1], true) {
                out.push(#{value: `[${l}]`, desc: "an output of -filter_complex"});
            }
        }
    }
    if cur.starts_with("-") { #{prefix: "-", candidates: out} } else { out }
}

// The sizes that ffmpeg knows by name (libavutil's parseutils.c).
fn sizes() {
    let out = [];
    for s in [["ntsc", "720x480"], ["pal", "720x576"], ["qntsc", "352x240"], ["qpal", "352x288"],
              ["sntsc", "640x480"], ["spal", "768x576"], ["film", "352x240"], ["ntsc-film", "352x240"],
              ["sqcif", "128x96"], ["qcif", "176x144"], ["cif", "352x288"], ["4cif", "704x576"],
              ["16cif", "1408x1152"], ["qqvga", "160x120"], ["qvga", "320x240"], ["vga", "640x480"],
              ["svga", "800x600"], ["xga", "1024x768"], ["uxga", "1600x1200"], ["qxga", "2048x1536"],
              ["sxga", "1280x1024"], ["qsxga", "2560x2048"], ["hsxga", "5120x4096"], ["wvga", "852x480"],
              ["wxga", "1366x768"], ["wsxga", "1600x1024"], ["wuxga", "1920x1200"], ["woxga", "2560x1600"],
              ["wqsxga", "3200x2048"], ["wquxga", "3840x2400"], ["whsxga", "6400x4096"], ["whuxga", "7680x4800"],
              ["cga", "320x200"], ["ega", "640x350"], ["hd480", "852x480"], ["hd720", "1280x720"],
              ["hd1080", "1920x1080"], ["2k", "2048x1080"], ["2kflat", "1998x1080"], ["2kscope", "2048x858"],
              ["4k", "4096x2160"], ["4kflat", "3996x2160"], ["4kscope", "4096x1716"], ["nhd", "640x360"],
              ["hqvga", "240x160"], ["wqvga", "400x240"], ["fwqvga", "432x240"], ["hvga", "480x320"],
              ["qhd", "960x540"], ["2kdci", "2048x1080"], ["4kdci", "4096x2160"], ["uhd2160", "3840x2160"],
              ["uhd4320", "7680x4320"]] {
        out.push(#{value: s[0], desc: s[1]});
    }
    out
}

// The frame rates that ffmpeg knows by name.
fn rates() {
    [
        #{value: "ntsc", desc: "30000/1001"}, #{value: "pal", desc: "25"}, #{value: "qntsc", desc: "30000/1001"},
        #{value: "qpal", desc: "25"}, #{value: "sntsc", desc: "30000/1001"}, #{value: "spal", desc: "25"},
        #{value: "film", desc: "24"}, #{value: "ntsc-film", desc: "24000/1001"},
    ]
}

// The levels of `-loglevel`, after the flags that can come before them (`repeat+level+verbose`).
fn loglevel(cur) {
    let out = [];
    for l in [["quiet", "show nothing"], ["panic", "only errors that crash the process"],
              ["fatal", "only errors after which ffmpeg can't go on"], ["error", "errors"],
              ["warning", "warnings and errors"], ["info", "the default"], ["verbose", "more than info"],
              ["debug", "everything, also debugging information"], ["trace", "everything"]] {
        out.push(#{value: l[0], desc: l[1]});
    }
    let given = cur.split("+");
    for f in [["repeat", "show repeated messages"], ["level", "prefix each message with its level"],
              ["time", "prefix each message with the time"],
              ["datetime", "prefix each message with the date and time"]] {
        if !(f[0] in given) {
            out.push(#{value: f[0] + "+", desc: f[1], suffix: ""});
        }
    }
    list(out, cur, "+")
}

fn kind(name, cur, words) {
    let prog = words[0];
    let parts = name.split(":");
    let side = scan(words, words.len() - 1).side;
    switch parts[0] {
        "help" => help(prog, cur),
        "loglevel" => loglevel(cur),
        "codec" => codecs(prog, side, parts[1]),
        "format" => if side == "in" { formats(prog, "-demuxers", "D") } else { formats(prog, "-muxers", "E") },
        "graph" => graph(words, parts[1], cur),
        "devices" => formats(prog, "-devices", if parts[1] == "in" { "D" } else { "E" }),
        "pix_fmts" => rows(listing(prog, "-pix_fmts"), "-----").map(|line| {
            let f = words_of(line);
            #{value: f[1], desc: `${f[2]} components, ${f[3]} bits per pixel`}
        }),
        "sample_fmts" => rows(listing(prog, "-sample_fmts"), "name").map(|line| {
            let f = words_of(line);
            let planar = if f[0].ends_with("p") { ", planar" } else { "" };
            #{value: f[0], desc: `${f[1]} bits${planar}`}
        }),
        "layouts" => layouts(prog, cur),
        "bsfs" => list(names(rows(listing(prog, "-bsfs"), "Bitstream filters:")), cur, ","),
        "protocols" => list(protocols(prog), cur, ","),
        "hwaccels" => ["auto", "none"] + names(rows(listing(prog, "-hwaccels"), "Hardware acceleration methods:")),
        "hwdevices" => names(rows(sh::capture_cached(300, [prog, "-hide_banner", "-init_hw_device", "list"]).out,
                                  "Supported hardware device types:")),
        "dispositions" => list(names(listing(prog, "-dispositions").split("\n")), cur, "+-"),
        "colors" => rows(listing(prog, "-colors"), "name").map(|line| {
            let f = words_of(line);
            #{value: f[0], desc: f[1]}
        }),
        "map" => map(words, cur),
        "inputs" => {
            let out = [#{value: "-1", desc: "none"}];
            let n = 0;
            for f in scan(words, words.len() - 1).inputs {
                out.push(#{value: `${n}`, desc: f});
                n += 1;
            }
            out
        },
        "metadata" => ["title", "artist", "album_artist", "album", "composer", "date", "genre", "track", "disc",
                       "comment", "description", "copyright", "language", "encoder", "show", "episode_id",
                       "network", "lyrics"].map(|key| #{value: key + "=", suffix: ""}),
        "sizes" => sizes(),
        "rates" => rates(),
        "flags" => {
            // `flags:gen:SIDE:NAME`, a generic option, or `flags:TYPE:NAME:OPTION`, a private option.
            let consts = if parts[1] == "gen" {
                opts::flags(parts[2] + ":" + parts[3])
            } else {
                let o = own_options(prog, parts[1], parts[2]).filter(|o| o.name == parts[3]);
                if o.is_empty() { [] } else { o[0].consts }
            };
            constants(consts, true, "", cur)
        },
        _ => throw `unknown kind: ${name}`,
    }
}
