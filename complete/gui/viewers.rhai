// Bioinformatics viewers: cytoscape (Cytoscape 3.10.4: `cytoscape.sh`, and the `Cytoscape` launcher of its
// installer), jalview (2.11.5.1), Artemis (18.2.0: art, act, bamview, dnaplotter), tablet (1.17.08.17), pymol
// (open-source 3.1.0), chimerax (1.11.1) and vmd (1.9.3). BandageNG has a generated module of its own.

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }

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

// The colour schemes of jalview's `--colour`.
fn jalview_colours() {
    ["clustal", "blosum62", "pc-identity", "zappo", "taylor", "gecos-flower", "gecos-blossom", "gecos-sunset",
     "gecos-ocean", "hydrophobic", "helix-propensity", "strand-propensity", "turn-propensity", "buried-index",
     "nucleotide", "nucleotide-ambiguity", "purine-pyrimidine", "rna-helices", "t-coffee-scores", "sequence-id"]
}

// jalview [--headless] [[--open|--append] FILES] [ARGUMENTS]: its arguments of 2.11.3 and later (`--help-all`), whose
// values are given after `=` (an argument can also take a modifier, `--open[1]=FILE`). The files are alignments.
fn jalview() {
    #{
        opts: `
            --help                      show the help
            --help-all                  show the help of all arguments
            --help-config               show the help of the configuration arguments
            --help-opening              show the help of the arguments that open and format alignments
            --help-structure            show the help of the arguments for 3D structures
            --help-process              show the help of the arguments that process an alignment
            --help-output               show the help of the arguments that save data
            --help-image                show the help of the arguments that export images
            --help-flow                 show the help of the arguments that control the others
            --jabaws=URL                the URL of a JABAWS server
            --props=FILE                the preferences file, instead of ~/.jalview_properties
            --news, --nonews            show the news feed (or not)
            --splash, --nosplash        show the splash screen (or not)
            --questionnaire, --noquestionnaire  show the questionnaire (or not)
            --javaconsole, --nojavaconsole  show the Java console (or not)
            --webservicediscovery, --nowebservicediscovery  connect to JABAWS web services (or not)
            --debug, --nodebug          debug log level (or not)
            --version                   show the version
            --headless                  run without a GUI, and quit after processing the arguments
            --gui                       run with a GUI, even when writing output files
            --nousagestats              don't send launch usage stats
            --nostartupfile             don't show the default startup file
            --quiet                     no output to standard output (twice: nor to standard error)
            --jvmmempc=PERCENT          the maximum heap size, as a percentage of the physical memory (90)
            --jvmmemmax=MAXMEMORY       the maximum heap size (32g, in bytes, k, m, g or t)
            --open=FILE                 open alignment files or URLs in new windows
            --append=FILE               append alignment files or URLs to the open window
            --title=TITLE               the title of the open alignment window
            --colour=SCHEME             the colour scheme of the open alignment window
            --features=FILE             add a feature file or URL to the open alignment
            --tree=FILE                 add a tree file or URL to the open alignment
            --annotations=FILE          add an annotations file or URL to the open alignment
            --sortbytree, --nosortbytree  sort the alignment by its tree (or not)
            --showannotations, --noshowannotations  show the alignment annotations (or not)
            --wrap, --nowrap            wrap the alignment (or not)
            --nostructure               don't open the 3D structures of --open or --append files
            --close                     close the open alignment window (after the outputs)
            --structure=FILE            load a structure file or URL for a sequence of the alignment
            --structuresfile=FILE       load a list of structure files (SEQID FILENAME lines)
            --seqid=ID                  the sequence of the preceding --structure
            --structureviewer=VIEWER    the viewer of the preceding --structure
            --paematrix=FILE            add a PAE JSON matrix to the preceding --structure
            --tempfac=TYPE              the type of temperature factor
            --viewerid=ID               the id of the structure viewer window to open the structure in
            --allstructuresviewerid=ID  the id of the structure viewer window for all structures
            --showssannotations, --noshowssannotations  show the secondary structure annotations (or not)
            --superpose, --nosuperpose  align the structure to those of the viewer (or not)
            --groovy=FILE               run a Groovy script on the open alignment
            --output=FILE               export the open alignment to a file (- for standard output)
            --format=FORMAT             the format of the preceding --output
            --backups, --nobackups      write backup files when saving (or not)
            --overwrite, --nooverwrite  overwrite output files without backups (or not)
            --mkdirs                    create the directories of output files
            --image=FILE                export an image of the open alignment window
            --structureimage=FILE       export an image of a 3D structure opened in Jmol
            --type=TYPE                 the format of the preceding --image or --structureimage
            --textrenderer=RENDERER     render text in vector images as text or line art
            --scale=SCALE               the scaling of PNG images
            --width=WIDTH               the width of PNG images
            --height=HEIGHT             the height of PNG images
            --imagecolour=SCHEME        the colour scheme of the image
            --bgcolour=COLOUR           the background colour of the structure image (a name or RRGGBB)
            --argfile=FILE              read arguments from files, one per line
            --substitutions, --nosubstitutions  allow substitutions in the values that follow (or not)
            --all, --noall              apply the following output arguments to all alignments (or not)
            --opened, --noopened        apply the following output arguments to the last --open'ed alignments (or not)
            --allstructures, --noallstructures  apply the following structure arguments to all structures (or not)
            --new                       move on to a new alignment window
            --npp                       increase the index counter of substitutions
            --quit                      quit after processing the arguments
        `,
        values: #{
            "--jabaws": "none",
            "--jvmmempc": "none",
            "--jvmmemmax": "none",
            "--title": "none",
            "--colour": jalview_colours(),
            "--imagecolour": jalview_colours(),
            "--seqid": "none",
            "--structureviewer": ["none", "JMOL", "CHIMERA", "CHIMERAX", "PYMOL"],
            "--tempfac": ["default", "plddt"],
            "--viewerid": "none",
            "--allstructuresviewerid": "none",
            "--format": ["fasta", "pfam", "stockholm", "pir", "blc", "amsa", "json", "pileup", "msf", "clustal",
                         "phylip", "jalview"],
            "--type": ["svg", "png", "eps", "html", "biojs"],
            "--textrenderer": ["text", "lineart"],
            "--scale": "none",
            "--width": "none",
            "--height": "none",
            "--bgcolour": "none",
        },
        strict_eq: true,
    }
}

