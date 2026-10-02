# Colour schemes

The plugin `themes` (`extra/themes`, if the repository was added as `extra`) defines colour schemes for luish's
syntax highlighting, completion menu and suggestions. It needs a luish with colour schemes (newer than 0.3.0). Each
scheme comes in a pair, for dark and light backgrounds:

| Dark               | Light              | Colours                                                    |
|--------------------|--------------------|------------------------------------------------------------|
| `ansi-dark`        | `ansi-light`       | the terminal's own 16, so they follow its palette          |
| `solarized-dark`   | `solarized-light`  | [Solarized](https://ethanschoonover.com/solarized/)        |
| `gruvbox-dark`     | `gruvbox-light`    | [gruvbox](https://github.com/morhetz/gruvbox)              |
| `catppuccin-mocha` | `catppuccin-latte` | [Catppuccin](https://catppuccin.com/palette)               |
| `tokyonight-night` | `tokyonight-day`   | [Tokyo Night](https://github.com/folke/tokyonight.nvim)    |

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
- syntax errors are underlined red, and with `setopt highlight.paths`, files are underlined.

## Colours and terminals

The schemes other than `ansi` write their palette's colours as `#rrggbb`, which needs a terminal with 24-bit colour
(most have it). They leave the background and the text colour to the terminal, so they look as meant when the
terminal is set to the same palette (most terminals ship Solarized, gruvbox, Catppuccin and Tokyo Night). `ansi-dark`
and `ansi-light` use the terminal's 16 colours instead, so they follow whatever palette it has; `ansi-light` leaves out
yellow and the bright colours, which are hard to read on a light background.

Solarized and Catppuccin Latte are soft palettes, with colours that contrast less with the background than the
others'. `catppuccin-latte` departs from Catppuccin's style guide where its colours are hardest to read: variables
are teal rather than yellow, escapes maroon rather than pink, and operators in the text colour.
