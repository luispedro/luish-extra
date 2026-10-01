"""Generates ../../complete/bio/align.rhai: bwa, bwa-mem2, bowtie2, hisat2, minimap2, STAR, kallisto
and featureCounts, from their --help at the pinned versions (see completion-todo.md).

    python3 scripts/gen/mk_align.py
"""
import os
import re, sys, json
import gen
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import help2opts as h

I = 12  # indent of the table lines in a sub spec case
def body(text, values=None, args=None, edit=None, extra="", indent=I, drop=(), add=()):
    opts = h.parse(text)
    opts = [o for o in opts if not any(x in drop for x in o[0].replace(",", " ").split())]
    if edit:
        opts = edit(opts)
    opts += list(add)
    tail = ""
    if args:
        tail += " " * (indent - 4) + f"args: {args},\n"
    tail += extra
    return h.emit(opts, indent, values, tail.rstrip("\n"))

def case(name, b):
    pad = " " * 8
    return f'{pad}{name} => #{{\n{b}\n{pad}}},'

K = lambda n: f'k("{n}")'
FA, FQ, SEQ, SAM, BAM, GFF, BED = K("fasta"), K("fastq"), K("sequences"), K("sam"), K("bam"), K("gff"), K("bed")
out = []
def emit(s): out.append(s)

emit('''// Mapping and quantification: bwa, bwa-mem2, bowtie2, minimap2, hisat2, STAR,
// kallisto and featureCounts. The option tables come from the tools' own
// `--help` (versions in completion-todo.md).

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("kinds:") + name }
''')

# ---------------- bwa ----------------
bwa_cmds = """
            index       index sequences in the FASTA format
            mem         BWA-MEM algorithm
            fastmap     identify super-maximal exact matches
            pemerge     merge overlapping paired ends (experimental)
            aln         gapped/ungapped alignment
            samse       generate alignment (single ended)
            sampe       generate alignment (paired ended)
            bwasw       BWA-SW for long queries (deprecated)
            shm         manage indices in shared memory
            fa2pac      convert FASTA to PAC format
            pac2bwt     generate BWT from PAC
            pac2bwtgen  alternative algorithm for generating BWT
            bwtupdate   update .bwt to the new format
            bwt2sa      generate SA from BWT and Occ
"""
emit(f'''fn bwa() {{
    #{{
        opts: `
            -h, --help  show help
        `,
        commands: `{bwa_cmds}        `,
        sub_spec: own("align:bwa"),
    }}
}}
''')
def bwa_mem_edit(opts):
    return [o for o in opts if not (o[0] == "-o" and o[1] == "")]
bwa_sub = []
bwa_sub.append(case('"index"', body(gen.helptext("bwa=0.7.19","bwa index 2>&1"), {"-a": '["bwtsw", "is", "rb2"]', "-p": '"files"'}, f"[{FA}]")))
memvals = {"-x": '["pacbio", "ont2d", "intractg"]', "-H": '"files"', "-o": '"files"'}
bwa_sub.append(case('"mem"', body(gen.helptext("bwa=0.7.19","bwa mem 2>&1"), memvals, f'[{K("bwa_index")}, {SEQ}]')))
bwa_sub.append(case('"aln"', body(gen.helptext("bwa=0.7.19","bwa aln 2>&1"), {"-f": '"files"'}, f'[{K("bwa_index")}, {FQ}]')))
bwa_sub.append(case('"samse"', body("", {"-f": '"files"'}, f'[{K("bwa_index")}, {K("sai")}, {FQ}]',
    add=[("-n", "INT", "maximum number of alignments to output in the XA tag"), ("-f", "FILE", "write the SAM output to FILE"), ("-r", "STR", "read group header line such as '@RG\\tID:foo\\tSM:bar'")])))
