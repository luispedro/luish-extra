// cwltool 3.3.20260925135507, from its argparse parser (`cwltool --help`). The arguments are the CWL document and,
// after it, the file of inputs.

fn spec(cmd) {
    #{
        opts: `
            -h, --help                                    show this help message and exit
            --basedir BASEDIR
            --outdir OUTDIR                               output directory
            -w, --write-summary WRITE_SUMMARY             path to write the final output JSON object to
            --parallel                                    run jobs in parallel
            --parallel-max PARALLEL_MAX                   maximum number of jobs to run in parallel
            --skip-schemas                                skip loading of schemas
            --enable-dev                                  enable loading and running unofficial development versions of the CWL standards
            --enable-ext                                  enable loading and running 'cwltool:' extensions to the CWL standards
            --on-error STOP|CONTINUE                      desired workflow behavior when a step fails
            --relax-path-checks                           relax requirements on path names to permit spaces and hash characters
            --overrides OVERRIDES                         read process requirement overrides from file
            --mpi-config-file MPI_CONFIG_FILE             platform specific configuration for MPI (parallel launcher, its flag etc). See README
            --print-rdf                                   print corresponding RDF graph for workflow and exit
            --print-dot                                   print workflow visualization in graphviz format and exit
            --print-pre                                   print CWL document after preprocessing
            --print-deps                                  print CWL document dependencies
            --print-input-deps                            print input object document dependencies
            --pack                                        combine components into single document and print
            --version                                     print version and exit
            --validate                                    validate CWL document only
            --print-supported-versions                    print supported CWL specs
            --print-subgraph                              print workflow subgraph that will execute
            --print-targets                               print targets (output parameters)
            --make-template                               generate a template input object
            --relative-deps PRIMARY|CWD                   when using --print-deps, print paths relative to primary file or current working directory
            --rdf-serializer RDF_SERIALIZER               output RDF serialization format used by --print-rdf (one of turtle (default), n3, nt, xml)
            --tool-help                                   print command line help for tool
            --verbose                                     default logging
            --no-warnings                                 only print errors
            --quiet                                       only print warnings and errors
            --debug                                       print even more logging
            --log-dir LOG_DIR                             log your tools stdout/stderr to this location outside of container This will only log
            --timestamps                                  add timestamps to the errors, warnings, and notifications
            --preserve-environment ENVVAR                 preserve specific environment variable when running CommandLineTools
            --preserve-entire-environment                 preserve all environment variables when running CommandLineTools without a software
            --tmpdir-prefix TMPDIR_PREFIX                 path prefix for temporary directories
            --tmp-outdir-prefix TMP_OUTDIR_PREFIX         path prefix for intermediate output directories
            --cachedir CACHEDIR                           directory to cache intermediate workflow outputs to avoid recomputing steps
            --rm-tmpdir                                   delete intermediate temporary directories
            --leave-tmpdir                                do not delete intermediate temporary directories
            --move-outputs                                move output files to the workflow output directory and delete intermediate output
            --leave-outputs                               leave output files in intermediate output directories
            --copy-outputs                                copy output files to the workflow output directory and don't delete intermediate output
            --provenance PROVENANCE                       save provenance to specified folder as a Research Object that captures and aggregates
            --enable-user-provenance                      record user account info as part of --provenance
            --disable-user-provenance                     do not record user account info in --provenance
            --enable-host-provenance                      record host info as part of --provenance
            --disable-host-provenance                     do not record host info in --provenance
            --orcid ORCID                                 record user ORCID identifier as part of --provenance, e.g
            --full-name CWL_FULL_NAME                     record full name of user as part of --provenance, e.g 'Josiah Carberry'. You may need to
            --strict                                      strict validation (unrecognized or out of place fields are errors)
            --non-strict                                  lenient validation (ignore unrecognized fields)
            --no-doc-cache                                disable disk cache for documents loaded over HTTP
            --doc-cache                                   enable disk cache for documents loaded over HTTP
            --user-space-docker-cmd CMD                   specify the path to udocker
            --udocker                                     use the udocker runtime for running containers
            --singularity                                 use Singularity or Apptainer runtime for running containers
            --podman                                      use Podman runtime for running containers
            --no-container                                do not execute jobs in a Docker container, even when 'DockerRequirement' is specified
            --enable-pull                                 try to pull Docker images
            --disable-pull                                do not try to pull Docker images
            --singularity-sandbox-path IMAGE_BASE_PATH    singularity/Apptainer sandbox image base path
            --force-docker-pull                           pull latest software container image even if it is locally present
            --no-read-only                                do not set root directory in the container as read-only
            --default-container DEFAULT_CONTAINER         specify a default software container to use for any CommandLineTool without a
            --no-match-user                               disable passing the current uid to 'docker run --user'
            --custom-net CUSTOM_NET                       passed to 'docker run' as the '--net' parameter when NetworkAccess is true, which is its
            --strict-memory-limit                         when running with software containers and the Docker engine, pass either the calculated
            --strict-cpu-limit                            when running with software containers and the Docker engine, pass either the calculated
            --rm-container                                delete Docker container used by jobs after they exit
            --leave-container                             do not delete Docker container used by jobs after they exit
            --cidfile-dir CIDFILE_DIR                     store the software container ID into a file in the specified directory
            --cidfile-prefix CIDFILE_PREFIX               specify a prefix to the software container ID filename
            --beta-dependency-resolvers-configuration BETA_DEPENDENCY_RESOLVERS_CONFIGURATION  dependency resolver configuration file describing how to adapt 'SoftwareRequirement'
            --beta-dependencies-directory BETA_DEPENDENCIES_DIRECTORY  default root directory used by dependency resolvers configuration
            --beta-use-biocontainers                      use biocontainers for tools without an explicitly annotated Docker container
            --beta-conda-dependencies                     short cut to use Conda to resolve 'SoftwareRequirement' packages
            --enable-color                                enable logging color
            --disable-color                               disable colored logging
            --enable-ga4gh-tool-registry                  enable tool resolution using GA4GH TRS API
            --disable-ga4gh-tool-registry                 disable tool resolution using GA4GH TRS API
            --add-ga4gh-tool-registry GA4GH_TOOL_REGISTRIES  add a GA4GH TRS endpoint to use for resolution, default ['https://dockstore.org/api']
            --compute-checksum                            compute checksum of contents while collecting outputs
            --no-compute-checksum                         do not compute checksum of contents while collecting outputs
            --eval-timeout EVAL_TIMEOUT                   time to wait for a Javascript expression to evaluate before giving an error, default 60s
            --js-console                                  enable javascript console output
            --disable-js-validation                       disable javascript validation
            --js-hint-options-file JS_HINT_OPTIONS_FILE   file of options to pass to jshint
            -t, --target TARGET                           only execute steps that contribute to listed targets (can be provided more than once)
            --single-step SINGLE_STEP                     only executes a single step in a workflow
            --single-process SINGLE_PROCESS               only executes the underlying Process (CommandLineTool, ExpressionTool, or sub-Workflow)
        `,
        values: #{
            "--basedir": "dirs", "--outdir": "dirs", "-w": "files", "--write-summary": "files",
            "--parallel-max": "none", "--on-error": ["stop", "continue"], "--overrides": "files",
            "--mpi-config-file": "files", "--relative-deps": ["primary", "cwd"], "--rdf-serializer": "none",
            "--log-dir": "dirs", "--preserve-environment": "none", "--tmpdir-prefix": "dirs",
            "--tmp-outdir-prefix": "dirs", "--cachedir": "dirs", "--provenance": "dirs", "--orcid": "files",
            "--full-name": "none", "--user-space-docker-cmd": "none", "--singularity-sandbox-path": "none",
            "--default-container": "none", "--custom-net": "none", "--cidfile-dir": "dirs",
            "--cidfile-prefix": "none", "--beta-dependency-resolvers-configuration": "files",
            "--beta-dependencies-directory": "dirs", "--add-ga4gh-tool-registry": "none", "--eval-timeout": "none",
            "--js-hint-options-file": "files", "-t": "none", "--target": "none", "--single-step": "none",
            "--single-process": "none",
        },
        args: ["@extra-complete/science/kinds:cwl", "@extra-complete/science/kinds:params_file"],
    }
}
