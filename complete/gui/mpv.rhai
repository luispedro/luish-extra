// mpv: its options are read from the installed program's `--list-options` when Tab is pressed (mpv 0.37.0 and
// 0.41.0 print them in the same format), since they depend on how it was built and there are a thousand of them.
//
//    --alang                          String list (default: )
//       --alang-add
//       --alang-append
//    --screenshot-format              Choices: jpg jpeg png webp jxl avif (default: jpg)
//    --fs                             alias for fullscreen
//    --sub-file                       alias for --sub-files-append (CLI/config files only)
//    --sub-files                      String list (default: ) [file]
//
// A flag is also `--no-NAME`, offered for a word that starts with `--no-`. The indented lines are the actions on a
// list (`--alang-add=LANG`), offered only for a word that starts with the list's name and `-`, so that `--` doesn't
// list them all. Deprecated and removed options are left out.

fn k(name) { "@extra-complete/gui/mpv:" + name }

// What the actions on a list are.
fn action_desc(a) {
    switch a {
        "add" | "append" => "append an item",
        "pre" => "prepend an item",
        "set" => "set the whole list",
        "toggle" => "append an item, or remove it if it is there",
        "remove" => "remove an item",
        "del" => "remove the items at these indexes",
        "clr" => "clear the list",
        "help" => "list the items",
        _ => "",
    }
}

// The options whose values `mpv --NAME=help` lists.
fn listed() {
    ["vo", "ao", "vf", "af", "hwdec", "gpu-api", "gpu-context", "demuxer", "audio-demuxer", "sub-demuxer", "profile",
     "show-profile", "audio-device"]
}

// The options of `mpv --list-options`: for each name, `ty` (the type, as mpv prints it, or for an alias, the type of
// its option), `flag` (whether it takes no value) and `kind` (what its value completes to), and `actions`, the
// actions on lists by their own names (`alang-add`), with the list's name.
fn options(text) {
    let opts = #{};
    let order = [];
    let aliases = [];
    let actions = #{};
    let last = "";
    let listed = listed();
    for line in text.split("\n") {
        if line.starts_with("    --") {
            let a = line;
            a.trim();
            a = a.sub_string(2);
            actions[a] = last;
            continue;
        }
        if !line.starts_with(" --") {
            continue;
        }
        let t = line;
        t.trim();
        let gap = t.index_of(" ");
        if gap < 0 {
            continue;
        }
        let name = t.sub_string(2, gap - 2);
        let ty = t.sub_string(gap);
        ty.trim();
        last = name;
        if ty.contains("[deprecated]") || name == "{" || name == "}" || name == "h" {
            continue;
        }
        order.push(name);
        if ty.starts_with("alias for ") {
            let target = ty.sub_string(10).split(" ")[0];
            if target.starts_with("--") {
                target = target.sub_string(2);
            }
            aliases.push([name, target]);
            continue;
        }
        let file = ty.contains("[file]");
        for note in [" [file]", " [not in config files]"] {
            ty.replace(note, "");
        }
        let kind = "none";
        if ty.starts_with("Choices: ") {
            kind = [];
            for w in ty.sub_string(9).split(" ") {
                if w.starts_with("(") {
                    break;
                }
                kind.push(w);
            }
        } else if file {
            kind = if name.contains("dir") || name.ends_with("-paths") { "dirs" } else { "files" };
        } else if name in listed {
            kind = k(name);
        }
        if name == "help" {
            ty = "print the help (--help=FILTER: the options that match FILTER)";
        } else if ty.starts_with("Print") {
            ty = "print it and quit";
        }
        opts[name] = #{ty: ty, flag: ty.starts_with("Flag") || ty.starts_with("print"), kind: kind};
    }
    // An alias of an action (`--sub-file`, for `--sub-files-append`) or of an option.
    for a in aliases {
        let target = a[1];
        let list = actions[target];
        let o = opts[list ?? target];
        if o == () {
            order.remove(order.index_of(a[0]));
            continue;
        }
        o.ty = `alias for --${target}`;
        if list != () {
            o.ty += ": " + action_desc(target.sub_string(list.len() + 1));
        }
        opts[a[0]] = o;
    }
    #{opts: opts, order: order, actions: actions}
}

// A short description from mpv's type: `flag (default: no)`.
fn describe(ty) {
    if ty.len() > 1 && ty[0] >= 'A' && ty[0] <= 'Z' && ty[1] >= 'a' && ty[1] <= 'z' {
        ty[0].to_lower() + ty.sub_string(1)
    } else {
        ty
    }
}