bwa_sub.append(case('"sampe"', body(gen.helptext("bwa=0.7.19","bwa sampe 2>&1"), {"-f": '"files"'}, f'[{K("bwa_index")}, {K("sai")}, {K("sai")}, {FQ}, {FQ}]')))
bwa_sub.append(case('"fastmap"', body(gen.helptext("bwa=0.7.19","bwa fastmap 2>&1"), {}, f'[{K("bwa_index")}, {FQ}]')))
bwa_sub.append(case('"pemerge"', body(gen.helptext("bwa=0.7.19","bwa pemerge 2>&1"), {}, f'[{FQ}]')))
bwa_sub.append(case('"bwasw"', body(gen.helptext("bwa=0.7.19","bwa bwasw 2>&1"), {"-f": '"files"'}, f'[{K("bwa_index")}, {FA}]')))
bwa_sub.append(case('"shm"', body("", {"-f": '"files"'}, f'[{K("bwa_index")}]',
    add=[("-d", "", "destroy all indices in shared memory"), ("-l", "", "list names of indices in shared memory"), ("-f", "FILE", "temporary file when loading indices")])))
bwa_sub.append('''        "fa2pac" | "pac2bwt" | "pac2bwtgen" | "bwtupdate" | "bwt2sa" => #{},''')
emit('fn bwa_sub(sub) {\n    switch sub {\n' + "\n".join(bwa_sub) + '\n        _ => (),\n    }\n}\n')

# ---------------- bwa-mem2 ----------------
emit(f'''fn bwa_mem2() {{
    #{{
        opts: `
            -h, --help  show help
        `,
        commands: `
            index    index sequences in the FASTA format
            mem      BWA-MEM2 algorithm
            version  show the version
        `,
        sub_spec: own("align:bwa-mem2"),
    }}
}}
''')
b2 = []
b2.append(case('"index"', body("", {"-p": '"files"'}, f"[{FA}]", add=[("-p", "STR", "prefix of the index")])))
b2.append(case('"mem"', body(gen.helptext("bwa-mem2=2.2.1","bwa-mem2 mem 2>&1"), memvals, f'[{K("bwa_index")}, {SEQ}]', edit=bwa_mem_edit)))
emit('fn bwa_mem2_sub(sub) {\n    switch sub {\n' + "\n".join(b2) + '\n        _ => (),\n    }\n}\n')

# ---------------- bowtie2 ----------------
bt2 = gen.helptext("bowtie2=2.5.5","bowtie2 --help")
def bt2_edit(opts):
    drop_names = {"-F", "-c", "--very-fast", "--fast", "--sensitive", "--very-sensitive", "--very-fast-local", "--fast-local",
                  "--sensitive-local", "--very-sensitive-local", "--fr", "--rf", "--ff", "--un-gz", "--no-head", "--non-deterministic",
                  "--align-paired-reads", "--preserve-tags", "--no-1mm-upfront", "-l", "--local", "--end-to-end", "-a", "-d"}
    o2 = [o for o in opts if o[0].split(",")[0].strip() not in drop_names]
    o2 += [
        ("-x", "BT2_IDX", "index filename prefix (minus the trailing .X.bt2)"),
        ("-1", "FILE", "files with #1 mates, paired with the files of -2"),
        ("-2", "FILE", "files with #2 mates, paired with the files of -1"),
        ("-U", "FILE", "files with unpaired reads"),
        ("--interleaved", "FILE", "files with interleaved paired-end FASTQ or FASTA reads"),
        ("-b", "BAM", "files are unaligned BAM sorted by read name"),
        ("-S", "FILE", "write the SAM output to FILE"),
        ("-c", "", "the reads (-1, -2, -U) are sequences themselves, not files"),
        ("-F", "k:INT,i:INT", "reads are substrings (k-mers) extracted from FASTA files"),
        ("--end-to-end", "", "the entire read must align, with no clipping"),
        ("--local", "", "local alignment: the ends might be soft clipped"),
        ("-a, --all", "", "report all alignments (very slow)"),
        ("-l, --lowseeds", "N", "ignore low quality seeds with ranges over this threshold"),
        ("-d, --deterministic-seeds", "", "consider all seeds in order (no subsampling; best with -a)"),
        ("--very-fast", "", "same as -D 5 -R 1 -N 0 -L 22 -i S,0,2.50"),
        ("--fast", "", "same as -D 10 -R 2 -N 0 -L 22 -i S,0,2.50"),
        ("--sensitive", "", "same as -D 15 -R 2 -N 0 -L 22 -i S,1,1.15 (the default)"),
        ("--very-sensitive", "", "same as -D 20 -R 3 -N 0 -L 20 -i S,1,0.50"),
        ("--very-fast-local", "", "same as -D 5 -R 1 -N 0 -L 25 -i S,1,2.00"),
        ("--fast-local", "", "same as -D 10 -R 2 -N 0 -L 22 -i S,1,1.75"),
        ("--sensitive-local", "", "same as -D 15 -R 2 -N 0 -L 20 -i S,1,0.75 (the default with --local)"),
        ("--very-sensitive-local", "", "same as -D 20 -R 3 -N 0 -L 20 -i S,1,0.50"),
        ("--fr", "", "mates align forward/reverse (the default)"),
        ("--rf", "", "mates align reverse/forward"),
        ("--ff", "", "mates align forward/forward"),
        ("--un-gz", "PATH", "like --un, gzip compressed (also --un-bz2, --un-lz4, and --al-*, --un-conc-*, --al-conc-*)"),
        ("--no-head", "", "suppress the header lines (starting with @)"),
        ("--non-deterministic", "", "seed the random number generator arbitrarily each time"),
        ("--align-paired-reads", "", "align paired reads from a BAM file (with -b)"),
        ("--preserve-tags", "", "preserve the tags of the original BAM record (with -b)"),
        ("--no-1mm-upfront", "", "do not allow 1 mismatch alignments before attempting to scan for the optimal seeded alignments"),
    ]
    return o2
