# cytoscape (and Cytoscape, cytoscape.sh): -s takes a session (.cys) file, and the program takes no other arguments.
__luish_internal plugin load "$EXTRA/complete/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p sessions
touch sessions/ppi.cys net.sif style.xml script.txt old.cys.bak
c 'cytoscape -'
c 'Cytoscape --s'
c 'cytoscape.sh -s '
c 'cytoscape --session sessions/'
c 'cytoscape -N '
c 'cytoscape -R '
c 'cytoscape -S script.txt '
echo "=== jalview"
touch aln.fa tree.nwk
c 'jalview --colour='
c 'jalview --open=aln.fa --format='
c 'jalview --tr'
echo "=== artemis"
touch reads.bam reads.cram genome.gbk
c 'art -D'
c 'art -Dbam=reads.bam,'
c 'art -Dshow_forward_lines='
c 'art genome.gbk +'
c 'act -'
c 'bamview -a '
c 'bamview -v '
c 'dnaplotter -t '
echo "=== BandageNG"
touch graph.gfa
c 'BandageNG '
c 'BandageNG image '
c 'BandageNG image graph.gfa out.png --sco'
c 'BandageNG image graph.gfa out.png --colour '
c 'BandageNG querypaths graph.gfa '
echo "=== pymol, chimerax, vmd"
c 'pymol -A '
c 'pymol -r '
c 'chimerax --start'
c 'vmd -dispdev '
c 'vmd -ps'
