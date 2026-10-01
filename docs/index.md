# luish-extra

Extra material for [luish](https://github.com/luispedro/luish).

Source: <https://github.com/luispedro/luish-extra>

## Installing

In luish, add the collection of completion plugins, then enable `all` of them:

```console
$ plugin add https://github.com/luispedro/luish-extra/tree/main/complete extra-complete
$ plugin add extra-complete/all
```

`all` loads `bio`, `science`, `gui`, `dev` and `system`. To have only some of them, enable them one by one instead
(`plugin add extra-complete/bio`, ...).

The collection must be named `extra-complete` (the second argument of the first command), since its plugins import
each other's modules by that name. They need luish at rev `9e3a39bf7dcbb4c472c3712bc4cf74cfb784c6cd` or later, and
std's `completion` plugin.

```{toctree}
:maxdepth: 2

completion
```
