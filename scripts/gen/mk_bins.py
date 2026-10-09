"""Generates ../../completion/bio/bins.rhai: binning of metagenomes and the quality, taxonomy and dereplication of the
genomes (MAGs) that come out of it (checkm, checkm2, gunc, gtdbtk, metabat2, concoct, MaxBin, DAS Tool, dRep,
coverm, vamb, and the programs that come with them), from their --help or argparse parser at the pinned versions (see
completion-todo.md).

    python3 scripts/gen/mk_bins.py
"""
import os, re, sys
import gen
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

PIN = {
    "checkm": "checkm-genome=1.2.5", "checkm2": "checkm2=1.1.0", "gunc": "gunc=1.1.1", "gtdbtk": "gtdbtk=2.7.2",
    "metabat2": "metabat2=2.18_23_gc869c52", "concoct": "concoct=1.1.0", "maxbin2": "maxbin2=2.2.7",
    "das_tool": "das_tool=1.1.7", "drep": "drep=3.7.1", "coverm": "coverm=0.8.0", "vamb": "vamb=5.0.4",
}

K = lambda n: f'k("{n}")'
FASTA, READS, BAM, GFF, HMM = K("fasta"), K("reads"), K("bam"), K("gff"), K("hmm")
L = lambda *xs: "[" + ", ".join(f'"{x}"' for x in xs) + "]"
FILES, DIRS, NONE = '"files"', '"dirs"', '"none"'
NO_ARGS = '["none"]'
out = []
def emit(s): out.append(s)

def option_names(n):
    """The names in the first column of a row: `-i, --bins=CONTIG2BIN` (docopt) is -i and --bins."""
    return [x.split("=")[0] for x in n.replace(",", " ").split()]

def check(opts, kinds):
    """Every option with a value has a kind (a list of values, a kind, "files" or "none")."""
    for n, a, _ in opts:
        if (a or "=" in n) and not any(x in kinds for x in option_names(n)):
            sys.exit(f"no kind for {n} {a}")

def body(opts, values, args, extra="", indent=12, single_dash=False):
    check(opts, values)
    names = {x for n, a, _ in opts if a or "=" in n for x in option_names(n)}
    values = {n: k for n, k in values.items() if n in names}
    tail = " " * (indent - 4) + f"args: {args},\n" + (" " * (indent - 4) + "single_dash: true,\n" if single_dash else "")
    return h.emit(opts, indent, values, (tail + extra).rstrip("\n"))

# the commands, with the name of their function
progs = {}
subs = {}

def fname(cmd):
    return re.sub(r"\W", "_", cmd.removesuffix(".py").removesuffix(".sh").removesuffix(".pl")).lower()

def fn(cmd, b):
    progs[cmd] = fname(cmd)
    emit(f"fn {fname(cmd)}() {{\n    #{{\n{b}\n    }}\n}}\n")

def kinds(table):
    """kind_of for gen.emit_argparse: the choices, or the kind in `table` by one of the option's names."""
    def kind_of(names, mv, choices):
        if choices:
            return L(*choices) if len(choices) <= 20 else NONE
        for n in names:
            if n in table:
                return table[n]
        sys.exit(f"no kind for {names} {mv}")
    return kind_of

def tidy(actions, fix):
    """The descriptions of `fix` instead of the parser's, by one of the option's names. A long list of choices is
    named by the option's dest (`--rank RANK`), not written out as its value name."""
    for a in actions:
        if a["choices"] and not a["metavar"] and len("|".join(a["choices"])) > 30:
            a["metavar"] = a["dest"].upper()
        n = [n for n in a["names"] if n in fix]
        if n:
            a["help"] = fix[n[0]]
        elif a["help"]:
            # (`R|`: dRep's mark for a help that keeps its line breaks)
            a["help"] = " ".join(a["help"].removeprefix("R|").replace("``", "'").split())
        if a["metavar"] and isinstance(a["metavar"], str) and a["metavar"].islower():
            a["metavar"] = a["metavar"].upper()
    return actions

def positionals(c, table, cmd):
    """The kinds of a parser's positional arguments: their choices, or by their dest in `table`."""
    ks = []
    for a in c["actions"]:
        if not a["positional"]:
            continue
        if a["choices"]:
            ks.append(L(*a["choices"]) if len(a["choices"]) <= 20 else NONE)
        elif a["dest"] in table:
            ks.append(table[a["dest"]])
        else:
            sys.exit(f"{cmd}: no kind for the argument {a['dest']}")
    return "[" + ", ".join(ks) + "]" if ks else NO_ARGS