bt2v = {"-x": K("bowtie2_index"), "-1": SEQ, "-2": SEQ, "-U": SEQ, "--interleaved": SEQ, "-b": BAM, "-S": '"files"',
        "--un": '"files"', "--al": '"files"', "--un-conc": '"files"', "--al-conc": '"files"', "--un-gz": '"files"',
        "--met-file": '"files"', "-p": '"none"', "--threads": '"none"', "--phred33": None}
bt2v = {k_: v for k_, v in bt2v.items() if v}
emit('''fn bowtie2() {
    #{
''' + body(bt2, bt2v, None, bt2_edit, indent=12).replace("\n            ", "\n            ") + '''
    }
}
''')
emit('''fn bowtie2_build() {
    #{
''' + body(gen.helptext("bowtie2=2.5.5","bowtie2-build -h"), {"--bmax": '"none"'}, f"[{FA}, {K('bowtie2_index')}]", drop=("-h", "--h")) + '''
    }
}
''')

# ---------------- hisat2 ----------------
ht = gen.helptext("hisat2=2.2.3","hisat2 --version | head -1; hisat2 -h")
def ht_edit(opts):
    drop_names = {"-c", "--fast", "--sensitive", "--very-sensitive", "-a", "--fr", "--un-gz", "--no-head", "--non-deterministic", "--temp-directory", "--bowtie2-dp", "--max-seeds", "-k"}
    o2 = [o for o in opts if o[0].split(",")[0].strip() not in drop_names]
    o2 += [
        ("-x", "HT2_IDX", "index filename prefix (minus the trailing .X.ht2)"),
        ("-1", "FILE", "files with #1 mates, paired with the files of -2"),
        ("-2", "FILE", "files with #2 mates, paired with the files of -1"),
        ("-U", "FILE", "files with unpaired reads"),
        ("-S", "FILE", "write the SAM output to FILE"),
        ("-c", "", "the reads (-1, -2, -U) are sequences themselves, not files"),
        ("--fast", "", "same as --no-repeat-index"),
        ("--sensitive", "", "same as --bowtie2-dp 1 -k 30 --score-min L,0,-0.5"),
        ("--very-sensitive", "", "same as --bowtie2-dp 2 -k 50 --score-min L,0,-1"),
        ("--bowtie2-dp", "INT", "use Bowtie2's dynamic programming alignment algorithm: 0 no, 1 when needed, 2 always"),
        ("-k", "INT", "search for at most INT distinct primary alignments for each read"),
        ("--max-seeds", "INT", "maximum number of seeds to extend"),
        ("-a, --all", "", "report all the alignments it can find"),
        ("--fr", "", "mates align forward/reverse (the default)"),
        ("--rf", "", "mates align reverse/forward"),
        ("--ff", "", "mates align forward/forward"),
        ("--un-gz", "PATH", "like --un, gzip compressed (also --un-bz2, and --al-*, --un-conc-*, --al-conc-*)"),
        ("--no-head", "", "suppress the header lines (starting with @)"),
        ("--non-deterministic", "", "seed the random number generator arbitrarily each time"),
        ("--temp-directory", "DIR", "the directory for temporary files"),
    ]
    return o2
