"""Generates ../../completion/media/ffmpeg_opts.rhai, the option tables of ffmpeg at a pinned version: its own options
(`ffmpeg -h long`) and the generic options of libavcodec and libavformat (the AVCodecContext, AVFormatContext and
SWScaler sections of `ffmpeg -h full`), for an input and for an output.

    python3 scripts/gen/mk_ffmpeg.py

The help doesn't say which options take a value (`-thread_queue_size  set the maximum ...` takes one, `-re <>`
doesn't) nor which of the per-stream ones are for inputs or outputs only, so these are read from the OptionDef tables
of fftools at the same version (`ffmpeg_opt.c`, `opt_common.h`, fetched from GitHub and cached as the help is). The
private options of codecs, formats and filters are read from the installed ffmpeg when Tab is pressed (ffmpeg.rhai).
"""
import hashlib, os, re, urllib.request
import gen
import help2opts as h

VERSION = "9.0.2"
PKG = f"ffmpeg={VERSION}"
K = lambda n: f'k("{n}")'
NONE = '"none"'
FILES = '"files"'


def lst(*xs):
    return "[" + ", ".join(f'"{x}"' for x in xs) + "]"


# What the value of each of ffmpeg's own options completes to; the generator stops at an option that takes a value and
# isn't here. `codec:` and `graph:` get the type of stream of the option's specifier (`-c:v`) in ffmpeg.rhai.
KINDS = {
    "h": K("help"), "?": K("help"), "help": K("help"), "-help": K("help"),
    "sources": K("devices:in"), "sinks": K("devices:out"),
    "v": K("loglevel"), "loglevel": K("loglevel"),
    "max_alloc": NONE, "cpuflags": NONE, "cpucount": NONE, "progress": FILES, "timelimit": NONE,
    "frame_drop_threshold": NONE, "copytb": lst("-1", "0", "1"), "dts_delta_threshold": NONE,
    "dts_error_threshold": NONE, "abort_on": lst("empty_output", "empty_output_stream"), "filter_threads": NONE,
    "filter_buffered_frames": NONE, "filter_complex": K("graph:"), "filter_complex_threads": NONE,
    "lavfi": K("graph:"), "stats_period": NONE, "max_error_rate": NONE, "vstats_file": FILES,
    "vstats_version": lst("1", "2"), "sdp_file": FILES, "vaapi_device": NONE, "qsv_device": NONE,
    "init_hw_device": K("hwdevices"), "filter_hw_device": NONE, "print_graphs_file": FILES,
    "print_graphs_format": lst("default", "compact", "csv", "flat", "ini", "json", "xml", "mermaid", "mermaidhtml"),
    "f": K("format"), "t": NONE, "to": NONE, "ss": NONE, "thread_queue_size": NONE, "sseof": NONE,
    "seek_timestamp": NONE, "isync": NONE, "itsoffset": NONE, "readrate": NONE, "readrate_initial_burst": NONE,
    "readrate_catchup": NONE, "dump_attachment": FILES, "stream_loop": NONE, "metadata": K("metadata"),
    "map": K("map"), "map_metadata": K("inputs"), "map_chapters": K("inputs"), "fs": NONE, "timestamp": lst("now"),
    "program": NONE, "stream_group": NONE, "dframes": NONE,
    "target": lst(*[p + t for p in ("", "pal-", "ntsc-", "film-") for t in ("vcd", "svcd", "dvd", "dv", "dv50")]),
    "shortest_buf_duration": NONE, "qscale": NONE, "profile": NONE, "attach": FILES, "muxdelay": NONE,
    "muxpreload": NONE, "fpre": FILES,
    "c": K("codec:"), "codec": K("codec:"), "pre": NONE, "itsscale": NONE, "copypriorss": NONE, "frames": NONE,
    "tag": NONE, "q": NONE, "reinit_filter": NONE, "drop_changed": NONE,
    "discard": lst("none", "default", "noref", "bidir", "nokey", "all"), "disposition": K("dispositions"),
    "bits_per_raw_sample": NONE, "stats_enc_pre": FILES, "stats_enc_post": FILES, "stats_mux_pre": FILES,
    "stats_enc_pre_fmt": NONE, "stats_enc_post_fmt": NONE, "stats_mux_pre_fmt": NONE, "time_base": NONE,
    "enc_time_base": NONE, "bsf": K("bsfs"), "max_muxing_queue_size": NONE, "muxing_queue_data_threshold": NONE,
    "filter": K("graph:"),
    "r": K("rates"), "aspect": lst("4:3", "16:9"), "vcodec": K("codec:v"), "vf": K("graph:v"), "b": NONE,
    "vframes": NONE, "fpsmax": K("rates"), "pix_fmt": K("pix_fmts"), "display_rotation": NONE,
    "rc_override": NONE, "timecode": NONE, "pass": lst("1", "2", "3"), "passlogfile": FILES,
    "intra_matrix": NONE, "inter_matrix": NONE, "chroma_intra_matrix": NONE, "vtag": NONE,
    "fps_mode": lst("passthrough", "cfr", "vfr", "auto"), "streamid": NONE,
    "force_key_frames": lst("source", "scd_metadata"), "hwaccel": K("hwaccels"), "hwaccel_device": NONE,
    "hwaccel_output_format": K("pix_fmts"), "apply_cropping": lst("none", "all", "codec", "container"),
    "mastering_display": NONE, "content_light": NONE, "vpre": NONE, "s": K("sizes"),
    "aq": NONE, "ar": lst("8000", "11025", "16000", "22050", "32000", "44100", "48000", "88200", "96000"),
    "ac": lst("1", "2", "6", "8"), "acodec": K("codec:a"), "ab": NONE, "af": K("graph:a"), "aframes": NONE,
    "apad": NONE, "atag": NONE, "sample_fmt": K("sample_fmts"), "channel_layout": K("layouts"),
    "ch_layout": K("layouts"), "guess_layout_max": NONE, "apre": NONE,
    "scodec": K("codec:s"), "stag": NONE, "canvas_size": K("sizes"), "spre": NONE, "dcodec": K("codec:d"),
    "i": FILES,
}
# Descriptions that the help has none of, or a misleading one.
DESC = {"s": "set frame size (WxH or abbreviation)", "i": "input file or URL",
        "h": "show help (long, full, or TYPE=NAME for a codec, format, filter, bsf or protocol)",
        "stdin": "enable interaction on standard input (-nostdin: disable it)",
        "re": "read input at native frame rate; equivalent to -readrate 1",
        "hide_banner": "do not show program banner",
        "max_error_rate": "ratio of decoding errors (0.0 to 1.0) above which ffmpeg exits with an error"}