def argparse_spec(c, values, pos, fix, indent, cmd, args=None):
    """The spec of a parser (an argparse_dump tree), with the specs of its subcommands in `subs`."""
    acts = tidy([a for a in c["actions"] if not a["positional"]], fix)
    pad = " " * (indent - 4)
    extra = f"{pad}args: {args or positionals(c, pos, cmd)},"
    if c["commands"]:
        extra = commands_table(c["commands"], {}, indent) + "\n" + pad + "subs: #{\n" + "\n".join(
            f'{pad}    "{s["name"]}": #{{\n' + argparse_spec(s, values, pos, fix, indent + 8, f"{cmd} {s['name']}") +
            f"\n{pad}    }}," for s in c["commands"]) + f"\n{pad}}},"
    return gen.emit_argparse(acts, kinds(values), indent, extra)

def commands_table(commands, helps, indent):
    """`commands:`, from the parser's subcommands, with the descriptions of `helps` (by name) or the parser's."""
    pad = " " * indent
    rows = [(", ".join([c["name"]] + c["aliases"]), h.clean(" ".join((helps.get(c["name"]) or c["help"] or "").split())))
            for c in commands]
    w = max(len(n) for n, _ in rows)
    return (pad[:-4] + "commands: `\n" + "".join(f"{pad}{n.ljust(w)}  {d}".rstrip() + "\n" for n, d in rows) +
            pad[:-4] + "`,")

def tidy_rows(opts, fix):
    """tidy() for the rows of an options table: (names, value name, description)."""
    return [(n, a, next((fix[x] for x in option_names(n) if x in fix), d)) for n, a, d in opts]

def visible(tree):
    """The parser without its subcommands whose help is argparse.SUPPRESS (vamb bin avamb)."""
    return dict(tree, commands=[visible(c) for c in tree["commands"] if c["help"] != "==SUPPRESS=="])

def tree_tool(cmd, tree, helps, values, pos, fix={}, args={}, top=None, sub_values={}):
    """A program with subcommands: `fn CMD()` with its options and subcommands, and `fn CMD_sub(sub)` with the spec of
    each, for sub_spec. `top` is the options table of a program whose parser has none of its own."""
    name = fname(cmd)
    tree = visible(tree)
    if top is None:
        acts = tidy([a for a in tree["actions"] if not a["positional"]], fix)
        opts = gen.emit_argparse(acts, kinds(values), 12, commands_table(tree["commands"], helps, 12))
    else:
        opts = "        opts: `\n" + "".join(f"            {r}\n" for r in top) + "        `,\n" + \
            commands_table(tree["commands"], helps, 12)
    progs[cmd] = name
    emit(f"fn {name}() {{\n    #{{\n{opts}\n        sub_spec: own(\"bins:{cmd}\"),\n    }}\n}}\n")
    cases = []
    for c in tree["commands"]:
        v = dict(values, **sub_values.get(c["name"], {}))
        b = argparse_spec(c, v, pos, fix, 16, f"{cmd} {c['name']}", args.get(c["name"]))
        cases.append(f'        {" | ".join(chr(34) + n + chr(34) for n in [c["name"]] + c["aliases"])} => #{{\n{b}\n        }},')
    subs[cmd] = name
    emit(f"fn {name}_sub(sub) {{\n    switch sub {{\n" + "\n".join(cases) + "\n        _ => (),\n    }\n}\n")

def arrow_commands(text):
    """`    tree         -> Place bins in the reference genome tree` (checkm, gtdbtk, dRep): the descriptions."""
    return dict(re.findall(r"^ {4}(\w+)\s*-> (.*?)\s*$", text, re.M))

emit('''// Binning of metagenomes, and the quality, taxonomy and dereplication of the
// genomes that come out of it: checkm, checkm2, gunc, gtdbtk, metabat2 (with
// jgi_summarize_bam_contig_depths), concoct (with its scripts), MaxBin
// (run_MaxBin.pl), DAS Tool, dRep, coverm and vamb. Generated by
// scripts/gen/mk_bins.py from the tools' own `--help` or argparse parser
// (versions in completion-todo.md).

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }
''')

# ---------------- checkm ----------------
# Its parser is built at the top of bin/checkm, which prints its own help (`checkm -h`) without any arguments.
cm = gen.argparse_dump(PIN["checkm"], "bin/checkm", "__main__ qa", tree=True)
CM_HELP = arrow_commands(gen.helptext(PIN["checkm"], "checkm -h"))
CM_HELP = {c: re.sub(r"^\[Experimental\] (.*)", r"\1 (experimental)", d) for c, d in CM_HELP.items()}
CM_HELP.update({"data": "set the CheckM data directory: checkm data setRoot DIR",
                "test": "run CheckM on a test genome"})
CM_POS = {"bin_input": FILES, "output_dir": DIRS, "tree_dir": DIRS, "marker_file": FILES, "taxon": NONE,
          "analyze_dir": DIRS, "results_dir": DIRS, "tetra_profile": FILES, "bam_file": BAM, "bam_files": BAM,
          "seq_file": FASTA, "output_seq_file": FILES, "output_stats_file": FILES, "output_file": FILES,
          "coverage_file": FILES, "bin_file": FASTA}