// art [OPTIONS] SEQUENCE_FILE [+FEATURE_FILE]...: its script's options, and Java's system properties (`-DNAME=VALUE`),
// which set Artemis's own options. act takes SEQUENCE_1 COMPARISON_1_2 SEQUENCE_2 ..., with the properties of each
// sequence numbered (`-Dbam1=FILE`).
fn artemis() {
    #{
        opts: `
            -h, -help, --help           show the help
            -options FILE               read options from a file
            -chado                      connect to a Chado database ($PGHOST, $PGPORT, $PGDATABASE, $PGUSER)
            -quiet                      don't print the arguments Java is started with
        `,
        skip: #{"-D": k("artemis_props"), "+": k("listing")},
    }
}

// bamview -a BAM [OPTIONS]: its options with a single dash; the script passes them all to BamView.
fn bamview() {
    #{
        opts: `
            -h                          show the help
            -a FILE                     the BAM or CRAM file to show
            -r FILE                     the reference file
            -n N                        the number of bases to show
            -c NAME                     the chromosome
            -v VIEW                     the view
            -b POSITION                 the base position
            -o                          show the orientation
            -pc                         plot the coverage
            -ps                         plot SNPs (with -r)
        `,
        values: #{
            "-a": k("bam"),
            "-r": k("fasta"),
            "-n": "none",
            "-c": "none",
            "-v": [#{value: "IS", desc: "inferred size"}, #{value: "S", desc: "stack"},
                   #{value: "PS", desc: "paired stack"}, #{value: "ST", desc: "strand"},
                   #{value: "C", desc: "coverage"}],
            "-b": "none",
        },
        args: ["none"],
        single_dash: true,
    }
}

