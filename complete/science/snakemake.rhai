// snakemake 9.27.0, from its argparse parser (`snakemake --help`). The targets are the rules of the
// Snakefile, and the files of the directory.

fn spec(cmd) {
    #{
        opts: `
            -h, --help                                    show this help message and exit
            -n, --dry-run, --dryrun                       do not execute anything, and display what would be done
            --profile PROFILE                             profile to use for configuring the Snakemake run with settings regarding the compute
            --workflow-profile WORKFLOW_PROFILE           profile to use for configuring this Snakemake run with parameters specific for this
            --cache RULE                                  store output files of given rules in a central cache given by the environment variable
            -s, --snakefile FILE                          the workflow definition in form of a snakefile
            -c, --cores N                                 use at most N CPU cores/jobs in parallel
            -j, --jobs N                                  use at most N CPU cluster/cloud jobs in parallel
            --local-cores N                               in cluster/cloud mode, use at most N cores of the host machine in parallel
            --resources, --res NAME=INT                   define additional resources that shall constrain the scheduling analogously to '--cores'
            --set-threads RULE=THREADS                    overwrite thread usage of rules
            --max-threads MAX_THREADS                     define a global maximum number of threads available to any rule
            --set-resources RULE:RESOURCE=VALUE           overwrite resource usage of rules
            --set-scatter NAME=SCATTERITEMS               overwrite number of scatter items of scattergather processes
            --set-resource-scopes RESOURCE=[global|local]  overwrite resource scopes
            --default-resources, --default-res NAME=INT   define default values of resources for rules that do not define their own values
            --preemptible-rules PREEMPTIBLE_RULES         define which rules shall use a preemptible machine which can be prematurely killed by e.g
            --preemptible-retries PREEMPTIBLE_RETRIES     number of retries that shall be made in order to finish a job from of rule that has been
            --configfile, --configfiles FILE              specify or overwrite the config file of the workflow (see the docs)
            -C, --config KEY=VALUE                        set or overwrite values in the workflow config object
            --replace-workflow-config                     config files provided via command line do not update and extend the config dictionary of
            --envvars VARNAME                             environment variables to pass to cloud jobs
            -d, --directory DIR                           specify working directory (relative paths in the snakefile will use this as their origin)
            -t, --touch                                   touch output files (mark them up to date without really changing them) instead of running
            -k, --keep-going                              go on with independent jobs if a job fails during execution
            --rerun-triggers CODE|INPUT|MTIME|PARAMS|SOFTWARE-ENV  define what triggers the rerunning of a job
            -f, --force                                   force the execution of the selected target or the first rule regardless of already
            -e, --executor LOCAL|DRYRUN|TOUCH             specify a custom executor, available via an executor plugin: snakemake_executor_<name>
            -F, --forceall                                force the execution of the selected (or the first) rule and all rules it is dependent on
            -R, --forcerun TARGET                         force the re-execution or creation of the given rules or files
            --consider-ancient RULE=INPUTITEMS            consider given input items of given rules as ancient, i.e not triggering re-runs if they
            -P, --prioritize TARGET                       tell the scheduler to assign creation of given targets (and all their dependencies)
            --batch RULE=BATCH/BATCHES                    only create the given BATCH of the input files of the given RULE. This can be used to
            -U, --until TARGET                            runs the pipeline until it reaches the specified rules or files
            -O, --omit-from TARGET                        prevent the execution or creation of the given rules or files as well as any rules or
            --rerun-incomplete, --ri                      re-run all jobs the output of which is recognized as incomplete
            --shadow-prefix DIR                           specify a directory in which the 'shadow' directory is created
            --strict-dag-evaluation CYCLIC-GRAPH|FUNCTIONS|PERIODIC-WILDCARDS  strict evaluation of rules' correctness even when not required to produce the output files
            --scheduler[=GREEDY|ILP]                      specifies the scheduling plugin to use
            --conda-base-path CONDA_BASE_PATH             path of conda base installation (home of conda, mamba, activate) (internal use only)
            --no-subworkflows, --nosw                     do not evaluate or execute subworkflows
            --precommand PRECOMMAND                       only used in case of remote execution
            --groups GROUPS                               assign rules to groups (this overwrites any group definitions from the workflow)
            --group-components GROUP_COMPONENTS           set the number of connected components a group is allowed to span
            --report[=FILE]                               create a self-contained HTML report with default statistics, provenance information and
            --report-after-run                            after finishing the workflow, directly create the report
            --report-stylesheet CSSFILE                   custom stylesheet to use for report
            --report-metadata FILE                        custom metadata to use for the landing page of the report
            --reporter PLUGIN                             specify a custom report plugin
            --draft-notebook TARGET                       draft a skeleton notebook for the rule used to generate the given target file
            --edit-notebook TARGET                        interactively edit the notebook associated with the rule used to generate the given
            --notebook-listen IP:PORT                     the IP address and PORT the notebook server used for editing the notebook
            --lint[=TEXT|JSON]                            perform linting on the given workflow
            --generate-unit-tests[=TESTPATH]              automatically generate unit tests for each workflow rule
            --containerize[=DOCKERFILE|APPTAINER]         print a container definition that provides an execution environment for the workflow
            --export-cwl FILE                             compile workflow to CWL and store it in given FILE
            -l, --list-rules, --list                      show available rules in given Snakefile
            --list-target-rules, --lt                     show available target rules in given Snakefile
            --dag[=DOT|MERMAID-JS]                        do not execute anything and print the directed acyclic graph of jobs in the dot language
            --rulegraph[=DOT|MERMAID-JS]                  do not execute anything and print the dependency graph of rules in the dot language or in
            --filegraph                                   do not execute anything and print the dependency graph of rules with their input and
            --d3dag                                       print the DAG in D3.js compatible JSON format
            -S, --summary                                 print a summary of all files created by the workflow
            -D, --detailed-summary                        print a summary of all files created by the workflow
            --archive FILE                                archive the workflow into the given tar archive FILE. The archive will be created such
            --cleanup-metadata, --cm FILE                 cleanup the metadata of given files
            --cleanup-shadow                              cleanup old shadow directories which have not been deleted due to failures or power loss
            --skip-script-cleanup                         don't delete wrapper scripts used for execution
            --unlock                                      remove a lock on the working directory
            --list-changes, --lc INPUT|PARAMS|CODE        list all output files for which the given items (code, input, params) have changed since
            --list-input-changes, --li                    list all output files for which the defined input files have changed in the Snakefile
            --list-params-changes, --lp                   list all output files for which the defined params have changed in the Snakefile
            --list-untracked, --lu                        list all files in the working directory that are not used in the workflow
            --delete-all-output                           remove all files generated by the workflow
            --delete-temp-output                          remove all temporary files generated by the workflow
            --keep-incomplete                             do not remove incomplete output files by failed jobs
            --drop-metadata                               drop metadata file tracking information after job finishes
            -v, --version                                 show program's version number and exit
            -p, --printshellcmds                          print out the shell commands that will be executed
            --debug-dag                                   print candidate and selected jobs (including their wildcards) while inferring DAG. This
            --nocolor                                     do not use a colored output
            -q, --quiet ALL|HOST|PROGRESS|REASON|RULES    do not output certain information
            --print-compilation                           print the python representation of the workflow
            --verbose                                     print debugging output
            --force-use-threads                           force threads rather than processes
            -a, --allow-ambiguity                         don't check for ambiguous rules and simply use the first if several can produce the same
            --nolock                                      do not lock the working directory
            --ignore-incomplete, --ii                     do not check for incomplete output files
            --max-inventory-time SECONDS                  spend at most SECONDS seconds to create a file inventory for the working directory
            --trust-io-cache                              tell Snakemake to assume that all input and output file existence and modification time
            --max-checksum-file-size SIZE                 compute the checksum during DAG computation and job postprocessing only for files that
            -w, --latency-wait, --output-wait SECONDS     wait given seconds if an output file of a job is not present after the job finished
            --wait-for-free-local-storage WAIT_FOR_FREE_LOCAL_STORAGE  wait for given timespan for enough free local storage when downloading remote storage
            --wait-for-files FILE                         wait '--latency-wait' seconds for these files to be present before executing the workflow
            --wait-for-files-file FILE                    same behaviour as '--wait-for-files', but file list is stored in file instead of being
            --runtime-source-cache-path PATH              path to the runtime source cache directory
            --queue-input-wait-time SECONDS               set the interval in seconds to check for new input in rules that use from_queue to obtain
            --omit-flags OMIT_FLAGS                       omit the given input and output file flags (e.g pipe)
            --notemp, --no-temp, --nt                     ignore temp() declarations
            --all-temp                                    mark all output files as temp files
            --unneeded-temp-files FILE                    given files will not be uploaded to storage and immediately deleted after job or group
            --keep-storage-local-copies                   keep local copies of remote input and output files
            --not-retrieve-storage                        do not retrieve remote files
            --target-files-omit-workdir-adjustment        do not adjust the paths of given target files relative to the working directory
            --allowed-rules ALLOWED_RULES                 only consider given rules
            --max-jobs-per-timespan MAX_JOBS_PER_TIMESPAN  maximal number of job submissions/executions per timespan
            --max-status-checks-per-second MAX_STATUS_CHECKS_PER_SECOND  maximal number of job status checks per second; fractions allowed
            --seconds-between-status-checks SECONDS_BETWEEN_STATUS_CHECKS  number of seconds to wait between two rounds of status checks
            -T, --retries, --restart-times RETRIES        number of times to restart failing jobs
            --wrapper-prefix WRAPPER_PREFIX               URL prefix for wrapper directive
            --default-storage-provider DEFAULT_STORAGE_PROVIDER  specify default storage provider to be used for all input and output files that don't yet
            --default-storage-prefix DEFAULT_STORAGE_PREFIX  specify prefix for default storage provider
            --local-storage-prefix LOCAL_STORAGE_PREFIX   specify prefix for storing local copies of storage files and folders
            --remote-job-local-storage-prefix REMOTE_JOB_LOCAL_STORAGE_PREFIX  specify prefix for storing local copies of storage files and folders
            --shared-fs-usage INPUT-OUTPUT|PERSISTENCE|SOFTWARE-DEPLOYMENT|SOFTWARE-DEPLOYMENT-CACHE|SOURCE-CACHE|SOURCES|STORAGE-LOCAL-COPIES|NONE  set assumptions on shared filesystem for non-local workflow execution
            --scheduler-greediness, --greediness SCHEDULER_GREEDINESS  set the greediness of scheduling
            --scheduler-subsample SCHEDULER_SUBSAMPLE     set the number of jobs to be considered for scheduling
            --no-hooks                                    do not invoke onstart, onsuccess or onerror hooks after execution
            --debug                                       allow to debug rules with e.g PDB. This flag allows to set breakpoints in run blocks
            --runtime-profile FILE                        profile Snakemake and write the output to FILE. This requires yappi to be installed
            --local-groupid LOCAL_GROUPID                 internal use only: Name for local groupid
            --attempt ATTEMPT                             internal use only: define the initial value of the attempt parameter
            --show-failed-logs                            automatically display logs of failed jobs
            --logger LOGGER                               specify one or more custom loggers, available via logger plugins
            --job-deploy-sources                          whether the workflow sources shall be deployed before a remote job is started
            --benchmark-extended                          write extended benchmarking metrics
            --persistence-backend DB|FILE                 the backend to use for Snakemake's metadata persistence
            --persistence-backend-db-url PERSISTENCE_BACKEND_DB_URL  the database URL to use for the 'db' persistence backend
            --container-image IMAGE                       docker image to use, e.g, when submitting jobs to kubernetes
            --immediate-submit, --is                      immediately submit all jobs to the cluster instead of waiting for present input files
            --jobscript, --js SCRIPT                      provide a custom job script for submission to the cluster
            --jobname, --jn NAME                          provide a custom name for the jobscript that is submitted to the cluster (see '--cluster')
            --software-deployment-method, --deployment-method, --deployment, --sdm APPTAINER|CONDA|ENV-MODULES  specify software environment deployment method
            --container-cleanup-images                    remove unused containers
            --use-conda                                   if defined in the rule, run job in a conda environment
            --conda-not-block-search-path-envvars         do not block environment variables that modify the search path
            --list-conda-envs                             list all conda environments and their location on disk
            --conda-prefix DIR                            specify a directory in which the 'conda' and 'conda-archive' directories are created
            --conda-cleanup-envs                          cleanup unused conda environments
            --conda-cleanup-pkgs[=TARBALLS|CACHE]         cleanup conda packages after creating environments
            --conda-create-envs-only                      if specified, only creates the job-specific conda environments then exits
            --conda-frontend CONDA|MAMBA                  choose the conda frontend for installing environments
            --use-apptainer, --use-singularity            if defined in the rule, run job within a apptainer/singularity container
            --apptainer-prefix, --singularity-prefix DIR  specify a directory in which apptainer/singularity images will be stored.If not supplied
            --apptainer-args, --singularity-args ARGS     pass additional args to apptainer/singularity
            --use-envmodules                              if defined in the rule, run job within the given environment modules, loaded in the given
            --deploy-sources QUERY                        internal use only: Deploy sources archive from given storage provider query to the
            --target-jobs TARGET_JOBS                     internal use only: Target particular jobs by RULE:WILDCARD1=VALUE,WILDCARD2=VALUE,
            --mode DEFAULT|REMOTE|SUBPROCESS              internal use only: Set execution mode of Snakemake
            --scheduler-solver-path SCHEDULER_SOLVER_PATH  internal use only: Set the PATH to search for scheduler solver binaries
            --max-jobs-per-second MAX_JOBS_PER_SECOND     maximal number of job submissions/executions per second
            --report-html-path VALUE                      path to the report file (either .html or .zip)
            --report-html-stylesheet-path VALUE           path to a custom stylesheet for the report
            --scheduler-greedy-greediness VALUE           set the greediness of scheduling
            --scheduler-greedy-omit-prioritize-by-temp-and-input  if set, jobs with larger temporary or input files are not prioritized
            --scheduler-ilp-solver VALUE                  set MILP solver to use
            --scheduler-ilp-solver-path VALUE             set the PATH to search for scheduler solver binaries
        `,
        values: #{
            "--profile": "dirs", "--workflow-profile": "dirs",
            "--cache": "@extra-complete/science/kinds:snakemake_rules",
            "-s": "@extra-complete/science/kinds:snakefile",
            "--snakefile": "@extra-complete/science/kinds:snakefile", "-c": ["all"], "--cores": ["all"],
            "-j": ["unlimited"], "--jobs": ["unlimited"], "--local-cores": ["all"], "--resources": "none",
            "--res": "none", "--set-threads": "none", "--max-threads": "none", "--set-resources": "none",
            "--set-scatter": "none", "--set-resource-scopes": "none", "--default-resources": "none",
            "--default-res": "none", "--preemptible-rules": "@extra-complete/science/kinds:snakemake_rules",
            "--preemptible-retries": "none", "--configfile": "@extra-complete/science/kinds:config",
            "--configfiles": "@extra-complete/science/kinds:config", "-C": "none", "--config": "none",
            "--envvars": "none", "-d": "dirs", "--directory": "dirs",
            "--rerun-triggers": ["code", "input", "mtime", "params", "software-env"],
            "-e": [
                "local", "dryrun", "touch", "cluster-generic", "cluster-sync", "slurm", "slurm-jobstep",
                "kubernetes", "googlebatch", "aws-batch", "azure-batch", "flux", "drmaa", "lsf", "htcondor", "tes",
            ],
            "--executor": [
                "local", "dryrun", "touch", "cluster-generic", "cluster-sync", "slurm", "slurm-jobstep",
                "kubernetes", "googlebatch", "aws-batch", "azure-batch", "flux", "drmaa", "lsf", "htcondor", "tes",
            ], "-R": "@extra-complete/science/kinds:snakemake_rules",
            "--forcerun": "@extra-complete/science/kinds:snakemake_rules", "--consider-ancient": "none",
            "-P": "@extra-complete/science/kinds:snakemake_rules",
            "--prioritize": "@extra-complete/science/kinds:snakemake_rules", "--batch": "none",
            "-U": "@extra-complete/science/kinds:snakemake_rules",
            "--until": "@extra-complete/science/kinds:snakemake_rules",
            "-O": "@extra-complete/science/kinds:snakemake_rules",
            "--omit-from": "@extra-complete/science/kinds:snakemake_rules", "--shadow-prefix": "dirs",
            "--strict-dag-evaluation": ["cyclic-graph", "functions", "periodic-wildcards"],
            "--scheduler": ["greedy", "ilp"], "--conda-base-path": "dirs", "--precommand": "none",
            "--groups": "none", "--group-components": "none", "--report": "files", "--report-stylesheet": "files",
            "--report-metadata": "files", "--reporter": "none",
            "--draft-notebook": "@extra-complete/science/kinds:snakemake_targets",
            "--edit-notebook": "@extra-complete/science/kinds:snakemake_targets", "--notebook-listen": "none",
            "--lint": ["text", "json"], "--generate-unit-tests": "dirs",
            "--containerize": ["dockerfile", "apptainer"], "--export-cwl": "files", "--dag": ["dot", "mermaid-js"],
            "--rulegraph": ["dot", "mermaid-js"], "--archive": "files", "--cleanup-metadata": "files",
            "--cm": "files", "--list-changes": ["input", "params", "code"], "--lc": ["input", "params", "code"],
            "-q": ["all", "host", "progress", "reason", "rules"],
            "--quiet": ["all", "host", "progress", "reason", "rules"], "--max-inventory-time": "none",
            "--max-checksum-file-size": "none", "-w": "none", "--latency-wait": "none", "--output-wait": "none",
            "--wait-for-free-local-storage": "none", "--wait-for-files": "files", "--wait-for-files-file": "files",
            "--runtime-source-cache-path": "dirs", "--queue-input-wait-time": "none", "--omit-flags": "none",
            "--unneeded-temp-files": "files", "--allowed-rules": "@extra-complete/science/kinds:snakemake_rules",
            "--max-jobs-per-timespan": "none", "--max-status-checks-per-second": "none",
            "--seconds-between-status-checks": "none", "-T": "none", "--retries": "none",
            "--restart-times": "none", "--wrapper-prefix": "dirs", "--default-storage-provider": "none",
            "--default-storage-prefix": "dirs", "--local-storage-prefix": "dirs",
            "--remote-job-local-storage-prefix": "dirs",
            "--shared-fs-usage": [
                "input-output", "persistence", "software-deployment", "software-deployment-cache", "source-cache",
                "sources", "storage-local-copies", "none",
            ], "--scheduler-greediness": "none", "--greediness": "none", "--scheduler-subsample": "none",
            "--runtime-profile": "files", "--local-groupid": "none", "--attempt": "none", "--logger": "none",
            "--persistence-backend": ["db", "file"], "--persistence-backend-db-url": "none",
            "--container-image": "none", "--jobscript": "files", "--js": "files", "--jobname": "none",
            "--jn": "none", "--software-deployment-method": ["apptainer", "conda", "env-modules"],
            "--deployment-method": ["apptainer", "conda", "env-modules"],
            "--deployment": ["apptainer", "conda", "env-modules"], "--sdm": ["apptainer", "conda", "env-modules"],
            "--conda-prefix": "dirs", "--conda-cleanup-pkgs": ["tarballs", "cache"],
            "--conda-frontend": ["conda", "mamba"], "--apptainer-prefix": "dirs", "--singularity-prefix": "dirs",
            "--apptainer-args": "none", "--singularity-args": "none", "--deploy-sources": "none",
            "--target-jobs": "none", "--mode": ["default", "remote", "subprocess"],
            "--scheduler-solver-path": "files", "--max-jobs-per-second": "none", "--report-html-path": "none",
            "--report-html-stylesheet-path": "none", "--scheduler-greedy-greediness": "none",
            "--scheduler-ilp-solver": ["COIN_CMD"], "--scheduler-ilp-solver-path": "files",
        },
        args: ["@extra-complete/science/kinds:snakemake_targets"],
    }
}
