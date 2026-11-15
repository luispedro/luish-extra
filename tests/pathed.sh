# The plugin pathed: pathed (list, add, rm, mv, clean, edit, undo, which), vipath, and pathed's completion, on a
# PATH of directories made here. The tools the test itself needs are found before PATH is set, and named by path.
# t runs a command in this shell (so that it can change PATH), with errors on standard output, without what luish
# adds to them (the script, the line), and the directory of the test (HOME) shown as ~; p shows PATH so.
__luish_internal plugin load "$EXTRA/pathed"
echo "load $?"
SED=$(command -v sed)
c() { echo "--- $1"; __luish_internal complete "$1" | $SED "s|$HOME|~|g"; }
t() {
    echo "--- $*" | $SED "s|$HOME|~|g"
    "$@" >.out 2>&1
    s=$?
    $SED "s/^pathed.sh: [0-9]*: //; /^  in function /d; / >\.out 2>&1$/d; /^ *t /d; /^ *EDITOR=/d; s|$HOME|~|g" .out
    echo "status $s"
}
p() { echo "PATH=$PATH" | $SED "s|$HOME|~|g"; }
LN=$(command -v ln)
MKDIR=$(command -v mkdir)
CHMOD=$(command -v chmod)
$MKDIR -p one two three/sub new
: >one/tool; : >one/only1; : >two/tool; : >two/other; : >two/data; : >notdir
$CHMOD +x one/tool one/only1 two/tool two/other
$LN -s two link
$LN -s tool one/alias
H=$PWD

echo "=== list"
PATH="$H/one:two:$H/link:$H/one/:$H/nope::$H/notdir:$H/three/sub/..:~/new:$H/two"
t pathed
PATH=$H/one:$H/two
t pathed
PATH=
t pathed

echo "=== add"
PATH=$H/one:$H/two
t pathed add -v $H/new
p
t pathed add -v $H/one
t pathed add -mv $H/two
t pathed add -av $H/three
t pathed add -v --before $H/one $H/three/sub
t pathed add -v --after 2 three/sub/../sub $H/link
t pathed add -n --after 2 ./link
t pathed add $H/nope
t pathed add -f $H/nope
t pathed add --after 1 --before 2 $H/new
t pathed add -x $H/new
t pathed add
p
echo "runs: $(command -v tool)" | $SED "s|$HOME|~|g"

echo "=== rm"
t pathed rm -v '*nope*' 1
t pathed rm -v link
t pathed rm 99
t pathed rm $H/nope
p
echo "runs: $(command -v tool)" | $SED "s|$HOME|~|g"

echo "=== mv"
t pathed
t pathed mv -v 1 last
t pathed mv -v two first
t pathed mv -v 3 2
t pathed mv -v --after 1 3
t pathed mv -v '*one' --before two
t pathed mv 1 1
t pathed mv 1 nowhere
t pathed mv 1
t pathed mv 1 --after 1
p

echo "=== undo"
t pathed undo -l
t pathed undo -n
t pathed undo
p
PATH=$PATH:$H/new
t pathed undo
t pathed undo -f
p

echo "=== clean"
PATH="$H/one:two:$H/link:$H/one/:$H/nope::$H/three/sub/..:$H/two"
t pathed clean -n
t pathed clean -v --missing
p
t pathed clean -v
t pathed undo
p

echo "=== edit"
PATH="$H/one:$H/two::$H/nope"
EDITOR=: t pathed edit
EDITOR="$SED -i -n p" t pathed edit
EDITOR="$SED -i -e /nope/d -e 1i~/new" t pathed edit
p
EDITOR="$SED -i '/^[^#]/d'" t pathed -e
EDITOR=false t pathed edit
EDITOR="$SED -i 1i/x" VISUAL="$SED -i /two/d" t vipath
p
t pathed undo -l
EDITOR="$SED -n w/dev/stdout" t pathed edit

echo "=== which"
PATH="$H/one:$H/link:$H/two:$H/notdir"
t pathed which tool
t pathed which other only1 none
t pathed which alias
t pathed which one/tool

echo "=== errors"
t pathed nonsense
t pathed list extra
t pathed help

echo "=== completion"
PATH="$H/one:$H/two::$H/one"
c 'pathed '
c 'pathed add -'
c 'pathed add --before '
c 'pathed add n'
c 'pathed rm '
c 'pathed rm 1'
c 'pathed rm ~/'
c 'pathed mv 1 '
c 'pathed undo -'
c 'pathed which to'