// dnaplotter [-t FILE]
fn dnaplotter() {
    #{
        opts: `
            -h, -help, --help           show the help
            -t FILE                     read a template file
        `,
        args: ["none"],
    }
}

// tablet [ASSEMBLY [REFERENCE]]: an assembly (BAM, SAM, ACE, AFG, MAF, SOAP) and its reference (FASTA, FASTQ, GFF).
fn tablet() {
    #{
        opts: `
            --version                   show the version
        `,
        args: ["files", "files", "none"],
    }
}

// pymol [OPTIONS] [FILES] [-- ARGUMENTS]: the files are structures, maps, Python scripts (.py, .pym), PyMOL scripts
// (.pml) and sessions (.pse). Its one-letter options can be given together (`-qc`), and `-A`, `-b` take their value
// in the same word.
fn pymol() {
    #{
        opts: `
            --help                      show the help
            --version                   show the version
            --gldebug                   use glDebugMessageCallback for GL debugging
            --testing                   run PyMOL's tests
            --diagnostics               dump system diagnostics
            -1                          one-button mouse
            -2                          two-button mouse
            -A N, -a N                  application configuration
            -b                          benchmark wizard (-bN)
            -c                          command-line only mode, for batch processing
            -C                          don't terminate on Ctrl-C
            -d CMD                      run a PyMOL command
            -D N                        defer_builds_mode=N
            -e                          full screen
            -E N                        multisampling (GL_MULTISAMPLE_ARB)
            -f N                        internal_feedback=N
            -F                          internal_feedback=0
            -g FILE                     save an image (png) or a movie (mpg)
            -h                          generic helper application (no controls, no feedback)
            -H N                        window height in pixels
            -i                          internal_gui=0
            -I                          auto_reinitialize=1 (macOS only)
            -j                          side-by-side stereo (stereo_mode=4)
            -J                          cd to the home directory
            -k                          don't load pymolrc or plugins
            -K                          without a GUI, don't quit after the input is exhausted
            -l FILE                     run a Python script in a thread
            -L FILE                     load a file after everything else
            -M                          force mono
            -o                          disable security protections
            -O N                        sphere_mode=N
            -p                          read commands from standard input
            -P                          handle scenes as in presentation mode
            -q                          don't show the startup message
            -Q                          quiet: no text output
            -r FILE                     run a Python script
            -R                          launch the RPC server
            -s FILE                     log to a file
            -S                          force stereo
            -t N                        stereo_mode=N
            -u FILE                     resume a log file (run it and append to it)
            -v                          use the openvr stub instead of real hardware
            -V N                        external GUI window height in pixels
            -W N                        window width in pixels
            -x                          no external GUI
            -X N                        window x position on the screen
            -y                          exit on error
            -Y N                        window y position on the screen
            -z N                        window_visible=N
            -Z N                        zoom_mode=N
        `,
        values: #{
            "-A": [#{value: "1", desc: "simple viewer window"}, #{value: "3", desc: "internal GUI only, no splash"},
                   #{value: "4", desc: "used by PYMOLVIEWER"}, #{value: "5", desc: "helper application"},
                   #{value: "6", desc: "full screen presentation"}],
            "-d": "none", "-D": "none", "-E": "none", "-f": "none", "-H": "none", "-O": "none", "-t": "none",
            "-V": "none", "-W": "none", "-X": "none", "-Y": "none", "-z": "none", "-Z": "none",
            "-l": k("py"), "-r": k("py"),
        },
    }
}

