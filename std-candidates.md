# Moving code from luish-extra to luish and its std plugins

Notes from a review (2026-09-30) of which parts of luish-extra belong in luish itself (the `sh::`/`fs::` modules every
extension gets) or in std's `completion` plugin (`../luish/luish-std-plugins/completion`). Done items record what
changed; the rest is still to do.

## Shared helpers: now in `extra-lib`

The copies of items 1, 2, 4 and 5 are now one each in `complete/extra-lib`, a library plugin (luish 9e3a39b) that
`bio`, `science` and `dev` depend on. Moving them to std would make luish-extra wait for a luish release, since each
release of luish takes std from its own tag.

1. **`with_suffix(cur, suffixes)`**: in `extra-lib/files.rhai`, with an optional third argument, directories to
   leave out (`dev`: `["__pycache__"]`). Still worth having in std: std has two `with_ext`s that differ
   (`bridges.rhai`: extensions without the dot; `tools.rhai`: suffixes with it), which one `kinds::with_suffix` would
   replace. When std has it, `extra-lib`'s can call it or go.
2. **`is_name(s)`**: in `extra-lib/text.rhai`, with `sh::matches`, rejecting `""` and a leading `-` (the ruff caller
   allows an empty section itself). std checks names inline with `sh::matches` (`lib::help_of`, `bridges.rhai`), so
   it doesn't need its own.
4. **`compressed(suffixes)`**: in `extra-lib/files.rhai`.
5. **String helpers** (`last_of`, `last_index`, `indent`, `ident`): in `extra-lib/text.rhai`.

## To do: reading options from `-h` generically

The same pattern (`help_spec(help_of(prog))`, `guess_values`, a `sub_spec` that re-reads `PROG SUB -h`, clap's `help`
subcommand) is in `complete/bio/dynamic.rhai` (mmseqs), `complete/science/dynamic.rhai` (xsv, qsv),
`complete/dev/dynamic.rhai` (ruff), and std's cargo, rustup (`dev.rhai`), uv and pixi (`langs.rhai`).

6. A generic `sub_spec` in std (e.g. `"@std/completion/lib:help"`) that re-reads `-h` for the growing command path,
   so that each tool gives only its overrides (values, argument kinds).
7. `help_spec` should take a tab as a column gap: mmseqs lists `  NAME<TAB>desc`, which is why it has its own parser.
   (qsv's `--list` has a single space before the longest name's description; see `qsv_commands`.)
8. `help_of` should take `sh::capture`'s stderr argument (and perhaps the help flag): mmseqs needs `"merge"`, so it
   calls `sh::capture` itself.

## To decide

9. **`sh::matches(pattern, s)`** in luish, with the shell's own glob matching (as `case` and `[[ ]]`). It would replace
    std's Rhai reimplementation `kinds::glob_match` (ssh_config `Host` patterns) and make name checks one line
    (`!sh::matches("*[!A-Za-z0-9._-]*", s)`). Not yet checked how the matcher is exposed inside luish. [DONE]
10. **An `env` option for `sh::capture`**: optional; `["env", ...]` works but costs an extra exec per call.
11. **Runtime `import`**: this repo's CLAUDE.md says "an `import` can't be chosen at run time, so `extension.rhai` has
    one completer function per module", yet std's `extension.rhai` does `let m = module_of[words[0]]; import m as
    specs;` inside the completer. Check which is true here; if the std pattern works, a helper such as
    `lib::register(commands, module)` would replace the wrapper functions (`ours`, `hts`, `align`, ...) in each
    `extension.rhai`. Checked (2026-10-01): an `import` of a name in a variable works, in a function of
    `extension.rhai` as in std's completer, so the CLAUDE.md note is out of date. Related: the "closures made in a
    module fail in Rhai 1.26.1" note is a Rhai/luish issue to fix upstream, not code to move.

## Possible follow-ups inside luish

- `src/plugins/fetch.rs` runs git through `super::capture` with a shell string built with `shell_quote`; it could use
  `capture_argv` (with `Stderr::Inherit`).
- `command -v` (`src/builtins/misc.rs`) uses `find_in_path`, which falls back to a non-executable file; compare
  with dash before changing anything.
