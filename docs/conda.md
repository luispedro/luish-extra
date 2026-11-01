# conda

The `conda` plugin (`extra/conda`, if the repository was added as `extra`) sets conda up in interactive shells, as
`conda init` does for bash: it runs conda's shell hook, then `conda activate` for the environment you choose. Both run
conda, and activation also runs its packages' activation scripts, which together can take seconds, so the plugin caches
what they did and a new shell restores it instead.

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

## Technical detail: what the cache depends on

conda runs again when any of these change:

- the options;
- `PATH`, `PS1`, and what a shell started from one with conda set up inherits: `CONDA_SHLVL`, `CONDA_PREFIX`,
  `CONDA_DEFAULT_ENV`;
- conda's configuration: the variables `CONDARC`, `CONDA_ENVS_PATH`, `CONDA_ENVS_DIRS`, `CONDA_AUTO_ACTIVATE`,
  `CONDA_AUTO_ACTIVATE_BASE` and `CONDA_CHANGEPS1`, and its `.condarc` files (`.condarc`, `condarc` or `condarc.d`
  in `~`, `~/.conda`, `$XDG_CONFIG_HOME/conda`, the installation and `/etc/conda`, and `$CONDARC`);
- the packages of the installation and of the environment (their `conda-meta`, so an update of conda too), the
  environment's variables (`conda env config vars`) and its activation scripts.

If the hook or `conda activate` fails, the error is shown and nothing is cached. For anything else,
`__luish_internal check-cache` says what changed, and removing `~/.cache/luish` makes the next shell run conda again.
