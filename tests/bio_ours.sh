# The group's tools: ngless, SemiBin2 (and SemiBin), macrel and argnorm.
__luish_internal plugin load "$EXTRA/complete/bio"
echo "load $?"
__luish_internal plugin list-loaded
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p data/sub
touch data/pipeline.ngl data/notes.txt data/contigs.fna data/contigs.fna.gz data/reads.fq.gz data/a.bam data/a.bam.bai data/x.py
echo "=== ngless"
c 'ngless --colo'
c 'ngless --color '
c 'ngless --color=f'
c 'ngless --search-path data/'
c 'ngless data/'
c 'ngless data/pipeline.ngl da'
c 'ngless -j'
echo "=== SemiBin2"
c 'SemiBin2 '
c 'SemiBin2 sin'
c 'SemiBin2 single_easy_bin --env'
c 'SemiBin2 single_easy_bin --environment '
c 'SemiBin2 single_easy_bin -i data/'
c 'SemiBin2 single_easy_bin --input-bam data/'
c 'SemiBin2 single_easy_bin --sequencing-type '
c 'SemiBin2 multi_easy_bin --sep'
c 'SemiBin2 bin --dat'
c 'SemiBin2 bin_short --model '
c 'SemiBin2 train_self --data-s'
c 'SemiBin2 concatenate_fasta -i data/'
c 'SemiBin2 citation --'
c 'SemiBin2 check_install --'
c 'SemiBin2 install_skills --u'
c 'SemiBin2 nosuch --'
c 'SemiBin single_easy_bin --orf-finder '
echo "=== macrel"
c 'macrel --que'
c 'macrel --query-mode='
c 'macrel contigs --fasta data/'
c 'macrel reads -1 data/'
echo "=== argnorm"
c 'argnorm --'
c 'argnorm deeparg -i data/'
c 'argnorm groot --db groot-c'
c 'SemiBin2 install-skills --skills-dir data/'
