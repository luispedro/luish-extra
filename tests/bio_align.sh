# Mapping and quantification: bwa, bowtie2, minimap2, hisat2, STAR, kallisto, featureCounts.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/ref.fa data/ref.fa.bwt data/ref.fa.amb data/ref.mmi data/r1.fq.gz data/r2.fq.gz data/reads.fa data/a.sai
touch data/idx.1.bt2 data/idx.2.bt2 data/idx.rev.1.bt2 data/gx.1.ht2 data/tx.idx data/genes.gtf data/a.bam data/notes.txt
echo "=== bwa"
c 'bwa '
c 'bwa me'
c 'bwa mem -'
c 'bwa mem -x '
c 'bwa mem data/'
c 'bwa mem data/ref.fa data/'
c 'bwa index -a '
c 'bwa index data/'
c 'bwa aln -f data/'
c 'bwa samse data/ref.fa data/'
c 'bwa sampe data/ref.fa data/a.sai data/'
c 'bwa-mem2 '
c 'bwa-mem2 mem -o data/'
echo "=== bowtie2, hisat2"
c 'bowtie2 -x data/'
c 'bowtie2 -x data/idx -1 data/'
c 'bowtie2 --very-'
c 'bowtie2 -p'
c 'bowtie2 --phred'
c 'bowtie2 --un-'
c 'bowtie2-build data/'
c 'bowtie2-build data/ref.fa data/'
c 'hisat2 -x data/'
c 'hisat2 --rna-strandness '
c 'hisat2 -U data/'
c 'hisat2-build --s'
echo "=== minimap2"
c 'minimap2 -x '
c 'minimap2 -x map-ont data/'
c 'minimap2 -x map-ont data/ref.mmi data/'
c 'minimap2 --secondary='
c 'minimap2 -d data/'
c 'minimap2 --sam-'
echo "=== STAR"
c 'STAR --runMode '
c 'STAR --runMod'
c 'STAR --genomeDir data/'
c 'STAR --readFilesIn data/'
c 'STAR --sjdbGTFfile data/'
c 'STAR --outSAMtype '
c 'STAR --outSAMstrandField '
c 'STAR --quantMode '
c 'STAR --genomeFastaFiles data/'
echo "=== kallisto, featureCounts"
c 'kallisto '
c 'kallisto index -i data/'
c 'kallisto index data/'
c 'kallisto quant -i data/'
c 'kallisto quant -g data/'
c 'kallisto quant -o data/'
c 'kallisto quant --f'
c 'kallisto bus -'
c 'featureCounts -a data/'
c 'featureCounts -F '
c 'featureCounts -s '
c 'featureCounts -o out.txt data/'
c 'featureCounts -R '
