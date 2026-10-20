"""Generates ../../completion/hpc/slurm_opts.rhai, the option tables of Slurm's commands (sbatch, salloc, srun, squeue,
scancel, sinfo, sacct) at a pinned version, from its source.

    python3 scripts/gen/mk_slurm.py

Slurm's `--help` leaves out many options (`sbatch --test-only`, `--open-mode`, `--kill-on-invalid-dep`, ...) and isn't
regular (`-B  --extra-node-info`, `scancel -M` shown without its value), and conda-forge's Slurm is old (22.05), so
the options are read from the source at TAG, fetched from GitHub and cached as gen.helptext's output is: the table of
`src/common/slurm_opt.c` for sbatch, salloc and srun (`.set_func_sbatch`, ... say which commands take an option), and
the `long_options` and the getopt string of the others. An option is kept if its man page documents one of its names,
which leaves out the deprecated aliases (`--cpu_bind`, `--pack-group`). The descriptions are those of `--help` where it
has one, or the first sentence of the man page's; the job and node states and the fields of `-O`/`--format` come from
the man pages and the source too. The values that depend on the cluster (partitions, accounts, jobs, ...) are kinds
of slurm.rhai, which reads them when Tab is pressed.
"""
import hashlib, os, re, sys, urllib.request
import gen
import help2opts as h

VERSION = "26.05.5"
TAG = "slurm-26-05-5-1"
COMMANDS = ["sbatch", "salloc", "srun", "squeue", "scancel", "sinfo", "sacct"]
K = lambda n: f'k("{n}")'
L = lambda n: f'k("list:{n}")'
NONE = '"none"'
FILES = '"files"'
DIRS = '"dirs"'


def lst(*xs):
    return "[" + ", ".join(f'"{x}"' for x in xs) + "]"


