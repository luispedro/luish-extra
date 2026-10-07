# nvm

A luish plugin that sets [nvm](https://github.com/nvm-sh/nvm) (the Node Version
Manager) up in interactive shells.

It uses luish's caching to avoid reading nvm.sh and running `nvm use` in every
shell, which takes most of a second, so that startup is fast.

## Enable it

```toml
[plugins.available]
extra = { gh = "luispedro/luish-extra" }


[plugins.enabled]
extra.nvm = { }
```

With no options, you get nvm and the version of its alias `default` (if you
have set one), as with nvm's own lines in `~/.bashrc`, and `nvm` works at the
prompt.

You can use a different version by setting the `version` option, to anything
`nvm use` takes (`node` is the newest version installed):

```toml
[plugins.enabled]
extra.nvm = { options = { version = "node" } }
```

`version = "none"` only loads nvm, leaving the node in `PATH`, if any.

By default, the plugin looks for nvm in `$NVM_DIR` or `~/.nvm`. If it is
elsewhere, give its directory with the `dir` option (a leading `~/` is
expanded):

```toml
[plugins.enabled]
extra.nvm = { options = { dir = "~/tools/nvm", version = "lts/*" } }
```

## Load it from `luishrc` or the prompt

Alternatively, you can load it from `~/.config/luish/luishrc` or from the
prompt:

```sh
# ~/.config/luish/luishrc
plugin load extra/nvm version=node
```

## When nvm runs again

The cache is rebuilt, and nvm runs again, when the options, `PATH`, the
installed versions or nvm's aliases change, so `nvm install` and `nvm alias`
take effect in the next shell. To see what changed, or to force a rebuild:

```sh
__luish_internal check-cache
rm -r ~/.cache/luish
```

See [`docs/nvm.md`](../docs/nvm.md) for the details of what the cache depends on.
