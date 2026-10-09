# Metagenomics and microbial genomics: rgi.
__luish_internal plugin load "$EXTRA/completion/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/contigs.fna data/reads_1.fq.gz data/reads_2.fq.gz data/card.json data/notes.txt
echo "=== rgi"
c 'rgi '
c 'rgi ma'
c 'rgi main -'
c 'rgi main -i data/'
c 'rgi main -t '
c 'rgi main -a '
c 'rgi main -d '
c 'rgi main -g '
c 'rgi tab -i data/'
c 'rgi bwt -1 data/'
c 'rgi bwt -a '
c 'rgi load --card_annotation data/'
c 'rgi load --wildcard_index data/'
c 'rgi wildcard_annotation -i data/'
c 'rgi heatmap -cat '
c 'rgi heatmap -clus '
c 'rgi heatmap -d '
c 'rgi kmer_query --'
c 'rgi kmer_build -c data/'
c 'rgi database -'
c 'rgi auto_load --'
