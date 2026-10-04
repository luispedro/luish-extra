# luish-extra

Extra material for [luish](https://github.com/luispedro/luish).

Source: <https://github.com/luispedro/luish-extra>

## Installing

In luish, add the repository (under any name, here `extra`), then enable `all` of its completion plugins:

```console
$ plugin add luispedro/luish-extra extra
$ plugin add extra/complete/all
```

`all` loads `bio`, `science`, `gui`, `dev` and `system`. To have only some of them, enable them one by one instead
(`plugin add extra/complete/bio`, ...).

This needs luish 0.4.0 or later, and the plugins need std's `completion` plugin.

The colour schemes are the plugin `themes` (`plugin add extra/themes`): see [](themes.md).

luish-extra is licensed under the MIT License, as luish is; the palettes of the colour schemes are their authors',
under their own licenses (see [](themes.md)).

```{toctree}
:maxdepth: 2

completion
themes
```