# What the value of each option completes to, by its long name (or, for one that has none, its short name); a
# `(command, name)` key is for one command only. The generator stops at an option that takes a value and isn't here.
KINDS = {
    "account": K("accounts"), "accounts": K("accounts"), "acctg-freq": NONE, "array": NONE, "batch": K("features"),
    "bb": NONE, "bbf": FILES, "begin": lst("now", "today", "tomorrow", "midnight", "noon", "teatime"),
    "bcast": FILES, "bcast-exclude": DIRS, "chdir": DIRS, "cluster-constraint": NONE, "clusters": K("clusters"),
    "comment": NONE, "compress": lst("lz4", "zlib", "none"), "container": DIRS, "container-id": NONE,
    "container-type": NONE, "context": NONE, "constraint": K("features"), "core-spec": NONE,
    "cores-per-socket": NONE, "cpu-bind": L("cpu_bind"),
    "cpu-freq": lst("low", "medium", "high", "highm1", "Conservative", "OnDemand", "Performance", "PowerSave",
                    "SchedUtil", "UserSpace"),
    "cpus-per-gpu": NONE, "cpus-per-task": NONE, "deadline": NONE, "delay-boot": NONE, "dependency": K("dependency"),
    "distribution": lst("block", "cyclic", "plane=", "arbitrary"), "epilog": FILES, "error": FILES,
    "exclude": K("nodes"), "exclusive": lst("user", "mcs", "topo"), "export": L("export"), "export-file": FILES,
    "external-launcher": NONE, "extra": NONE, "extra-node-info": NONE, "gid": '"groups"', "gpu-bind": NONE,
    "gpu-freq": NONE, "gpus": NONE, "gpus-per-node": NONE, "gpus-per-socket": NONE, "gpus-per-task": NONE,
    "gres": K("gres"),
    "gres-flags": lst("allow-task-sharing", "disable-binding", "enforce-binding", "multiple-tasks-per-sharing",
                      "one-task-per-sharing"),
    "het-group": NONE, "hint": lst("compute_bound", "memory_bound", "multithread", "nomultithread", "help"),
    "ignore-signals": NONE, "immediate": NONE, "input": FILES, "jobid": K("jobs"), "job-name": NONE,
    "kill-command": '"signals"', "kill-on-bad-exit": lst("0", "1"), "kill-on-invalid-dep": lst("yes", "no"),
    "licenses": K("licenses"), "mail-type": L("mail_types"), "mail-user": '"users"', "threads": NONE,
    "mcs-label": NONE, "mem": NONE, "mem-bind": L("mem_bind"), "mem-per-cpu": NONE, "mem-per-gpu": NONE,
    "mem-update": NONE, "mincpus": NONE, "mpi": lst("list", "none", "pmi2", "pmix", "cray_shasta"),
    "msg-timeout": NONE, "network": NONE, "nice": NONE, "no-kill": lst("off"), "nodefile": FILES,
    "nodelist": K("nodes"), "nodes": NONE, "ntasks": NONE, "ntasks-per-core": NONE, "ntasks-per-gpu": NONE,
    "ntasks-per-node": NONE, "ntasks-per-socket": NONE, "ntasks-per-tres": NONE, "oom-kill-step": lst("0", "1"),
    "open-mode": lst("append", "truncate"), "output": FILES, "overlap": lst("force"), "partition": K("partitions"),
    "prefer": K("features"), "priority": lst("TOP"), "profile": L("profile"), "prolog": FILES,
    "propagate": L("rlimits"), "pty": NONE, "qos": K("qos"), "relative": NONE, "requeue": lst("expedite"),
    "resources": NONE, "reservation": K("reservations"), "resv-ports": NONE, "segment": NONE,
    "send-libs": lst("yes", "no"), "signal": NONE,
    "slurmd-debug": lst("quiet", "fatal", "error", "info", "verbose", "debug", "debug2", "debug3", "debug4",
                        "debug5"),
    "sockets-per-node": NONE, "switches": NONE, "task-epilog": FILES, "task-prolog": FILES, "thread-spec": NONE,
    "threads-per-core": NONE, "time": NONE, "time-min": NONE, "tmp": NONE, "treewidth": NONE, "tres-bind": NONE,
    "tres-per-task": NONE, "uid": '"users"', "wait": NONE, "wait-all-nodes": lst("0", "1"), "wckey": NONE,
    "wrap": NONE, "x11": lst("all", "batch", "first", "last"),
    # squeue, sinfo, scancel, sacct
    "Format": NONE, "format": NONE, "iterate": NONE, "jobs": K("jobs"), "name": NONE, "partitions": K("partitions"),
    "running-over": NONE, "running-under": NONE, "sort": NONE, "steps": NONE, "states": L("job_states"),
    "user": K("users"), "json": NONE, "yaml": NONE, "admin-comment": NONE, "sibling": K("clusters"),
    "state": L("job_states"), "constraints": K("features"), "delimiter": NONE, "endtime": lst("now", "today"),
    "file": FILES, "flags": L("sacct_flags"), "nnodes": NONE, "ncpus": NONE, "timelimit-min": NONE,
    "timelimit-max": NONE, "units": lst("K", "M", "G", "T", "P"), "fields": L("sacct_fields"), "reason": NONE,
    "starttime": lst("now", "today", "midnight"), "wckeys": NONE, "whole-hetjob": lst("yes", "no"),
    "associations": NONE, "jobname": NONE,
    ("squeue", "Format"): L("squeue_fields"), ("sinfo", "Format"): L("sinfo_fields"),
    ("sinfo", "nodes"): K("nodes"), ("sinfo", "states"): L("node_states"), ("scancel", "signal"): '"signals"',
    ("sacct", "jobs"): K("past_jobs"), ("sacct", "format"): L("sacct_fields"), ("sacct", "group"): '"groups"',
    ("sacct", "gid"): '"groups"', ("sacct", "uid"): K("users"), ("sacct", "name"): NONE,
}
# The value names that the man pages' are too long or odd for, by long name (or command and long name).
ARGNAME = {"acctg-freq": "LIST", "cluster-constraint": "LIST", "cpu-bind": "TYPE", "cpu-freq": "FREQ",
           "deadline": "TIME", "dependency": "TYPE:JOBID", "distribution": "TYPE", "exclude": "NODES",
           "exclusive": "MODE", "extra-node-info": "S[:C[:T]]", "gpu-bind": "TYPE", "gpu-freq": "SPEC",
           "mem-bind": "TYPE", "nodelist": "NODES", "nodes": "MIN[-MAX]", "signal": "[R|B:]SIG[@TIME]",
           "switches": "COUNT[@TIME]", "jobs": "JOBS", "ntasks-per-tres": "N", "x11": "TARGET", "json": "PARSER",
           "yaml": "PARSER", "bcast": "DEST", "export": "VARS", "threads": "N", "input": "FILENAME_PATTERN",
           "format": "FORMAT", "Format": "FIELDS", "group": "GROUPS", "partition": "PARTITION", "qos": "QOS",
           "starttime": "TIME", "endtime": "TIME", "timelimit-min": "TIME", "timelimit-max": "TIME",
           "user": "USERS", "wait-all-nodes": "0|1", "open-mode": "append|truncate", "priority": "VALUE",
           "units": "K|M|G|T|P", "clusters": "CLUSTERS", "licenses": "LICENSES", "mpi": "TYPE",
           ("sinfo", "nodes"): "NODES", ("sacct", "format"): "FIELDS", ("srun", "input"): "MODE"}