// The line of an option in the table.
fn line(name, x, desc) {
    if x.flag { `--${name}  ${desc}` + "\n" } else { `--${name}=VALUE  ${desc}` + "\n" }
}

// The spec for the word `cur`: the options of the installed mpv, with the flags' negations for `--no-`, and in
// `actions`, the actions on lists (by their names, with the list's).
fn spec(cmd, cur) {
    let r = sh::capture([cmd, "--list-options"]);
    let o = options(if r.status == 0 { r.out } else { "" });
    let table = "";
    let values = #{};
    for name in o.order {
        let x = o.opts[name];
        table += line(name, x, describe(x.ty));
        if x.flag && cur.starts_with("--no-") {
            table += `--no-${name}  ${describe(x.ty)}` + "\n";
        }
        if !x.flag {
            values["--" + name] = x.kind;
        }
    }
    // The actions are always in the table, for the words before `cur` (`--alang-add en`).
    let actions = #{};
    for a in o.actions.keys() {
        let list = o.actions[a];
        let x = o.opts[list];
        if x == () {
            continue;
        }
        let action = a.sub_string(list.len() + 1);
        let x = #{flag: action == "clr" || action == "help", kind: x.kind};
        table += line(a, x, action_desc(action) + ` (--${list})`);
        if !x.flag {
            values["--" + a] = x.kind;
        }
        actions["--" + a] = "--" + list + "-";
    }
    #{opts: table, values: values, actions: actions}
}

fn complete(words, i) {
    import "@std/completion/lib" as lib;
    let cur = words[i];
    let s = spec(words[0], cur);
    let r = lib::complete(s, words, i);
    if type_of(r) != "array" || !cur.starts_with("--") || cur.contains("=") {
        return r;
    }
    // The actions on a list only for a word that starts with its name (`--alang-`).
    let actions = s.actions;
    r.filter(|c| {
        let v = c.value;
        if v.ends_with("=") {
            v = v.sub_string(0, v.len() - 1);
        }
        let list = actions[v];
        list == () || cur.starts_with(list)
    })
}

// The names that `mpv --NAME=help` lists: its indented lines (`  gpu  Shader-based GPU Renderer`, `'auto' (Autoselect
// device)`, `\tname\tdescription`), the first word of each, with what follows as its description. A name listed
// more than once (`--gpu-api`) has none, nor have those of `--hwdec`, whose other names follow them.
fn help_list(prog, name) {
    let r = sh::capture([prog, `--${name}=help`]);
    let out = [];
    let seen = #{};
    for line in r.out.split("\n") {
        if !line.starts_with(" ") && !line.starts_with("\t") {
            continue;
        }
        let t = line;
        t.replace("\t", " ");
        t.trim();
        let v = "";
        let desc = "";
        if t.starts_with("'") {
            let q = t.index_of("'", 1);
            if q < 0 {
                continue;
            }
            v = t.sub_string(1, q - 1);
            desc = t.sub_string(q + 1);
        } else {
            let gap = t.index_of(" ");
            v = if gap < 0 { t } else { t.sub_string(0, gap) };
            desc = if gap < 0 { "" } else { t.sub_string(gap) };
        }
        desc.trim();
        if desc.starts_with("(") && desc.ends_with(")") {
            desc = desc.sub_string(1, desc.len() - 2);
        } else if desc.starts_with("- ") {
            desc = desc.sub_string(2);
        }
        if v == "" || v.ends_with(":") {
            continue;
        }
        if seen[v] != () || name == "hwdec" {
            if seen[v] != () {
                out[seen[v]].desc = "";
                continue;
            }
            desc = "";
        }
        seen[v] = out.len();
        out.push(#{value: v, desc: desc});
    }
    out
}

// The values of a listed option. Those of lists (`--vf=scale,format`) complete after the last comma, and a filter's
// own options (`--vf=scale=w=1280`) to nothing.
fn kind(name, cur, words) {
    if name == "audio-device" {
        return help_list(words[0], name);
    }
    let c = -1;
    let j = 0;
    for ch in cur.chars() {
        if ch == ',' {
            c = j;
        }
        j += 1;
    }
    let item = cur.sub_string(c + 1);
    if item.contains("=") {
        return [];
    }
    #{prefix: cur.sub_string(0, c + 1), candidates: help_list(words[0], name)}
}