# The value names that the help's are too long or odd for.
ARGNAME = {"map": "STREAMS", "map_metadata": "SPEC", "program": "SPEC", "stream_group": "SPEC",
           "timecode": "TIMECODE", "max_error_rate": "RATIO", "hwaccel": "NAME", "tag": "TAG", "vtag": "TAG",
           "atag": "TAG", "stag": "TAG", "isync": "INDEX", "metadata": "KEY=VALUE"}
# The options that ffmpeg's OptionDef tables don't have, but that it takes: `-i`, which ends an input's options
# (offered for an output too, since a second input comes after the first one's `-i`).
EXTRA = [("i", "URL", [], "OPT_TYPE_STRING")]


def source(path):
    """A file of FFmpeg's source at VERSION, cached as gen.helptext's output is."""
    url = f"https://raw.githubusercontent.com/FFmpeg/FFmpeg/n{VERSION}/{path}"
    f = os.path.join(gen.CACHE, hashlib.md5(url.encode()).hexdigest())
    if not os.path.exists(f):
        open(f, "w").write(urllib.request.urlopen(url, timeout=60).read().decode())
    return open(f).read()


def optiondefs():
    """name -> (type, flags) for each OptionDef of ffmpeg."""
    out = {}
    for path in ["fftools/opt_common.h", "fftools/ffmpeg_opt.c"]:
        src = source(path)
        for name, typ, flags in re.findall(r'\{\s*"([^"]+)"\s*,\s*(OPT_TYPE_\w+),\s*([^,{]+?),\s*\{', src):
            out[name] = (typ, set(f.strip() for f in flags.split("|")))
    for name, _, flags, typ in EXTRA:
        out[name] = (typ, set(flags))
    return out


def takes_value(typ, flags, arg):
    if "OPT_EXIT" in flags and arg:     # `-h long`, `-sources pulse`: an optional value
        return True
    if typ == "OPT_TYPE_BOOL":
        return False
    return not (typ == "OPT_TYPE_FUNC" and "OPT_FUNC_ARG" not in flags)


