# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## State of the repository

luish-extra is a plugin collection for [luish](https://github.com/luispedro/luish) (a sibling checkout at `../luish`):
completion modules that don't belong in luish's standard library (`std`), in plugins `bio`, `science`, `gui`, `dev`
and `system`. **No plugin code exists yet.** The repository holds planning and documentation only, and the scaffold
in `PLAN.md` ("Layout", "Next steps") is still to be built. Rhai (luish's scripting language) is the implementation
language: `plugin.toml` + `extension.rhai` per plugin.

There is no build, lint or test tooling yet. The only buildable thing is the Read the Docs site
(`.readthedocs.yaml`, Sphinx + MyST + furo, `fail_on_warning: true`):

```sh
pip install -r docs/requirements.txt
sphinx-build -W docs docs/_build
```

`docs/requirements.txt` says it is kept in step with a `docs` feature in `pixi.toml`, which doesn't exist yet.
The planned tests (`tests/run.sh`, `tests/bio_*.sh` with `.expected`) will load std's `completion` plugin and this
repo's plugin, then run `__luish_internal complete LINE`, with stand-in programs in `~/bin`. They should follow
`../luish/tests/plugins/std_completion*.sh`.

## Documents and what is authoritative

- `docs/completion.md`: **the authoritative list of commands** to complete, grouped by plugin and section. Add or
  remove commands here first.
- `completion-todo.md`: a checkbox list derived from `docs/completion.md`, one line per command. Keep the two in
  step; the TODO has no generator script.

## Design decisions to keep in mind

- Requires luish at rev `c744056c3718f7f383f610c8ef07a526faccc0f2` or later.
- Plugin naming is `SOURCE.NAME`, one level only. These plugins form a collection `extra-complete` (`subdir =
  "complete"`) enabled as `extra-complete.bio`, and so on. Other kinds of plugin would be further collections.
- Completion is by **command name, not Bioconda package name** (`star` → `STAR`, `subread` → `featureCounts`,
  `entrez-direct` → `esearch`/`efetch`). Check the real executables.
- Commands that std's `completion` plugin already covers (`fd`, `rg`, `jq`, `uv`, `pixi`, `conda`, `docker`, …) are
  deliberately not repeated. Go/Cobra tools may work through std's `PROG __complete` bridge with no spec (prefer that
  where its completion is good).
- Modules import lazily, inside the completer, so each one is compiled on first Tab. Kinds and `sub_spec` are named
  as qualified strings (`"@extra-complete/bio/kinds:fasta"`) because closures made in a module fail in Rhai 1.26.1
  when `lib.rhai` calls them.
- Spec style follows std: short lowercase descriptions, `values` for option values (`"none"` for free text), `args`
  with kinds.