CM_VALUES = {"-x": NONE, "-t": NONE, "--pplacer_threads": NONE, "--tmpdir": DIRS, "-f": FILES, "-u": NONE,
             "-m": NONE, "--exclude_markers": FILES, "--aai_strain": NONE, "-a": FILES, "-e": NONE, "-l": NONE,
             "-c": FILES, "--dpi": NONE, "--font_size": NONE, "--width": NONE, "--height": NONE, "-w": NONE,
             "-b": NONE, "-1": NONE, "-2": NONE, "-3": NONE, "-s": NONE, "--fig_padding": NONE,
             "--delta_comp": NONE, "--delta_cont": NONE, "--merged_comp": NONE, "--merged_cont": NONE,
             "-r": NONE, "-o": FILES}
CM_SUB = {"dist_plot": {"-a": NONE, "-c": NONE}, "gc_bias_plot": {"-a": NONE},
          "ssu_finder": {"-c": NONE}, "coverage": {"-a": NONE},
          "modify": {"-a": NONE}}
# (the descriptions of `--out_format` list the formats over several lines)
for c in cm["commands"]:
    for a in c["actions"]:
        if a["names"][:1] == ["-o"] and a["dest"] == "out_format":
            a["help"] = "output format: " + ", ".join(re.findall(r"^\s*(\d+)\. ", a["help"], re.M)) + \
                " (see checkm " + c["name"] + " -h)"
tree_tool("checkm", cm, CM_HELP, CM_VALUES, CM_POS, args={"data": '[["setRoot"], "dirs"]'},
          top=["-h, --help  show the commands"], sub_values=CM_SUB)

# ---------------- checkm2 ----------------
# (main() prints its help when it is given no subcommand)
c2 = gen.argparse_dump(PIN["checkm2"], "checkm2.main", "main predict", tree=True)
tree_tool("checkm2", c2, {}, {"--input": FILES, "--output-directory": DIRS, "-x": NONE, "--tmpdir": DIRS,
                              "--threads": NONE, "--ttable": NONE, "--database_path": K("diamond_db"),
                              "--setdblocation": K("diamond_db"), "--path": DIRS},
          {}, fix={"--download": "download the DIAMOND database (by default into ~/databases)",
                   "--input": "folder of MAGs, or list of MAGs, to analyze",
                   "--no_write_json_db": "don't write the database path to the internal JSON file",
                   "--output-directory": "output folder"})


# ---------------- gunc ----------------
# (main() prints its help when it is given no subcommand)
gu = gen.argparse_dump(PIN["gunc"], "gunc.gunc", "main run", tree=True)
GU_DBS = ["progenomes_2.1", "gtdb_95", "gtdb_214"]
tree_tool("gunc", gu, {"summarise": "re-score genomes using a different contamination cutoff"}, {"--db_file": K("diamond_db"), "--custom_genome2taxonomy": FILES, "--input_fasta": FASTA,
                           "--input_file": FILES, "--input_dir": DIRS, "--file_suffix": NONE, "--threads": NONE,
                           "--out_dir": DIRS, "--temp_dir": DIRS, "--min_mapped_genes": NONE,
                           "--database": L(*GU_DBS), "--gunc_file": FILES, "--checkm_file": FILES,
                           "--diamond_file": FILES, "--gunc_gene_count_file": FILES, "--tax_levels": NONE,
                           "--remove_minor_clade_level": NONE, "--contig_display_num": NONE,
                           "--contig_display_list": NONE, "--max_csslevel_file": FILES,
                           "--gunc_detailed_output_dir": DIRS, "--contamination_cutoff": NONE,
                           "--output_file": FILES},
          {"path": DIRS}, fix={"--database": "database to download: " + ", ".join(GU_DBS),
                               "--db_file": "DIAMOND database (default: $GUNC_DB)",
                               "--use_species_level": "allow species level to be picked as maxCSS"})

# ---------------- gtdbtk ----------------
gt = gen.argparse_dump(PIN["gtdbtk"], "gtdbtk.cli", "get_main_parser", tree=True)
GT_VALUES = {"--genome_dir": DIRS, "--batchfile": FILES, "--outgroup_taxon": NONE, "--out_dir": DIRS, "-x": NONE,
             "--taxa_filter": NONE, "--min_perc_aa": NONE, "--cols_per_gene": NONE, "--min_consensus": NONE,
             "--max_consensus": NONE, "--min_perc_taxa": NONE, "--rnd_seed": NONE,
             "--gtdbtk_classification_file": FILES, "--custom_taxonomy_file": FILES, "--prefix": NONE,
             "--cpus": NONE, "--tmpdir": DIRS, "--pplacer_cpus": NONE, "--scratch_dir": DIRS, "--min_af": NONE,
             "--identify_dir": DIRS, "--msa_file": FILES, "--align_dir": DIRS, "--input_tree": FILES,
             "--output_tree": FILES, "--ingroup_taxon": NONE, "--untrimmed_msa": FILES, "--output": FILES,
             "--mask_file": FILES, "--db_version": NONE}
