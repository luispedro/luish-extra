"""Helpers of the generators: the help text of a tool at a pinned version.

    helptext("bowtie2=2.5.5", "bowtie2 --help")

runs the command in a temporary pixi environment (Bioconda, conda-forge) and
caches its output in $HELP_CACHE (default: a directory in the system temporary
directory), so that a generator can be rerun without the network. Delete the
cache to read the help again.
"""
import os, subprocess, sys, hashlib, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
CACHE = os.environ.get("HELP_CACHE", os.path.join(__import__("tempfile").gettempdir(), "luish-extra-help-cache"))
os.makedirs(CACHE, exist_ok=True)

def helptext(pkg, cmd, chan="-c conda-forge -c bioconda"):
    key = hashlib.md5((pkg + "|" + cmd).encode()).hexdigest()
    f = os.path.join(CACHE, key)
    if os.path.exists(f):
        return open(f).read()
    r = subprocess.run(f"pixi exec {chan} -s '{pkg}' -- sh -c '{cmd} 2>&1' </dev/null", shell=True,
                       capture_output=True, text=True, timeout=300)
    open(f, "w").write(r.stdout)
    return r.stdout

def spec_body(pkg, cmd, values=None, args=None, extra="", indent=12, opts_extra="", drop=(), single_dash=False, text=None, edit=None):
    t = text if text is not None else helptext(pkg, cmd)
    opts = h.parse(t)
    opts = [o for o in opts if o[0].split(",")[0].strip() not in drop and not any(x in drop for x in o[0].replace(",", " ").split())]
    if edit:
        opts = edit(opts)
    tail = ""
    if args:
        tail += " " * (indent - 4) + f"args: {args},\n"
    if single_dash:
        tail += " " * (indent - 4) + "single_dash: true,\n"
    tail += extra
    return h.emit(opts, indent, values, tail.rstrip("\n"))
