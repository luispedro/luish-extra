#!/bin/sh
# Check that HEAD can be released as TAG, then tag it. A release is a tag
# vX.Y.N, the Nth release for luish X.Y, which luish's release = "luish" takes
# for luish X.Y (any X.Y.Z), so it must not need more than luish X.Y.0.
#
#   scripts/release.sh vX.Y.N          check, then make the signed tag
#   scripts/release.sh --check vX.Y.N  only check (CI, on a pushed tag)
#   scripts/release.sh --needs         print the luish the plugins need: the
#                                      highest luish-version of a plugin.toml
#
# The checks: the tag's form; every plugin.toml has a luish-version, none newer
# than X.Y.0; the ChangeLog's top section is Version X.Y.N; no tag vX.Y.M with
# M >= N exists. To tag, also: a clean tree, and CI passed for HEAD (it tests
# against luish's main and against the vX.Y.0 that the plugins need), if gh is
# there to ask.
#
# vX.Y.0 is tagged before luish's X.Y.0, so that luish's release = "luish" finds
# it as soon as luish X.Y.0 is out: it is tested against luish's main, which
# is then the commit that luish tags (so check that it is).
cd "$(dirname "$0")/.." || exit 1
luish_repo=https://github.com/luispedro/luish

die() { echo "release.sh: $*" >&2; exit 1; }

# The luish-version of each plugin.toml, as "FILE VERSION".
versions() {
    for f in $(git ls-files '*plugin.toml'); do
        v=$(sed -n 's/^luish-version *= *"\([0-9.]*\)".*/\1/p' "$f")
        echo "$f ${v:-none}"
    done
}

needs() { versions | awk '{print $2}' | grep -v none | sort -V | tail -1; }

check=
case $1 in
--needs) needs; exit ;;
--check) check=1; shift ;;
esac
[ $# -eq 1 ] || die "usage: scripts/release.sh [--check] vX.Y.N | --needs"
tag=$1
echo "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' ||
    die "$tag: a release is vX.Y.N (luish skips pre-releases such as v0.7.0-rc1)"
version=${tag#v}
xy=${version%.*}
n=${version##*.}

# A plugin needing luish X.Y.Z with Z > 0 can't be in a vX.Y.N release: luish
# X.Y.0 takes it too.
versions | while read -r f v; do
    [ "$v" = none ] && die "$f has no luish-version"
    [ "$(printf '%s\n%s.0\n' "$v" "$xy" | sort -V | tail -1)" = "$xy.0" ] ||
        die "$f needs luish $v, newer than $xy.0"
done || exit 1

head -1 ChangeLog | grep -q "^Version $version " ||
    die "the ChangeLog starts with '$(head -1 ChangeLog)', not 'Version $version DATE by NAME'"

git ls-remote --exit-code --tags "$luish_repo" "refs/tags/v$xy.0" >/dev/null ||
    echo "release.sh: luish has no tag v$xy.0 yet: CI tested luish's main," \
        "$(git ls-remote "$luish_repo" refs/heads/main | cut -c1-7) now, which must be what luish tags v$xy.0" >&2

for t in $(git tag -l "v$xy.*"); do
    [ "$t" = "$tag" ] && [ -n "$check" ] && continue
    m=${t##*.}
    [ "$m" -ge "$n" ] 2>/dev/null && die "$t already exists: the next release is v$xy.$((m + 1))"
done

[ -n "$check" ] && { echo "$tag: ok"; exit 0; }

[ -z "$(git status --porcelain --untracked-files=no)" ] || die "the tree has uncommitted changes"
head=$(git rev-parse HEAD)
if command -v gh >/dev/null; then
    ci=$(gh run list --workflow CI --commit "$head" --json conclusion --jq '.[0].conclusion' 2>/dev/null)
    [ "$ci" = success ] || die "CI for $head: ${ci:-no run (push it first)}, not success"
else
    echo "release.sh: no gh, so CI for $head is not checked" >&2
fi

# Signed, as luish's tags, with the ChangeLog's section as the message.
{
    echo "RLS Version $version"
    echo
    sed -n '2,/^Version /{/^Version /d;s/^    //;p}' ChangeLog
} | git tag -s "$tag" -F - || exit 1
echo "Tagged $tag at $(git rev-parse --short HEAD). To publish it: git push origin $tag"