GT_FIX = {"-x": "extension of the files to process (gz: gzipped)",
          "--full_tree": "use the unsplit bacterial tree for the classify step (the original GTDB-Tk approach)",
          "--custom_taxonomy_file": "file of custom taxonomy strings for the user genomes",
          "--outgroup_taxon": "taxon to use as outgroup (e.g. p__Patescibacteriota)",
          "--custom_msa_filters": "custom filtering of the MSA with --cols_per_gene, --min_consensus, ...",
          "--rnd_seed": "random seed to use for selecting columns",
          "--batchfile": "file describing genomes: tab separated, the FASTA file, the genome ID and its translation table"}
tree_tool("gtdbtk", gt, arrow_commands(gen.helptext(PIN["gtdbtk"], "gtdbtk -h")), GT_VALUES, {}, fix=GT_FIX,
          top=["-h, --help     show the commands", "-v, --version  show the version"])

# ---------------- dRep ----------------
dr = gen.argparse_dump(PIN["drep"], "drep.argumentParser", "parse_args", tree=True)
DR_VALUES = {"-p": NONE, "-g": FASTA, "-l": NONE, "-comp": NONE, "-con": NONE, "--genomeInfo": FILES,
             "--set_recursion": NONE, "--checkm_group_size": NONE, "-ms": NONE, "--skani_extra": NONE, "-pa": NONE,
             "-sa": NONE, "-nc": NONE, "--primary_chunksize": NONE, "-comW": NONE, "-conW": NONE, "-strW": NONE,
             "-N50W": NONE, "-sizeW": NONE, "-centW": NONE, "-extraW": FILES, "--warn_dist": NONE,
             "--warn_sim": NONE, "--warn_aln": NONE}
DR_FIX = {"--S_algorithm": "algorithm for the secondary clustering comparisons",
          "--n_PRESET": "presets to pass to nucmer: tight (only highly conserved regions) or normal",
          "-nc": "minimum level of overlap between genomes in the secondary comparisons",
          "--multiround_primary_clustering": "cluster each primary chunk separately and merge them with single linkage",
          "-extraW": "a TSV file of genomes and extra scores to add (two columns, no header)",
          "--clusterAlg": "algorithm used to cluster genomes (scipy.cluster.hierarchy.linkage)",
          "--skip_plots": "don't make plots"}
tree_tool("dRep", dr, arrow_commands(gen.helptext(PIN["drep"], "dRep -h")), DR_VALUES, {"work_directory": DIRS},
          fix=DR_FIX)

# ---------------- vamb ----------------
# `vamb bin default`, `vamb bin taxvamb`, `vamb bin avamb`: the binners are subcommands of `bin`.
vb = gen.argparse_dump(PIN["vamb"], "vamb.__main__", "main bin", tree=True)
VB_VALUES = {"--outdir": DIRS, "-m": NONE, "-p": NONE, "--seed": NONE, "--fasta": FASTA, "--composition": FILES,
             "--bamdir": DIRS, "--abundance_tsv": FILES, "--abundance": FILES, "--minfasta": NONE, "-o": NONE,
             "--taxonomy": FILES, "--markers": FILES, "--hmm_path": HMM, "--latent_path": FILES,
             "--clusters_path": FILES}
tree_tool("vamb", vb, {}, VB_VALUES, {}, fix={
    "--abundance_tsv": "TSV file of precomputed abundances, with a header: contigname and the samples",
    "--minfasta": "minimum bin size to output as FASTA (default: no files)",
    "-o": "binsplit separator (default: C if present; an empty string disables it)"})

# ---------------- concoct ----------------
cc = gen.argparse_dump(PIN["concoct"], "bin/concoct", "arguments")
CC_FIX = {
    "--coverage_file": "coverage table: a row per contig, a column per sample, separated by tabs",
    "--composition_file": "contigs in FASTA format, for their k-mer composition",
    "-c": "maximal number of clusters for VGMM", "-k": "k-mer length", "-r": "read length for coverage",
    "-l": "length threshold: contigs shorter than this are left out",
    "-b": "basename of the output files, or directory (with a trailing /)",
    "-s": "seed for clustering: 0 random, 1 the default, or another positive integer",
    "-i": "maximum number of iterations for the VBGMM",
    "--no_cov_normalization": "don't normalize the coverage, only log-transform it",
    "--no_total_coverage": "don't add the total coverage as a column of the coverage data",
    "--no_original_data": "don't save the original data to disk"}
fn("concoct", gen.emit_argparse(tidy(cc, CC_FIX), kinds({
    "--coverage_file": FILES, "--composition_file": FASTA, "-c": NONE, "-k": NONE, "-t": NONE, "-l": NONE,
    "-r": NONE, "--total_percentage_pca": NONE, "-b": FILES, "-s": NONE, "-i": NONE}), 12, f"        args: {NO_ARGS},"))