def own_options():
    """ffmpeg's options, in the order of `-h long`: (name, argname, desc, side, spec) for each, `side` "in", "out" or
    "" (both, or global), `spec` "stream" (`-c:v`), "meta" (`-metadata:s:a`) or None; and the names of the flags
    (OPT_TYPE_BOOL), which also take `-no` before their names."""
    text = gen.helptext(PKG, "ffmpeg -hide_banner -h long")
    defs = optiondefs()
    rows, seen = [], set()
    lines = [l for l in text.splitlines() if l.startswith("-")] + ["-s[:<stream_spec>] <size>  ", "-i <url>  "]
    for line in lines:
        m = re.match(r"^-(\S+?)(\[:<(stream_spec|spec)>\])?(?: <([^>]*)>)?(?:\s{2,}(.*))?$", line)
        if not m:
            raise SystemExit(f"unparsed: {line}")
        name, spec, arg, desc = m.group(1), m.group(3), m.group(4), m.group(5) or ""
        if name in seen or "deprecated" in desc:
            continue
        seen.add(name)
        if name not in defs:
            raise SystemExit(f"-{name}: not in the OptionDef tables")
        typ, flags = defs[name]
        value = takes_value(typ, flags, arg)
        if value and name not in KINDS:
            raise SystemExit(f"-{name}: no kind for its value")
        argname = ""
        if value:
            argname = ARGNAME.get(name) or re.sub(r"[^A-Za-z0-9]+", "_", arg or "value").strip("_").upper() or "VALUE"
        side = "in" if "OPT_INPUT" in flags and "OPT_OUTPUT" not in flags else \
            "out" if "OPT_OUTPUT" in flags and "OPT_INPUT" not in flags else ""
        spec = "stream" if spec == "stream_spec" else "meta" if spec == "spec" else None
        rows.append((name, argname, h.clean(DESC.get(name, desc)), side, spec))
    bools = [n for n, (t, _) in defs.items() if t == "OPT_TYPE_BOOL" and n in seen]
    return rows, bools


def avoptions(text, heading):
    """The options of the first section `HEADING AVOptions:` of `-h full`: (name, type, flags, desc, constants) for
    each, `flags` as `ED.VA......` and `constants` a list of (name, flags, desc)."""
    start = text.index(f"\n{heading} AVOptions:\n") + 1
    end = text.index(" AVOptions:", start + len(heading) + 12)
    end = text.rindex("\n\n", start, end)
    opts = []
    for line in text[start:end].splitlines()[1:]:
        m = re.match(r"^  -(\S+)\s+\[?<(\w+)>\s*\]?\s*([A-Z.]{11})\s?(.*)$", line)
        if m:
            opts.append([m.group(1), m.group(2), m.group(3), m.group(4).strip(), []])
            continue
        m = re.match(r"^     (\S+)\s+(?:\S+\s+)?([A-Z.]{11})\s?(.*)$", line)
        if m and opts:
            opts[-1][4].append((m.group(1), m.group(2), h.clean(m.group(3))))
            continue
        if line.strip():
            raise SystemExit(f"{heading}: unparsed: {line}")
    return opts


def type_kind(name, typ, consts, key):
    """What the value of an AVOption completes to, from its type and its constants (as ffmpeg.rhai's `type_kind`)."""
    if name in ("protocol_whitelist", "protocol_blacklist"):
        return K("protocols")
    if consts:
        return K("flags:gen:" + key) if typ == "flags" else consts_list(consts, 16)
    return {"image_size": K("sizes"), "video_rate": K("rates"), "pix_fmt": K("pix_fmts"),
            "sample_fmt": K("sample_fmts"), "channel_layout": K("layouts"), "color": K("colors"),
            "boolean": lst("true", "false")}.get(typ, NONE)


def consts_list(consts, indent):
    """A Rhai list of the constants (`#{value, desc}`), one per line."""
    q = lambda s: s.replace("\\", "\\\\").replace('"', '\\"')
    items = [f'#{{value: "{q(v)}", desc: "{q(d)}"}}' if d else f'"{q(v)}"' for v, d in consts]
    one = "[" + ", ".join(items) + "]"
    if indent + len(one) < 100:
        return one
    pad = " " * indent
    return "[\n" + "".join(f"{pad}{i},\n" for i in items) + " " * (indent - 4) + "]"


def table(rows, indent):
    pad = " " * indent
    w = min(max(len(n) for n, _ in rows), 34)
    return "\n".join(f"{pad}{n}{' ' * max(2, w + 2 - len(n))}{d}".rstrip() for n, d in rows)


def packed(items, indent):
    """Map items `"KEY": VALUE,`, several to a line, but a multi-line value on lines of its own."""
    pad = " " * indent
    out, line = [], pad
    for n, v in items:
        item = f'"{n}": {v},'
        if "\n" in v or len(line) + len(item) > 116:
            if line.strip():
                out.append(line.rstrip())
            line = pad
        if "\n" in v:
            out.append(pad + item)
            continue
        line += item + " "
    if line.strip():
        out.append(line.rstrip())
    return "\n".join(out)


