# fzf, and bat (and Debian's batcat): its languages and themes are asked of tests/bin/bat, a stand-in.
__luish_internal plugin load "$EXTRA/complete/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p bin src
touch notes.md src/main.rs
ln -s "$(command -v bat)" bin/batcat
PATH=$PWD/bin:$PATH
echo "=== fzf"
c 'fzf --lay'
c 'fzf --layout='
c 'fzf --layout '
c 'fzf --border='
c 'fzf --border'
c 'fzf --header-border='
c 'fzf --tiebreak='
c 'fzf -m'
c 'fzf --walker-root='
c 'fzf --history '
c 'fzf --no-'
c 'fzf '
echo "=== bat"
c 'bat '
c 'bat -l '
c 'bat -l py'
c 'bat --language=Ma'
c 'bat --theme='
c 'bat --theme-dark '
c 'bat --style '
c 'bat --paging='
c 'bat -p'
c 'batcat -l R'
c 'batcat --theme '
