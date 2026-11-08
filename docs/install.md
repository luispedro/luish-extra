# Installing

luish-extra is a repository of luish plugins. Installing it means adding the repository as a source of plugins, once;
each plugin is then enabled on its own (see [Enabling the plugins](#enabling-the-plugins)).

It needs luish 0.8.0 or later: every plugin says so in its `plugin.toml`, and an older luish doesn't load them.

## Adding the repository

The simplest way is `plugin add`, in luish:

```console
$ plugin add luispedro/luish-extra extra
```

This adds the repository to `[plugins.available]` in `config.toml`, under the name `extra`, and fetches it. Any name
works; the docs say `extra`, so that the plugins are `extra/completion/bio`, `extra/themes`, ... (`plugin
list-available` lists them).

Or, by hand, in `config.toml` (then run `plugin sync`):

```toml
[plugins.available]
extra = { gh = "luispedro/luish-extra", release = "luish" }
```

## Releases

`release = "luish"` keeps you on the newest release made for your version of luish, so that the plugins never need a
newer luish than yours. `plugin add` writes the source without it, and so follows `main`, which may need a newer luish
than yours: add `release = "luish"` to the line by hand.

The releases are tags `vX.Y.N`, the `N`th for luish `X.Y`: `v0.8.0` is the first for luish 0.8, and `v0.8.1`, ...
come as commands are added. `plugin update` moves to a newer release, and `plugin sync`, after luish is upgraded, to
the releases for the new version.

## Enabling the plugins

Once the repository is added, enable the plugins you want:

| Plugin | What it does | Enabling |
|---|---|---|
| `extra/completion/all` | Tab completion for many more commands (recommended: all of the completion plugins) | [](completion.md) |
| `extra/themes` | Colour schemes, for dark and light backgrounds | [](themes.md) |
| `extra/conda` | Sets conda up in interactive shells, cached | [](conda.md) |
| `extra/nvm` | Sets nvm up in interactive shells, cached | [](nvm.md) |
| `extra/zmv` | zsh's `zmv`, `zcp`, `zln` and `mmv`, to rename many files at once | [](zmv.md) |
