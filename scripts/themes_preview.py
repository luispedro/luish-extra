#!/usr/bin/env python3
"""Draw the colour schemes of themes/ on sample command lines, as HTML for docs/themes.md.

The styles are those luish resolved for each scheme, read from tests/themes.expected, so run
`UPDATE=1 tests/run.sh themes` first after changing a scheme. Writes docs/themes_preview.html, a fragment with
its own <style> that the docs include; `scripts/themes_preview.py FILE` writes it to FILE instead.

Each scheme is drawn on the background and text colour that its `terminal` table in themes/plugin.toml sets in the
terminal, and the ansi ones, which set none, on the Tango palette's 16 colours, on backgrounds chosen here
(ANSI_BACKGROUND). Each terminal says which.
"""
import html
import os
import re
import sys
import tomllib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# The 16 colours of the Tango palette (GNOME Terminal's), for the ansi schemes, and 136 of the 256.
TANGO = dict(black="#2e3436", red="#cc0000", green="#4e9a06", yellow="#c4a000", blue="#3465a4",
             magenta="#75507b", cyan="#06989a", white="#d3d7cf")
TANGO_BRIGHT = dict(black="#555753", red="#ef2929", green="#8ae234", yellow="#fce94f", blue="#729fcf",
                    magenta="#ad7fa8", cyan="#34e2e2", white="#eeeeec")
XTERM_256 = {"136": "#af8700"}

# The backgrounds and text colours of the ansi schemes, which set none of the terminal's colours: chosen here.
ANSI_BACKGROUND = {
    "ansi-dark": ("#1a1b1e", "#d3d7cf"),
    "ansi-light": ("#fbfbf8", "#2e3436"),
}
# Each scheme's background and text colour, and where they come from (read_backgrounds).
BACKGROUND = {}


def scheme_names():
    return [scheme for _, dark, light, _ in FAMILIES for scheme in (dark, light)]


def read_backgrounds(path):
    """Each scheme's background and text colour, and where they come from: those that its `terminal` table sets
    (or that of a scheme it inherits from), else ANSI_BACKGROUND's."""
    schemes = tomllib.load(open(path, "rb"))["colorscheme"]
    out = {}
    for name in scheme_names():
        if name in ANSI_BACKGROUND:
            out[name] = (*ANSI_BACKGROUND[name], "chosen for this page, with the Tango palette")
            continue
        terminal, cur = {}, name
        while cur:
            for k, v in schemes[cur].get("terminal", {}).items():
                terminal.setdefault(k, v)
            cur = schemes[cur].get("inherits")
        out[name] = (terminal["background"], terminal["foreground"], "the colours the scheme sets in the terminal")
    return out

FAMILIES = [
    ("ansi", "ansi-dark", "ansi-light",
     "The terminal's own 16 colours: they follow whatever palette it has, and need no 24-bit colour. "
     "Drawn here with the Tango palette (public domain)."),
    ("solarized", "solarized-dark", "solarized-light",
     "The same eight accents on both backgrounds; only the greys change. Soft by design. "
     "Colours: Solarized, by Ethan Schoonover (MIT)."),
    ("gruvbox", "gruvbox-dark", "gruvbox-light",
     "Bright accents on the dark background, faded ones on the light. Keywords red, as gruvbox has them. "
     "Colours: gruvbox, by Pavel Pertsev (MIT/X11)."),
    ("catppuccin", "catppuccin-mocha", "catppuccin-latte",
     "Mocha and Latte, after Catppuccin's style guide. Latte trades a few pastels for darker colours that read "
     "on its background. Colours: Catppuccin's palette (MIT)."),
    ("tokyonight", "tokyonight-night", "tokyonight-day",
     "Night and Day. Options take the colour of parameters, special variables that of built-in ones. "
     "Colours: tokyonight.nvim, by Folke Lemaitre (Apache-2.0), after Enkia's Tokyo Night (MIT)."),
]

