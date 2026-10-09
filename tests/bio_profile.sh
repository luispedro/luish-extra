# Taxonomic and functional profiling: kraken2, bracken, krakenuniq, centrifuge,
# kaiju, metaphlan, humann, motus, and the programs that come with them.
__luish_internal plugin load "$EXTRA/completion/bio"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/k2db data/cfdb
touch data/reads_1.fq.gz data/reads_2.fq.gz data/sample.bam data/report.txt data/notes.md
touch data/nodes.dmp data/names.dmp data/kaiju_db_nr.fmi data/genomes.fna data/sample.json.bz2
touch data/cfdb/p_compressed.1.cf data/cfdb/p_compressed.2.cf data/cfdb/p_compressed.3.cf
echo "=== kraken2"
c 'kraken2 --re'
c 'kraken2 --db data/'
c 'kraken2 --paired data/'
c 'kraken2-build --download-library '
c 'kraken2-build --add-to-library data/'
c 'kraken2-inspect --'
c 'k2 '
c 'k2 download --library '
c 'k2 build --special '
c 'k2 classify --merge-policy '
c 'k2 classify data/r'
echo "=== bracken"
c 'bracken -'
c 'bracken -l '
c 'bracken-build -y '
c 'combine_bracken_outputs.py --'
echo "=== krakenuniq"
c 'krakenuniq --report'
c 'krakenuniq-build --download-library '
c 'krakenuniq-build --lca'
c 'krakenuniq-download '
c 'krakenuniq-download -'
c 'krakenuniq-report --'
echo "=== centrifuge"
c 'centrifuge -x data/cfdb/'
c 'centrifuge --out-fmt '
c 'centrifuge --un-c'
c 'centrifuge-build -'
c 'centrifuge-build --taxonomy-tree data/'
c 'centrifuge-build data/genomes.fna data/cfdb/'
c 'centrifuge-inspect data/cfdb/'
c 'centrifuge-kreport -x data/cfdb/'
echo "=== kaiju"
c 'kaiju -t data/'
c 'kaiju -f data/'
c 'kaiju -a '
c 'kaiju-multi -f data/'
c 'kaiju2table -r '
c 'kaiju2table -n data/'
c 'kaiju-mergeOutputs -c '
c 'kaiju-makedb -s '
c 'kaiju-mkbwt -'
c 'kaiju-mkbwt -a '
echo "=== metaphlan"
c 'metaphlan --input_type '
c 'metaphlan --tax_lev '
c 'metaphlan --stat '
c 'metaphlan data/'
c 'merge_metaphlan_tables.py -'
c 'strainphlan --phylophlan_mode '
c 'strainphlan -s data/'
c 'sample2markers.py -i data/'
c 'sample2markers.py -f '
echo "=== humann"
c 'humann --input-format '
c 'humann --pathways '
c 'humann --o'
c 'humann_databases --download '
c 'humann_renorm_table -u '
c 'humann_regroup_table -g '
c 'humann_rename_table -n '
c 'humann_split_table --taxonomy_level '
c 'humann_barplot --sort '
c 'humann_join_tables -i data/'
echo "=== motus"
c 'motus '
c 'motus profile -'
c 'motus profile -f data/'
c 'motus profile -y '
c 'motus calc_mgc -i data/'
c 'motus genomes -d '
c 'motus download -t '
c 'motus downloadMGDB -f '
