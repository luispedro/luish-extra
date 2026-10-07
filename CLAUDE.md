# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## State of the repository

luish-extra is a plugin collection for [luish](https://github.com/luispedro/luish) (a sibling checkout at `../luish`):
completion modules that don't belong in luish's standard library (`std`), in plugins `bio`, `science`, `gui`, `dev`
and `system`. Rhai (luish's scripting language) is the implementation language: `plugin.toml` + `extension.rhai` per
plugin.

`complete/bio`, `complete/science`, `complete/gui`, `complete/dev` and `complete/system` exist so far.
`complete/bio`: `extension.rhai` (registers the completers, one function per module), `kinds.rhai` (bio file kinds:
FASTA, BAM, index prefixes of aligners, reference names and samples of VCFs, ...) and, by family of tools, `ours.rhai`
(ngless, SemiBin2, macrel, argnorm), `hts.rhai` (samtools, bedtools, tabix, bgzip, htsfile), `bcftools.rhai`, `bam.rhai`
(sambamba, bamtools, samblaster, mosdepth, cramino, vcftools), `align.rhai` (bwa, bwa-mem2, bowtie2, hisat2, minimap2,
STAR, kallisto, featureCounts), `blast.rhai` (BLAST+), `diamond.rhai`, `hmmer.rhai`, `reads.rhai` (read QC, trimming and
filtering: fastp, fastqc, falco, cutadapt, trimmomatic, trim_galore, fastq_screen, seqtk, filtlong, chopper, nanoq,
rasusa, porechop, NanoPlot, NanoFilt, NanoStat), `asm.rhai` (assembly and annotation: spades.py, metaspades.py, megahit,
flye, quast, metaquast, busco, prodigal, prokka, bakta, barrnap), `meta.rhai` (metagenomics and microbial genomics:
rgi, so far), `profile.rhai` (taxonomic and functional profiling: kraken2, bracken, krakenuniq, centrifuge, kaiju,
metaphlan, humann, motus, and the programs that come with them: kraken2-build, k2, kaiju2table, strainphlan,
humann_renorm_table, ...), `bins.rhai` (binning and the quality, taxonomy and dereplication of MAGs: checkm,
checkm2, gunc, gtdbtk, metabat2 and jgi_summarize_bam_contig_depths, concoct and its scripts, run_MaxBin.pl, DAS_Tool and
Fasta_to_Contig2Bin.sh, dRep, coverm, vamb) and `dynamic.rhai` (mmseqs: the options are read from
the installed program's `-h` when Tab is pressed, through extra-lib's `help`; use it for programs whose help has a
regular format). Python programs built with Click (multiqc, genmod, cooler, ...) have no module: `extension.rhai`
registers them with std's Click bridge (`@std/completion/bridges`), only if they answer in under a second. Go programs
built with Cobra (seqkit, csvtk, taxonkit) are registered with std's Cobra bridge in the same way.

`complete/science`: `kinds.rhai` (files by extension; the rules of a Snakefile; the profiles, runs and projects of
Nextflow and the parameters of an nf-core pipeline's schema; pandoc's formats; ...), `workflow.rhai` (jug, nf-test),
`nextflow.rhai`, `quarto.rhai`, `tex.rhai` (pdflatex, xelatex, lualatex, bibtex, latexmk), `jupyter.rhai` (with
`jupyter_specs.rhai`), `tools.rhai` (duckdb, datamash, pigz, gnuplot, R, Rscript), `dynamic.rhai` (xsv and qsv, read
from `-h` like mmseqs), `bridges.rhai` (aws, through `aws_completer`) and the generated `snakemake.rhai`, `pandoc.rhai`,
`aria2.rhai`, `parallel.rhai`, `miller.rhai`, `cwltool.rhai`, `jupyter_specs.rhai`. `extension.rhai` also registers
apptainer and singularity (Cobra bridge) and nf-core (Click bridge).

`complete/dev`: `kinds.rhai` (pytest's tests in a file and markers; poetry's groups, extras, dependencies, locked
packages, scripts and sources from `pyproject.toml` and `poetry.lock`; `~/.pypirc`; ruff's rules and settings; bat's
languages and themes; claude's agents and codex's profiles), `python.rhai` (twine), `tools.rhai` (fzf, bat and batcat),
`agents.rhai` (opencode, a table: yargs help, and a start-up of most of a second), `dynamic.rhai` (ruff, codex and
claude, from their `-h` like mmseqs; claude is Commander, whose help `commander()` puts in clap's shape before std's
`help_spec` reads it: wrapped descriptions joined, `stop|kill <id>` as `stop, kill`, `(choices: ...)` as
`[possible values: ...]`) and the generated `pytest.rhai`, `mypy.rhai`, `poetry.rhai`. `complete/system`: `kinds.rhai` (borg
locations and compression specs, FUSE mount points from `/proc/mounts`), `tools.rhai` (fusermount, fusermount3) and the
generated `borg.rhai`. `complete/gui`: `kinds.rhai` (LibreOffice's filters and file types, read from the `.xcd` files of
its registry, found by following the `soffice` link in `PATH`; CUPS's printers; kate's sessions; GIMP's session files;
the object IDs of the SVG files on the line and the actions of `inkscape --action-list`; OBS's profiles, scene
collections and scenes; Firefox's, Thunderbird's and Chrome's profiles; VS Code's extensions and profiles; Krita's
workspaces and sessions; Artemis's `-D` properties; xrandr's outputs and modes, gsettings's schemas, keys and values,
dconf's paths and wmctrl's windows), `qt.rhai` (the options of every KDE program, from QCommandLineParser and Qt),
`browsers.rhai` (firefox, thunderbird, chromium, google-chrome), `documents.rhai` (libreoffice, soffice, evince, okular,
zathura, xdg-open), `editors.rhai` (code, with a completer of its own and its clap subcommands read through extra-lib's
`help`; meld, gedit, kate), `media.rhai` (vlc, cvlc, gimp, inkscape, krita, blender, obs, audacity, eog),
`viewers.rhai` (cytoscape, jalview, art, act, bamview, dnaplotter, tablet, pymol, chimerax, vmd), `desktop.rhai`
(xrandr, gsettings, dconf, notify-send, wmctrl, swaymsg, hyprctl, and xdotool, whose chained commands have a completer
of their own), the generated `bandage.rhai` (BandageNG) and `mpv.rhai` (its options read from the installed mpv's
`--list-options` when Tab is pressed, with a completer of its own, as nextflow has); proksee goes through std's Click
bridge. svn, netlify and adb (`dev`) are still to do. Every module has `fn spec(cmd)` (the generated ones too, ignoring
`cmd`), and `extension.rhai` maps each command to its module (`module_of`), so a new module needs an entry there;
nextflow, whose spec depends on the line, and mpv have completers of their own.

`themes` is a plugin of its own, beside the `complete` collection (`extra/themes`): only a `plugin.toml` with
`[colorscheme.NAME]` tables (luish's colour schemes), in pairs for dark and light backgrounds (`ansi`, `solarized`,
`gruvbox`, `catppuccin` mocha/latte, `tokyonight` night/day). Its header comment says what each role means in every
scheme (one colour for commands, functions bold, ...); a new scheme keeps to it, and its light member usually `inherits`
the dark one. luish reads a manifest's tables only in interactive shells, so `tests/themes.sh` runs `$LUISH -i`.
`docs/themes.md` and the README list the schemes; the preview in `docs/themes.md` is `docs/themes_preview.html`, written
by `scripts/themes_preview.py` from `tests/themes.expected` (the styles luish resolved), on the background and text
colour of each scheme's `terminal` table (`ANSI_BACKGROUND` for the `ansi` pair, which sets none). Each palette scheme
has a `[colorscheme.NAME.terminal]` table (background, foreground, cursor, the 16 colours of the palette), taken from
what the palette's authors give terminals (their kitty themes, or their own mapping), which luish sets while the scheme
is in use. After changing a scheme: `UPDATE=1 tests/run.sh themes`, read the diff, then rerun the script. The palettes
are other people's: `themes/README.md` says where each comes from and under which license, `themes/LICENSES/` has the
license texts, and a scheme's colours are its palette's own (a new one needs all three, and a check that each `#rrggbb`
is upstream). luish-extra itself is MIT (`COPYING.MIT`, as luish's).

`conda` is another plugin beside `complete` (`extra/conda`): `plugin.toml` declares its options (`root`, `env`) and
`rc.lsh` runs conda's bash hook and `conda activate ENV` in a `__luish_cache` block, whose `env=` and `files=` are what
the hook and the activation read (the comment at the top of `rc.lsh` says why each); a failure `return`s, so that it
isn't cached. `tests/conda.sh` stands in for conda with a script in `~/miniconda3` that logs its calls, and sets
`PATH` itself (the machine's may have a conda).

`nvm` is a third (`extra/nvm`), built as `conda` is: options `dir` and `version`, and `rc.lsh` reads nvm.sh with
`--no-use` and runs `nvm use VERSION` (by default the alias `default`; `none`: no `nvm use`) in a `__luish_cache`
block, keyed on the aliases and installed versions. luish's `.` doesn't pass arguments (`. FILE ARG` gives FILE the
caller's `$@`), so nvm.sh is read from a function called with `--no-use`. `tests/nvm.sh` stands in for nvm with an
nvm.sh in `~/.nvm` that logs its calls.

`complete/extra-lib` is a library plugin (`library = true` in its `plugin.toml`, which is its only entry point; `plugin
list-available` leaves it out) of helpers the others share: `files.rhai` (`with_suffix(cur, suffixes)`, and with a third
argument, directories to leave out; `compressed(suffixes)`), `text.rhai` (`is_name`, `last_of`, `last_index`, `indent`,
`ident`) and `help.rhai`, which the `dynamic.rhai` modules use: `help::spec(PATH, how)` reads a spec from the `-h` of a
command PATH (`PROG SUB ...`), `help::sub(PATH, SUB, how)` is the usual body of a `sub_spec` (`()` for a word that isn't
a subcommand), and `help::commands(text)` takes a list of commands under any heading, with any gap after the name; `how`
gives the help flag, `stderr` (`"merge"` for mmseqs), the `sub_spec` module and clap's `help` command. They are imported
as `import "../extra-lib/files" as lib_files;`, `lib_text` and `help`, and a plugin that does so lists
`extra-lib = "*"` in its `[dependencies]` (now `bio`, `science`, `dev` and `gui`). A helper that a second plugin needs
goes there, not into a copy.

Option tables are written from the tools' real `--help`, and `completion-todo.md` records the version each ticked tool
was checked against. To check or add one, use the scripts (all run the tool through `pixi exec`, a temporary
environment with Bioconda, so nothing is installed):

- `scripts/optcheck.sh PKG=VERSION PROG [SUB]...` compares a spec with the tool's `--help` (via `optdiff.py`; `HELP=-h`
  for tools without `--help`). What it prints for a finished spec is only noise from prose in the help.
- `scripts/clickcheck.sh PACKAGE PROG [WORD]...` checks that a program built with Click answers the bridge's protocol
  (`_PROG_COMPLETE=fish_complete`) and times it. Tab runs the program each time, so register only fast ones; the
  others are for `complete-click`. Not every Python program with `click` in its dependencies is a Click program
  (hybracter, pysradb print usage), and Typer programs don't speak this protocol: read the output.
- `scripts/help2opts.py` drafts `opts:` and `values:` from a help text on standard input; read a draft before using
  it, since help formats differ in many small ways.
- `align.rhai`, `bam.rhai`, `blast.rhai`, `diamond.rhai`, `hmmer.rhai`, `reads.rhai`, `asm.rhai`, `profile.rhai` and
  `bins.rhai` of `bio`, `snakemake.rhai`, `pandoc.rhai`, `aria2.rhai`, `parallel.rhai`, `miller.rhai`, `cwltool.rhai` and
  `jupyter_specs.rhai` of `science`, `pytest.rhai`, `mypy.rhai` and `poetry.rhai` of `dev`, `borg.rhai` of `system`
  and `bandage.rhai` of `gui` are **generated** by `scripts/gen/mk_*.py` from the `--help` of pinned versions
  (`gen.helptext("bowtie2=2.5.5", "bowtie2 --help")`, cached in `$HELP_CACHE`), with the corrections and value kinds
  written in the generators. For Python programs built with argparse, `gen.argparse_dump(PKG, "module", "function")`
  runs the parser in the program's environment
  (`argparse_dump.py`) and gives its options with their choices and number of values, and `gen.emit_argparse` writes the
  table; the function may also be one that builds the parser and parses the command line itself
  (`porechop.porechop:get_arguments`), since the parser is caught at `parse_args`, or one that takes the command line
  as a parameter (`metaphlan.metaphlan:read_params(args)`). The module can be a helper file of
  `scripts/gen` (`pytest_parser.py`, `borg_parser.py`) for a parser that needs a few lines to get at, or `bin/PROG`
  for a Python script among the environment's programs (`bin/k2`); the function `__main__` runs such a script as a
  program, for one that builds its parser at its top level (`bin/checkm`), and words after the function are the command
  line the program sees, for one that prints its help without arguments (`checkm2.main:main predict`). `tree=True` gives
  the subcommands too (borg), and `python=` runs a local interpreter instead of pixi (borg: not in conda-forge).
  `gen.cleo_dump` does the same for Cleo programs (poetry), and `gen.dump` runs any helper that prints JSON
  (`mypy_info.py`: mypy's error codes). A program that prints its usage only when its standard input is a terminal
  (seqtk) is run under `script -qec "PROG SUB" /dev/null`, which gives it a pseudo-terminal (the input of `script` is
  still `/dev/null`). The generators stop at an option they have no kind for (`KINDS`, `VALUES`, `ARGS` in each), so a
  new version's options get looked at. Edit the generator and run it (`python3 scripts/gen/mk_align.py`), not the
  `.rhai`; to move to a new version, change the pin, rerun, read the diff of the module and of the tests' `.expected`,
  and update the version in `completion-todo.md`. The other modules are written by hand. `PLUGIN=complete/science
  scripts/optcheck.sh ...` checks a spec of `science` (`HELP='--help=#all'` for aria2c; `HELP=-help` for duckdb), and
  `PLUGIN=complete/dev` one of `dev`.
- Never run a tool with its standard input on a terminal: `samtools sort` waits for it. Use `</dev/null`.

Tests (`tests/run.sh`, cases `tests/PLUGIN_*.sh` with `.expected`) load std's `completion` plugin and this repo's
plugin, then run `__luish_internal complete LINE`, as `../luish/tests/plugins/std_completion*.sh` do. Programs that
completion itself runs are stood in for by scripts in `tests/bin`. Read the `.expected` before committing it: it is
a snapshot, not a check.

CI (`.github/workflows/ci.yml`) has two jobs: `test` builds luish from `luispedro/luish` (ref `LUISH_REF`, `main`) and
runs `tests/run.sh` with `LUISH` and `STD_PLUGINS` pointing at that checkout; `docs` runs the Sphinx build below.
`LUISH` must be an absolute path, because the runner `cd`s into a temp directory.

The Read the Docs site (`.readthedocs.yaml`, Sphinx + MyST + furo, `fail_on_warning: true`) builds with:

```sh
pip install -r docs/requirements.txt
sphinx-build -W docs docs/_build
```

`docs/requirements.txt` says it is kept in step with a `docs` feature in `pixi.toml`, which doesn't exist yet.

## Documents and what is authoritative

- `docs/completion.md`: **the authoritative list of commands** to complete, grouped by plugin and section. Add or
  remove commands here first.
- `completion-todo.md`: a checkbox list derived from `docs/completion.md`, one line per command. Keep the two in
  step (tick a command when its spec and test exist); the TODO has no generator script.

## Design decisions to keep in mind

- Needs luish 0.5.0 or later (the minimum supported version: sub-collections, colour schemes and their terminal
  colours, plugin options, `sh::capture_cached`). Every `plugin.toml` says so (`luish-version = "0.5"`, after
  `description`, if any), so that an older luish doesn't load it; a new plugin does too, and raising the minimum
  changes them all. The docs add the whole repository as a source (`extra = { gh = "luispedro/luish-extra" }`, plugins
  `extra/complete/bio`, ...).
- Run programs with `sh::capture(["prog", arg, ...])` (no shell parsing; stdin is /dev/null, stderr discarded unless
  a second argument says `"merge"`, `"return"` or `"inherit"`; variables through `env`), not by building a shell
  string. A program whose output changes seldom (help text, lists of formats, rules or themes) goes through
  `sh::capture_cached(TTL, argv)`, which keeps it in memory for `TTL` seconds (at most 300) and drops it when a
  command line names the program: 300 for help and lists, 30 for what is read from a file (BAM headers, VCF samples),
  which may be rewritten, and less or none for live state (`xrandr --query`, `wmctrl -l`, `dconf read`). Bridges
  that pass the line (`aws_completer`) aren't cached, as std's aren't. Find programs with `sh::which(name)` and list
  them with `sh::commands(prefix)`, so that PATH is searched as luish searches it; don't walk `PATH` in Rhai.
- **Nothing depends on the name the user gives the source.** Users add the repository as a source under a name of
  their choice (the docs say `extra`, so the plugins are `extra/complete/bio`, ...), or the `complete/` directory alone
  (`subdir = "complete"`: `extra-complete/bio`). So never write `@SOURCE/...`: import this repository's modules by
  relative path (`import "kinds"`, `import "../extra-lib/files"`), and name kinds and `sub_spec` with each module's
  `fn own(name) { sh::plugin_dir() + "/" + name }` (`own("kinds:fasta")`, the module's absolute path, which std's
  engine imports). Only std is named (`@std/completion/...`). The plugins can be enabled one by one
  (`extra.complete.bio`), or all at once as `extra.complete.all`: `complete/all` is
  only a `plugin.toml` that depends on the others (a new user-facing plugin goes in its `[dependencies]`, and in the
  `all_load` test). `complete/` itself must not get a `plugin.toml` or any other entry point: luish would then take
  it as one plugin, not a collection, and both `extra.complete.bio` and the plain-name dependencies (`extra-lib =
  "*"`) would stop resolving. Other kinds of plugin go beside `complete/`, as a plugin (`themes/`) or a further
  collection.
- Completion is by **command name, not Bioconda package name** (`star` → `STAR`, `subread` → `featureCounts`,
  `entrez-direct` → `esearch`/`efetch`). Check the real executables.
- Commands that std's `completion` plugin already covers (`fd`, `rg`, `jq`, `uv`, `pixi`, `conda`, `docker`, …) are
  deliberately not repeated. Go/Cobra tools may work through std's `PROG __complete` bridge with no spec (prefer that
  where its completion is good).
- Rhai gotchas met so far: functions get arrays and maps **by value** (a helper that fills a list must return it);
  `String::replace`, `trim` and `sort` change the value in place and return `()`; a `switch` case with several values is
  `"a" | "b" =>`; a closure kept in a variable can't be called as `f(x)` (use a named `fn`); a backtick string keeps
  `\n` as two characters; `module` and `in` are reserved words (also as keys of a map literal: quote them); `parse_json`
  takes only an object, so a JSON array is read as ``parse_json(`{"a": ${out}}`).a``; `go` and `sync` are reserved
  words. An `import` can name a variable (`let m = module_of[words[0]]; import m as specs;`), which is how each
  `extension.rhai` imports a command's module.
- For a program whose long options take their value as the next word and have a single dash or two (`mlr`: `single_dash: true`
  and `strict_eq: true`, else the engine completes `--name=`; `nextflow` and `latexmk` have `single_dash` only). The `sub_spec`
  of a spec is `own("MODULE:NAME")`, and the engine calls `MODULE::sub_spec(NAME, SUBCOMMAND)`
  (`NAME` is what is after the colon, not the command).
- A test that depends on what is in `PATH` (the `jupyter-*` programs, the commands starting with a prefix, the
  LibreOffice whose registry is read) must set `PATH` itself, after making its files (the `PATH` of `run.sh` is the
  machine's, after `tests/bin`).
- In an option table (std's format) a word after the names that starts with `-` is taken as another option name, so a
  value called `-|LIST` or `-|+TYPE` makes the option a flag: write `LIST|-`. The table is inside a Rhai backtick
  string, so it can't contain a backtick or `${`.
- Modules import lazily, inside the completer, so each one is compiled on first Tab. Kinds and `sub_spec` are named
  as strings (`own("kinds:fasta")`) because closures made in a module fail in Rhai 1.26.1
  when `lib.rhai` calls them.
- Spec style follows std: short lowercase descriptions, `values` for option values (`"none"` for free text), `args`
  with kinds.
