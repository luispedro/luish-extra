"""Generates ../../complete/science/parallel.rhai for GNU parallel, from `parallel --shellcompletion bash` (the
list of its options) at a pinned version, with the descriptions and values written here.

    python3 scripts/gen/mk_parallel.py
"""
import re
import gen

PKG = "parallel=20260922"
K = lambda n: f'"@extra-complete/science/kinds:{n}"'
# option -> (description, value name or "", kind of the value)
INFO = {
    "-j": ("run N jobs in parallel", "N", '"none"'), "--jobs": ("run N jobs in parallel", "N", '"none"'),
    "-P": ("run N jobs in parallel", "N", '"none"'), "--max-procs": ("run N jobs in parallel", "N", '"none"'),
    "-k": ("keep the same order as the input", "", None), "--keep-order": ("keep the same order as the input", "", None),
    "-X": ("multiple arguments with context replace", "", None), "-m": ("multiple arguments without context replace", "", None),
    "--colsep": ("split input on a regexp for positional replacements", "REGEXP", '"none"'),
    "-C": ("split input on a regexp for positional replacements", "REGEXP", '"none"'),
    "--col-sep": ("split input on a regexp for positional replacements", "REGEXP", '"none"'),
    "-S": ("use these ssh logins", "SSHLOGIN", '"none"'), "--sshlogin": ("use these ssh logins", "SSHLOGIN", '"none"'),
    "--slf": ("use FILE as the list of sshlogins", "FILE", '"files"'),
    "--sshloginfile": ("use FILE as the list of sshlogins", "FILE", '"files"'),
    "--trc": ("shorthand for --transfer --return FILE --cleanup", "FILE", '"none"'),
    "--onall": ("run the given command with each argument on all sshlogins", "", None),
    "--nonall": ("run the given command with no arguments on all sshlogins", "", None),
    "--pipe": ("split stdin to multiple jobs", "", None), "--spreadstdin": ("split stdin to multiple jobs", "", None),
    "--recend": ("record end separator for --pipe", "STR", '"none"'),
    "--recstart": ("record start separator for --pipe", "STR", '"none"'),
    "--block": ("size of the block for --pipe", "SIZE", '"none"'), "--block-size": ("size of the block for --pipe", "SIZE", '"none"'),
    "--joblog": ("log the jobs to FILE", "FILE", '"files"'), "--jl": ("log the jobs to FILE", "FILE", '"files"'),
    "--results": ("save the output of each job in a directory or file", "NAME", '"files"'),
    "--resume": ("resume from the last unfinished job of --joblog", "", None),
    "--resume-failed": ("resume, and rerun the failed jobs of --joblog", "", None),
    "--retry-failed": ("rerun the failed jobs of --joblog", "", None),
    "--dry-run": ("print the jobs instead of running them", "", None),
    "--progress": ("show progress of the computations", "", None), "--eta": ("show the estimated time of arrival", "", None),
    "--bar": ("show progress as a progress bar", "", None),
    "-a": ("read the arguments from FILE", "FILE", '"files"'), "--arg-file": ("read the arguments from FILE", "FILE", '"files"'),
    "-N": ("use N arguments per job", "N", '"none"'), "--max-replace-args": ("use N arguments per job", "N", '"none"'),
    "-n": ("use at most N arguments per command line", "N", '"none"'), "--max-args": ("use at most N arguments per command line", "N", '"none"'),
    "-L": ("use at most N input lines per command line", "N", '"none"'), "--max-lines": ("use at most N input lines per command line", "N", '"none"'),
    "-l": ("use at most N input lines per command line", "N", '"none"'),
    "--tag": ("tag lines with the arguments", "", None), "--delay": ("delay starting jobs by SECONDS", "SECONDS", '"none"'),
    "--halt": ("when to stop, and how", "WHEN", '["never", "soon,fail=1", "now,fail=1", "soon,done=1", "now,done=1"]'),
    "--halt-on-error": ("when to stop, and how", "WHEN", '["never", "soon,fail=1", "now,fail=1", "soon,done=1", "now,done=1"]'),
    "--line-buffer": ("buffer output on line basis", "", None), "--linebuffer": ("buffer output on line basis", "", None),
    "-g": ("group output: print the output of a job when it is done", "", None), "--group": ("group output: print the output of a job when it is done", "", None),
    "-u": ("print the output at once, without grouping", "", None), "--ungroup": ("print the output at once, without grouping", "", None),
    "-0": ("use NUL as the delimiter", "", None), "--null": ("use NUL as the delimiter", "", None),
    "-d": ("use STR as the delimiter", "STR", '"none"'), "--delimiter": ("use STR as the delimiter", "STR", '"none"'),
    "-q": ("quote the command", "", None), "--quote": ("quote the command", "", None),
    "-I": ("use STR as the replacement string", "STR", '"none"'), "--link": ("link the input sources instead of a cartesian product", "", None),
    "--xapply": ("link the input sources instead of a cartesian product", "", None),
    "--tmpdir": ("directory for temporary files", "DIR", '"dirs"'), "--tempdir": ("directory for temporary files", "DIR", '"dirs"'),
    "--nice": ("run the jobs with this niceness", "N", '"none"'), "--load": ("only start jobs when the load is below this", "N", '"none"'),
    "--memfree": ("only start jobs when this much memory is free", "SIZE", '"none"'),
    "--timeout": ("time out a job after this long", "SECONDS", '"none"'), "--retries": ("retry a failed job N times", "N", '"none"'),
    "--workdir": ("run the jobs in this directory", "DIR", '"dirs"'), "--wd": ("run the jobs in this directory", "DIR", '"dirs"'),
    "--transfer": ("transfer the files of the arguments to the remote host", "", None),
    "--return": ("transfer this file back from the remote host", "FILE", '"none"'),
    "--cleanup": ("remove the transferred files", "", None), "--shuf": ("shuffle the jobs", "", None),
    "--plus": ("add more replacement strings", "", None), "--header": ("use the first line as the column names", "REGEXP", '"none"'),
    "--will-cite": ("silence the citation notice", "", None), "--citation": ("print the citation notice", "", None),
    "--version": ("print the version", "", None), "-V": ("print the version", "", None),
    "--help": ("print help", "", None), "-h": ("print help", "", None),
    "--sql": ("use a database as the job queue", "DBURL", '"none"'), "--shell-quote": ("quote the given string", "", None),
    "--bg": ("run the command in the background", "", None), "--fg": ("run the command in the foreground", "", None),
    "--wait": ("wait for all the jobs started with --semaphore", "", None), "--semaphore": ("work as a counting semaphore", "", None),
    "--sem": ("work as a counting semaphore", "", None),
    "--files": ("save the output of each job to a file, and print its name", "", None),
    "--fifo": ("give each job a fifo as its input", "", None), "--cat": ("give each job a temporary file as its input", "", None),
    "--tee": ("send the same input to all jobs", "", None), "--group-by": ("group input by the value of a column", "COL", '"none"'),
    "--color": ("colour the output by job", "", None), "--tmux": ("run the jobs in tmux", "", None),
    "--compress": ("compress the temporary files", "", None), "--env": ("copy this environment variable to the jobs", "NAME", '"none"'),
    "--session": ("record the environment and use it in the jobs", "", None), "--plain": ("ignore the profile files", "", None),
    "-r": ("do not run with empty input", "", None), "--no-run-if-empty": ("do not run with empty input", "", None),
    "-t": ("print the command before running it", "", None), "--verbose": ("print the command before running it", "", None),
    "-p": ("ask before running each job", "", None), "--interactive": ("ask before running each job", "", None),
    "--silent": ("silence the output of the jobs", "", None), "--total-jobs": ("the number of jobs, for the progress", "N", '"none"'),
    "-x": ("exit if the command line is too long", "", None), "--show-limits": ("print the limits of the command line", "", None),
    "-E": ("stop reading at this string", "STR", '"none"'), "--eof": ("stop reading at this string", "STR", '"none"'),
    "-i": ("replace {} with the argument (with this string)", "STR", '"none"'), "--replace": ("replace this string with the argument", "STR", '"none"'),
    "--rpl": ("define a replacement string", "\"TAG PERL\"", '"none"'), "--parens": ("use these characters around the perl expression", "STR", '"none"'),
    "--arg-sep": ("the separator of arguments on the command line", "STR", '"none"'),
    "--skip-first-line": ("do not use the first line of input", "", None),
    "--trim": ("trim white space in the input", "MODE", '["n", "l", "r", "lr", "rl"]'),
    "--bibtex": ("print the citation as bibtex", "", None), "--shebang": ("run as an interpreter in the #! line", "", None),
    "--use-compress-program": ("the program to compress temporary files", "PROG", '"files"'),
}
# names that are the same as another with the dashes removed (`--keeporder`), or with `_`
text = gen.helptext(PKG, "parallel --shellcompletion bash")
m = re.search(r'compgen -W "([^"]*)"', text)
names = m.group(1).split()
dashed = {n[2:].replace("-", "") for n in names if n.startswith("--") and "-" in n[2:]}
keep = [n for n in dict.fromkeys(names)
        if not (n.startswith("--") and "-" not in n[2:] and n[2:].replace("_", "") in dashed) and "_" not in n]
lines, values = [], []
for n in keep:
    d, meta, kind = INFO.get(n, ("", "", None))
    lines.append(f"{n}{' ' + meta if meta else ''}")
    lines[-1] = (lines[-1], d)
    if meta:
        values.append((n, kind))
opts = "\n".join(f"            {a}{' ' * max(2, 32 - len(a))}{d}".rstrip() for a, d in lines)
vals, line = [], "            "
for n, v in values:
    item = f'"{n}": {v}, '
    if len(line) + len(item) > 116:
        vals.append(line.rstrip())
        line = "            "
    line += item
vals.append(line.rstrip())
open(gen.REPO + "/complete/science/parallel.rhai", "w").write(f"""// GNU parallel 20260922, from `parallel --shellcompletion bash` (the option names, without their aliases that
// are only spelled differently: `--keeporder`), with the descriptions and values of the common ones. The command
// is completed as a command, and after it come the arguments (`:::`, `::::`) and files.

fn spec(cmd) {{
    #{{
        opts: `
{opts}
        `,
        values: #{{
{chr(10).join(vals)}
        }},
        args: ["commands", {K("parallel_args")}],
    }}
}}
""")
print("ok", len(keep), len([1 for a, d in lines if d]))
