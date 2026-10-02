# Where the colours come from

The schemes in `plugin.toml` are adaptations of other people's palettes. The colours are theirs, and nearly every
one is taken as it is. What is ours is which colour goes to which part of a command line, and the few changes noted
below. Copies of the upstream licenses are in [`LICENSES/`](LICENSES/). The rest of luish-extra, this mapping
included, is under the MIT License ([`../COPYING.MIT`](../COPYING.MIT)).

| Schemes | Palette | By | Taken from | License |
|---|---|---|---|---|
| `solarized-dark`, `solarized-light` | Solarized | Ethan Schoonover | [altercation/solarized](https://github.com/altercation/solarized) | MIT, © 2011 Ethan Schoonover ([`LICENSES/solarized.txt`](LICENSES/solarized.txt)) |
| `gruvbox-dark`, `gruvbox-light` | gruvbox | Pavel Pertsev (morhetz) | [morhetz/gruvbox](https://github.com/morhetz/gruvbox), `colors/gruvbox.vim` | MIT/X11, as its README and `package.json` say (the repository has no license file) |
| `catppuccin-mocha`, `catppuccin-latte` | Catppuccin (Mocha, Latte) | Catppuccin | [catppuccin/palette](https://github.com/catppuccin/palette), and the [style guide](https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md) for which colour marks what | MIT, © 2021 Catppuccin ([`LICENSES/catppuccin.txt`](LICENSES/catppuccin.txt)) |
| `tokyonight-night`, `tokyonight-day` | Tokyo Night (night and day styles) | Folke Lemaitre, after Enkia's theme | [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim), `extras/`; ported from [Tokyo Night for VS Code](https://github.com/tokyo-night/tokyo-night-vscode-theme) | Apache-2.0 ([`LICENSES/tokyonight.nvim.txt`](LICENSES/tokyonight.nvim.txt)); the original theme MIT, © 2018-present Enkia ([`LICENSES/tokyo-night-vscode-theme.txt`](LICENSES/tokyo-night-vscode-theme.txt)) |

`ansi-dark` and `ansi-light` name only the terminal's own colours (and 136 of the standard 256), so they take
nothing from anyone. The preview in the docs draws them with the colours of the
[Tango palette](https://en.wikipedia.org/wiki/Tango_Desktop_Project), which is in the public domain.

Changes from the palettes:

- `catppuccin-latte` doesn't follow Catppuccin's style guide everywhere: variables are teal rather than yellow,
  escapes maroon rather than pink, `$(` mauve, and operators in the text colour, as Latte's lighter colours are hard
  to read on its background. All of them are still Latte's colours.
- In Solarized, a match is reversed yellow, as Solarized's Vim scheme has its search matches.

These projects don't endorse luish-extra, and the names are theirs: each scheme is named after its palette only to
say where its colours come from.