# Descriptions that the help and the man page have none of, or a misleading or long one, by long name (or command and
# long name).
DESC = {
    "batch": "features that the node of the batch script must have", "prefer": "features to prefer",
    "extra": "arbitrary string", "kill-on-invalid-dep": "end the job if its dependency can never be satisfied",
    "ntasks-per-gpu": "number of tasks to invoke for each GPU", "profile": "the profiling data to gather",
    "segment": "size of the segments of a block or ring topology",
    "consolidate-segments": "consolidate the segments of the allocation into one higher-level block",
    "container-type": "container type", "resources": "hierarchical resources to allocate",
    "deadline": "remove the job if it can't end before this time",
    "mem-update": "reduce the job's memory limit after it has run for a time",
    "stepmgr": "enable the management of steps by slurmstepd", "wait-all-nodes": "wait for all nodes to be ready",
    "external-launcher": "create a step that uses no resources, for an external launcher",
    "multi-prog": "the program is a file that configures a program for each task",
    "wait-for-children": "wait for the children of a task to end before the task ends",
    "test-only": "estimate when the job would start, without submitting it",
    "distribution": "how to distribute the tasks over the nodes", "exclusive": "allocate nodes exclusively",
    "mem-bind": "bind memory to locality domains", "open-mode": "append to the output and error files or truncate them",
    "extra-node-info": "sockets per node, cores per socket and threads per core",
    ("sbatch", "parsable"): "print only the job ID and cluster name", 
    ("srun", "export"): "environment variables to pass to the tasks", ("srun", "nodefile"): "file of the nodes to use",
    ("squeue", "jobs"): "comma separated list of job IDs to view",
    ("squeue", "licenses"): "comma separated list of licenses to view", ("sbatch", "wait"): "wait for the job to end",
    ("srun", "x11"): "forward X11 to the nodes", ("salloc", "x11"): "forward X11 to the nodes",
    # sacct's help is in sentences
    ("sacct", "accounts"): "jobs of these accounts", ("sacct", "allocations"): "show the allocations, not their steps",
    ("sacct", "associations"): "jobs of these association IDs", ("sacct", "clusters"): "jobs of these clusters",
    ("sacct", "constraints"): "jobs that requested these features",
    ("sacct", "delimiter"): "field separator of -p and -P",
    ("sacct", "duplicates"): "show every record of a job ID, not only the most recent",
    ("sacct", "file"): "read accounting data from this file", ("sacct", "flags"): "jobs handled in these ways",
    ("sacct", "gid"): "jobs of these groups", ("sacct", "jobs"): "comma separated list of jobs (or job steps)",
    ("sacct", "json"): "print JSON", ("sacct", "yaml"): "print YAML", ("sacct", "long"): "show many fields",
    ("sacct", "nodelist"): "jobs that ran on these nodes", ("sacct", "noheader"): "no header",
    ("sacct", "partition"): "jobs in these partitions", ("sacct", "qos"): "jobs with these QOS",
    ("sacct", "reason"): "jobs held for these reasons", ("sacct", "state"): "jobs in these states",
    ("sacct", "timelimit-max"): "maximum time limit, with --timelimit-min",
    ("sacct", "timelimit-min"): "jobs with this time limit (or more, with --timelimit-max)",
    ("sacct", "uid"): "jobs of these users", ("sacct", "use-local-uid"): "show the UID of the local system",
    ("sacct", "verbose"): "verbose mode", ("sacct", "wckeys"): "jobs with these wckeys",
    ("sacct", "whole-hetjob"): "show every component of a heterogeneous job", ("sacct", "units"): "unit of the values",
}


