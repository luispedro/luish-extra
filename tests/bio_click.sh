# Programs built with Click, completed by std's Click bridge (complete/bio/extension.rhai).
# The programs are stand-ins made here, one for each command: they answer
# _PROG_COMPLETE=fish_complete as Click does, and print usage otherwise.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir bin
for prog in multiqc peddy genmod plassembler cooler pairtools checkv virsorter metacoag harpy defense-finder dnaapler \
            genomepy freyja fastq-dl biom; do
    var=_$(echo "$prog" | tr a-z- A-Z_)_COMPLETE
    cat >bin/$prog <<STUB
#!/bin/sh
[ "\$$var" = fish_complete ] || { echo "Usage: $prog [OPTIONS]"; exit 0; }
W=\$(printf "%s" "\$COMP_WORDS" | sed "s/\x27\([A-Za-z0-9_=.\/-]*\)\x27/\1/g")
case "\$W|\$COMP_CWORD" in
"$prog |") printf "plain,run\tRun $prog.\nplain,info\tShow info.\n" ;;
"$prog run --|--") printf "plain,--input\tThe input.\nplain,--format\tThe format.\nplain,--help\tShow this message and exit.\n" ;;
"$prog run --format |") printf "plain,json\nplain,tsv\n" ;;
"$prog ru|ru") printf "plain,run\tRun $prog.\n" ;;
"$prog run --f|--f") printf "plain,--format\tThe format.\n" ;;
"$prog run --format j|j") printf "plain,json\n" ;;
"$prog run -i r|r") printf "file,r\n" ;;
esac
STUB
    chmod +x bin/$prog
done
PATH=$PWD/bin:$PATH
touch reads.fq report.html
mkdir results

echo "=== each command is asked"
for prog in multiqc peddy genmod plassembler cooler pairtools checkv virsorter metacoag harpy defense-finder dnaapler \
            genomepy freyja fastq-dl biom; do
    c "$prog "
done
echo "=== subcommands, options, values, files"
c 'multiqc ru'
c 'multiqc run --'
c 'multiqc run --format '
c 'multiqc run -i r'
c 'fastq-dl run --f'
c 'defense-finder run --format j'
echo "=== not installed: filenames"
c 'nosuchclick r'
