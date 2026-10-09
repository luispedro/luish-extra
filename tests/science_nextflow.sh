# Nextflow: subcommands and options, profiles of nextflow.config, runs of .nextflow/history,
# downloaded projects, and the parameters of an nf-core pipeline's nextflow_schema.json.
__luish_internal plugin load "$EXTRA/completion/science"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
export NXF_HOME=$PWD/nxf
mkdir -p nxf/assets/nf-core/rnaseq nxf/assets/nf-core/sarek nxf/assets/nextflow-io/hello pipe/conf .nextflow results
touch main.nf other.nf notes.txt custom.config params.yaml params.json
cat >nextflow.config <<'CFG'
params.x = 1
// profiles { commented { } }
profiles {
    debug { process.beforeScript = 'echo' }
    'test_full' {
        params.y = 2
        process { withName: 'X' { cpus = 2 } }
    }
    conda { conda.enabled = true }
}
process.cpus = 1
CFG
cat >pipe/nextflow.config <<'CFG'
profiles {
    docker {
        docker.enabled = true
    }
    singularity {
        singularity.enabled = true
    }
}
CFG
cat >pipe/main.nf <<'NF'
workflow { }
NF
cat >pipe/nextflow_schema.json <<'JSON'
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "$defs": {
    "input_output_options": {
      "type": "object",
      "properties": {
        "input": {"type": "string", "format": "file-path", "description": "Path to the samplesheet. More text."},
        "outdir": {"type": "string", "format": "directory-path", "description": "The output directory"},
        "email": {"type": "string", "description": "Email address"}
      }
    },
    "reference": {
      "type": "object",
      "properties": {
        "aligner": {"type": "string", "enum": ["star", "hisat2"], "description": "The aligner"},
        "skip_qc": {"type": "boolean", "description": "Skip the QC"},
        "genome": {"type": "string", "description": "Genome name"}
      }
    }
  },
  "allOf": [{"$ref": "#/$defs/input_output_options"}]
}
JSON
printf '2026-01-01 10:00:00\t1m\tnasty_lamarr\tOK\t8f7e\t8d26bb61-aaaa\tnextflow run main.nf\n2026-01-02 10:00:00\t2m\tsilly_darwin\tERR\t9a1b\t7c15aa50-bbbb\tnextflow run main.nf -resume\n' >.nextflow/history
echo "=== commands and options"
c 'nextflow '
c 'nextflow ru'
c 'nextflow -'
c 'nextflow -c '
c 'nextflow -c c'
c 'nextflow run -'
c 'nextflow run -with-d'
c 'nextflow run -with-docker=n'
c 'nextflow run -hub '
c 'nextflow run -ansi-log '
c 'nextflow run -output-format '
c 'nextflow run -w '
c 'nextflow run -params-file '
echo "=== pipelines"
c 'nextflow run '
c 'nextflow run m'
c 'nextflow run n'
c 'nextflow run nf-core/'
c 'nextflow run nf-core/s'
echo "=== profiles"
c 'nextflow run main.nf -profile '
c 'nextflow run main.nf -profile d'
c 'nextflow run main.nf -profile debug,'
c 'nextflow run main.nf -profile debug,c'
c 'nextflow run pipe -profile '
c 'nextflow run pipe/main.nf -profile s'
c 'nextflow run main.nf -c pipe/nextflow.config -profile '
c 'nextflow config -profile '
c 'nextflow inspect pipe -profile '
echo "=== parameters of the pipeline"
c 'nextflow run pipe --'
c 'nextflow run pipe --o'
c 'nextflow run pipe --aligner '
c 'nextflow run pipe --outdir '
c 'nextflow run pipe --input '
c 'nextflow run pipe --skip_qc '
c 'nextflow run main.nf --'
echo "=== runs and projects"
c 'nextflow log '
c 'nextflow log n'
c 'nextflow log -before '
c 'nextflow clean -but s'
c 'nextflow clean -'
c 'nextflow pull '
c 'nextflow drop nf-core/r'
c 'nextflow info nextflow-io/'
c 'nextflow view -'
echo "=== other subcommands"
c 'nextflow fs '
c 'nextflow module '
c 'nextflow lineage v'
c 'nextflow secrets '
c 'nextflow lint -o '
c 'nextflow lint '
c 'nextflow list -'
echo "=== nf-test"
mkdir -p tests
touch tests/main.nf.test tests/modules.nf.test
c 'nf-test '
c 'nf-test t'
c 'nf-test test --'
c 'nf-test test --filter '
c 'nf-test test --shard-strategy '
c 'nf-test test --junitxml '
c 'nf-test test tests/'
c 'nf-test test tests/m'
c 'nf-test generate '
c 'nf-test generate process '
c 'nf-test list --'
c 'nf-test init --'
c 'nf-test coverage --'
