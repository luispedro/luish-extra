# BLAST+ programs.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/q.fa data/nr.00.pin data/nr.01.pin data/nr.pal data/nt.nin data/notes.txt data/list.txt data/p.dmnd
echo "=== blast"
c 'blastn -qu'
c 'blastn -query data/'
c 'blastn -query data/q.fa -db data/'
c 'blastn -task '
c 'blastn -strand '
c 'blastn -outfmt '
c 'blastn -out data/'
c 'blastn -use_index '
c 'blastp -matrix '
c 'blastp -comp_based_stats '
c 'blastx -db data/'
c 'blastx -seg '
c 'tblastn -taxidlist data/'
c 'psiblast -in_msa data/'
c 'psiblast -out_pssm data/'
c 'rpsblast -db data/'
c 'makeblastdb -dbtype '
c 'makeblastdb -in data/'
c 'makeblastdb -input_type '
c 'makeblastdb -parse'
c 'blastdbcmd -db data/'
c 'blastdbcmd -entry_batch data/'
c 'blastdbcmd -outfmt'
c 'blast_formatter -archive data/'
c 'blastdb_aliastool -dbtype '
c 'dustmasker -in data/'
c 'update_blastdb.pl --source '
c 'update_blastdb.pl --showall='
c 'update_blastdb.pl --de'
echo "=== diamond"
c 'diamond '
c 'diamond blastp -'
c 'diamond blastp --db data/'
c 'diamond blastp -d data/'
c 'diamond blastp --query data/'
c 'diamond blastp --outfmt '
c 'diamond blastp --strand='
c 'diamond blastp --matrix '
c 'diamond blastp --unal '
c 'diamond blastp --very'
c 'diamond makedb --in data/'
c 'diamond makedb --db data/'
c 'diamond view --daa data/'
c 'diamond nosuchsub --'
