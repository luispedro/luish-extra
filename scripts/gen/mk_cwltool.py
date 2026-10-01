"""Generates ../../complete/science/cwltool.rhai for cwltool, from its argparse parser at a pinned version.

    python3 scripts/gen/mk_cwltool.py
"""
import re
import gen

PKG = "cwltool=3.3.20260925135507"
K = lambda n: f'"@extra-complete/science/kinds:{n}"'
FILES = {"--write-summary", "--overrides", "--mpi-config-file", "--beta-dependency-resolvers-configuration",
         "--js-hint-options-file", "--orcid"}


def kind_of(names, mv, choices):
    if choices:
        return "[" + ", ".join(f'"{c}"' for c in choices) + "]"
    if any(n in FILES for n in names):
        return '"files"'
    n = names[-1]
    if n in ("--orcid", "--full-name", "--eval-timeout", "--parallel-max", "--target", "--single-step", "--single-process",
             "--default-container", "--custom-net", "--add-ga4gh-tool-registry", "--rdf-serializer", "--cidfile-prefix",
             "--singularity-sandbox-path"):
        return '"none"'
    if re.search(r"dir|prefix|provenance", n):
        return '"dirs"'
    return '"none"'


actions = gen.argparse_dump(PKG, "cwltool.argparser", "arg_parser")
body = gen.emit_argparse(actions, kind_of, 12, f"        args: [{K('cwl')}, {K('params_file')}],")
open(gen.REPO + "/complete/science/cwltool.rhai", "w").write(f"""// cwltool 3.3.20260925135507, from its argparse parser (`cwltool --help`). The arguments are the CWL document and,
// after it, the file of inputs.

fn spec(cmd) {{
    #{{
{body}
    }}
}}
""")
print("ok")
