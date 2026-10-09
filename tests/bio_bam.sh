# Utilities for alignment and variant files: sambamba, bamtools, samblaster,
# mosdepth, cramino and vcftools. tests/bin/samtools and tests/bin/bcftools
# stand in for the programs that give reference names and samples.
__luish_internal plugin load "$EXTRA/completion/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/a.bam data/b.sam data/c.cram data/genome.fa data/peaks.bed data/calls.vcf.gz data/notes.txt
echo "=== sambamba"
c 'sambamba '
c 'sambamba m'
c 'sambamba view -'
c 'sambamba view --for'
c 'sambamba view -f '
c 'sambamba view -L data/'
c 'sambamba view data/'
c 'sambamba view data/a.bam '
c 'sambamba index data/'
c 'sambamba index -F data/'
c 'sambamba sort --tmpdir data/'
c 'sambamba markdup data/'
c 'sambamba subsample --logging '
c 'sambamba depth '
c 'sambamba depth window --'
c 'sambamba depth region -T '
c 'sambamba depth region -L data/'
c 'sambamba mpileup --s'
echo "=== bamtools"
c 'bamtools '
c 'bamtools filter -isP'
c 'bamtools filter -isPaired '
c 'bamtools convert -format '
c 'bamtools convert -in data/'
c 'bamtools convert -fasta data/'
c 'bamtools help '
echo "=== samblaster, mosdepth, cramino"
c 'samblaster --max'
c 'samblaster -i data/'
c 'mosdepth -'
c 'mosdepth -b data/'
c 'mosdepth out data/'
c 'mosdepth -c '
c 'cramino --format '
c 'cramino --hi'
c 'cramino --reference data/'
echo "=== vcftools"
c 'vcftools --gz'
c 'vcftools --gzvcf data/'
c 'vcftools --bed data/'
c 'vcftools --gzvcf data/calls.vcf.gz --chr '
c 'vcftools --gzvcf data/calls.vcf.gz --indv '
c 'vcftools --TsTv'
