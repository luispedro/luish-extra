# Developing

How to add a command to luish-extra, step by step. The reference for the conventions (what each module holds, the
quirks of Rhai met so far, how caching and releases work) is
[`CLAUDE.md`](https://github.com/luispedro/luish-extra/blob/main/CLAUDE.md). This page is the path through it.

## Setting up

You need:

- luish 0.7 or later, in `PATH` or given as `LUISH`;
- a checkout of [luish](https://github.com/luispedro/luish) next to this one (`../luish`), for std's plugins, whose
  completion engine the plugins use (`STD_PLUGINS`, by default `../luish/luish-std-plugins`);
- Python 3.11 or later, for the scripts;
- [pixi](https://pixi.sh/), for the scripts that run a tool: `pixi exec` runs it in a temporary environment, with
  Bioconda and conda-forge, so nothing is installed.

Then run the tests:

```sh
tests/run.sh                       # every case
tests/run.sh bio_align gui_media   # some cases, by name without .sh
```

## How a plugin is laid out

Each completion plugin (`completion/bio`, `completion/science`, ...) has:

- `plugin.toml`, which says which luish it needs (`luish-version = "0.7"`) and what it depends on (`std.completion`,
  and `extra-lib`, the helpers that the plugins share);
- `extension.rhai`, which registers a completer for each command. Its `module_of` map gives the module of each
  command. A module is imported only on the first Tab for one of its commands, so a shell start costs nothing per
  module;
- modules of specs, one per family of tools (`align.rhai`, `blast.rhai`, ...), each with `fn spec(cmd)`;
- `kinds.rhai`, with `fn kind(name, cur, words)`: what an argument or the value of an option completes to (FASTA
  files, the reference names of a BAM, the rules of a Snakefile).

A spec is a map (`opts`, `values`, `args`, `commands`, `subs`, ...) that std's completion engine completes from. luish
documents its fields and the format of the option tables in
[Reusing std's completion engine](https://luish.readthedocs.io/en/latest/extensions.html#reusing-std-s-completion-engine).
`completion/system/tools.rhai` is a short example of a module.

`media` (ffmpeg) and `hpc` (Slurm) have a completer of their own rather than specs, and so do a few commands
elsewhere (`nextflow`, `mpv`, `code`, `xdotool`, `git-annex`). Start from a spec unless the line itself decides what
an option means.

## Adding a tool

The [commit that added pyrodigal](https://github.com/luispedro/luish-extra/commit/af48d70) is a complete example. It touched the generator, the generated
module, `extension.rhai`, a test, `completion-todo.md`, the README, the ChangeLog and `CLAUDE.md`.

### 1. Check that it is on the list, and how it should be completed

[](completion.md) is the list of commands to complete, and `completion-todo.md` has a box for each. A command goes
on the list in `docs/completion.md` first.

Completion is by command name, not by package name: `STAR`, not `star`; `featureCounts`, not `subread`. Install
the package, or look at its recipe, to see which executables it brings.

Before writing a spec, check whether one is needed:

- std's `completion` plugin may already complete the command (`fd`, `rg`, `uv`, `docker`, ...). Then it isn't
  repeated here.
- A Python program built with Click completes itself. `scripts/clickcheck.sh PACKAGE PROG [WORD]...` checks that it
  answers std's Click bridge and times it. A program that answers in under a second is one name in a list of
  `extension.rhai`; a slower one is left to the user (`complete-click PROG`). Read the output: not every program
  with `click` among its dependencies is a Click program.
- A Go program built with Cobra completes itself too: `PROG __complete ''` answers with its subcommands. It is
  registered with std's Cobra bridge, also in `extension.rhai`.

### 2. Choose the module

A tool goes in the module of its family (`reads.rhai` for read QC and trimming, `profile.rhai` for taxonomic
profilers, ...). `CLAUDE.md` says what each module holds. A new module needs `fn own(name)` and `fn spec(cmd)`, as
the others have, and an entry in `module_of`.

Some modules are **generated**: `CLAUDE.md` lists them. In one of those, the spec is
added to the generator (`scripts/gen/mk_MODULE.py`), which is then rerun. An edit to the `.rhai` itself would be
undone by the next run.

### 3. Write the spec from the tool's own help

Option tables are written from the real `--help` of a pinned version, never from memory or from the manual of
another version:

```sh
pixi exec -c conda-forge -c bioconda -s pyrodigal=3.7.1 -- pyrodigal --help </dev/null
```

Always give the tool `</dev/null`: some read standard input when it is a terminal (`samtools sort` waits for it).

By hand, `scripts/help2opts.py` drafts the `opts` and `values` of a spec from a help text on standard input. Read
the draft before using it, as help formats differ in many small ways. Descriptions are short and lowercase, as in
std's specs. `values` gives what the value of each option completes to: a kind, a list of choices, or `"none"` for
free text.

A generator is worth it when the table is long, when the tool is one of a family whose help has the same shape,
or when the program uses argparse. `gen.argparse_dump` then runs the program's own parser and gives its options with
their choices and number of values. The generators stop at an option they have no kind for, so the options of a
new version are always looked at. `CLAUDE.md` describes their helpers.

### 4. Add kinds for what the values are

A value that is a file of some type (`-i` takes a FASTA file) gets a kind of `kinds.rhai`, named in the spec as
`own("kinds:fasta")` (most modules define `fn k(name)` for it: `k("fasta")`). Look for an existing kind first. A new one is
a case of `kind()`'s `switch`, usually with `lib_files::with_suffix` from `extra-lib`.

A kind that runs a program goes through `sh::capture` with a list of arguments (no shell string), or
`sh::capture_cached` for output that changes seldom. A kind that reads files keeps what it builds with
`sh::cache_get`/`sh::cache_put`, keyed by the files. `CLAUDE.md` gives the time each kind of data is kept for.

Never write the name of the source (`@extra/...`): users name it as they like. Import this repository's modules by
relative path (`import "../extra-lib/files" as lib_files;`).

### 5. Register the command

Add the command to its module's entry in `module_of`, in the plugin's `extension.rhai`.

### 6. Test it

The tests are `tests/PLUGIN_NAME.sh`, usually one per module (`tests/bio_asm.sh`), each with its expected output
beside it (`tests/bio_asm.expected`). A case loads the plugin and completes lines:

```sh
c 'pyrodigal --'
c 'pyrodigal -g '
c 'pyrodigal -i data/'
```

Add a line for each option, argument or kind that does something more than offer filenames. Then write the
snapshot and read its diff, since it is a snapshot, not a check:

```sh
UPDATE=1 tests/run.sh bio_asm
git diff tests/bio_asm.expected
```

Each case runs under `env -i`, in a fresh directory that is also `$HOME`, and anything on standard error fails it.
A program that a kind runs is stood in for by a script in `tests/bin`. A test that depends on what is in `PATH` sets
`PATH` itself.

`scripts/optcheck.sh PKG=VERSION PROG [SUB]...` then compares the spec with the tool's help, and lists the options
that only one of them has. For a finished spec, what it prints is only noise from the prose of the help.

### 7. Record it

- Tick the tool in `completion-todo.md`, with the version you checked it against (`- [x] \`pyrodigal\`: pyrodigal
  3.7.1`).
- Add it to its plugin's "Done:" list in `README.md`, and run `scripts/counts.py`, which prints the counts table of
  the README's "What is supported". CI runs `scripts/counts.py --check`.
- Add a line for users to the `Unreleased` section of `ChangeLog` (`* bio: completion for pyrodigal`).
- Add it to the list of what the module holds in `CLAUDE.md`.

## Moving a generated module to a new version

Change the pin in the generator and rerun it (`python3 scripts/gen/mk_asm.py`). Then read the diff of the module
and of the tests' `.expected`, and update the version in `completion-todo.md`. The help texts are cached in
`~/.cache/luish-extra/help` (`HELP_CACHE`), so a rerun at the same versions needs no network.

## Before committing

```sh
tests/run.sh
scripts/counts.py --check
sphinx-build -W docs docs/_build     # after pip install -r docs/requirements.txt
```

Releases are described in `CLAUDE.md`, with `scripts/release.sh`.
