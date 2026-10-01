// Bioinformatics viewers: cytoscape (Cytoscape 3.10.4: `cytoscape.sh`, and the `Cytoscape` launcher of its
// installer).

fn k(name) { "@extra-complete/gui/kinds:" + name }

// cytoscape [OPTIONS]: it opens the files of its options, and takes no others.
fn cytoscape() {
    #{
        opts: `
            -h, --help                  show the help
            -v, --version               show the version
            -s, --session FILE          load a session (.cys) file
            -N, --network FILE          load a network file (any format)
            -P, --props FILE            load a properties file, or a property (NAME=VALUE)
            -V, --vizmap FILE           load a VizMap properties file
            -S, --script FILE           run the commands of a script file
            -R, --rest PORT             start a REST service
        `,
        values: #{
            "--session": k("cys"),
            "--rest": "none",
        },
        args: ["none"],
    }
}

fn spec(cmd) {
    switch cmd {
        "cytoscape" | "Cytoscape" | "cytoscape.sh" => cytoscape(),
        _ => #{},
    }
}
