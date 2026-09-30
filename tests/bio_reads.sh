# Read QC, trimming and filtering: fastp, fastqc, falco, cutadapt, trimmomatic, trim_galore, fastq_screen, seqtk,
# filtlong, chopper, nanoq, rasusa, porechop, NanoPlot, NanoFilt, NanoStat; seqkit (Cobra, through std's bridge).
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/r1.fq.gz data/r2.fq.gz data/ont.fastq data/ref.fa data/adapters.fasta data/a.bam data/u.bam data/notes.txt
touch data/regions.bed
echo "=== fastp"
c 'fastp --in'
c 'fastp -i data/'
c 'fastp -i data/r1.fq.gz -o '
c 'fastp --adapter_fasta data/'
c 'fastp --umi_loc '
c 'fastp -?'
echo "=== fastqc, falco"
c 'fastqc -f '
c 'fastqc --cont'
c 'fastqc -o data/'
c 'fastqc data/'
c 'falco --stdin '
c 'falco --no-'
echo "=== cutadapt"
c 'cutadapt -a '
c 'cutadapt -a file:data/'
c 'cutadapt -G ^file:data/'
c 'cutadapt --action '
c 'cutadapt --pair-filter '
c 'cutadapt --discard'
c 'cutadapt -o out.fq data/'
echo "=== trimmomatic"
c 'trimmomatic '
c 'trimmomatic PE -'
c 'trimmomatic PE -phred33 data/'
c 'trimmomatic PE data/r1.fq.gz data/r2.fq.gz p1 u1 p2 u2 '
c 'trimmomatic PE data/r1.fq.gz data/r2.fq.gz p1 u1 p2 u2 SL'
c 'trimmomatic SE data/r1.fq.gz out.fq ILLUMINACLIP:'
c 'trimmomatic SE data/r1.fq.gz out.fq ILLUMINACLIP:Tru'
c 'trimmomatic SE data/r1.fq.gz out.fq ILLUMINACLIP:data/'
c 'trimmomatic SE data/r1.fq.gz out.fq ILLUMINACLIP:data/adapters.fasta:2'
c 'trimmomatic PE -basein data/'
echo "=== trim_galore, fastq_screen"
c 'trim_galore --pa'
c 'trim_galore --output-format '
c 'trim_galore -o data/'
c 'trim_galore --paired data/'
c 'fastq_screen --aligner '
c 'fastq_screen --min'
echo "=== seqtk"
c 'seqtk '
c 'seqtk s'
c 'seqtk seq -'
c 'seqtk seq -M data/'
c 'seqtk comp -r data/'
c 'seqtk subseq data/ref.fa data/'
c 'seqtk mergepe data/r1.fq.gz data/'
c 'seqtk gc data/'
c 'seqtk mergepe -'
echo "=== long reads: filtlong, chopper, nanoq, porechop, NanoPlot, NanoFilt, NanoStat"
c 'filtlong -a data/'
c 'filtlong --t'
c 'filtlong data/'
c 'chopper --trim-approach '
c 'chopper -c data/'
c 'chopper data/'
c 'nanoq -O '
c 'nanoq -i data/'
c 'porechop --format '
c 'porechop -v '
c 'NanoPlot --fastq data/'
c 'NanoPlot --fastq data/ont.fastq data/'
c 'NanoPlot -f '
c 'NanoPlot --bam data/'
c 'NanoFilt --readtype '
c 'NanoStat --fasta data/'
echo "=== rasusa"
c 'rasusa '
c 'rasusa reads -O '
c 'rasusa reads -Z '
c 'rasusa reads data/'
c 'rasusa aln --strategy '
c 'rasusa aln data/'
c 'rasusa help '
echo "=== seqkit (Cobra)"
mkdir bin
# answers as seqkit 2.14.0 does (`seqkit __complete ...`), shortened
cat >bin/seqkit <<'STUB'
#!/bin/sh
[ "$1" = __complete ] || { echo "Usage: seqkit [command]"; exit 0; }
shift
case "$*" in
"") printf 'amplicon\textract amplicon (or specific region around it) via primer(s)\nseq\ttransform sequences (extract ID, filter by length, remove gaps, reverse complement...)\nstats\tsimple statistics of FASTA/Q files\n:4\n' ;;
"seq --rev") printf -- '--reverse\treverse sequence\n:4\n' ;;
*) printf ':0\n' ;;
esac
STUB
chmod +x bin/seqkit
PATH=$PWD/bin:$PATH
c 'seqkit '
c 'seqkit seq --rev'
