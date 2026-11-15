# pathed

A luish plugin to see and edit `PATH`: `pathed` shows it numbered, with what is
wrong with it (missing, duplicated, relative or empty entries, and the commands
that each directory shadows), and changes it.

```sh
pathed                     # PATH, with notes, and normalised if that differs
pathed add ~/bin           # at the front (-a: at the end; --after ENTRY)
pathed rm '*conda*'        # by number, directory or pattern
pathed mv 3 first
pathed clean               # absolute, without duplicates or empty entries
pathed edit                # (or vipath) in $EDITOR, one directory per line
pathed undo                # the last change
pathed which python3       # every python3 in PATH, and which one runs
```

Changes are to the shell's `PATH`: nothing is written to a file.

## Enable it

```toml
[plugins.available]
extra = { gh = "luispedro/luish-extra", release = "luish" }

[plugins.enabled]
extra.pathed = { }
```

or `plugin load extra/pathed`.

See [`docs/pathed.md`](../docs/pathed.md) for the details.
