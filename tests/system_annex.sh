# git-annex, which completes itself (tests/bin/git-annex stands in for it, with the remotes origin and
# backup): the commands, with the descriptions of its --help; options; remotes, also after `--to=`;
# backends; files, which luish lists again (git-annex lists them with compgen); a value it has no
# completion for is a filename. std's git completer hands `git annex` over, in the directory of `-C`.
__luish_internal plugin load "$EXTRA/completion/system"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p repo/sub repo/.git
touch repo/afile repo/bfile repo/sub/c
c 'git -C repo annex get '
cd repo
c 'git-annex '
c 'git-annex co'
c 'git-annex help co'
c 'git-annex copy --t'
c 'git-annex copy -d'
c 'git-annex copy --to '
c 'git-annex copy --to=or'
c 'git-annex copy --in '
c 'git-annex copy -B SHA2'
c 'git-annex get '
c 'git-annex get s'
c 'git-annex get sub/'
c 'git-annex sync '
c 'git-annex sync --content-of '
c 'git-annex version '
c 'git annex co'
c 'git annex copy --to=or'
