# Binning of metagenomes and the quality of the genomes: checkm, checkm2, gunc,
# gtdbtk, metabat2, concoct, MaxBin, DAS Tool, dRep, coverm, vamb, and the
# programs that come with them.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/bins data/out
touch data/assembly.fna data/sample.bam data/reads_1.fq.gz data/depth.txt data/uniref.dmnd data/notes.md
touch data/contigs.bed data/genes.gff
echo "=== checkm"
c 'checkm '
c 'checkm data '
c 'checkm lineage_wf data/'
c 'checkm lineage_wf data/bins data/out --'
c 'checkm qa -o '
c 'checkm taxonomy_wf '
c 'checkm coverage data/bins data/out data/'
echo "=== checkm2"
c 'checkm2 '
c 'checkm2 predict --database_path data/'
c 'checkm2 predict --output'
echo "=== gunc"
c 'gunc '
c 'gunc download_db -db '
c 'gunc rescore --'
echo "=== gtdbtk"
c 'gtdbtk classify_wf --genome_dir '
c 'gtdbtk infer --prot_model '
c 'gtdbtk export_msa --domain '
echo "=== metabat2"
c 'metabat2 -i data/'
c 'metabat2 --min'
c 'jgi_summarize_bam_contig_depths --outputDepth data/depth.txt data/'
c 'jgi_summarize_bam_contig_depths --ref'
echo "=== concoct"
c 'concoct --composition_file data/'
c 'cut_up_fasta.py data/'
c 'concoct_coverage_table.py data/'
c 'concoct_coverage_table.py data/contigs.bed data/'
c 'extract_fasta_bins.py data/assembly.fna data/'
echo "=== MaxBin, DAS Tool"
c 'run_MaxBin.pl -contig data/'
c 'run_MaxBin.pl -markerset '
c 'run_MaxBin.pl -re'
c 'DAS_Tool --search'
c 'DAS_Tool --search_engine='
c 'DAS_Tool -c data/'
c 'Fasta_to_Contig2Bin.sh -'
echo "=== dRep"
c 'dRep '
c 'dRep dereplicate --S_algorithm '
c 'dRep compare -g data/'
echo "=== coverm"
c 'coverm '
c 'coverm genome -m '
c 'coverm contig --mapper '
c 'coverm contig --coupled data/'
c 'coverm filter -o data/'
c 'coverm genome --dereplication-quality-formula '
c 'coverm shell-completion --shell '
echo "=== vamb"
c 'vamb '
c 'vamb bin '
c 'vamb bin default --fasta data/'
c 'vamb recluster --algorithm '
c 'vamb recluster --hmm'
