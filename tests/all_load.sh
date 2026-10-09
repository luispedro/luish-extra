# The plugin all, which only depends on the others: loading it loads each of them, after std's completion and
# extra-lib, and a command of each completes.
__luish_internal plugin load "$EXTRA/completion/all"
echo "load $?"
__luish_internal plugin list-loaded
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
c 'samtools so'
c 'pdflatex -inter'
c 'evince --pres'
c 'twine up'
c 'fusermount -'
