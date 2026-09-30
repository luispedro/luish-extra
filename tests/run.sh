#!/bin/sh
# Run each tests/*.sh with luish, in a fresh directory that is also $HOME, and
# compare its standard output with the .expected next to it, as luish's own
# plugin tests do (../luish/tests/compare.rs).
#
#   tests/run.sh [NAME...]     run these cases (by name, without .sh), or all
#   UPDATE=1 tests/run.sh ...  write the .expected files instead of comparing
#
# Environment:
#   LUISH        the luish to run (default: luish in PATH)
#   STD_PLUGINS  luish-std-plugins (default: ../luish/luish-std-plugins)
#
# The scripts get $STD_PLUGINS, $EXTRA (this repository) and $PATH with
# tests/bin first: stand-in programs go there (none are needed yet).
here=$(cd "$(dirname "$0")" && pwd)
EXTRA=$(dirname "$here")
LUISH=${LUISH:-luish}
STD_PLUGINS=${STD_PLUGINS:-$EXTRA/../luish/luish-std-plugins}
STD_PLUGINS=$(cd "$STD_PLUGINS" && pwd) || exit 1
export EXTRA STD_PLUGINS

if [ $# -eq 0 ]; then
    set -- $(cd "$here" && ls *.sh | sed 's/\.sh$//' | grep -v '^run$')
fi

tmp=$(mktemp -d "${TMPDIR:-/tmp}/luish-extra-test.XXXXXX") || exit 1
trap 'rm -rf "$tmp"' EXIT
fail=0
for name in "$@"; do
    dir=$tmp/$name
    mkdir -p "$dir"
    cp "$here/$name.sh" "$dir/"
    mkdir -p "$dir/.config/luish"
    printf '[plugins.available]\nstd = { path = "%s" }\n' "$STD_PLUGINS" >"$dir/.config/luish/config.toml"
    (
        cd "$dir" &&
        env -i PATH="$here/bin:$PATH" HOME="$dir" LC_ALL=C \
            EXTRA="$EXTRA" STD_PLUGINS="$STD_PLUGINS" \
            "$LUISH" "$name.sh" >"$dir/.stdout" 2>"$dir/.stderr"
    )
    if [ -n "$UPDATE" ]; then
        cp "$dir/.stdout" "$here/$name.expected"
        echo "updated $name"; [ -s "$dir/.stderr" ] && cat "$dir/.stderr"
        continue
    fi
    if diff -u "$here/$name.expected" "$dir/.stdout" >"$dir/.diff"; then
        if [ -s "$dir/.stderr" ]; then
            echo "FAIL $name (stderr)"
            cat "$dir/.stderr"
            fail=1
        else
            echo "ok   $name"
        fi
    else
        echo "FAIL $name"
        cat "$dir/.diff"
        [ -s "$dir/.stderr" ] && cat "$dir/.stderr"
        fail=1
    fi
done
exit $fail
