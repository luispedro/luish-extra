# conda

The plugin `conda` (`extra/conda`, if the repository was added as `extra`) sets conda up in interactive shells, as
`conda init` does for bash: it runs conda's shell hook, which defines the function `conda`, and then `conda activate`
for the environment you choose. Both run conda, a Python program, and activating an environment also runs the
activation scripts of its packages (r-base's runs `R CMD javareconf`), which together can take seconds. The plugin
does this in a `__luish_cache` block, so that a new shell restores what they did instead.

## Enabling it

Enable it in `config.toml`, with the environment to activate:

```toml
[plugins.enabled]
extra.conda = { options = { env = "py3.12" } }
```

or load it from `luishrc` (`~/.config/luish/luishrc`), or at the prompt, with `plugin load extra/conda env=py3.12`.
Its options:

| Option | Meaning |
|---|---|
| `env` | The environment to activate (a name or a path), after conda's own (`base`, unless conda's `auto_activate` is false). None by default |
| `root` | The conda installation, the directory with `bin/conda`. By default that of the `conda` in `PATH`, or the first of `~/miniforge3`, `~/miniconda3`, `~/anaconda3`, `~/mambaforge`, `~/.miniforge3`, `~/.miniconda3`, `~/.anaconda3`, `/opt/conda`, ... that exists |

## What the cache depends on

The block is rebuilt (conda runs again) when what it depends on changes: the options; `PATH`, `PS1`, and the
variables that a shell started from one where conda was set up inherits (`CONDA_SHLVL`, `CONDA_PREFIX`,
`CONDA_DEFAULT_ENV`); conda's configuration (its `.condarc` files, and `CONDARC`, `CONDA_ENVS_PATH`,
`CONDA_ENVS_DIRS`, `CONDA_AUTO_ACTIVATE`, `CONDA_AUTO_ACTIVATE_BASE`, `CONDA_CHANGEPS1`); and the packages of the
installation and of the environment (their `conda-meta`), the environment's variables (`conda env config vars`) and
its activation scripts. For anything else, `__luish_internal check-cache` finds what changed, and removing
`~/.cache/luish` makes the next shell run conda again.