# The sample lines, as (role, text); None is text with no role, "cursor" the cursor, and "A+B" both styles.
LINES = [
    [("comment", "# map the reads of each sample, then sort them")],
    [("keyword", "for"), (None, " s "), ("keyword", "in"), (None, " "), ("arg", "*.fq.gz"), ("op.control", ";"),
     (None, " "), ("keyword", "do"), (None, " "), ("command.external", "bwa"), (None, " "), ("arg", "mem"),
     (None, " "), ("arg.option", "-t"), (None, " "), ("arg", "8"), (None, " "), ("arg", "ref.fa"), (None, " "),
     ("string.double", '"'), ("var", "$s"), ("string.double", '"'), (None, " "), ("redir", ">"), (None, " "),
     ("string.double", '"'), ("var", "${s%.fq.gz}"), ("string.double", '.sam"'), ("op.control", ";"), (None, " "),
     ("keyword", "done")],
    [("command.precommand", "sudo"), (None, " "), ("assign", "LC_ALL="), ("arg", "C"), (None, " "),
     ("command.external", "sort"), (None, " "), ("arg.option", "-k2,2"), (None, " "), ("arg", "counts.tsv"),
     (None, " "), ("op.pipe", "|"), (None, " "), ("command.function", "topn"), (None, " "), ("arg", "20"),
     (None, " "), ("redir.fd", "2"), ("redir", ">"), ("arg", "/dev/null")],
    [("keyword", "if"), (None, " "), ("keyword", "[["), (None, " "), ("arg.option", "-z"), (None, " "),
     ("var.unset", "$OUTDIR"), (None, " "), ("keyword", "]]"), ("op.control", ";"), (None, " "), ("keyword", "then"),
     (None, " "), ("command.builtin", "echo"), (None, " "), ("string.single", "'no output dir:'"), (None, " "),
     ("string.double", '"using '), ("string.escape", "\\$"), ("string.double", "HOME="), ("var.exported", "$HOME"),
     ("string.double", '"'), ("op.control", ";"), (None, " "), ("keyword", "fi")],
    [("command.alias", "ll"), (None, " "), ("expand.tilde", "~"), ("arg", "/data/"), ("expand.brace", "{"),
     ("arg", "raw"), ("expand.brace", ","), ("arg", "clean"), ("expand.brace", "}"), ("arg", "/"),
     ("expand.glob", "*"), ("arg", ".bam"), (None, " "), ("op.control", "&&"), (None, " "),
     ("command.builtin", "echo"), (None, " "), ("subst.command", "$("), ("command.external", "date"), (None, " "),
     ("arg", "+%F"), ("subst.command", ")"), (None, " "), ("var.special", "$?"), (None, " "),
     ("var.array", "${runs[1]}"), (None, " "), ("var.readonly", "$UID")],
    [("command.unknown", "samtoools"), (None, " "), ("arg", "view"), (None, " "), ("arg", "in.bam"), (None, " "),
     ("string.double+error", '"chr1:100-200')],
    [("command.external", "samtools"), (None, " "), ("arg", "s"), ("cursor", ""),
     ("suggestion", "ort -@ 4 -o sorted.bam in.bam")],
]
MENU = [("sort", "sort alignment file"), ("split", "split a file by read group"),
        ("stats", "comprehensive statistics")]

STYLE = """<style>
.lx-themes { display: grid; gap: 1.6rem; margin: 1rem 0 1.5rem; }
.lx-themes .lx-note { margin: 0; }
.lx-fam { display: grid; gap: .6rem; }
.lx-fam > p { margin: 0; }
.lx-fam > p b { font-family: var(--font-stack--monospace, ui-monospace, monospace); }
.lx-pair { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 40em), 1fr)); gap: .8rem; }
.lx-term { margin: 0; border-radius: 6px; overflow: hidden; min-width: 0;
  box-shadow: 0 0 0 1px var(--color-background-border, #d6d9d5); }
.lx-term figcaption { display: flex; flex-wrap: wrap; gap: 0 1.2ch; justify-content: space-between;
  padding: .45rem .9rem 0; font-family: var(--font-stack--monospace, ui-monospace, monospace); font-size: .72rem; }
.lx-term figcaption b { font-weight: 700; }
.lx-term figcaption span { opacity: .75; }
.lx-scr { font-family: var(--font-stack--monospace, ui-monospace, monospace); font-size: .76rem; line-height: 1.6;
  padding: .35rem .9rem .9rem; overflow-x: auto; white-space: pre; }
.lx-ps { opacity: .55; }
.lx-cur { display: inline-block; width: .55em; height: 1.15em; vertical-align: text-bottom; opacity: .75; }
.lx-menu { margin: 2px 0 0 2ch; display: grid; width: max-content; }
.lx-mi { display: flex; gap: 3ch; padding: 0 1ch; }
.lx-mw { min-width: 6ch; }
</style>"""


