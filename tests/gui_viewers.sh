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
