# kate: the sessions of -s are the .katesession files of $XDG_DATA_HOME/kate/sessions (~/.local/share), named with
# their names percent-encoded. (The pids of -p, those of the running kates, depend on the machine.)
__luish_internal plugin load "$EXTRA/complete/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p .local/share/kate/sessions data/kate/sessions
touch .local/share/kate/sessions/work.katesession '.local/share/kate/sessions/my%20notes.katesession' \
    .local/share/kate/sessions/stray.txt data/kate/sessions/other.katesession notes.txt
echo "=== options"
c 'kate -'
c 'kate --s'
c 'kate -n'
echo "=== values"
c 'kate -s '
c 'kate --start w'
c 'kate -e '
c 'kate --encoding=ISO'
c 'kate -l 10 -c 3 n'
c 'kate --platform w'
XDG_DATA_HOME=$PWD/data
c 'kate -s '
