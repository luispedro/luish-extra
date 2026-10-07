# nvm

The plugin `nvm` (`extra/nvm`, if the repository was added as `extra`) sets [nvm](https://github.com/nvm-sh/nvm), the
Node Version Manager, up in interactive shells, as the lines that its installer puts in `~/.bashrc` do: it reads
`$NVM_DIR/nvm.sh`, which defines the function `nvm`, and then runs `nvm use` for the version you choose. nvm.sh is
some 4000 lines of shell, and `nvm use` runs node and npm, which together take most of a second. The plugin does this
in a `__luish_cache` block, so that a new shell restores what they did instead.

## Enabling it

Enable it in `config.toml`, with the version to use:

```toml
[plugins.enabled]
extra.nvm = { options = { version = "node" } }
```

or load it from `luishrc` (`~/.config/luish/luishrc`), or at the prompt, with `plugin load extra/nvm version=node`.
Its options:

| Option | Meaning |
|---|---|
| `version` | What to `nvm use`: a version or an alias (`node` for the newest installed version, `lts/*`, `20`, `v22.1.0`, `system`, ...), or `none` to only load nvm. By default the alias `default`, if there is one, as nvm.sh does |
| `dir` | nvm's directory (`NVM_DIR`, with `nvm.sh`). By default `$NVM_DIR`, or `$XDG_CONFIG_HOME/nvm` if `XDG_CONFIG_HOME` is set and nvm is there, or `~/.nvm` |

Unlike nvm.sh on its own, the plugin doesn't fall back to the `.nvmrc` of the directory the shell starts in when there
is no alias `default`: run `nvm use` there for that.

## What the cache depends on

The block is rebuilt (nvm.sh is read and `nvm use` runs again) when what it depends on changes: the options; `PATH`
and `MANPATH`, from which `nvm use` takes out the directories of the version that a shell started from one with nvm
set up already has; the variables that change what `nvm use` does (`NVM_SYMLINK_CURRENT`) or make it fail (npm's
prefix: `PREFIX`, `NPM_CONFIG_PREFIX`, `npm_config_prefix`, and `~/.npmrc`); and nvm's aliases and installed versions,
so that `nvm install`, `nvm uninstall` and `nvm alias` take effect in the next shell. An update of nvm (a new nvm.sh)
is seen too. If `nvm use` fails (a version that isn't installed), the error is shown and nothing is cached. For
anything else, `__luish_internal check-cache` finds what changed, and removing `~/.cache/luish` makes the next shell
read nvm again.