own, bools = own_options()
full = gen.helptext(PKG, "ffmpeg -hide_banner -h full")
codec = avoptions(full, "AVCodecContext")
fmt = avoptions(full, "AVFormatContext")
sws = avoptions(full, "SWScaler")

tables, values, flags, negations, switches = {}, {}, {}, {}, set()
for side, ed in (("in", "D"), ("out", "E")):
    rows, vals, names = [], [], set()
    for name, argname, desc, s, _ in own:
        if s and s != side:
            continue
        rows.append((f"-{name} {argname}".rstrip(), desc))
        if argname:
            vals.append((f"-{name}", KINDS[name]))
        else:
            switches.add(name)
        names.add(name)
    # The generic options of libavcodec and libavformat (and libswscale's, for an output) that ffmpeg's own don't
    # hide, for decoding (D) or encoding (E), and their constants for the same.
    for opts in (codec, fmt) + ((sws,) if side == "out" else ()):
        for name, typ, fl, desc, consts in opts:
            if ed not in fl or name in names or "deprecated" in desc:
                continue
            names.add(name)
            key = f"{side}:{name}"
            consts = [(v, d) for v, cf, d in consts if ed in cf]
            if typ == "flags" and consts:
                flags[key] = consts
            rows.append((f"-{name} {typ.upper()}", h.clean(desc) or typ))
            vals.append((f"-{name}", type_kind(name, typ, consts, key)))
    tables[side], values[side] = rows, vals
    # (Not those of two letters, `-noy` and `-novn`.)
    negations[side] = [(f"-no{n}", f"not -{n}") for n in bools if n in names and len(n) > 2]
    switches |= {r[0][1:] for r in negations[side]} | {"no" + n for n in bools if len(n) <= 2}

# The generic options of libavcodec take a stream specifier, also those that ffmpeg has as its own (`-b:v`).
per_stream = dict((r[0], r[4]) for r in own if r[4])
for o in codec:
    per_stream.setdefault(o[0], "stream")

flag_cases = "\n".join(f'        "{k}" => {consts_list(v, 12)},' for k, v in flags.items())
spec_items = packed([(n, f'"{s}"') for n, s in per_stream.items()], 8)
switch_items = packed([("-" + n, "true") for n in sorted(switches)], 8)

out = gen.REPO + "/completion/media/ffmpeg_opts.rhai"
open(out, "w").write(f"""// ffmpeg {VERSION} (conda-forge's), generated by scripts/gen/mk_ffmpeg.py from `ffmpeg -h long` and from the
// AVCodecContext, AVFormatContext and SWScaler sections of `ffmpeg -h full`, with which options take values and which
// are for inputs or outputs only from the OptionDef tables of fftools. The options of an input (`side`: "in") are
// ffmpeg's own for inputs and the generic options for decoding and demuxing, those of an output ("out"), ffmpeg's
// own for outputs and the generic options for encoding and muxing. The kinds are ffmpeg.rhai's.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

fn k(name) {{ own("ffmpeg:") + name }}

// The options of an input or an output.
fn opts(side) {{
    if side == "in" {{
        `
{table(tables["in"], 12)}
        `
    }} else {{
        `
{table(tables["out"], 12)}
        `
    }}
}}

// What their values complete to.
fn values(side) {{
    if side == "in" {{
        #{{
{packed(values["in"], 12)}
        }}
    }} else {{
        #{{
{packed(values["out"], 12)}
        }}
    }}
}}

// The `-noNAME` of the flags (`-nostdin`), offered for a word that starts with `-no`.
fn negations(side) {{
    if side == "in" {{
        `
{table(negations["in"], 12)}
        `
    }} else {{
        `
{table(negations["out"], 12)}
        `
    }}
}}

// The options that take a stream specifier (`-c:v`, "stream") or a metadata specifier (`-metadata:s:a`, "meta"), by
// name: those of ffmpeg marked so, and the generic options of libavcodec.
fn specifiers() {{
    #{{
{spec_items}
    }}
}}

// The options that take no value (OPT_TYPE_BOOL and the options that print something), in an input or an output.
fn switches() {{
    #{{
{switch_items}
    }}
}}

// The constants of a generic option of type flags, by `SIDE:NAME`.
fn flags(key) {{
    switch key {{
{flag_cases}
        _ => [],
    }}
}}
""")
print("ok", len(tables["in"]), "options of an input,", len(tables["out"]), "of an output")