CC_SCRIPTS = {
    "concoct_coverage_table.py": ({"--samplenames": FILES}, {"bedfile": K("bed"), "bamfiles": BAM},
                                  {"--samplenames": "file of sample names, one per line, in the order of the BAM files"}),
    "cut_up_fasta.py": ({"-c": NONE, "-o": NONE, "-b": FILES}, {"contigs": FASTA},
                        {"-b": "BED file to write, with the regions of the original contigs of each part"}),
    "merge_cutup_clustering.py": ({}, {"cutup_clustering_result": FILES}, {}),
    "extract_fasta_bins.py": ({"--output_path": DIRS}, {"fasta_file": FASTA, "cluster_file": FILES}, {}),
}
for cmd, (values, pos, fix) in CC_SCRIPTS.items():
    acts = tidy(gen.argparse_dump(PIN["concoct"], f"bin/{cmd}", "__main__ x"), fix)
    fn(cmd, gen.emit_argparse([a for a in acts if not a["positional"]], kinds(values), 12,
                              f"        args: {positionals({'actions': acts}, pos, cmd)},"))

# ---------------- metabat2 ----------------
# Boost's program options: `-i [ --inFile ] arg   Contigs in ...`, the description going on at column 36.
def boost_opts(text):
    rows = []
    for m in re.finditer(r"^  (?:(-\w) \[ (--\w+) \]|(--\w+))( arg(?: \(=([^)]*)\))?)?\s+(\S.*)\n((?: {36}\S.*\n)*)", text, re.M):
        short, long, only, arg, default, d, more = m.groups()
        names = f"{short}, {long}" if short else only
        mv = "" if not arg else "NUM" if default is not None and re.match(r"^[\d.]+$", default) else "FILE"
        rows.append((names, mv, h.clean(" ".join((d + " " + more).split()))))
    return rows
mb = boost_opts(gen.helptext(PIN["metabat2"], "metabat2 -h"))
assert len(mb) == 29, len(mb)
mb = tidy_rows(mb, {"-o": "base file name and path of the bins (FASTA, or contig names with -l)",
                    "-a": "file of the mean and variance of the depth of each contig (jgi_summarize_bam_contig_depths)",
                    "--pTNF": "TNF probability cutoff for the TNF graph, 1 to 100 (0: automatic)",
                    "-q": "be less verbose", "--minRecruitingSize": "minimum cluster size for recruiting small and leftover contigs",
                    "--cvExt": "the coverage file has no variance (from third party tools), instead of an abdFile",
                    "-m": "minimum size of a contig for binning (at least 1500)",
                    "--minSmallContig": "minimum size of a small contig to recruit into the bins (at least 500)",
                    "--minS": "minimum score of an edge for binning, 1 to 99",
                    "--recruitWithTNF": "factor of the TNF threshold for small and lost contigs (experimental)",
                    "--recruitToAbdCentroid": "recruit small and lost contigs to the abundance-weighted centroid (experimental)"})
fn("metabat2", body(mb, {"-i": FASTA, "-o": FILES, "-a": FILES, "-m": NONE, "--minSmallContig": NONE, "--maxP": NONE,
                         "--minS": NONE, "--maxEdges": NONE, "--pTNF": NONE, "--minRecruitingSize": NONE,
                         "--recruitWithTNF": NONE, "-x": NONE, "--minCVSum": NONE, "-s": NONE, "-t": NONE,
                         "--seed": NONE}, NO_ARGS))

# `\t--outputDepth       arg  The file to ...`
jg = []
for m in re.finditer(r"^\t(--\w+)\s+(arg)?\s+(\S.*)$", gen.helptext(PIN["metabat2"], "jgi_summarize_bam_contig_depths"), re.M):
    n, arg, d = m.groups()
    jg.append((n, ("FILE" if re.match(r"The (file|prefix|reference)", d) else "NUM") if arg else "", h.clean(d)))
assert len(jg) == 20, len(jg)
# (`--maxEdgeBases` takes a number, which the help doesn't show)
jg = [(n, "NUM" if n == "--maxEdgeBases" else a, d) for n, a, d in jg]
jg = tidy_rows(jg, {"--maxEdgeBases": "the maximum length of the edges left out (without --includeEdgeBases)",
                    "--referenceFasta": "the reference: the FASTA that the BAM files were mapped to",
                    "--unmappedFastq": "prefix of the FASTQ files of the unmapped reads of each BAM file",
                    "--weightMapQual": "weight the per-base depth by the mapping quality of the read (default: 0, off)"})
fn("jgi_summarize_bam_contig_depths", body(jg, {"--outputDepth": FILES, "--percentIdentity": NONE,
                                                 "--pairedContigs": FILES, "--unmappedFastq": FILES,
                                                 "--minMapQual": NONE, "--weightMapQual": NONE,
                                                 "--referenceFasta": FASTA, "--outputGC": FILES, "--gcWindow": NONE,
                                                 "--outputReadStats": FILES, "--outputKmers": FILES,
                                                 "--shredLength": NONE, "--shredDepth": NONE,
                                                 "--minContigLength": NONE, "--minContigDepth": NONE,
                                                 "--maxEdgeBases": NONE}, f"[{BAM}]"))

