#!/bin/sh
# Check that a program built with Click answers completion, and how fast, in a
# temporary pixi environment (bioconda + conda-forge), the way luish's Click
# bridge (std's completion plugin) asks it:
#
#   scripts/clickcheck.sh PACKAGE[=VERSION] PROG [WORD...]
#
# runs, for each WORD ("" is the empty word: the subcommands), the completion
# of `PROG WORD` and prints the time of the third run (the first ones write the
# .pyc files) and the first candidates. No output but the time means the
# program doesn't know the protocol. A completion should take well under a
# second; several seconds means the program imports too much at startup.
# Environment: CHANNELS (default: -c conda-forge -c bioconda).
set -e
pkg=$1; prog=$2; shift 2
CHANNELS=${CHANNELS:--c conda-forge -c bioconda}
[ $# -eq 0 ] && set -- ""
export PROG=$prog
# shellcheck disable=SC2086
timeout 900 pixi exec $CHANNELS -s "$pkg" -- sh -c '
    var=_$(printf %s "$PROG" | tr a-z- A-Z_)_COMPLETE
    for line in "$@"; do
        cur=${line##* }; [ "$line" = "$cur" ] && [ -n "$line" ] && cur=$line
        [ "${line% *}" = "$line" ] && before= || before=${line% *}
        [ -z "$line" ] && cur= 
        words="$PROG${before:+ $before}${cur:+ $cur}"
        [ -z "$cur" ] && words="$words "
        run() { env "$var=fish_complete" COMP_WORDS="$words" COMP_CWORD="$cur" "$PROG" </dev/null 2>/dev/null; }
        run >/dev/null; run >/dev/null
        t0=$(date +%s%N); out=$(run); t1=$(date +%s%N)
        printf "== %s [%s]: %d ms, %d candidates\n" "$PROG" "$line" $(( (t1 - t0) / 1000000 )) "$(printf "%s\n" "$out" | grep -c .)"
        printf "%s\n" "$out" | head -${HEAD:-6}
    done' sh "$@" </dev/null
