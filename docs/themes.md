# Colour schemes

The plugin `themes` (`extra/themes`, if the repository was added as `extra`) defines colour schemes for luish's
syntax highlighting, completion menu and suggestions. It needs luish 0.4.0 or later. Each scheme comes in a pair, for
dark and light backgrounds:

| Dark               | Light              | Colours                                                    |
|--------------------|--------------------|------------------------------------------------------------|
| `ansi-dark`        | `ansi-light`       | the terminal's own 16, so they follow its palette          |
| `solarized-dark`   | `solarized-light`  | [Solarized](https://ethanschoonover.com/solarized/)        |
| `gruvbox-dark`     | `gruvbox-light`    | [gruvbox](https://github.com/morhetz/gruvbox)              |
| `catppuccin-mocha` | `catppuccin-latte` | [Catppuccin](https://catppuccin.com/palette)               |
| `tokyonight-night` | `tokyonight-day`   | [Tokyo Night](https://github.com/folke/tokyonight.nvim)    |

Here they are on a few command lines, each drawn with the styles that luish resolves for it, with a completion menu
and a suggestion:

```{raw} html
:file: themes_preview.html
```

## Choosing one

Loading the plugin only makes the schemes available. Choose a pair in `config.toml`, and luish takes the one that
fits the terminal's background, which it asks the terminal for (or reads from `$LUISH_BACKGROUND`):

```toml
[plugins.enabled]
extra.themes = "*"

[style]
colorscheme = { dark = "tokyonight-night", light = "tokyonight-day" }
```

`style -c` lists the schemes, and `style -c NAME` (or `style -c DARK LIGHT`) tries one in the running shell. Styles
set in `[style]` or with `style NAME VALUE` still go over the scheme's.

## What the colours say

The schemes differ in their colours, not in what they mark:

- commands have one colour, whatever their kind: functions are bold, aliases italic, and unknown commands bold red;
  `sudo`, `env`, `exec` and the other commands that run a command are italic in the colour of keywords;
- keywords are bold, in a colour of their own;
- options have a colour of their own; other arguments are left in the terminal's text colour;
- strings have one colour; escapes, `$(...)` and the expansions (`~`, `{a,b}`, `*`) stand out from it;
- variables have one colour, which the `NAME=` of an assignment shares: exported ones are bold, arrays italic,
  special and read-only ones (`$?`, `$1`) in a second colour, and unset ones italic red;
- operators and redirections are bold; the file descriptors of redirections are in the colour of numbers;
- comments are italic, in the palette's colour for comments, which suggestions and descriptions in the menu share;
- syntax errors are underlined red, and with `setopt highlight.paths`, files are underlined;
- in the output of `plugin`, names are bold, what worked green, what changed (or can) yellow, warnings orange
  where the palette has it, errors bold red, and details in the colour of the menu's descriptions.

## Colours and terminals

The schemes other than `ansi` write their palette's colours as `#rrggbb`, which needs a terminal with 24-bit colour
(most have it). They also set the terminal's own colours while they are in use: its background, text and cursor
colours, and the 16 colours that other programs use (`ls --color`, `git diff`), as the palette's authors give them
for terminals. luish puts back the terminal's colours when the scheme is no longer in use and when it exits (see
luish's [The terminal's colours](https://luish.readthedocs.io/en/latest/usage.html#the-terminals-colours)); the
terminal must accept the colours (xterm, GNOME Terminal and other VTE ones, kitty, foot, Alacritty, WezTerm and iTerm2
do; tmux and screen may not pass them on). To keep your terminal's own colours, with the schemes' colours only on the
command line:

```toml
[style]
terminal-colors = false
```

The dark or light member of a pair is still chosen by the terminal's own background, before the scheme changes it.

`ansi-dark` and `ansi-light` set none of the terminal's colours, and use its 16 colours, so they follow whatever
palette it has; `ansi-light` leaves out yellow and the bright colours, which are hard to read on a light
background.

Solarized and Catppuccin Latte are soft palettes, with colours that contrast less with the background than the
others'. `catppuccin-latte` departs from Catppuccin's style guide where its colours are hardest to read: variables
are teal rather than yellow, escapes maroon rather than pink, and operators in the text colour.

## Where the colours come from

The palettes are other people's work, and every `#rrggbb` colour in these schemes is one of theirs. What luish-extra
adds is which colour marks which part of a command line, and the changes to `catppuccin-latte` above. Their
licenses allow this; copies are in
[`themes/LICENSES`](https://github.com/luispedro/luish-extra/tree/main/themes/LICENSES), and
[`themes/README.md`](https://github.com/luispedro/luish-extra/blob/main/themes/README.md) has the details.

| Schemes | Palette, by | License |
|---|---|---|
| `solarized-*` | [Solarized](https://github.com/altercation/solarized), by Ethan Schoonover | MIT |
| `gruvbox-*` | [gruvbox](https://github.com/morhetz/gruvbox), by Pavel Pertsev | MIT/X11 (as its README says; it has no license file) |
| `catppuccin-*` | [Catppuccin](https://github.com/catppuccin/palette)'s Mocha and Latte | MIT |
| `tokyonight-*` | the night and day styles of [tokyonight.nvim](https://github.com/folke/tokyonight.nvim), by Folke Lemaitre, ported from Enkia's [Tokyo Night](https://github.com/tokyo-night/tokyo-night-vscode-theme) | Apache-2.0; the original MIT |

The `ansi` pair uses only the terminal's own colours. The preview above draws it with the
[Tango palette](https://en.wikipedia.org/wiki/Tango_Desktop_Project), which is in the public domain. None of these
projects endorses luish-extra; the schemes carry their palettes' names to say where the colours come from.
