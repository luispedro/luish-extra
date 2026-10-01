"""Generates ../../complete/science/snakemake.rhai for snakemake, from its argparse parser at a pinned version.

    python3 scripts/gen/mk_snakemake.py
"""
import gen

PKG = "snakemake=9.27.0"
K = lambda n: f'"@extra-complete/science/kinds:{n}"'
RULES = K("snakemake_rules")
# Executor plugins are separate packages, and their names are not in the parser of snakemake itself.
EXECUTORS = ["local", "dryrun", "touch", "cluster-generic", "cluster-sync", "slurm", "slurm-jobstep", "kubernetes",
             "googlebatch", "aws-batch", "azure-batch", "flux", "drmaa", "lsf", "htcondor", "tes"]
BY_NAME = {
    "--profile": '"dirs"', "--workflow-profile": '"dirs"', "--snakefile": K("snakefile"),
    "--configfile": K("config"), "--cores": '["all"]', "--jobs": '["unlimited"]', "--local-cores": '["all"]',
    "--executor": "[" + ", ".join(f'"{e}"' for e in EXECUTORS) + "]",
    "--conda-base-path": '"dirs"', "--runtime-source-cache-path": '"dirs"', "--local-storage-prefix": '"dirs"',
    "--jobscript": '"files"', "--scheduler-solver-path": '"files"', "--scheduler-ilp-solver-path": '"files"',
    "--precommand": '"none"', "--draft-notebook": K("snakemake_targets"), "--edit-notebook": K("snakemake_targets"),
    "--allowed-rules": RULES, "--preemptible-rules": RULES, "--target-jobs": '"none"',
    "--reporter": '"none"', "--report": '"files"', "--generate-unit-tests": '"dirs"',
}
NONE = '"none"'


def kind_of(names, mv, choices):
    if names[-1] in BY_NAME or names[0] in BY_NAME:
        return BY_NAME.get(names[0]) or BY_NAME[names[-1]]
    if choices:
        return "[" + ", ".join(f'"{c}"' for c in choices) + "]"
    if mv in ("RULE", "TARGET"):
        return RULES
    if "DIR" in mv or "PREFIX" in mv and mv != "PREFIX":
        return '"dirs"'
    if "FILE" in mv:
        return '"files"'
    return NONE


actions = gen.argparse_dump(PKG, "snakemake.cli", "get_argument_parser")
body = gen.emit_argparse(actions, kind_of, 12, "        args: [" + K("snakemake_targets") + "],")
open(gen.REPO + "/complete/science/snakemake.rhai", "w").write(f"""// snakemake 9.27.0, from its argparse parser (`snakemake --help`). The targets are the rules of the
// Snakefile, and the files of the directory.

fn spec(cmd) {{
    #{{
{body}
    }}
}}
""")
print("ok")
