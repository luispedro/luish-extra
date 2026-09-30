# Small tools: duckdb, datamash, pigz, gnuplot, R and Rscript, aria2c and GNU parallel.
__luish_internal plugin load "$EXTRA/complete/science"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir bin
touch bin/zzcmd
chmod +x bin/zzcmd
PATH=$PWD/bin:$PATH
touch model.duckdb data.tsv plot.gp analysis.R run.r seeds.torrent list.meta4 notes.txt archive.tar
echo "=== duckdb"
c 'duckdb -'
c 'duckdb -cs'
c 'duckdb -f '
c 'duckdb mo'
echo "=== datamash"
c 'datamash '
c 'datamash --'
c 'datamash -g 1 su'
c 'datamash --sort-cmd '
c 'datamash -t '
echo "=== pigz"
c 'pigz -'
c 'pigz --su'
c 'pigz -S '
c 'pigz arch'
echo "=== gnuplot"
c 'gnuplot -'
c 'gnuplot -c '
c 'gnuplot pl'
echo "=== R and Rscript"
c 'Rscript '
c 'Rscript --v'
c 'Rscript --no-'
c 'Rscript --vanilla an'
c 'Rscript -e '
c 'Rscript analysis.R da'
c 'Rscript -g '
c 'R --'
c 'R CM'
echo "=== aria2c"
c 'aria2c --file-allocation='
c 'aria2c --file-allocation '
c 'aria2c --log-level '
c 'aria2c --dir '
c 'aria2c -o '
c 'aria2c --max-overall'
c 'aria2c --continue'
c 'aria2c --continue=t'
c 'aria2c --tor'
c 'aria2c -T '
c 'aria2c -M '
c 'aria2c se'
echo "=== parallel"
c 'parallel --jo'
c 'parallel --joblog '
c 'parallel --halt '
c 'parallel --results '
c 'parallel --keeporder'
c 'parallel --keep'
c 'parallel -j 4 zzc'
c 'parallel echo :'
c 'parallel echo {} ::: a'
c 'parallel echo {} :::: '
