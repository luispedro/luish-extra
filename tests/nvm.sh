# The plugin nvm, loaded from luishrc with its options (and, at the end, enabled in config.toml): nvm.sh and `nvm use
# VERSION` run once, and later shells restore what they did, until something the block is keyed on changes. nvm is
# stood in for by an nvm.sh in ~/.nvm, which logs its calls and does what the real one does, in short: it defines the
# function nvm, whose `use` resolves `node` (the newest installed version) and the aliases, and puts the version's bin
# in PATH.
mk() {
    mkdir -p "$1/alias/lts" "$1/versions/node/v20.1.0/bin" "$1/versions/node/v22.2.0/bin"
    cat > "$1/nvm.sh" <<'X'
echo "nvm.sh $*" >> "$HOME/nvm.log"
case " $* " in *" --no-use "*) ;; *) nvm use default >/dev/null 2>&1 ;; esac
nvm() {
    [ "$1" = use ] || return 0
    echo "nvm use $2" >> "$HOME/nvm.log"
    case $2 in
    node) v=$(ls "$NVM_DIR/versions/node" | sort -V | tail -n 1) ;;
    v*) v=$2 ;;
    *) v=$(cat "$NVM_DIR/alias/$2" 2>/dev/null) ;;
    esac
    if [ -z "$v" ] || [ ! -d "$NVM_DIR/versions/node/$v" ]; then
        echo "N/A: version \"$2\" is not yet installed." >&2
        return 3
    fi
    export PATH=$NVM_DIR/versions/node/$v/bin:$PATH NVM_BIN=$NVM_DIR/versions/node/$v/bin
    echo "Now using node $v"
}
X
}
mk "$HOME/.nvm"
C=$HOME/.config/luish
# Not the machine's PATH, which may have a node of nvm's.
LUISH=$(command -v "$LUISH")
PATH=/usr/bin:/bin
show='echo "PATH=$PATH"; echo "NVM_DIR=$NVM_DIR NVM_BIN=$NVM_BIN"; type nvm | head -1; set | grep -c "^_luish_nvm"'
run() {
    : > "$HOME/nvm.log"
    "$LUISH" -i -c "$show" 2>&1 | grep -v 'job control' | sed "s|$HOME|~|g"
    sed "s|$HOME|~|g; s/^/ran: /" "$HOME/nvm.log"
}
echo 'plugin load "$EXTRA/nvm" version=node' > "$C/luishrc"
echo '--- the first shell runs nvm (and nvm use prints nothing)'
run
echo '--- the next restores what it did'
run
echo '--- a version installed'
mkdir -p "$HOME/.nvm/versions/node/v24.0.0/bin"
run
run
echo '--- a version uninstalled'
rm -r "$HOME/.nvm/versions/node/v24.0.0"
run
echo '--- no version: the alias default, if there is one'
echo 'plugin load "$EXTRA/nvm"' > "$C/luishrc"
run
echo 'v20.1.0' > "$HOME/.nvm/alias/default"
run
run
echo '--- an alias changed'
echo 'v22.2.0' > "$HOME/.nvm/alias/default"
run
echo '--- a new alias, used by name'
echo 'v20.1.0' > "$HOME/.nvm/alias/lts/iron"
echo 'plugin load "$EXTRA/nvm" version=lts/iron' > "$C/luishrc"
run
run
echo '--- a version that is not installed: an error, not cached'
echo 'plugin load "$EXTRA/nvm" version=v18.0.0' > "$C/luishrc"
run
run
echo '--- none: only nvm.sh'
echo 'plugin load "$EXTRA/nvm" version=none' > "$C/luishrc"
run
echo '--- an ~/.npmrc (where npm prefix, which nvm refuses, may be set)'
echo 'plugin load "$EXTRA/nvm" version=node' > "$C/luishrc"
run
echo 'color=false' > "$HOME/.npmrc"
run
echo '--- NVM_DIR in the environment, or the option dir'
mk "$HOME/other"
export NVM_DIR=$HOME/other
run
unset NVM_DIR
echo 'plugin load "$EXTRA/nvm" dir=~/other version=v20.1.0' > "$C/luishrc"
run
echo '--- no nvm'
echo 'plugin load "$EXTRA/nvm" dir=~/nowhere' > "$C/luishrc"
run
echo '--- enabled in config.toml, with its options: the block is cached on its own there too'
rm "$C/luishrc"
printf '[plugins.enabled]\nnvm = { path = "%s/nvm", options = { version = "node" } }\n' "$EXTRA" >> "$C/config.toml"
run
run
mkdir -p "$HOME/.nvm/versions/node/v24.0.0/bin"
run
run
