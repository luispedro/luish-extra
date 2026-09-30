# luish-extra

Plugins for [luish](https://github.com/luispedro/luish) that don't belong in its standard library: completion for
bioinformatics tools (`bio`), scientific computing (`science`), development (`dev`) and system administration
(`system`), and later desktop programs. The commands are listed in [`docs/completion.md`](docs/completion.md), and
what is done so far in [`completion-todo.md`](completion-todo.md).

Requires luish at rev `c744056c3718f7f383f610c8ef07a526faccc0f2` or later, and its `std.completion` plugin (the
plugin depends on it, so luish loads it first).

## Enabling

In `config.toml`:

```toml
[plugins.available]
extra-complete = { gh = "luispedro/luish-extra", subdir = "complete" }

[plugins.enabled]
extra-complete.bio = "*"
extra-complete.science = "*"
extra-complete.dev = "*"
extra-complete.system = "*"
```

## `bio`

Completes commands by their name (not their Bioconda package's): options, subcommands, and values by kind (FASTA,
FASTQ, BAM, BED, ... files by extension; reference names for regions, from a `.fai` or a BAM header; presets and
output formats).

Done: `ngless`, `SemiBin2` / `SemiBin`, `macrel`, `argnorm`; `samtools`, `bcftools`, `bedtools`, `tabix`, `bgzip`,
`htsfile`; `bwa`, `bwa-mem2`, `bowtie2`, `hisat2`, `minimap2`, `STAR`, `kallisto`, `featureCounts`; BLAST+
(`blastn` and the rest), `diamond`, `mmseqs`, HMMER. `completion-todo.md` has the tool versions they were checked
against.

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

## Tests

```sh
tests/run.sh                 # all the cases
tests/run.sh bio_hts         # one
UPDATE=1 tests/run.sh bio_hts   # write the .expected file (and read it before committing it)
```

They need luish (`LUISH`, default the one in `PATH`) and a checkout of its `luish-std-plugins` (`STD_PLUGINS`,
default `../luish/luish-std-plugins`). Programs that completion runs (`samtools view -H`, `tabix -l`, `bcftools query
-l`, `mmseqs -h`, `pandoc --list-output-formats`, `xsv -h`, `qsv --list`, `mlr help list-separator-aliases`, `ruff -h`,
`bat --list-languages`) are stood in for by the scripts in `tests/bin`. A test that lists a directory of `PATH`
(`jupyter-*`) or the commands in it sets `PATH` itself.
