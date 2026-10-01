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
echo "=== code"
mkdir -p .vscode/extensions .config/Code/User/globalStorage src
cat >.vscode/extensions/extensions.json <<'JSON'
[{"identifier": {"id": "ms-python.python", "uuid": "x"}, "version": "2026.4.0"},
 {"identifier": {"id": "mechatroner.rainbow-csv"}, "version": "3.24.1"}]
JSON
echo '{"userDataProfiles": [{"location": "-1a2b", "name": "Data science"}]}' >.config/Code/User/globalStorage/storage.json
touch ext.vsix
c 'code '
c 'code t'
c 'code -n t'
c 'code --uninstall-extension '
c 'code --install-extension '
c 'code --profile '
c 'code --locate-shell-integration-path '
c 'code chat -'
c 'code chat --mode '
c 'code tunnel '
c 'code tunnel --n'
c 'code tunnel user '
echo "=== meld"
c 'meld -'
c 'meld --comparison-file '
echo "=== gedit"
c 'gedit --encoding='
c 'gedit -'