def source(path):
    """A file of Slurm's source at TAG, cached as gen.helptext's output is."""
    url = f"https://raw.githubusercontent.com/SchedMD/slurm/{TAG}/{path}"
    f = os.path.join(gen.CACHE, hashlib.md5(url.encode()).hexdigest())
    if not os.path.exists(f):
        open(f, "w").write(urllib.request.urlopen(url, timeout=60).read().decode())
    return open(f).read()


HAS_ARG = {"no_argument": 0, "required_argument": 1, "optional_argument": 2}


def char_of(val):
    m = re.fullmatch(r"'(.)'", val.strip())
    return m.group(1) if m else None


def common_options(cmd):
    """(long name, has_arg, val) of each option of slurm_opt.c that `cmd` (sbatch, salloc or srun) takes."""
    src = source("src/common/slurm_opt.c")
    # (`#ifdef WITH_SLURM_X11` gives `--x11` its name, which a build without X11 leaves to a SPANK plugin.)
    src = re.sub(r"#ifdef WITH_SLURM_X11\n(.*?)#else\n.*?#endif\n", r"\1", src, flags=re.S)
    defs = {}
    for m in re.finditer(r"static slurm_cli_opt_t (slurm_opt_\w+) = \{(.*?)\n\};", src, re.S):
        defs[m.group(1)] = dict(re.findall(r"\.(\w+)\s*=\s*([^,\n]+),", m.group(2)))
    table = re.search(r"common_options\[\] = \{(.*?)\};", src, re.S).group(1)
    out = []
    for var in re.findall(r"&(slurm_opt_\w+)", table):
        d = defs[var]
        name = d.get("name", "NULL")
        if name == "NULL" or not ("set_func" in d or f"set_func_{cmd}" in d):
            continue
        out.append((name.strip('"'), HAS_ARG[d["has_arg"]], d["val"]))
    return out


def getopt_options(cmd, path):
    """(long name, has_arg, val) of each option of a command's `long_options`, and those of its getopt string that
    have no long name (with the long name None)."""
    src = source(path)
    longs = re.findall(r'\{\s*"([\w-]+)",\s*(\w+),\s*0,\s*([^}]+?)\s*\}', src)
    out = [(n, HAS_ARG[a], v) for n, a, v in longs]
    shorts = re.search(r'getopt_long\(\s*argc,\s*argv,\s*"([^"]+)"', src).group(1)
    have = {char_of(v) for _, _, v in out}
    for m in re.finditer(r"(\w)(:{0,2})", shorts):
        if m.group(1) not in have:
            out.append((None, len(m.group(2)), f"'{m.group(1)}'"))
    return out


def untroff(s):
    s = re.sub(r"\\f(?:\(..|\[[^\]]*\]|.)", "", s)
    s = s.replace('\\"', '"').replace("\\-", "-").replace("\\(bu", "*").replace("\\e", "\\").replace("\\&", "").replace("\\ ", " ")
    return re.sub(r"\\\(\w\w", "", s)


