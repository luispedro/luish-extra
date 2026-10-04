# The whole repository as a source, under any name (here x, not extra): its plugins are x/complete/NAME (luish's
# sub-collections), and their kinds and sub_specs name their modules by path, so they don't depend on the name.
printf 'x = { path = "%s" }\n' "$EXTRA" >>"$HOME/.config/luish/config.toml"
echo "--- available: the completion plugins under complete/, and themes"
__luish_internal plugin list-available | grep '^x/'
__luish_internal plugin load x/complete/all
echo "load $?"
__luish_internal plugin list-loaded
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir data
touch data/genome.fa data/notes.txt
c 'samtools view -T data/'
c 'bwa mem -'
c 'borg create --compression '
