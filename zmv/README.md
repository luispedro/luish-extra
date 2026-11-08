# zmv

A luish plugin with zsh's `zmv`, `zcp` and `zln`, which rename, copy or link
many files at once, and `mmv`, their simpler form.

```sh
zmv '(*).txt' '$1.md'           # a.txt -> a.md, ...
zmv '(**/)(*).jpeg' '$1$2.jpg'  # also in subdirectories
mmv '*.txt' '*.md'              # the same, with wildcards in both
zmv -n '(*)' '${1:l}'           # show what would be done: names in lower case
```

## Enable it

```toml
[plugins.available]
extra = { gh = "luispedro/luish-extra", release = "luish" }

[plugins.enabled]
extra.zmv = { }
```

or `plugin load extra/zmv`. With a luish that has `noglob` (after 0.8.0),
`mmv` is `noglob zmv -W`, so its patterns need no quotes (`mmv *.txt *.md`);
with luish 0.8.0, quote them, as `zmv`'s.

See [`docs/zmv.md`](../docs/zmv.md) for the details.
