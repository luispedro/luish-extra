// Python packaging tools whose options fit in a table: twine (twine 7.0.0).

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

// twine COMMAND [OPTIONS] DIST...
fn twine() {
    let upload = `
        -r, --repository REPOSITORY        the repository (package index) to upload to, a section of ~/.pypirc
        --repository-url REPOSITORY_URL    the URL of the repository (package index) to upload to
        --attestations                     upload each file's associated attestations
        -s, --sign                         sign files to upload using GPG
        --sign-with SIGN_WITH              GPG program used to sign uploads
        -i, --identity IDENTITY            GPG identity used to sign files
        -u, --username USERNAME            the username to authenticate to the repository as
        -p, --password PASSWORD            the password to authenticate to the repository with
        --non-interactive                  do not prompt for a missing username or password
        -c, --comment COMMENT              the comment to include with the distribution file
        --config-file CONFIG_FILE          the .pypirc config file to use
        --skip-existing                    continue uploading files if one already exists
        --cert path                        path to alternate CA bundle
        --client-cert path                 path to SSL client certificate (key and certificate, in PEM format)
        --verbose                          show verbose output
        --disable-progress-bar             disable the progress bar
        -h, --help                         show help
    `;
    #{
        opts: `
            -h, --help  show help
            --version   show the version
            --no-color  disable colored output
        `,
        commands: `
            upload    upload distribution files to a package index
            check     check that the long description of distribution files will render on PyPI
            register  pre-register a project (not needed with PyPI)
        `,
        values: #{
            "-r": k("pypirc"), "--repository": k("pypirc"),
            "--repository-url": ["https://upload.pypi.org/legacy/", "https://test.pypi.org/legacy/"],
            "--sign-with": ["gpg", "gpg2"], "-i": "none", "--identity": "none", "-u": "none", "--username": "none",
            "-p": "none", "--password": "none", "-c": "none", "--comment": "none", "--config-file": "files",
            "--cert": "files", "--client-cert": "files",
        },
        subs: #{
            "upload": #{opts: upload, args: [k("python_dists")]},
            "register": #{opts: upload, args: [k("python_dists")]},
            "check": #{
                opts: `
                    --strict    fail on warnings
                    -h, --help  show help
                `,
                args: [k("python_dists")],
            },
        },
    }
}

fn spec(cmd) {
    switch cmd {
        "twine" => twine(),
        _ => #{},
    }
}