# ---------------- MaxBin ----------------
# `-contig (contig file)`, `[-thread (thread num; default 1)]`: options of one dash. The table is written here, and
# checked against the names in the help.
MAXBIN = [("-contig", "FILE", "contigs (FASTA)"), ("-out", "PREFIX", "output prefix"),
          ("-reads", "FILE", "reads file (FASTA or FASTQ)"), ("-reads2", "FILE", "reads file of a second sample"),
          ("-reads3", "FILE", "reads file of a third sample"), ("-reads4", "FILE", "reads file of a fourth sample"),
          ("-abund", "FILE", "abundance file (contig name, abundance)"),
          ("-abund2", "FILE", "abundance file of a second sample"), ("-abund3", "FILE", "abundance file of a third sample"),
          ("-abund4", "FILE", "abundance file of a fourth sample"),
          ("-reads_list", "FILE", "file listing reads files, one per line"),
          ("-abund_list", "FILE", "file listing abundance files, one per line"),
          ("-min_contig_length", "NUM", "minimum contig length (default: 1000)"),
          ("-max_iteration", "NUM", "maximum number of EM iterations (default: 50)"),
          ("-thread", "NUM", "number of threads (default: 1)"),
          ("-prob_threshold", "NUM", "probability threshold for the final EM classification (default: 0.9)"),
          ("-plotmarker", "", "plot the marker gene presence of the bins"),
          ("-markerset", "SET", "marker gene set: 107 (bacteria, the default) or 40 (bacteria and archaea)"),
          ("-version, -v", "", "print the version"), ("-verbose", "", "verbose output"),
          ("-preserve_intermediate", "", "keep the intermediate files")]
names = set(re.findall(r"(?<![\w-])-(\w+)", gen.helptext(PIN["maxbin2"], "run_MaxBin.pl")))
assert names == {x.lstrip("-") for n, _, _ in MAXBIN for x in n.split(", ")}, names
fn("run_MaxBin.pl", body(MAXBIN, {"-contig": FASTA, "-out": FILES, "-reads": READS, "-reads2": READS,
                                  "-reads3": READS, "-reads4": READS, "-abund": FILES, "-abund2": FILES,
                                  "-abund3": FILES, "-abund4": FILES, "-reads_list": FILES, "-abund_list": FILES,
                                  "-min_contig_length": NONE, "-max_iteration": NONE, "-thread": NONE,
                                  "-prob_threshold": NONE, "-markerset": L("107", "40")}, NO_ARGS, single_dash=True))

# ---------------- DAS Tool ----------------
# docopt: `   -i --bins=<contig2bin>    Comma separated ...`, the description going on at column 44.
das = []
for m in re.finditer(r"^   (?:(-\w) )?(--\w+)(?:=<(\w+)>)?\s+(\S.*)$", gen.helptext(PIN["das_tool"], "DAS_Tool -h"), re.M):
    short, long, arg, d = m.groups()
    das.append((f"{short}, {long}" if short else long, (arg or "").upper(), h.clean(re.sub(r"\s*\[default: [^]]*\]", "", d))))
assert len(das) == 19, len(das)
das = [(n + ("=" + a if a else ""), "", d) for n, a, d in das]
das = tidy_rows(das, {"-i": "contig-to-bin tables (tab separated), comma separated",
                      "-l": "names of the binning predictions, comma separated",
                      "--search_engine": "engine for single copy gene identification: diamond, blastp, usearch",
                      "-p": "predicted proteins in prodigal FASTA format (>contigID_geneNo), to skip gene prediction",
                      "--score_threshold": "score threshold until which the selection keeps selecting bins (0..1)",
                      "--duplicate_penalty": "penalty for duplicate single copy genes per bin (weight b, 0..3)",
                      "--megabin_penalty": "penalty for megabins (weight c, 0..3)"})
fn("DAS_Tool", body(das, {"-i": FILES, "-c": FASTA, "-o": FILES, "-l": NONE,
                          "--search_engine": L("diamond", "blastp", "usearch"), "-p": FASTA, "-t": NONE,
                          "--score_threshold": NONE, "--duplicate_penalty": NONE, "--megabin_penalty": NONE,
                          "--max_iter_post_threshold": NONE, "--dbDirectory": DIRS}, NO_ARGS))
# `   -e, --extension            Extension of fasta files. (default: fasta)`: no value name
f2c = []
for m in re.finditer(r"^   (-\w, --\w+)\s+(\S.*)$", gen.helptext(PIN["das_tool"], "Fasta_to_Contig2Bin.sh -h"), re.M):
    n, d = m.groups()
    f2c.append((n, {"-e": "EXT", "-i": "DIR"}.get(n.split(",")[0], ""), h.clean(d)))
