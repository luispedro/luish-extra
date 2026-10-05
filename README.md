# luish-extra

Tab completion for [luish](https://github.com/luispedro/luish), for the programs that its standard library leaves out:
bioinformatics tools (`bio`), scientific computing (`science`), desktop programs (`gui`), development (`dev`) and
system administration (`system`). Each plugin can be enabled on its own. And [colour schemes](#colour-schemes) for
luish's highlighting, for dark and light backgrounds (`themes`), and a [cached set-up of conda](#conda) (`conda`).

Completion knows each program's options and subcommands, and the kind of value each one takes: `samtools sort -O`
offers `BAM`, `CRAM` and `SAM`, `samtools view -T` offers FASTA files and `samtools view in.bam` the reference names
in its header, `pytest tests/test_x.py::` the tests in that file, and `ruff check --select F4` the rule codes
`F401`, `F403`, ... Option tables are written from each tool's own `--help`, and
[`completion-todo.md`](completion-todo.md) records the version each one was checked against.

## What is supported

272 commands are completed so far, by 239 tools (a tool can bring several commands: BLAST+ is `blastn`, `blastp`,
`makeblastdb` and 16 others):

| Plugin    | Commands | Tools done / listed |
|-----------|---------:|--------------------:|
| `bio`     |      169 |           164 / 768 |
| `science` |       42 |             26 / 37 |
| `gui`     |       49 |             40 / 40 |
| `dev`     |        9 |              7 / 10 |
| `system`  |        3 |               2 / 2 |
| **Total** |  **272** |       **239 / 857** |

The tools to support are listed in [`docs/completion.md`](docs/completion.md) and, with a box per tool, in
[`completion-todo.md`](completion-todo.md) (`grep -c '^- \[x\]' completion-todo.md` counts the ticked ones). The
sections below list what each plugin completes.

Commands are completed by the name you type, not the name of their Bioconda package (`STAR`, not `star`;
`featureCounts`, not `subread`). Commands that std's `completion` plugin already covers (`rg`, `fd`, `jq`, `uv`, `pixi`,
`conda`, `docker`, ...) are left to it.

## Enabling

Requires luish 0.5.0 or later (the plugins say so in their `plugin.toml`, and an older luish doesn't load them), and
its `std.completion` plugin. The plugins depend on it and on `extra-lib`, this
collection's library of shared helpers, so luish loads them first; `extra-lib` is not listed by `plugin
list-available`.

The simplest way is `plugin add`, in luish:

```console
$ plugin add luispedro/luish-extra extra
$ plugin add extra/complete/all
```

The first command adds the repository to `[plugins.available]` in `config.toml`, under the name `extra` (any name
works), and fetches it. Its completion plugins are then `extra/complete/bio`, `extra/complete/science`, ...
(`plugin list-available` lists them). The second enables `all`, which loads `bio`, `science`, `gui`, `dev` and
`system`. To have only some of them, enable them one by one instead (`plugin add extra/complete/bio`, ...).

Or, by hand, in `config.toml` (then run `plugin sync`):

```toml
[plugins.available]
extra = { gh = "luispedro/luish-extra" }

[plugins.enabled]
extra.complete.all = "*"        # or "extra/complete/all" = "*"
```

To have only some of them, enable them one by one instead:

```toml
[plugins.enabled]
extra.complete.bio = "*"
extra.complete.science = "*"
```

A plugin costs little until it is used: each module is compiled the first time Tab is pressed for one of its commands.

## Programs that complete themselves

Some programs know their own completions, and are asked rather than described here:

- Python programs built with [Click](https://click.palletsprojects.com/) (`multiqc`, `cooler`, `nf-core`, `proksee`,
  ...) go through std's Click bridge. Each Tab runs the program, so only those that answer in under a second are
  registered; a slower one (`cooltools`, `genomad`, `iphop`, `planemo`, ...: 1.4 to 5 s) can be added with
  `complete-click PROG` if you accept the wait.
- Go programs built with Cobra (`seqkit`, `csvtk`, `taxonkit`, `apptainer`) go through std's Cobra bridge.
- `aws` is asked through its own `aws_completer`.

If such a program isn't installed, or doesn't answer, Tab offers filenames.

A few programs have their options read from the installed version when Tab is pressed, so that they follow it:
`mmseqs`, `xsv`, `qsv` and `ruff` (from their `-h`), `mpv` (`--list-options`), and `inkscape`'s actions.

## `bio`

Options, subcommands, and values by kind: FASTA, FASTQ, BAM, BED, ... files by extension; reference names for regions,
from a `.fai` or a BAM header; presets and output formats.

Done: `ngless`, `SemiBin2` / `SemiBin`, `macrel`, `argnorm`; `samtools`, `bcftools`, `bedtools`, `tabix`, `bgzip`,
`htsfile`, `sambamba`, `bamtools`, `samblaster`, `mosdepth`, `cramino`, `vcftools`; `bwa`, `bwa-mem2`, `bowtie2`,
`hisat2`, `minimap2`, `STAR`, `kallisto`, `featureCounts`; BLAST+ (`blastn` and the rest), `diamond`, `mmseqs`,
HMMER; `fastp`, `fastqc`, `falco`, `cutadapt`, `trimmomatic` (its steps, and the adapter files that come with it),
`trim_galore`, `fastq_screen`, `seqtk`, `filtlong`, `chopper`, `nanoq`, `rasusa`, `porechop`, `NanoPlot`,
`NanoFilt`, `NanoStat`; assembly and annotation (`spades.py`, `megahit`, `flye`, `quast`, `busco`, `prodigal`,
`prokka`, `bakta`, `barrnap`); profiling of metagenomes (`kraken2`, `bracken`, `krakenuniq`, `centrifuge`, `kaiju`,
`metaphlan`, `humann`, `motus`); binning and MAGs (`metabat2`, `concoct`, `run_MaxBin.pl`, `vamb`, `DAS_Tool`,
`checkm`, `checkm2`, `gunc`, `gtdbtk`, `dRep`, `coverm`); `rgi`; `seqkit`, `csvtk` and `taxonkit` (which complete
themselves, as Cobra programs); and, through the Click bridge, `multiqc`, `peddy`, `genmod`, `plassembler`, `cooler`,
`pairtools`, `checkv`, `virsorter`, `metacoag`, `harpy`, `defense-finder`, `dnaapler`, `genomepy`, `freyja`,
`fastq-dl` and `biom`.
`completion-todo.md` has the tool versions they were checked against.

## `science`

Workflows, writing, Python and R, tabular data and a few command-line utilities. Some of it reads the project you are
in: the rules and included files of a `Snakefile` (targets, `-R`, `--until`), the profiles of a `nextflow.config`, the
runs of `.nextflow/history`, the downloaded Nextflow projects, the parameters of an nf-core pipeline's
`nextflow_schema.json`; and the installed program: pandoc's formats and extensions, Miller's separator names, the
commands of `xsv` and `qsv` and their options (read from their `-h`), the `jupyter-*` programs in `PATH`.

Done: `jug`, `snakemake`, `nextflow`, `nf-core`, `nf-test`, `cwltool`; `quarto`, `pandoc`, `latexmk`, `pdflatex`,
`xelatex`, `lualatex`, `bibtex`; `ipython`, `jupyter`, `Rscript` and `R`; `gnuplot`, `datamash`; `mlr`, `xsv`, `qsv`,
`duckdb`; `parallel`, `aria2c`, `pigz`, `apptainer` (Cobra; `singularity` is registered the same way, but was not run),
`aws`.

## `gui`

Desktop programs. It reads the installed LibreOffice's filter registry (found from the `soffice` in `PATH`): the
formats of `--convert-to` (`pdf`, `docx`, ...) and, after `EXT:`, the filters that write them (`pdf:writer_pdf_Export`),
and the input filters of `--infilter=`; and CUPS's printers (`lpstat -e`) for `--pt` and `--printer-name`. mpv's
options are read from the installed mpv (`--list-options`), with the values of its choices and the video outputs,
filters, profiles and audio devices it lists; and Inkscape's actions (`--actions`) from `inkscape --action-list`, and
the object IDs of `--export-id`, `--query-id` and `--select` from the SVG files on the command line. It also reads
kate's sessions, GIMP's session files, and OBS's profiles, scene collections and scenes (of the collection given or the
current one); Firefox's and Thunderbird's profiles (`-P`) and Chrome's (`--profile-directory`); VS Code's installed
extensions and profiles, and the subcommands of `code tunnel`, `code serve-web` and `code agent` from their help;
Krita's workspaces, window layouts and sessions; xrandr's outputs and modes, gsettings's schemas, keys and the values of
enum and boolean keys, dconf's keys and directories, and wmctrl's windows. xdotool's commands are completed as they are
chained (`xdotool search --name x windowactivate`).

Done: `firefox`, `thunderbird`, `chromium`, `google-chrome`; `libreoffice` and `soffice`, `evince`, `okular`,
`zathura`, `xdg-open`; `code`, `meld`, `gedit`, `kate`; `vlc` (and `cvlc`), `mpv`, `gimp`, `inkscape`, `krita`,
`blender`, `obs`, `audacity`, `eog`; `cytoscape` (and `Cytoscape`, `cytoscape.sh`), `jalview`, Artemis (`art`, `act`,
`bamview`, `dnaplotter`), `tablet`, `BandageNG`, `proksee` (Click), `pymol`, `chimerax`, `vmd`; `xrandr`, `gsettings`,
`dconf`, `notify-send`, `wmctrl`, `xdotool`, `swaymsg`, `hyprctl`.

## `dev`

Python tooling and command-line utilities, beyond what std's `completion` plugin covers. It reads the project: the tests
of a test file for pytest (`test_x.py::TestY::test_z`), the markers its configuration files register (`-m`), the groups,
extras, dependencies, scripts and sources of `pyproject.toml` and the packages of `poetry.lock` for poetry, the
repositories of `~/.pypirc` for twine; and the installed program: ruff's options, linters and rule codes
(`--select F4` offers `F401`, ...), bat's languages and themes.

Done: `pytest` (with the options of pytest-xdist and pytest-cov), `ruff`, `mypy` (its error codes, and the inverses of
its flags), `poetry`, `twine`; `fzf`, `bat` (and `batcat`).

## `system`

Done: `borg` (repositories, and `::ARCHIVE` with `BORG_REPO`; compression specs), `fusermount` and `fusermount3` (the
FUSE mount points, for `-u`).

## Colour schemes

The plugin `themes` (`extra/themes`) has colour schemes for luish's syntax highlighting, completion menu and
suggestions, each in a pair for dark and light backgrounds:

| Dark               | Light              | Colours                                                          |
|--------------------|--------------------|------------------------------------------------------------------|
| `ansi-dark`        | `ansi-light`       | the terminal's own 16, so they follow its palette                |
| `solarized-dark`   | `solarized-light`  | [Solarized](https://ethanschoonover.com/solarized/)              |
| `gruvbox-dark`     | `gruvbox-light`    | [gruvbox](https://github.com/morhetz/gruvbox)                    |
| `catppuccin-mocha` | `catppuccin-latte` | [Catppuccin](https://catppuccin.com/palette)                     |
| `tokyonight-night` | `tokyonight-day`   | [Tokyo Night](https://github.com/folke/tokyonight.nvim)          |

Enable the plugin, which only makes them available, and choose a pair in `config.toml`; luish takes the one that
fits the terminal's background:

```toml
[plugins.enabled]
extra.themes = "*"

[style]
colorscheme = { dark = "gruvbox-dark", light = "gruvbox-light" }
```

or try one with `style -c catppuccin-mocha` (`style -c` lists them). All of them give each kind of word the same
role: one colour for commands (functions bold, aliases italic, unknown commands bold red), one for keywords, options,
strings, variables (also in `NAME=`; exported ones bold, unset ones italic red); comments italic. Except the `ansi`
pair, they write colours as `#rrggbb`, which needs a terminal with 24-bit colour, and also set the terminal's own
background, text and cursor colours and its 16 colours while they are in use, putting them back afterwards
(`terminal-colors = false` in `[style]` keeps the terminal's own).

The palettes are other people's, used under their licenses (MIT for Solarized, gruvbox, Catppuccin and the original
Tokyo Night; Apache-2.0 for tokyonight.nvim, whose night and day styles these are). [`themes/README.md`](themes/README.md)
says where each comes from, and [`themes/LICENSES`](themes/LICENSES) has the license texts.

## conda

The plugin `conda` (`extra/conda`) does what `conda init` does for bash (conda's shell hook, then `conda activate
ENV`) in a `__luish_cache` block, so that only the first shell runs conda, and the next ones restore what it did until
the environment's packages, conda's configuration or the variables it reads change. Enable it in `config.toml`, with
the environment to activate:

```toml
[plugins.enabled]
extra.conda = { options = { env = "py3.12" } }
```

(or `plugin load extra/conda env=py3.12`). The option `root` gives the installation, if it isn't the `conda` in `PATH`
or in one of the usual places (`~/miniforge3`, `~/miniconda3`, ...). See [`docs/conda.md`](docs/conda.md) for what
the cache depends on.

## Tests

For working on the plugins (see [`CLAUDE.md`](CLAUDE.md) for how specs are written and generated):

```sh
tests/run.sh                 # all the cases
tests/run.sh bio_hts         # one
UPDATE=1 tests/run.sh bio_hts   # write the .expected file (and read it before committing it)
```

They need luish (`LUISH`, default the one in `PATH`) and a checkout of its `luish-std-plugins` (`STD_PLUGINS`, default
`../luish/luish-std-plugins`). Programs that completion runs (`samtools view -H`, `tabix -l`, `bcftools query -l`,
`mmseqs -h`, `pandoc --list-output-formats`, `xsv -h`, `qsv --list`, `mlr help list-separator-aliases`, `ruff -h`, `mpv
--list-options`, `inkscape --action-list`, `bat --list-languages`, `lpstat -e`, `code tunnel -h`, `xrandr --query`,
`gsettings`, `dconf list`, `wmctrl -l`) are stood in for by the scripts in
`tests/bin`. A test that lists a directory of `PATH` (`jupyter-*`) or the commands in it sets `PATH` itself, as does one
that finds a program's files from it (LibreOffice's registry).

## License

luish-extra is licensed under the [MIT License](COPYING.MIT), as luish is. The colour palettes that the schemes in
`themes` use are their authors', under their own licenses: see [`themes/README.md`](themes/README.md).
