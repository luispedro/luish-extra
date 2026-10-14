# Sequence clustering: vsearch and cd-hit.
__luish_internal plugin load "$EXTRA/completion/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/seqs.fasta data/reads.fq.gz data/prot.faa data/db.udb data/notes.txt
echo "=== vsearch"
c 'vsearch --cluster_'
c 'vsearch --cluster_fast data/'
c 'vsearch --fastq_mergepairs data/'
c 'vsearch --cluster_fast data/seqs.fasta --id 0.97 --centroids data/'
c 'vsearch --usearch_global data/seqs.fasta --db data/'
c 'vsearch --qmask '
c 'vsearch --strand '
c 'vsearch --iddef '
c 'vsearch --fastq_minm'
c 'vsearch -'
echo "=== cd-hit"
c 'cd-hit -'
c 'cd-hit -i data/'
c 'cd-hit -a'
c 'cd-hit -g '
c 'cd-hit-est -i data/'
c 'cd-hit-est -j'
c 'cd-hit-2d -i2 data/'
c 'cd-hit-est-2d -gap'
c 'cd-hit-454 -D'
