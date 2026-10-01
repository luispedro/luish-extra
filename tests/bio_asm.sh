# Assembly and annotation: spades.py, metaspades.py, megahit, flye, quast, metaquast, busco, prodigal, prokka, bakta,
# barrnap.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/r1.fq.gz data/r2.fq.gz data/ont.fastq data/contigs.fa data/genes.gff data/a.bam data/models.hmm
touch data/notes.txt
echo "=== spades.py, metaspades.py"
c 'spades.py --pe-'
c 'spades.py -1 data/'
c 'spades.py --pe-1 1 data/'
c 'spades.py --trusted-contigs data/'
c 'spades.py --restart-from '
c 'spades.py -o data/'
c 'metaspades.py --'
echo "=== megahit"
c 'megahit --presets '
c 'megahit -r data/'
c 'megahit --k-'
echo "=== flye"
c 'flye --nano'
c 'flye --nano-hq data/'
c 'flye --nano-hq data/ont.fastq data/'
c 'flye --stop-after '
c 'flye --polish-target data/'
echo "=== quast, metaquast"
c 'quast -a '
c 'quast.py --plots-format '
c 'quast -r data/'
c 'quast --ref-bam data/'
c 'quast data/'
c 'metaquast --max'
echo "=== busco"
c 'busco -m '
c 'busco -i data/'
c 'busco --datasets_version '
c 'busco -l '
mkdir -p busco_downloads/lineages/bacteria_odb12 busco_downloads/lineages/mine_odb12 dl/lineages/archaea_odb12
printf 'bacteria_odb12\t2024-11-14\tx\tProkaryota\tlineages\nbacteroidales_odb12\t2024-11-14\tx\tProkaryota\tlineages\nlist_of_reference_markers.bacteria_odb12.txt\t2024-11-15\tx\tProkaryota\tplacement_files\n' >busco_downloads/file_versions.tsv
c 'busco -l bac'
c 'busco -l m'
c 'busco -l busco_downloads/lineages/'
c 'busco --download_path dl -l '
c 'busco --download '
echo "=== prodigal, prokka, bakta, barrnap"
c 'prodigal -'
c 'prodigal -p '
c 'prodigal -i data/'
c 'prokka --kingdom '
c 'prokka --hmms data/'
c 'prokka data/'
c 'bakta --gram '
c 'bakta --skip-'
c 'bakta data/'
c 'barrnap --kingdom '
c 'barrnap --no-'
c 'barrnap data/'
