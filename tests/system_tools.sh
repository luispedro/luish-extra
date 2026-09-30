# borg (repositories as directories or HOST:, `::` for an archive of BORG_REPO) and fusermount. The FUSE mount
# points come from the machine's /proc/mounts, so only a path that none can match is tried, and the hosts
# from its /etc/hosts, so repositories are only completed from a word that no host starts with.
__luish_internal plugin load "$EXTRA/complete/system"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p backups/repo mnt src bin
touch src/data.txt excludes.txt bin/zzcmd
chmod +x bin/zzcmd
PATH=$PWD/bin:$PATH
echo "=== borg"
c 'borg '
c 'borg --lock'
c 'borg init -e '
c 'borg init --encryption=repokey-'
c 'borg init back'
c 'borg init backups/'
c 'borg create --comp'
c 'borg create -C '
c 'borg create --compression=zs'
c 'borg create --chunker-params '
c 'borg create --files-cache='
c 'borg create --exclude-from '
c 'borg create backups/repo::today '
c 'borg create backups/repo::'
c 'borg list --sort-by '
c 'borg list backups/repo::x '
c 'borg prune --keep-'
c 'borg recreate --recompress='
c 'borg mount backups/repo mn'
c 'borg umount /zz-no-such-mount'
c 'borg key '
c 'borg key export --'
c 'borg benchmark crud backups/repo '
c 'borg help '
c 'borg help p'
c 'borg with-lock backups/repo zzc'
c 'borg with-lock backups/repo zzcmd s'
c 'borg list :'
BORG_REPO=$PWD/backups/repo
c 'borg list :'
echo "=== fusermount"
c 'fusermount -'
c 'fusermount m'
c 'fusermount -o '
c 'fusermount -u /zz-no-such-mount'
c 'fusermount3 -uz /zz-no-such-mount'