def man_entries(text):
    """The options of a man page: for each `.TP` paragraph that starts with an option, its names, its value name (or
    None), whether that value is optional (`[=...]`) and its first sentence."""
    lines = text.split("\n")
    out = []
    for i, line in enumerate(lines):
        if not line.startswith(".TP") or i + 1 >= len(lines):
            continue
        head = untroff(lines[i + 1]).strip()
        if not head.startswith("-"):
            continue
        body = []
        for l in lines[i + 2:]:
            if l.startswith(".") or not l.strip():
                break
            body.append(untroff(l).strip())
        # `-A, --account=<account>`, `--json, --json=list, --json=<data_parser>`, `-k, --no-kill[=off]`
        names, arg, optional = [], None, False
        for part in re.split(r",\s+(?=-)", head):
            m = re.match(r"(--?[\w-]+)(\[?=)?\s*(.*)", part)
            if not m:
                break
            if m.group(1) not in names:
                names.append(m.group(1))
            if m.group(2) or m.group(3):
                optional = optional or m.group(2) == "[="
                a = re.search(r"<([^>]+)>", m.group(3)) or re.match(r"\[?([\w.|-]+)", m.group(3))
                arg = arg or (a.group(1) if a else "VALUE")
        out.append((names, arg, optional, " ".join(body)))
    return out


def help_descs(text):
    """The descriptions of a `--help` (with Slurm's spacing), by option name."""
    out = {}
    lines = text.split("\n")
    for i, line in enumerate(lines):
        m = re.match(r"\s+(?:(-\w),?\s+)?(--[\w-]+)(\[=[^\]]*\]|=\([^)]*\)|\S*)(?:\s+(.*))?$", line)
        if not m:
            continue
        desc = (m.group(4) or "").strip()
        if desc.startswith("| "):        # `--signal=name | integer     signal to send`
            desc = re.split(r"\s{2,}", desc, maxsplit=1)[-1]
        # the rest of the sentence, on the lines below (or the whole description, after a long option)
        for l in lines[i + 1:]:
            if not re.match(r"\s{20,}\S", l) or re.match(r"\s+-", l):
                break
            desc += " " + l.strip()
        for n in (m.group(1), m.group(2)):
            if n and desc:
                out.setdefault(n, desc)
    return out


def sacct_descs(text):
    """The descriptions of sacct's help, whose options are on lines of their own (`-a, --allusers:`), with the
    description after them or on the lines below."""
    out = {}
    lines = text.split("\n")
    for i, line in enumerate(lines):
        m = re.match(r"\s+(?:(-\w), )?(--[\w-]+):\s*(.*)$", line)
        if not m:
            continue
        desc = m.group(3)
        for l in lines[i + 1:]:
            if re.match(r"\s+(?:-\w, )?--[\w-]+:", l) or not l.strip():
                break
            desc += " " + l.strip()
        for n in (m.group(1), m.group(2)):
            if n:
                out.setdefault(n, desc.strip())
    return out


def help_text(cmd):
    if cmd in ("squeue", "sinfo", "sacct"):
        return source(f"src/{cmd}/help.txt")
    path = {"sbatch": "src/sbatch/opt.c", "salloc": "src/salloc/opt.c", "srun": "src/srun/opt.c",
            "scancel": "src/scancel/opt.c"}[cmd]
    src = source(path)
    i = src.index("static void _help(void)\n{")
    body = src[i:src.index("\n}\n", i)]
    return "".join(re.findall(r'"((?:[^"\\]|\\.)*)"', body)).encode().decode("unicode_escape")


GETOPT = {"squeue": "src/squeue/opts.c", "sinfo": "src/sinfo/opts.c", "scancel": "src/scancel/opt.c",
          "sacct": "src/sacct/options.c"}


