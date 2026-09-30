# Workflow managers: jug and snakemake (the rules of the Snakefile, and the files it includes).
__luish_internal plugin load "$EXTRA/complete/science"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p workflow/rules results
touch jugfile.py analysis.py notes.txt config.yaml other.json results/a.txt
cat >Snakefile <<'SMK'
include: "workflow/rules/map.smk"
include: 'workflow/rules/missing.smk'
rule all:
    input: "results/a.txt"

checkpoint split:
    output: directory("split")

    rule not_a_rule:
        input: "x"
SMK
cat >workflow/rules/map.smk <<'SMK'
rule map_reads:
    input: "reads.fq"
rule count_reads:
    input: "reads.fq"
SMK
cat >other.smk <<'SMK'
rule other_rule:
    output: "o.txt"
SMK
echo "=== jug"
c 'jug '
c 'jug ex'
c 'jug execute -'
c 'jug execute --'
c 'jug execute '
c 'jug execute j'
c 'jug status --'
c 'jug status --cache-file '
c 'jug status jugfile.py --'
c 'jug cleanup --'
c 'jug execute --verbose '
c 'jug execute --jugdir '
c 'jug invalidate --t'
c 'jug graph --'
echo "=== snakemake"
c 'snakemake -'
c 'snakemake --de'
c 'snakemake --cores '
c 'snakemake --executor '
c 'snakemake --executor s'
c 'snakemake --rerun-triggers '
c 'snakemake --dag'
c 'snakemake -s '
c 'snakemake -s other'
c 'snakemake --configfile '
c 'snakemake --profile '
c 'snakemake -d '
c 'snakemake '
c 'snakemake a'
c 'snakemake -R '
c 'snakemake --until c'
c 'snakemake -s other.smk '
c 'snakemake -sother.smk '
c 'snakemake --snakefile=other.smk '
c 'snakemake -j 4 res'
c 'snakemake --list-changes '
echo "=== cwltool"
touch tool.cwl inputs.yml
c 'cwltool --'
c 'cwltool --on-error '
c 'cwltool --outdir '
c 'cwltool --relative-deps '
c 'cwltool --overrides '
c 'cwltool t'
c 'cwltool tool.cwl i'
