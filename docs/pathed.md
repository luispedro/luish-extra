# pathed

The `pathed` plugin (`extra/pathed`, if the repository was added as `extra`) has `pathed`, which shows `PATH` with
what is wrong with it and edits it, and `vipath`, which is `pathed edit`. Enable it in `config.toml`:

```toml
[plugins.enabled]
extra.pathed = { }
```

or load it from `luishrc` or at the prompt with `plugin load extra/pathed`.

Changes are to the shell's `PATH`, for the rest of the session: nothing is written to a file. To keep a directory,
add it in a startup file as usual (`path=(~/bin "${path[@]}")`).

## Seeing PATH

`pathed` alone (or `pathed list`) shows `PATH`, numbered, with notes:

```text
$ pathed
 1  ~/.local/bin
 2  ~/miniconda3/bin       shadows pip, python3
 3  ./bin                  relative: ~/project/bin
 4  /usr/local/cuda/bin    missing
 5  /usr/bin
 6  /bin                   same directory as 5
 7  ~/.local/bin/          normalised: ~/.local/bin; duplicate of 1

normalised (pathed clean):
1  ~/.local/bin
2  ~/miniconda3/bin
3  ~/project/bin
4  /usr/local/cuda/bin
5  /usr/bin
6  /bin
```

The notes are:

| Note | Meaning |
|---|---|
| `shadows CMD, ...` | Commands that a later directory also has: this one's are run |
| `relative: DIR` | A relative directory, which changes with the current directory |
| `empty: the current directory` | An empty entry (`::`, or `:` at either end), which means the current directory |
| `a literal ~, which only bash expands` | A `~` that the shell didn't expand when `PATH` was set (other programs don't) |
| `normalised: DIR` | The entry has `.`, `..`, `//` or a trailing `/` |
| `duplicate of N` | The same directory as entry `N`, once normalised: it is never searched |
| `same directory as N` | The same directory as entry `N` through a symbolic link |
| `missing`, `not a directory` | There is no such directory |

When the normalised `PATH` differs from `PATH`, it is shown below. Normalised, each entry is absolute (a relative
one is taken from the current directory, and a leading `~` is the home directory), without `.`, `//` or a trailing
`/`, and without `..` where taking it out names the same directory. Empty entries and duplicates are left out (the
first is kept). Symbolic links aren't resolved, as a link is often chosen on purpose (a `current` link to a version,
say), and missing directories are kept, as they may be on a disk that isn't mounted.

`pathed which CMD...` shows every copy of a command in `PATH`, with the directory's number, where a symbolic link
points, and which one runs:

```text
$ pathed which python3
2  ~/miniconda3/bin/python3 -> python3.12  (runs)
5  /usr/bin/python3 -> python3.11
```

## Changing PATH

```text
pathed add [-afmnv] [--before ENTRY|--after ENTRY] DIR...
pathed rm [-nv] ENTRY...
pathed mv [-nv] ENTRY (N|first|last|--before ENTRY|--after ENTRY)
pathed clean [-nv] [--missing]
pathed edit                       (or pathed -e, or vipath)
pathed undo [-fn] | pathed undo -l
```

An `ENTRY` is a number, as `pathed` shows them; a directory, which names every entry that is the same once
normalised (`~/bin`, `/home/me/bin/`); or a pattern, quoted, matched against each entry as it is and normalised
(`'*conda*'`).

```sh
pathed add ~/bin                    # at the front
pathed add -a /opt/tool/bin         # at the end
pathed add --after ~/.local/bin .   # after an entry (the current directory, made absolute)
pathed add -m ~/bin                 # already there: moved to the front
pathed rm 4                         # by number
pathed rm '*conda*'                 # every entry that matches
pathed mv 2 last                    # to the end
pathed mv /usr/local/bin 1          # to the front
pathed mv 3 --before /usr/bin
pathed clean                        # PATH normalised
pathed clean --missing              # and without directories that don't exist
```

`add` takes the normalised forms of its directories, which must exist (`-f` adds them anyway). A directory that is
already in `PATH` is left where it is, unless `-m` moves it.

The changes are silent; `-v` shows them, and `-n` shows them without making them:

```text
$ pathed clean -n
normalised ./bin as ~/project/bin (3)
removed ~/.local/bin/ (7)
```

## Editing PATH in an editor

`pathed edit` (`pathed -e`, `vipath`) opens `PATH` in `$VISUAL` or `$EDITOR` (by default `vi`), one directory per
line, the first searched first, with the notes of `pathed` after `  #`:

```text
# PATH, one directory per line: the first is searched first. ...
~/.local/bin
~/miniconda3/bin       # shadows pip, python3
./bin                  # relative: ~/project/bin
/usr/local/cuda/bin    # missing
/usr/bin
```

Move lines to reorder `PATH`, delete them to remove directories, add some (a leading `~` is the home directory, and
a line `''` is the empty entry). Lines that start with `#` and notes after `  #` are ignored. When the editor exits,
`PATH` is set from the file, and the changes are shown. A file left as it was, or emptied, or an editor that fails
leaves `PATH` as it is. As in git, `$EDITOR` is shell code, so it can have arguments (`EDITOR='code -w'`).

## Undoing a change

Each change made by `pathed` keeps the `PATH` from before it. `pathed undo` goes back to the last one, and again to
the one before, up to 100; `pathed undo -l` lists the changes that can be undone, the last first, and `-n` shows
what undoing the last one would change. If `PATH` has changed since in some other way (`conda activate`, an
assignment), `undo` refuses, as that would be undone too, unless given `-f`.

The history is in the shell variables `__pathed_before`, `__pathed_after` and `__pathed_cmds`, so it is the
shell's own: a subshell can undo its own changes, which its parent doesn't see.

## Completion

`pathed` completes its subcommands and options, directories after `add`, the entries of `PATH` after `rm`, `mv`,
`--before` and `--after` (as numbers once a digit is typed, and with `~` once it is typed), the positions of `mv`,
and commands after `which`.
