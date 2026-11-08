# The plugin zmv: zmv, zcp, zln and mmv (zmv -W), run on files made here, and their completion. Errors go to standard
# output (2>&1), without what luish adds (the script, the line, the function and the code around the error).
__luish_internal plugin load "$EXTRA/zmv"
echo "load $?"
c() { echo "--- $1"; __luish_internal complete "$1"; }
t() { echo "--- $*"; "$@" 2>&1 | sed 's/^.*: [0-9]*: //; /^  in function /d; /^    /d'; }
mkdir -p d/e
touch a.txt b.txt 'c d.txt' d/x.txt d/e/y.txt p.c q.h .hidden.txt
mkdir esc bin
touch 'esc/a(1)' 'esc/a{2},' bin/zmvprog
chmod +x bin/zmvprog
t zmv -n '(*).txt' '$1.md'
t zmv -n '(*)' '${1:u}'
t zmv -n '(*).(c|h)' '$2.$1'
t zmv -n '(**/)(*).txt' '$1new-$2.txt'
t zmv -nW '**/*.txt' '**/*.lis'
t zmv -nw '*.txt' '$1.$f'
t mmv -n '*.txt' '*.md'
t mmv -n '[ab].txt' '*.TXT'
t zmv -n '*.txt(#qD)' 'dot/$f'
t zmv -nQ '(*)(.)' 'files/$1'
t zmv -n 'esc/a\((*)\)' 'esc/a-$1'
t zmv -n 'esc/a(\{*\}),' 'esc/b$1'
t zmv -n 'esc/*' 'esc/$f'
# Errors: nothing is done.
t zmv '(*).txt' 'all'
t zmv '(a).txt' 'b.txt'
t zmv '(*).txt' ''
t zmv 'none*' x
t zmv '(*.txt' x
t zmv -W '*.txt' '*.*'
t zmv '(*).txt' '"'
t zmv one
t zmv -Z a b
t zmv -p
ls
# Done: positional parameters and $f are left as they were.
set -- one two
f=kept
t zmv -v '(*).txt' '$1.md'
echo "$1 $2 $f"
t zmv -f '(a).md' 'b.md'
t zcp -v '(b).md' '$1.copy'
t zln -sv b.md link
t zmv -L -o -s '(b).copy' '$1.link2'
t zmv -P echo '(p).c' '$1.C'
t zmv -p 'echo run' '(q).h' '$1.H'
t zmv -M '(**/)(*).txt' '$1$2.txt.bak'
t zmv -i '*.md' 'X$f' </dev/null
echo
ls -l | sed -n 's/^\(l\).* \([^ ]*\) -> \(.*\)$/\1 \2 -> \3/p'
find . -name '*.bak' | sort
c 'zmv -'
c 'mmv -n'
PATH=$PWD/bin:$PATH c 'zmv -p zmvpr'
c 'zcp -o '
c 'zln b.'
