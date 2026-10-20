// Completion for Slurm's commands (sbatch, salloc, srun, squeue, scancel, sinfo, sacct). Their options are the
// generated slurm_opts.rhai's; the values that depend on the cluster (partitions, accounts, QOS, nodes, features,
// the user's jobs, ...) are asked of it when Tab is pressed, with the cluster's own commands (sinfo, squeue,
// sacctmgr, scontrol). srun and salloc run a command, which is completed by its own completer, and sbatch a script,
// whose arguments are files.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

import "@std/completion/lib" as lib;
import "@std/completion/kinds" as std_kinds;
import "../extra-lib/text" as lib_text;
import "slurm_opts" as opts;

fn spec(cmd) {
    let s = opts::spec(cmd);
    switch cmd {
        "srun" | "salloc" => s.args = ["commands"],
        "scancel" => s.args = [own("slurm:jobs")],
        "squeue" | "sinfo" | "sacct" => s.args = ["none"],
        _ => (),
    }
    if cmd == "squeue" {
        // (`squeue -j 4242`: the job IDs of `-j`, whose value is optional, can be the argument.)
        let jobs = [own("slurm:jobs")];
        s.args_if = #{"-j": jobs, "--jobs": jobs};
    }
    s
}

fn complete(words, i) {
    let cmd = words[0];
    let s = spec(cmd);
    if cmd == "srun" || cmd == "salloc" || cmd == "sbatch" {
        // The first word that isn't an option is the command (or the script), and the words after it are its own.
        let at = lib::scan(lib::parse(s.opts), words, i, false, true, []).cmd;
        if at != () {
            return if cmd == "sbatch" { () } else { #{delegate: words.extract(at), index: i - at} };
        }
    }
    lib::complete(s, words, i)
}

// What a command of the cluster prints, or "" if it fails. Slurm's commands wait for the controller (for
// MessageTimeout, 10 s by default), which Ctrl-C can't interrupt during Tab, so they run under `timeout`.
fn query(ttl, argv) {
    let a = if sh::which("timeout") == () { argv } else { ["timeout", "3"] + argv };
    let r = sh::capture_cached(ttl, a);
    if r.status == 0 { r.out } else { "" }
}

// The lines of `query`, split at `|` (the separator of sacctmgr's `-P` and of the formats below).
fn rows(ttl, argv) {
    let out = [];
    for line in query(ttl, argv).split("\n") {
        if line != "" {
            out.push(line.split("|"));
        }
    }
    out
}

// The candidates `items` (strings, or maps with a `value`) after the last comma of `cur`, without those given
// before it.
fn list(cur, items) {
    let c = lib_text::last_of(cur, [',']);
    let prefix = cur.sub_string(0, c + 1);
    let given = prefix.split(",");
    let out = [];
    for x in items {
        let v = if type_of(x) == "map" { x.value } else { x };
        if !given.contains(v) {
            out.push(x);
        }
    }
    #{prefix: prefix, candidates: out}
}

// The fields of the `key=value` words of a line of `scontrol -o show`.
fn fields_of(line) {
    let f = #{};
    for w in line.split(" ") {
        let eq = w.index_of("=");
        if eq > 0 {
            f[w.sub_string(0, eq)] = w.sub_string(eq + 1);
        }
    }
    f
}

// The partitions, with whether they are up, their time limits and their sizes.
fn partitions() {
    let out = [];
    let seen = #{};
    for r in rows(300, ["sinfo", "-h", "-o", "%R|%a|%l|%D"]) {
        if r.len() == 4 && seen[r[0]] == () {
            seen[r[0]] = true;
            out.push(#{value: r[0], desc: `${r[1]}, ${r[2]}, ${r[3]} nodes`});
        }
    }
    out
}

// The accounts of the user's associations.
fn accounts() {
    let argv = ["sacctmgr", "-nP", "show", "assoc", "format=account"];
    let user = sh::getvar("USER") ?? "";
    if user != "" {
        argv.insert(4, "user=" + user);
    }
    let out = [];
    for r in rows(300, argv) {
        if r[0] != "" && !out.contains(r[0]) {
            out.push(r[0]);
        }
    }
    out
}

fn qos() {
    rows(300, ["sacctmgr", "-nP", "show", "qos", "format=name,description"]).map(|r| #{value: r[0], desc: r[1] ?? ""})
}

fn clusters() {
    rows(300, ["sacctmgr", "-nP", "show", "cluster", "format=cluster"]).map(|r| r[0])
}

// The reservations or licenses (`scontrol -o show THING`), by the field that names them.
fn scontrol_names(thing, key, ttl) {
    let out = [];
    for line in query(ttl, ["scontrol", "-o", "show", thing]).split("\n") {
        let f = fields_of(line);
        let n = f[key];
        if n == () {
            continue;
        }
        let desc = if key == "LicenseName" { `${f.Free ?? "?"} of ${f.Total ?? "?"} free` } else { f.State ?? "" };
        out.push(#{value: n, desc: desc});
    }
    out
}

// The nodes, with their states.
fn nodes() {
    let out = [];
    let seen = #{};
    for r in rows(30, ["sinfo", "-h", "-N", "-o", "%N|%T"]) {
        if r.len() == 2 && seen[r[0]] == () {
            seen[r[0]] = true;
            out.push(#{value: r[0], desc: r[1]});
        }
    }
    out
}

// The features of the nodes, for a constraint (`a&b|c`, `[a*2&b]`), after its last operator.
fn features(cur) {
    let out = [];
    for line in query(300, ["sinfo", "-h", "-o", "%f"]).split("\n") {
        for f in line.split(",") {
            if f != "" && f != "(null)" && !out.contains(f) {
                out.push(f);
            }
        }
    }
    let k = lib_text::last_of(cur, [',', '&', '|', '[', '(']);
    #{prefix: cur.sub_string(0, k + 1), candidates: out}
}

// The generic resources of the nodes (`gpu:a100:4(S:0-1)`), as `gpu` and `gpu:a100`.
fn gres() {
    let out = [];
    for line in query(300, ["sinfo", "-h", "-o", "%G"]).split("\n") {
        for g in line.split(",") {
            let p = g.index_of("(");
            if p >= 0 {
                g = g.sub_string(0, p);
            }
            let parts = g.split(":");
            if g == "" || parts[0] == "" {
                continue;
            }
            for n in [parts[0], if parts.len() > 2 { parts[0] + ":" + parts[1] } else { "" }] {
                if n != "" && !out.contains(n) {
                    out.push(n);
                }
            }
        }
    }
    out
}

// The user's jobs in the queue, with their names and states. They change as they run, so they are kept 5 s only.
fn jobs() {
    rows(5, ["squeue", "--me", "-h", "-o", "%i|%j|%T"]).filter(|r| r.len() == 3)
        .map(|r| #{value: r[0], desc: `${r[1]} (${r[2]})`})
}

// The user's jobs of today, from the accounting database (sacct's default window), for `sacct -j`.
fn past_jobs() {
    rows(30, ["sacct", "-X", "-n", "-P", "-o", "JobID,JobName,State"]).filter(|r| r.len() == 3)
        .map(|r| #{value: r[0], desc: `${r[1]} (${r[2]})`})
}

// A dependency (`afterok:123:124,singleton`): its types, and after a type the user's jobs.
fn dependency(cur) {
    let sep = lib_text::last_of(cur, [',', '?']);
    let item = cur.sub_string(sep + 1);
    let colon = lib_text::last_of(item, [':']);
    if colon >= 0 {
        return #{prefix: cur.sub_string(0, sep + colon + 2), candidates: jobs()};
    }
    let out = [];
    for t in ["after", "afterany", "afterburstbuffer", "aftercorr", "afternotok", "afterok"] {
        out.push(#{value: t + ":", suffix: ""});
    }
    out.push("singleton");
    #{prefix: cur.sub_string(0, sep + 1), candidates: out}
}

fn kind(name, cur, words) {
    if name.starts_with("list:") {
        return list(cur, opts::list(name.sub_string(5)));
    }
    switch name {
        "partitions" => list(cur, partitions()),
        "accounts" => list(cur, accounts()),
        "qos" => list(cur, qos()),
        "clusters" => list(cur, clusters()),
        "reservations" => list(cur, scontrol_names("reservation", "ReservationName", 300)),
        "licenses" => list(cur, scontrol_names("licenses", "LicenseName", 30)),
        "nodes" => list(cur, nodes()),
        "features" => features(cur),
        "gres" => list(cur, gres()),
        "jobs" => list(cur, jobs()),
        "past_jobs" => list(cur, past_jobs()),
        "users" => list(cur, std_kinds::users()),
        "dependency" => dependency(cur),
        _ => throw `unknown kind: ${name}`,
    }
}
