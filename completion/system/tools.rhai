// Small system tools: fusermount (fuse 3.14.0; fusermount3 takes the same options).

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

// fusermount [OPTIONS] MOUNTPOINT: a directory to mount on, or, with -u, a FUSE file system to unmount.
fn fusermount() {
    #{
        opts: `
            -h       print help
            -V       print version
            -o OPTS  mount options (comma-separated)
            -u       unmount
            -q       quiet
            -z       lazy unmount
        `,
        values: #{
            "-o": ["ro", "rw", "allow_other", "allow_root", "auto_unmount", "default_permissions", "nosuid", "nodev", "noexec"],
        },
        args: ["dirs"],
        args_if: #{"-u": [k("fuse_mounts")]},
    }
}

fn spec(cmd) {
    switch cmd {
        "fusermount" | "fusermount3" => fusermount(),
        _ => #{},
    }
}
