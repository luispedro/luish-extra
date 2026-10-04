# conda

A luish plugin that sets conda up in interactive shells.

It uses luish's caching to avoid running conda's shell hook in every shell, so
that startup is fast (under 4 ms on my machine).

## Enable it


```toml
[plugins.available]
extra = { gh = "luispedro/luish-extra" }


[plugins.enabled]
extra.conda = { }
```

With no options, you get conda's hook and its own `base` activation, and `conda
activate` works at the prompt.

You can activate a different environment by setting the `env` option:

```toml
[plugins.enabled]
extra.conda = { options = { env = "py3.12" } }
```

You can specify the environment by path (a leading `~/` is expanded):

```toml
[plugins.enabled]
extra.conda = { options = { env = "~/projects/analysis/.env" } }
```

By default, the plugin looks for conda in `PATH`, and in the usual places
(`~/miniforge3`, `~/miniconda3`, `/opt/conda`, ...). If you want to use a
different conda installation, you may need to specify the `root` option, which
is the path to the conda installation (a leading `~/` is expanded):

```toml
[plugins.enabled]
extra.conda = { options = { root = "~/tools/miniforge", env = "bio" } }
```



## Load it from `luishrc` or the prompt

Alternatively, you can load it from `~/.config/luish/luishrc` or from the
prompt:

```sh
# ~/.config/luish/luishrc
plugin load extra/conda env=py3.12
```

```sh
plugin load extra/conda env=bio root=/opt/conda
```

## Use it

Once it is loaded, conda behaves as it does in bash:

```sh
conda activate bio      # the prompt gets "(bio) "
conda env list
conda deactivate
```

## When conda runs again

The cache is rebuilt, and conda runs again, when the options, `PATH`, `PS1`,
conda's configuration (`~/.condarc`, ...) or the packages of the installation
or the environment change, so `conda install` and `conda update` take effect in
the next shell. To see what changed, or to force a rebuild:

```sh
__luish_internal check-cache
rm -r ~/.cache/luish
```

See [`docs/conda.md`](../docs/conda.md) for the details of what the cache depends on.
