# Commands whose help is read at Tab time (dynamic.rhai). tests/bin/mmseqs is a
# stand-in with the help of three modules.
__luish_internal plugin load "$EXTRA/completion/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
touch mydb.fa
echo "=== mmseqs"
c 'mmseqs '
c 'mmseqs easy-'
c 'mmseqs createdb -'
c 'mmseqs createdb --shuffle '
c 'mmseqs createdb --dbtype '
c 'mmseqs createdb --local-tmp '
c 'mmseqs createdb my'
c 'mmseqs easy-search -e'
c 'mmseqs easy-search --add-self-matches '
c 'mmseqs nosuchmodule --'
c 'mmseqs ../evil --'