// chimerax [OPTIONS] [FILES]: its options and those of Python that it takes (`-c`, `-m`: only as the first argument).
fn chimerax() {
    #{
        opts: `
            -c COMMAND                  run a Python command, with the rest of the arguments (implies --nogui)
            -d                          turn on debugging
            -h, --help                  show the help
            -m MODULE                   run a Python module as __main__ (implies --nogui)
            -u                          unbuffered standard output and error
            -V                          show the version of Python
            --cmd COMMAND               run a ChimeraX command at startup, after starting the tools
            --color                     colored text in nogui mode
            --nocolor                   no colored text in nogui mode
            --debug                     turn on debugging code
            --devel                     development mode (Python deprecation warnings)
            --exit                      exit after processing the command line
            --noexit                    don't exit after processing the command line
            --lineprofile               turn on line profiling
            --listioformats             list the file suffixes it opens and saves
            --nogui                     run without a GUI
            --nostatus                  don't write to the status line
            --offscreen                 run without a GUI, rendering images with OSMesa
            --safemode                  don't run bundle initialization nor load tools
            --script SCRIPT             run a Python script at startup (quoted with its arguments)
            --silent                    no startup splash text, and less verbose
            --start_tool TOOL           start a tool at startup
            --tools                     run the tools at startup
            --notools                   don't run the tools at startup
            --toolshed URL              the URL of the Toolshed (preview for the next one)
            --uninstall                 deregister icons and MIME types and remove the installation
            --usedefaults               ignore the user's settings
            --version                   show the version (twice: of the tools; three times: of the Python packages)
        `,
        values: #{
            "-c": "none", "-m": "none", "--cmd": "none", "--script": k("py"), "--start_tool": "none",
            "--toolshed": ["preview"],
        },
    }
}

// vmd [OPTIONS] [FILES]: options with a single dash; `-TYPE FILE` loads a file of a type that its name doesn't tell.
fn vmd() {
    #{
        opts: `
            -h, --help                  show the help
            -dispdev DEVICE             the display device
            -dist D                     distance from the origin to the screen
            -e FILE                     run the commands of a file
            -python                     use Python for -e files and the text input
            -eofexit                    exit at the end of the input
            -pos X Y                    the lower left corner of the display
            -nt                         no title display at start
            -size X Y                   the size of the display
            -startup FILE               the startup script
            -m                          load the following files as separate molecules
            -f                          load the following files into the same molecule
            -args                       pass the following arguments to the text interpreter
            -pdb FILE                   load a PDB file
            -psf FILE                   load a PSF file
            -dcd FILE                   load a DCD trajectory
            -xtc FILE                   load a GROMACS XTC trajectory
            -trr FILE                   load a GROMACS TRR trajectory
            -gro FILE                   load a GROMACS GRO file
            -mol2 FILE                  load a MOL2 file
            -xyz FILE                   load an XYZ file
            -pqr FILE                   load a PQR file
            -parm7 FILE                 load an AMBER7 parameter/topology file
            -crd FILE                   load an AMBER coordinate file
            -netcdf FILE                load an AMBER NetCDF trajectory
            -lammpstrj FILE             load a LAMMPS trajectory
            -mdf FILE                   load an Insight II MDF file
            -dx FILE                    load a DX density map
            -cube FILE                  load a Gaussian cube file
            -ccp4 FILE                  load a CCP4 map
        `,
        values: #{
            "-dispdev": ["win", "cave", "text", "none"],
            "-dist": "none", "-pos": "none", "-size": "none",
        },
        single_dash: true,
    }
}

fn spec(cmd) {
    switch cmd {
        "cytoscape" | "Cytoscape" | "cytoscape.sh" => cytoscape(),
        "jalview" => jalview(),
        "art" | "act" => artemis(),
        "bamview" => bamview(),
        "dnaplotter" => dnaplotter(),
        "tablet" => tablet(),
        "pymol" => pymol(),
        "chimerax" | "ChimeraX" => chimerax(),
        "vmd" => vmd(),
        _ => #{},
    }
}
