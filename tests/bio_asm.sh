# Assembly and annotation: spades.py, metaspades.py, megahit, flye, quast, metaquast, busco, prodigal, pyrodigal,
# prokka, bakta, barrnap, emapper.py, download_eggnog_data.py, create_dbs.py, hmm_mapper.py.
__luish_internal plugin load "$EXTRA/completion/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/r1.fq.gz data/r2.fq.gz data/ont.fastq data/contigs.fa data/genes.gff data/a.bam data/models.hmm
touch data/notes.txt data/eggnog_proteins.dmnd
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
echo "=== prodigal, pyrodigal, prokka, bakta, barrnap"
c 'prodigal -'
c 'prodigal -p '
c 'prodigal -i data/'
c 'pyrodigal --'
c 'pyrodigal -g '
c 'pyrodigal -i data/'
c 'prokka --kingdom '
c 'prokka --hmms data/'
c 'prokka data/'
c 'bakta --gram '
c 'bakta --skip-'
c 'bakta data/'
c 'barrnap --kingdom '
c 'barrnap --no-'
c 'barrnap data/'
echo "=== emapper.py"
c 'emapper.py --sensm'
c 'emapper.py -m '
c 'emapper.py -i data/'
c 'emapper.py --itype '
c 'emapper.py --dmnd_db data/'
c 'emapper.py --tax_scope '
c 'emapper.py --tax_scope data/'
c 'emapper.py --tax_scope_mode inner'
c 'emapper.py --decorate_gff '
c 'emapper.py --decorate_gff data/'
c 'emapper.py --data_dir data/'
c 'emapper.py -d '
echo "=== download_eggnog_data.py, create_dbs.py, hmm_mapper.py"
c 'download_eggnog_data.py -'
c 'download_eggnog_data.py --data_dir data/'
c 'create_dbs.py -m '
c 'hmm_mapper.py --qtype '
c 'hmm_mapper.py -d data/'
c 'hmm_mapper.py --hmm_'
