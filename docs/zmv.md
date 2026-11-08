# zmv

The `zmv` plugin (`extra/zmv`, if the repository was added as `extra`) has zsh's
[`zmv`](https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#index-zmv), `zcp` and `zln`, which rename,
copy or link the files that a pattern matches, to names built from the parts of each name that the pattern's groups
matched, and `mmv`, which is `zmv -W`. Enable it in `config.toml`:

```toml
[plugins.enabled]
extra.zmv = { }
```

or load it from `luishrc` or at the prompt with `plugin load extra/zmv`.

## Using it

```text
zmv [-finqQsvwW] [-C|-L|-M|-p PROG|-P PROG] [-o OPTS] SRCPAT DEST
```

`SRCPAT` is a pattern, and its parenthesised parts are groups. `DEST` is evaluated for each file that `SRCPAT`
matches, as a string in double quotes, with `$1`, `$2`, ... the text that the groups matched and `$f` the file's
name. Quote both, so that the shell passes them as they are:

```sh
zmv '(*).txt' '$1.md'              # a.txt -> a.md
zmv '(*)-(*).mp3' '$2-$1.mp3'      # artist-title.mp3 -> title-artist.mp3
zmv '(**/)(*).jpeg' '$1$2.jpg'     # also in subdirectories
zmv '(*).(c|h)' 'old/$1.$2'        # into old/
zmv '(*)' '${1:l}'                 # names in lower case (luish's modifiers)
zmv -W '*.txt' '*.md'              # -W: the wildcards are the groups
mmv '*.txt' '*.md'                 # mmv is zmv -W
zcp '(*).conf' '$1.conf.orig'      # copies
zln -s '(*).so.1' '$1.so'          # symbolic links
```

Nothing is done if anything is wrong: if two files would get the same name (unless it is a directory, which they
are moved into), a target exists (without `-f`), or a target is empty. A file whose target is its own name is left
alone. Run it with `-n` first to see what it would do.

| Option | Meaning |
|---|---|
| `-n` | Show the commands, without running them |
| `-v` | Show each command as it runs |
| `-i` | Ask before each command (run it if the answer starts with `y`) |
| `-f` | Overwrite targets that exist (it isn't passed to `mv`: use `-o -f` for that) |
| `-w` | Make each wildcard of `SRCPAT` (`*`, `?`, `[...]`, `**/`) a group |
| `-W` | As `-w`, and turn the wildcards of `DEST` into `${1}`, `${2}`, ... in turn |
| `-C`, `-L`, `-M` | Copy, link or move, whatever the command's name |
| `-s` | Symbolic links, with `zln` or `-L` (`ln -s`) |
| `-p PROG` | Run `PROG -- FILE TARGET` instead of `mv`, `cp` or `ln` (`-p 'git mv'`) |
| `-P PROG` | As `-p`, for a program that doesn't take `--` |
| `-o OPTS` | Options for the program, split at spaces (`-o -f`) |
| `-Q` | A final group of `SRCPAT` is a glob qualifier (`'(*)(.)'`: regular files) |

### Patterns

`SRCPAT` has `*` and `?` (which don't match `/`), bracket expressions (`[a-c]`, `[!0-9]`, `[[:digit:]]`), `**/`
for any number of directories (`***/` follows symbolic links), groups (`(...)`), alternatives in a group
(`(*.c|*.h)`) and a backslash quoting the next character. As in zsh, files whose name starts with `.` match only
with the `D` qualifier, and a qualifier is written `(#q...)` at the end (`'*.log(#qD.m+7)'`: also hidden files,
regular files only, modified more than 7 days ago), or, with `-Q`, as a final group. The qualifiers are those of
luish's [globbing](https://luish.readthedocs.io/en/latest/globbing.html). zsh's other extended patterns (`#`, `~`,
`^`, `<1-10>`) are taken literally.

## Without quotes: `mmv` and `noglob`

zsh users usually have `alias mmv='noglob zmv -W'`, so that `mmv *.txt *.md` reaches `zmv` as typed, rather than
with the patterns expanded. With a luish that has `noglob` (after 0.8.0), the plugin defines that alias in interactive
shells. With luish 0.8.0, `mmv` is the plugin's command, and its patterns must be quoted (unquoted, they are expanded,
and `mmv` is given the wrong number of arguments, or patterns that don't match, which it reports without doing
anything).

## How it works

The commands are written in Rhai. `SRCPAT` is translated into a pattern for luish's globbing (without the groups;
`(a|b)` becomes `{a,b}`) and into an anchored extended regular expression with them. A shell function matches each
file with `[[ $f =~ RE ]]` and evaluates `DEST` with the groups as its positional parameters, so that the shell's
own are left as they are, and the functions and variables of the shell can be used in `DEST`.
