# Programs that complete themselves, asked through std's bridges: apptainer and singularity (Cobra), nf-core
# (Click). The programs are stand-ins made here: they answer as the real ones do (apptainer 1.5.4, nf-core).
__luish_internal plugin load "$EXTRA/completion/science"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir bin
for prog in apptainer singularity; do
    cat >bin/$prog <<'STUB'
#!/bin/sh
[ "$1" = __complete ] || { echo "Usage: apptainer [global options...]"; exit 0; }
shift
case "$*" in
"") printf 'build\tBuild an Apptainer image\nexec\tRun a command within a container\nrun\tRun the user-defined default command within a container\nshell\tRun a shell within a container\n:4\n' ;;
"run --") printf -- '--app\tset an application to run inside a container\n--bind\ta user-bind path specification\n:4\n' ;;
"run --app ") printf ':0\n' ;;
"instance ") printf 'list\tList all running and named Apptainer instances\nstart\tStart a named instance of the given container image\n:4\n' ;;
*) printf ':0\n' ;;
esac
STUB
    chmod +x bin/$prog
done
cat >bin/nf-core <<'STUB'
#!/bin/sh
[ "$_NF_CORE_COMPLETE" = fish_complete ] || { echo "Usage: nf-core [OPTIONS]"; exit 0; }
W=$(printf "%s" "$COMP_WORDS" | sed "s/'\([A-Za-z0-9_=.\/-]*\)'/\1/g")
case "$W|$COMP_CWORD" in
"nf-core |") printf "plain,interface\tLaunch the nf-core interface\nplain,modules\tCommands to manage Nextflow DSL2 modules.\nplain,pipelines\tCommands to manage nf-core pipelines.\n" ;;
"nf-core pipelines |") printf "plain,create\tCreate a new pipeline.\nplain,lint\tCheck pipeline code against nf-core guidelines.\nplain,list\tList available nf-core pipelines.\n" ;;
"nf-core pipelines lint --|--") printf "plain,--dir\tPipeline directory.\nplain,--release\tExecute additional checks for release-ready workflows.\nplain,--help\tShow this message and exit.\n" ;;
esac
STUB
chmod +x bin/nf-core
cat >bin/aws_completer <<'STUB'
#!/bin/sh
# Stand-in for aws_completer (AWS CLI 2.36.47): the candidates for COMP_LINE, whole.
case "$COMP_LINE|$COMP_POINT" in
"aws |4") printf 's3\nec2\nsts\nlambda\n' ;;
"aws s3 |7") printf 'ls\nwebsite\ncp\nmv\nrm\n' ;;
"aws s3 cp --re|14") printf -- '--request-payer\n--recursive\n--region\n' ;;
"aws s3 cp --region |19") printf 'us-east-1\neu-west-1\n' ;;
esac
STUB
chmod +x bin/aws_completer
PATH=$PWD/bin:$PATH
mkdir results
touch reads.fq
echo "=== apptainer"
c 'apptainer '
c 'apptainer run --'
c 'apptainer run --app '
c 'singularity instance '
c 'singularity '
echo "=== nf-core"
c 'nf-core '
c 'nf-core pipelines '
c 'nf-core pipelines lint --'
echo "=== aws"
c 'aws '
c 'aws s3 '
c 'aws s3 cp --re'
c 'aws s3 cp --region '
c 'aws s3 cp re'
echo "=== not installed: filenames"
c 'nosuchcmd r'
