# luish-extra

Extra material for [luish](https://github.com/luispedro/luish).

Source: <https://github.com/luispedro/luish-extra>

## Installing

In luish, add the repository (under any name, here `extra`), then enable `all` of its completion plugins:

```console
$ plugin add luispedro/luish-extra extra
$ plugin add extra/completion/all
```

`all` loads `bio`, `science`, `gui`, `dev`, `system`, `media` and `hpc`. To have only some of them, enable them one by one instead
(`plugin add extra/completion/bio`, ...).

This needs luish 0.7.0 or later, and the plugins need std's `completion` plugin.

[](supported.md) lists the commands that are completed so far, and what to check when Tab doesn't offer what you
expect; [](completion.md) lists those planned too. [](developing.md) says how to add one.

The colour schemes are the plugin `themes` (`plugin add extra/themes`): see [](themes.md). The plugin `conda` sets
conda up in interactive shells, cached (`extra.conda = { options = { env = "ENV" } }`): see [](conda.md). The plugin `nvm` does
the same for nvm (`extra.nvm = { options = { version = "node" } }`): see [](nvm.md).

luish-extra is licensed under the MIT License, as luish is; the palettes of the colour schemes are their authors',
under their own licenses (see [](themes.md)).

```{toctree}
:maxdepth: 2

supported
completion
themes
conda
nvm
developing
```