def read_styles(path):
    """The styles of each scheme, from the listing that `style` prints in tests/themes.expected."""
    schemes, cur = {}, None
    for line in open(path):
        if line.startswith("--- "):
            m = re.match(r"--- (\S+)$", line)
            cur = m.group(1) if m and m.group(1) in scheme_names() else None
            if cur:
                schemes[cur] = {}
        elif cur and re.match(r"[a-z]", line):
            name, value = line.split(None, 1)
            schemes[cur][name] = value.strip()
    missing = set(scheme_names()) - set(schemes)
    if missing:
        sys.exit(f"themes_preview: not in {path}: {', '.join(sorted(missing))}")
    return schemes


def colour(c, text):
    if c.startswith("#"):
        return c
    if c.startswith("bright-"):
        return TANGO_BRIGHT[c[len("bright-"):]]
    if c in TANGO:
        return TANGO[c]
    if c in XTERM_256:
        return XTERM_256[c]
    if c == "default":
        return text
    sys.exit(f"themes_preview: no colour for {c}")


def css(value, scheme):
    """CSS for a style's value."""
    bg, text, _ = BACKGROUND[scheme]
    words = value.split()
    if "plain" in words:
        return ""
    out, lines, fg, back, reverse = [], [], None, None, False
    for w in words:
        if w == "bold":
            out.append("font-weight:700")
        elif w == "italic":
            out.append("font-style:italic")
        elif w == "underline":
            lines.append("underline")
        elif w == "strike":
            lines.append("line-through")
        elif w == "dim":
            out.append("opacity:.6")
        elif w == "reverse":
            reverse = True
        elif w.startswith("bg:"):
            back = colour(w[3:], text)
        else:
            fg = colour(w, text)
    if reverse:  # as a terminal does: the colours swap, the defaults too
        fg, back = back or bg, fg or text
    if fg:
        out.append(f"color:{fg}")
    if back:
        out.append(f"background:{back}")
    if lines:
        out.append("text-decoration:" + " ".join(lines) + ";text-underline-offset:3px")
    return ";".join(out)


def terminal(scheme, styles):
    bg, text, source = BACKGROUND[scheme]
    st = styles[scheme]
    rows = []
    for line in LINES:
        parts = []
        for role, s in line:
            if role is None:
                parts.append(html.escape(s))
            elif role == "cursor":
                parts.append(f'<span class="lx-cur" style="background:{text}"></span>')
            else:
                style = ";".join(css(st[r], scheme) for r in role.split("+"))
                parts.append(f'<span style="{style}" title="{role.split("+")[0]}">{html.escape(s)}</span>')
        rows.append(f'<div><span class="lx-ps">$</span> {"".join(parts)}</div>')
    items = []
    for i, (word, desc) in enumerate(MENU):
        selected = css(st["menu.selected"], scheme) if i == 0 else ""
        # luish draws the selected row in menu.selected alone, without menu.description.
        described = "" if i == 0 else css(st["menu.description"], scheme)
        items.append(f'<div class="lx-mi" style="{selected}"><span class="lx-mw">{word}</span>'
                     f'<span style="{described}">{desc}</span></div>')
    rows.append(f'<div class="lx-menu">{"".join(items)}</div>')
    return (f'<figure class="lx-term" style="background:{bg};color:{text}">'
            f'<figcaption><b>{scheme}</b><span title="{source}">on {bg}, text {text}</span></figcaption>'
            f'<div class="lx-scr">{"".join(rows)}</div></figure>')


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "docs", "themes_preview.html")
    BACKGROUND.update(read_backgrounds(os.path.join(ROOT, "themes", "plugin.toml")))
    styles = read_styles(os.path.join(ROOT, "tests", "themes.expected"))
    parts = [f"<!-- Written by scripts/themes_preview.py from tests/themes.expected; don't edit. -->", STYLE,
             '<div class="lx-themes">',
             '<p class="lx-note">Each scheme other than <code>ansi</code> also sets the terminal\'s background and '
             "text colour (unless <code>terminal-colors = false</code>), and is drawn here on them; each terminal says which. The <code>ansi</code> pair sets none, and is drawn with the "
             "Tango palette on backgrounds chosen for this page: in your terminal it takes the terminal's colours. "
             "Hover over a word to see its role. The palettes are other people's; "
             '<a href="https://github.com/luispedro/luish-extra/blob/main/themes/README.md">themes/README.md</a> '
             "says where each comes from, under which license.</p>"]
    for name, dark, light, blurb in FAMILIES:
        parts.append(f'<section class="lx-fam"><p><b>{name}</b>: {html.escape(blurb)}</p>'
                     f'<div class="lx-pair">{terminal(dark, styles)}{terminal(light, styles)}</div></section>')
    parts.append("</div>")
    with open(out, "w") as f:
        f.write("\n".join(parts) + "\n")


if __name__ == "__main__":
    main()