htv = {"-x": K("hisat2_index"), "-1": SEQ, "-2": SEQ, "-U": SEQ, "-S": '"files"', "--un": '"files"', "--al": '"files"',
       "--un-conc": '"files"', "--al-conc": '"files"', "--un-gz": '"files"', "--known-splicesite-infile": '"files"',
       "--novel-splicesite-infile": '"files"', "--novel-splicesite-outfile": '"files"', "--summary-file": '"files"',
       "--met-file": '"files"', "--rna-strandness": '["F", "R", "FR", "RF"]', "--temp-directory": '"dirs"'}
emit('''fn hisat2() {
    #{
''' + body(ht, htv, None, ht_edit) + '''
    }
}
''')
emit('''fn hisat2_build() {
    #{
''' + body(gen.helptext("hisat2=2.2.3","hisat2-build -h"), {"--snp": '"files"', "--haplotype": '"files"', "--ss": '"files"', "--exon": '"files"'}, f"[{FA}, {K('hisat2_index')}]", drop=("-h", "--usage", "--help")) + '''
    }
}
''')

# ---------------- minimap2 ----------------
mm = gen.helptext("minimap2=2.30","minimap2 --help")
def mm_edit(opts):
    o2 = [o for o in opts if o[0] not in ("-r",)]
    o2 += [
        ("-r", "NUM[,NUM]", "chaining and alignment bandwidth, and long-join bandwidth"),
        ("-V, --version", "", "show the version number"),
        ("-2", "", "use two I/O threads during mapping"),
        ("--secondary", "yes|no", "whether to output secondary alignments"),
        ("--sam-hit-only", "", "in SAM, do not output unmapped reads"),
        ("--junc-bed", "FILE", "junctions in BED12 to extend short RNA-seq alignment"),
        ("--split-prefix", "STR", "prefix for the temporary files of the split index"),
        ("--frag", "yes|no", "fragment mode: use paired-end alignment for the reads"),
        ("--for-only", "", "only map to the forward strand of the transcript"),
        ("--rev-only", "", "only map to the reverse strand of the transcript"),
        ("--seed", "INT", "the random seed"),
        ("--max-qlen", "NUM", "skip query sequences longer than NUM"),
        ("--end-bonus", "INT", "score bonus when alignment extends to the end of the query"),
        ("--no-end-flt", "", "do not filter seeds towards the ends of the chains"),
        ("--paf-no-hit", "", "in PAF, output unmapped queries"),
        ("--dual", "yes|no", "for the split index, map in both directions"),
        ("--MD", "", "output the MD tag"),
        ("--splice", "", "splice preset, the same as -x splice"),
        ("--sr", "", "short read preset, the same as -x sr"),
        ("--heap-sort", "yes|no", "use heap sort instead of radix sort when merging"),
    ]
    return o2
mmv = {"-x": '["map-ont", "map-hifi", "map-pb", "lr:hq", "splice", "splice:hq", "splice:sr", "asm5", "asm10", "asm20", "sr", "ava-pb", "ava-ont"]',
       "-d": '"files"', "-j": BED, "-o": '"files"', "--junc-bed": BED, "--secondary": '["yes", "no"]', "--frag": '["yes", "no"]',
       "--dual": '["yes", "no"]', "-u": '["f", "b", "n"]', "--split-prefix": '"files"', "--heap-sort": '["yes", "no"]'}
emit('''fn minimap2() {
    #{
''' + body(mm, mmv, f"[{K('minimap2_ref')}, {SEQ}]", mm_edit) + '''
    }
}
''')