assert [n for n, _, _ in f2c] == ["-e, --extension", "-i, --input_folder", "-h, --help"], f2c
fn("Fasta_to_Contig2Bin.sh", body(f2c, {"-e": NONE, "-i": DIRS}, NO_ARGS))

# ---------------- coverm ----------------
# The options of each subcommand from its manual page (`--full-help-roff`: `.TP`, the names, then the description),
# and the values of those with a list of them from coverm's own fish completion (`-l mapper -r -f -a "bwa-mem\t''
# ..."`, one value per line).
def roff(t):
    return re.sub(r"\\f(\[[A-Z]*\]|[A-Z])", "", t).replace("\\-", "-")

def roff_opts(text):
    rows = []
    for names, d in re.findall(r"^\.TP\n(.*)\n(.*)", text, re.M):
        names = roff(names)
        if not names.startswith("-"):
            continue
        m = re.match(r"^(-[\w-]+(?:, --[\w-]+)?)(?: (\S+))?", names)
        rows.append((m.group(1), m.group(2) or "", h.clean(roff(d).replace("e.g.", "e.g").replace("i.e.", "i.e"))))
    return rows

CV_FISH = gen.helptext(PIN["coverm"], "d=$(mktemp -d); coverm shell-completion --shell fish --output-file $d/c.fish "
                                      ">/dev/null 2>&1; cat $d/c.fish")
def fish_choices(sub):
    """The values of the options of SUB that have a list of them, and the options that take a value (`-r`)."""
    out, takes = {}, set()
    for m in re.finditer(rf'^complete -c coverm -n "__fish_coverm_using_subcommand {sub}"([^\n]*)', CV_FISH, re.M):
        if " -r" in m.group(1):
            takes.update("--" + n for n in re.findall(r" -l (\S+)", m.group(1)))
    for m in re.finditer(rf'^complete -c coverm -n "__fish_coverm_using_subcommand {sub}"([^\n]*?) -a "([^"]*)"', CV_FISH,
                         re.M):
        for n in re.findall(r" -l (\S+)", m.group(1))[:1]:
            out["--" + n] = gen.wrap_list([v.split("\\t")[0] for v in m.group(2).split("\n")], 16)
    return out, takes

CV_CMDS = re.findall(r'^complete -c coverm -n "__fish_coverm_needs_command" -f -a "([\w-]+)" -d \'(.*)\'$', CV_FISH, re.M)
CV_CMDS = [(c, d) for c, d in CV_CMDS if c != "help"]
CV_VALUES = {"-1": READS, "-2": READS, "--coupled": READS, "--interleaved": READS, "--single": READS, "-b": BAM,
             "-r": FILES, "--minimap2-params": NONE, "--bwa-params": NONE, "--strobealign-params": NONE,
             "--minibwa-params": NONE, "--rammap-params": NONE, "--min-read-aligned-length": NONE,
             "--min-read-percent-identity": NONE, "--min-read-aligned-percent": NONE,
             "--min-read-aligned-length-pair": NONE, "--min-read-percent-identity-pair": NONE,
             "--min-read-aligned-percent-pair": NONE, "--min-mapq": NONE, "--min-covered-fraction": NONE,
             "--contig-end-exclusion": NONE, "--trim-min": NONE, "--trim-max": NONE, "--gff": GFF,
             "--gff-feature-type": NONE, "-o": FILES, "--cache-unfiltered-bam-directory": DIRS,
             "--cache-unfiltered-bam-files": FILES, "-t": NONE, "-f": FASTA, "-d": DIRS, "-x": NONE,
             "--genome-fasta-list": FILES, "-s": NONE, "--genome-definition": FILES,
             "--checkm2-quality-report": FILES, "--checkm-tab-table": FILES, "--genome-info": FILES,
             "--min-completeness": NONE, "--max-contamination": NONE, "--checkm2-db-path": K("diamond_db"),
             "--exclude-genomes-from-deshard": FILES, "--shell": L("bash", "elvish", "fish", "powershell", "zsh")}
for p in ["--dereplication-", "--"]:
    CV_VALUES.update({p + n: NONE for n in ["ani", "aligned-fraction", "fragment-length", "prethreshold-ani"]})
    CV_VALUES.update({p + n: FASTA for n in ["reference-genomes"]})
    CV_VALUES.update({p + n: FILES for n in ["reference-genomes-list", "output-cluster-definition",
                                             "output-representative-list"]})
    CV_VALUES.update({p + n: DIRS for n in ["output-representative-fasta-directory",
                                            "output-representative-fasta-directory-copy"]})
