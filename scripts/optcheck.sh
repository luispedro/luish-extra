#!/bin/sh
# Check a spec against the --help of a tool at a pinned version, in a temporary
# pixi environment (bioconda + conda-forge):
#
#   scripts/optcheck.sh PACKAGE[=VERSION] PROG [SUB]...
#
# runs `PROG SUB --help` in the environment and prints what scripts/optdiff.py
# finds for "PROG SUB" (for each SUB, or for PROG alone). The version to write in
# completion-todo.md is the one printed on the first line.
# Environment: HELP (the flag that prints the help, default --help),
# CHANNELS (default: -c conda-forge -c bioconda), LUISH and STD_PLUGINS as for optdiff.py.
set -e
here=$(cd "$(dirname "$0")" && pwd)
pkg=$1; prog=$2; shift 2
HELP=${HELP:---help}
CHANNELS=${CHANNELS:--c conda-forge -c bioconda}
pixi exec $CHANNELS -s "$pkg" -- conda-meta-version 2>/dev/null || true
[ $# -eq 0 ] && set -- ""
for sub in "$@"; do
    printf '%s %s: ' "$prog" "$sub"
    # shellcheck disable=SC2086
    timeout 60 pixi exec $CHANNELS -s "$pkg" -- sh -c "$prog $sub $HELP </dev/null 2>&1" |
        "$here/optdiff.py" "$prog $sub" | tr '\n' ' '
    echo
done