def options(cmd):
    """The rows of a command's table, in the order of its man page: (names, argname or None, optional, kind, desc)."""
    raw = common_options(cmd) if cmd in ("sbatch", "salloc", "srun") else getopt_options(cmd, GETOPT[cmd])
    man = man_entries(source(f"doc/man/man1/{cmd}.1"))
    helps = (sacct_descs if cmd == "sacct" else help_descs)(help_text(cmd))
    # The options by `val`: a short name and the long names that share it.
    groups = {}
    for name, has_arg, val in raw:
        g = groups.setdefault(val, {"short": None, "longs": [], "has_arg": has_arg})
        if name:
            g["longs"].append(name)
        c = char_of(val)
        if c and c != "?":
            g["short"] = "-" + c
    by_name = {}
    for g in groups.values():
        for n in ([g["short"]] if g["short"] else []) + ["--" + l for l in g["longs"]]:
            by_name[n] = g
    rows, seen = [], set()
    for names, arg, optional, body in man:
        gs = [by_name[n] for n in names if n in by_name]
        if not gs or id(gs[0]) in seen:
            continue
        g = gs[0]
        seen.add(id(g))
        # (getopt takes a prefix of a long name: squeue's man page has `--account` for `--accounts`.)
        documented = [n for n in names if by_name.get(n) is g]
        for n in names:
            if n.startswith("--") and n not in by_name:
                documented += [m for m in ["--" + l for l in g["longs"]] if m.startswith(n) and m not in documented]
        short = [n for n in documented if not n.startswith("--")]
        longs = [n for n in documented if n.startswith("--")]
        key = longs[0][2:] if longs else short[0][1:]
        kind = None
        argname = None
        if g["has_arg"]:
            kind = KINDS.get((cmd, key), KINDS.get(key))
            if kind is None:
                sys.exit(f"{cmd}: no kind for --{key} ({arg})")
            argname = ARGNAME.get((cmd, key)) or ARGNAME.get(key) or re.sub(r"[^A-Za-z0-9_.:|\[\]=-]", "_", (arg or "VALUE")).upper()
        desc = DESC.get((cmd, key)) or DESC.get(key) or next((helps[n] for n in longs + short if n in helps), None) or body
        desc = h.clean(" ".join(desc.replace("e.g.", "e.g").replace("i.e.", "i.e").split()))
        rows.append((short + longs, argname, g["has_arg"] == 2, kind, desc))
    return rows


def rhai_list(items, pad, head):
    """`head` and a Rhai list of strings, at the indentation `pad`, on one line if it fits, or else a row of items per
    line."""
    one = pad + head + "[" + ", ".join(f'"{x}"' for x in items) + "]"
    if len(one) < 116:
        return one
    out, row = [pad + head + "["], pad + "    "
    for it in items:
        if len(row) + len(it) + 4 > 116:
            out.append(row.rstrip())
            row = pad + "    "
        row += f'"{it}", '
    return "\n".join(out + [row.rstrip(), pad + "]"])


def emit(cmd, rows):
    """The `opts` and `values` of a spec."""
    pad = " " * 16
    specs = []
    for names, argname, optional, kind, desc in rows:
        if argname is None:
            specs.append((", ".join(names), desc))
        elif optional:
            # (`-k[off]` takes its value in the same word only: the short name is a flag for the engine.)
            specs.append((", ".join(names[:-1] + [names[-1] + f"[={argname}]"]), desc))
        else:
            specs.append((", ".join(names) + "=" + argname if names[-1].startswith("--")
                          else ", ".join(names) + " " + argname, desc))
    w = min(max(len(s) for s, _ in specs), 40)
    out = ["            opts: `"]
    out += [f"{pad}{s}{' ' * max(2, w + 2 - len(s))}{d}".rstrip() for s, d in specs]
    out.append("            `,")
    vals = [f'"{n}": {kind}' for names, _, _, kind, _ in rows if kind for n in names]
    out.append("            values: #{")
    line = pad
    for v in vals:
        if len(line) + len(v) + 2 > 116:
            if line.strip():
                out.append(line.rstrip())
            line = pad
            if len(pad) + len(v) + 2 > 116:      # a long list, on lines of its own
                n, items = v.split(": ", 1)
                out.append(rhai_list(re.findall(r'"([^"]*)"', items), pad, n + ": ") + ",")
                continue
        line += v + ", "
    if line.strip():
        out.append(line.rstrip())
    out.append("            },")
    return "\n".join(out)