CV_VALUES.update({"--min-aligned-fraction": NONE, "--fragment-length": NONE, "--precluster-ani": NONE})
CV_SUB = {"filter": {"-o": BAM}, "make": {"-o": DIRS}, "makedb": {"-o": DIRS, "-r": FASTA}}
# (by the long name: -o and -b are not the same option in each subcommand)
CV_FIX = {"--reference": "FASTA file of contigs (concatenated genomes or an assembly), or a minimap2, strobealign or BWA index",
          "--coupled": "pairs of forward and reverse FASTA/Q files: sample1_R1 sample1_R2 sample2_R1 sample2_R2 ...",
          "--bam-files": "BAM files, sorted by reference (by read name with --sharded): no mapping is done",
          "--sharded": "the BAM files (or the mappings to each reference) are sharded: choose the best hit for each pair",
          "--min-read-aligned-percent-pair": "exclude pairs by percent aligned bases (implies --proper-pairs-only)",
          "--min-mapq": "exclude reads with a mapping quality below this value (0 to 254)",
          "--output-file": "output coverage values to this file, or '-' for stdout",
          "--separator": "the character that separates genome names from contig names in the reference file",
          "--strobealign-use-index": "use a pregenerated index (strobealign --create-index) of the reference",
          "--use-full-contig-names": "the BAM files were made with contig names that have spaces",
          "--dereplicate": "dereplicate genomes by ANI, choosing a representative of each cluster",
          "--dereplication-small-genomes": "use small-genomes settings in skani (recommended for sequences < 20kbp)",
          "--small-genomes": "use small-genomes settings in skani (recommended for sequences < 20kbp)",
          "--dereplication-cluster-contigs": "cluster contigs within a FASTA file instead of genomes",
          "--cluster-contigs": "cluster contigs within a FASTA file instead of genomes",
          "--checkm2-quality-report": "CheckM2's quality_report.tsv, for the quality of the genomes",
          "--checkm-tab-table": "CheckM's tab table (checkm ... --tab_table -f PATH), for the quality of the genomes",
          "--genome-info": "dRep's genome info table, for the quality of the genomes",
          "--gff": "GFF (or GTF) file of the genes or features, to report the coverage of each",
          "--min-read-aligned-percent": "exclude reads by percent aligned bases (95: 95% of the read's bases)",
          "--min-read-percent-identity-pair": "exclude pairs by overall percent identity (implies --proper-pairs-only)",
          "--dereplication-prethreshold-ani": "minimum precluster ANI for preclustering and primary clustering",
          "--precluster-ani": "minimum precluster ANI for preclustering and primary clustering",
          "--dereplication-cluster-method": "method of calculating ANI: fastani (FastANI) or skani (Skani)",
          "--cluster-method": "method of calculating ANI: fastani (FastANI) or skani (Skani)",
          "--dereplication-precluster-method": "method of calculating rough ANI: finch (MinHash) or skani",
          "--precluster-method": "method of calculating rough ANI: finch (MinHash) or skani",
          "--exclude-genomes-from-deshard": "ignore the genomes named in this file (one per line) when combining shards",
          "--output-bam-files": "output BAM files, one per input BAM file",
          "--output-directory": "directory of the output (created if it does not exist)"}
cmds = []
for sub, d in CV_CMDS:
    if sub == "shell-completion":
        o = h.parse(gen.helptext(PIN["coverm"], "coverm shell-completion -h"))
        o = [(n, a.strip("<>").upper().replace("-", "_"),
              {"-o, --output-file": "file to write the completion script to", "--shell": "the shell"}.get(n, d))
             for n, a, d in o]
    else:
        o = roff_opts(gen.helptext(PIN["coverm"], f"coverm {sub} --full-help-roff"))
    assert len(o) >= 5, (sub, o)
    o = tidy_rows(o, dict(CV_FIX, **{"filter": {"--bam-files": "BAM files to filter, sorted by reference"}}.get(sub, {})))
    choices, takes = fish_choices(sub)
    # (an option whose value the manual page doesn't name)
    o = [(n, "PATH" if not a and takes & set(option_names(n)) else a, d) for n, a, d in o]
    v = dict(CV_VALUES, **CV_SUB.get(sub, {}))
    v.update(choices)
    cmds.append(f'        "{sub}" => #{{\n' + body(o, v, NO_ARGS, indent=16) + "\n        },")
w = max(len(c) for c, _ in CV_CMDS)
progs["coverm"] = "coverm"
subs["coverm"] = "coverm"
emit('fn coverm() {\n    #{\n        opts: `\n            -h, --help     show the commands\n'
     '            -V, --version  print version information\n        `,\n        commands: `\n' +
     "".join(f"            {c.ljust(w)}  {h.clean(d)}\n" for c, d in CV_CMDS) +
     '        `,\n        sub_spec: own("bins:coverm"),\n    }\n}\n')
emit("fn coverm_sub(sub) {\n    switch sub {\n" + "\n".join(cmds) + "\n        _ => (),\n    }\n}\n")

emit('''fn spec(cmd) {
    switch cmd {
''' + "".join(f'        "{c}" => {n}(),\n' for c, n in progs.items()) + '''        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
''' + "".join(f'        "{c}" => {n}_sub(sub),\n' for c, n in subs.items()) + '''        _ => (),
    }
}''')
open(gen.REPO + "/completion/bio/bins.rhai", "w").write("\n".join(out) + "\n")
print("written")
