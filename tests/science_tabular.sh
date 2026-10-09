# Tabular data: xsv and qsv, whose commands and options are read from their help (tests/bin/xsv and qsv are
# their real help, cut short).
__luish_internal plugin load "$EXTRA/completion/science"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
touch data.csv other.tsv notes.txt
echo "=== xsv"
c 'xsv '
c 'xsv se'
c 'xsv -'
c 'xsv select -'
c 'xsv select --'
c 'xsv select -o '
c 'xsv select --output '
c 'xsv select -d '
c 'xsv sort -'
c 'xsv sort -s '
c 'xsv sort data.csv '
c 'xsv nosuch -'
echo "=== qsv"
c 'qsv '
c 'qsv des'
c 'qsv --'
c 'qsv select --'
c 'qsv select -S -o '
c 'qsv select --seed '
c 'qsv select 1,2 da'
echo "=== mlr"
c 'mlr --icsv --op'
c 'mlr --ifs '
c 'mlr --ifs s'
c 'mlr --from '
c 'mlr --icsv --opprint so'
c 'mlr --icsv --opprint sort -'
c 'mlr sort -f a -nr x da'
c 'mlr --icsv head -'
c 'mlr cut --'
c 'mlr split -'
c 'mlr nosuchverb -'