def state_codes(cmd, section):
    """The names of the states in a section of a man page (`\\fBCA  CANCELLED\\fR`, `\\fBALLOCATED\\fR`)."""
    text = source(f"doc/man/man1/{cmd}.1")
    i = text.index(f'.SH "{section}"')
    j = text.find("\n.SH", i + 1)
    out = []
    for m in re.finditer(r"^\.TP[^\n]*\n([^\n]+)", text[i:j], re.M):
        t = untroff(m.group(1)).split()
        if t and re.fullmatch(r"[A-Z][A-Z_+]+", t[-1]) and t[-1] not in out:
            out.append(t[-1])
    return out


def fields(path, pattern):
    return list(dict.fromkeys(re.findall(pattern, source(path))))


def lists():
    """The fixed lists that the `list:NAME` kind completes, several separated by commas."""
    return {
        "job_states": state_codes("squeue", "JOB STATE CODES") + ["all"],
        "node_states": [s.lower() for s in state_codes("sinfo", "NODE STATE CODES")] + ["all"],
        "squeue_fields": fields("src/squeue/opts.c", r'\{"(\w+)", (?:\'.\'|0), _print_job_'),
        "sinfo_fields": fields("src/sinfo/opts.c", r'\{"(\w+)", (?:\'.\'|0), _print_'),
        "sacct_fields": fields("src/sacct/sacct.c", r'\{\s*-?\d+, "(\w+)", print_fields_'),
        "sacct_flags": ["SchedSubmit", "SchedMain", "SchedBackfill", "StartReceived"],
        "mail_types": ["NONE", "BEGIN", "END", "FAIL", "REQUEUE", "ALL", "INVALID_DEPEND", "STAGE_OUT", "TIME_LIMIT",
                       "TIME_LIMIT_90", "TIME_LIMIT_80", "TIME_LIMIT_50", "ARRAY_TASKS"],
        "cpu_bind": ["quiet", "verbose", "none", "rank", "map_cpu:", "mask_cpu:", "rank_ldom", "map_ldom:",
                     "mask_ldom:", "sockets", "cores", "threads", "ldoms", "help"],
        "mem_bind": ["quiet", "verbose", "none", "rank", "map_mem:", "mask_mem:", "local", "sort", "nosort",
                     "prefer", "help"],
        "export": ["ALL", "NONE", "NIL"],
        "profile": ["all", "none", "energy", "task", "lustre", "network"],
        "rlimits": ["ALL", "NONE", "AS", "CORE", "CPU", "DATA", "FSIZE", "MEMLOCK", "NOFILE", "NPROC", "RSS",
                    "STACK"],
    }


def main():
    specs = []
    for cmd in COMMANDS:
        specs.append(f'        "{cmd}" => #{{\n{emit(cmd, options(cmd))}\n        }},')
    ls = []
    for name, items in lists().items():
        ls.append(rhai_list(items, " " * 8, f'"{name}" => ') + ",")
    open(gen.REPO + "/completion/hpc/slurm_opts.rhai", "w").write(f"""\
// Slurm {VERSION}, generated by scripts/gen/mk_slurm.py from its source: the options of sbatch, salloc and srun from
// the table of src/common/slurm_opt.c, those of the other commands from their getopt tables, the descriptions from
// `--help` or the man pages, and the states and fields from the man pages and the source. The kinds are
// slurm.rhai's.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) {{ sh::plugin_dir() + "/" + name }}

fn k(name) {{ own("slurm:") + name }}

// The options of a command.
fn spec(cmd) {{
    switch cmd {{
{chr(10).join(specs)}
        _ => #{{}},
    }}
}}

// The fixed lists of values, for the kind `list:NAME`.
fn list(name) {{
    switch name {{
{chr(10).join(ls)}
        _ => [],
    }}
}}
""")
    print("ok")


main()
