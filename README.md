# luish-extra

Plugins for [luish](https://github.com/luispedro/luish) that don't belong in its standard library: completion for
bioinformatics tools (`bio`), and later scientific computing, desktop programs, development and system
administration. The commands are listed in [`docs/completion.md`](docs/completion.md), and what is done so far in
[`completion-todo.md`](completion-todo.md).

Requires luish at rev `c744056c3718f7f383f610c8ef07a526faccc0f2` or later, and its `std.completion` plugin (the
plugin depends on it, so luish loads it first).

## Enabling

In `config.toml`:

```toml
[plugins.available]
extra-complete = { gh = "luispedro/luish-extra", subdir = "complete" }

[plugins.enabled]
extra-complete.bio = "*"
```

## `bio`

Completes commands by their name (not their Bioconda package's): options, subcommands, and values by kind (FASTA,
FASTQ, BAM, BED, ... files by extension; reference names for regions, from a `.fai` or a BAM header; presets and
output formats).

Done: `ngless`, `SemiBin2` / `SemiBin`, `macrel`, `argnorm`, `samtools`, `bedtools`, `tabix`, `bgzip`, `htsfile`.

## Tests

```sh
tests/run.sh                 # all the cases
tests/run.sh bio_hts         # one
UPDATE=1 tests/run.sh bio_hts   # write the .expected file (and read it before committing it)
```

They need luish (`LUISH`, default the one in `PATH`) and a checkout of its `luish-std-plugins` (`STD_PLUGINS`,
default `../luish/luish-std-plugins`). Programs that completion runs (`samtools view -H`, `tabix -l`) are stood in
for by the scripts in `tests/bin`.