# ---------------- STAR ----------------
import star_params
sopts, svals = star_params.star_params()
lines = "\n".join("            " + l for l in sopts)
vals = []
line = "            "
for n, v in svals:
    entry = f'"--{n}": {v}, '
    if len(line) + len(entry) > 118 or v.startswith("["):
        if line.strip(): vals.append(line.rstrip())
        line = "            "
    if v.startswith("["):
        vals.append("            " + entry.rstrip())
    else:
        line += entry
if line.strip(): vals.append(line.rstrip())
emit('''fn star() {
    #{
        opts: `
''' + lines + '''
        `,
        values: #{
''' + "\n".join(vals).replace("            ", "            ") + '''
        },
        strict_eq: true,
    }
}
''')

# ---------------- kallisto ----------------
kal = {}
kv = {"-i": K("kallisto_index"), "--index": K("kallisto_index"), "-o": '"dirs"', "--output-dir": '"dirs"', "-g": GFF, "--gtf": GFF, "-c": '"files"',
      "--chromosomes": '"files"', "-d": FA, "--d-list": FA, "-T": '"dirs"', "--tmp": '"dirs"', "-B": '"files"', "--batch": '"files"', "-p": '"files"', "--priors": '"files"'}
def kbody(cmd, args, extra_vals=None, edit=None):
    v = dict(kv)
    if extra_vals: v.update(extra_vals)
    return body(gen.helptext("kallisto=0.52.0", f"kallisto {cmd}"), v, args, edit)
emit('''fn kallisto() {
    #{
        opts: `
            -h, --help  show help
        `,
        commands: `
            index      build a kallisto index
            quant      run the quantification algorithm
            quant-tcc  run quantification on transcript-compatibility counts
            bus        generate BUS files for single-cell data
            h5dump     convert HDF5-formatted results to plaintext
            inspect    inspect an index and give information about it
            version    print version information
            cite       print citation information
        `,
        sub_spec: own("align:kallisto"),
    }
}
''')
ks = []
ks.append(case('"index"', kbody("index", f"[{FA}]")))
ks.append(case('"quant"', kbody("quant", f"[{FQ}]", {"-p": '"files"'})))
ks.append(case('"bus"', kbody("bus", f"[{FQ}]", {"-x": '"none"'})))
ks.append(case('"h5dump"', kbody("h5dump", '["files"]')))
ks.append(case('"inspect"', body(gen.helptext("kallisto=0.52.0","kallisto inspect"), {}, f"[{K('kallisto_index')}]")))
emit('fn kallisto_sub(sub) {\n    switch sub {\n' + "\n".join(ks) + '\n        _ => (),\n    }\n}\n')

# ---------------- featureCounts ----------------
fc = gen.helptext("subread=2.1.1","featureCounts")
fcv = {"-a": GFF, "-o": '"files"', "-F": '["GTF", "SAF"]', "-A": '"files"', "-G": FA, "-s": '["0", "1", "2"]',
       "-R": '["CORE", "SAM", "BAM"]', "--Rpath": '"dirs"', "--tmpDir": '"dirs"', "--read2pos": '["5", "3"]'}
emit('''fn featurecounts() {
    #{
''' + body(fc, fcv, f"[{K('sam')}]") + '''
    }
}
''')

# ---------------- dispatch ----------------
emit('''fn spec(cmd) {
    switch cmd {
        "bwa" => bwa(),
        "bwa-mem2" => bwa_mem2(),
        "bowtie2" => bowtie2(),
        "bowtie2-build" => bowtie2_build(),
        "hisat2" => hisat2(),
        "hisat2-build" => hisat2_build(),
        "minimap2" => minimap2(),
        "STAR" => star(),
        "kallisto" => kallisto(),
        "featureCounts" => featurecounts(),
        _ => #{},
    }
}

fn sub_spec(name, sub) {
    switch name {
        "bwa" => bwa_sub(sub),
        "bwa-mem2" => bwa_mem2_sub(sub),
        "kallisto" => kallisto_sub(sub),
        _ => (),
    }
}
''')
open(gen.REPO + "/complete/bio/align.rhai", "w").write("\n".join(out))
print("written")
