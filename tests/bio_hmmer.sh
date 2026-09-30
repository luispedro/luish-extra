# HMMER.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/pfam.hmm data/q.fa data/db.faa data/aln.sto data/aln.sto.gz data/notes.txt
echo "=== hmmer"
c 'hmmsearch --tb'
c 'hmmsearch data/'
c 'hmmsearch data/pfam.hmm data/'
c 'hmmsearch --tblout data/'
c 'hmmsearch --cut_'
c 'hmmsearch -E'
c 'hmmscan --domtblout '
c 'phmmer --mx '
c 'phmmer --tformat '
c 'jackhmmer -N'
c 'hmmbuild --inf'
c 'hmmbuild --informat '
c 'hmmbuild out.hmm data/'
c 'hmmbuild --amino'
c 'hmmalign --outformat '
c 'hmmalign data/'
c 'hmmpress data/'
c 'hmmemit -'
c 'nhmmer --dna'
