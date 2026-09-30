# Alignment files, variants and intervals: samtools, tabix, bgzip, htsfile and
# bedtools. tests/bin/samtools is a stand-in that gives a BAM header with the
# sequences chrA and chrB.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/a.bam data/a.bam.bai data/b.sam data/c.cram data/notes.txt data/genome.fa data/genome.fa.gz data/reads.fq
touch data/peaks.bed data/peaks.bed.gz data/genes.gff3 data/calls.vcf.gz data/calls.bcf data/sizes.genome
printf 'chr1\t100\t6\t60\t61\nchr2\t50\t120\t60\t61\n' > data/genome.fa.fai
echo "=== samtools"
c 'samtools sor'
c 'samtools sort -'
c 'samtools sort -O '
c 'samtools sort --output-fmt='
c 'samtools sort -o out.bam data/'
c 'samtools view -T data/'
c 'samtools view --reference=data/'
c 'samtools view -L data/'
c 'samtools view -b data/'
c 'samtools view --with-h'
c 'samtools view data/a.bam '
c 'samtools view -T data/genome.fa data/a.bam c'
c 'samtools view -r '
c 'samtools index data/'
c 'samtools index -'
c 'samtools faidx data/'
c 'samtools faidx data/genome.fa '
c 'samtools faidx --mark-strand '
c 'samtools flagstat -O '
c 'samtools flagstat data/'
c 'samtools depth -b data/'
c 'samtools depth -r chrA data/a.bam'
c 'samtools coverage --'
c 'samtools mpileup -f data/'
c 'samtools merge -h data/'
c 'samtools stats -r data/'
c 'samtools bedcov data/'
c 'samtools fastq -'
c 'samtools nosuchsub data/'
echo "=== tabix, bgzip, htsfile"
c 'tabix -p '
c 'tabix data/'
c 'tabix -R data/'
c 'tabix data/calls.vcf.gz '
c 'tabix --pre'
c 'bgzip -'
c 'bgzip -I data/'
c 'htsfile -'
echo "=== bedtools"
c 'bedtools '
c 'bedtools inter'
c 'bedtools intersect -'
c 'bedtools intersect -a data/'
c 'bedtools intersect -a data/peaks.bed -b data/'
c 'bedtools intersect -a data/peaks.bed -b data/genes.gff3 -w'
c 'bedtools intersect -g data/'
c 'bedtools closest -D '
c 'bedtools closest -t '
c 'bedtools map -o '
c 'bedtools getfasta -fi data/'
c 'bedtools getfasta -bed data/'
c 'bedtools genomecov -ibam data/'
c 'bedtools genomecov -strand '
c 'bedtools makewindows -i '
c 'bedtools bamtobed -i data/'
c 'bedtools merge -i data/'
c 'bedtools sort -'
c 'bedtools slop -g data/'
c 'bedtools nosuchsub -'
