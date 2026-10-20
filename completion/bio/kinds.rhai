// What the arguments and option values of bio commands complete to, named
// `own("kinds:NAME")` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;
import "../extra-lib/files" as lib_files;

// The names of the directory of `cur` without the first of `suffixes` that
// they end with, for files that make up a whole (the index of an aligner
// is `PREFIX.1.bt2`, ...), and the directories. Files of the same prefix
// come once.
fn prefixes(cur, suffixes) {
    let r = lib_files::with_suffix(cur, suffixes);
    let out = [];
    for c in r.candidates {
        if type_of(c) == "map" {
            out.push(c);
            continue;
        }
        for s in suffixes {
            if c.ends_with(s) && c.len() > s.len() {
                let p = c.sub_string(0, c.len() - s.len());
                if !out.contains(p) {
                    out.push(p);
                }
                break;
            }
        }
    }
    r.candidates = out;
    r
}

// BLAST databases: PREFIX.nin, PREFIX.pin, or PREFIX.NN.nin for each volume.
fn blast_db(cur) {
    let r = prefixes(cur, [".nal", ".pal", ".nin", ".pin", ".ndb", ".pdb"]);
    let out = [];
    for c in r.candidates {
        if type_of(c) == "string" && c.len() > 3 && c[c.len() - 3] == '.'
            && c[c.len() - 2] >= '0' && c[c.len() - 2] <= '9' && c[c.len() - 1] >= '0' && c[c.len() - 1] <= '9' {
            c = c.sub_string(0, c.len() - 3);
        }
        if !out.contains(c) {
            out.push(c);
        }
    }
    r.candidates = out;
    r
}

// The candidates of both `a` and `b` (results of `with_suffix` or `prefixes`).
fn union(a, b) {
    for c in b.candidates {
        if !a.candidates.contains(c) {
            a.candidates.push(c);
        }
    }
    a
}

fn is_fasta(name) {
    lib_files::compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas"]).some(|s| name.ends_with(s))
}

fn is_alignment(name) {
    [".bam", ".cram", ".sam"].some(|s| name.ends_with(s))
}

// The names among `names` (sorted) that start with `cur`. A reference can have millions of sequences (the contigs of
// an assembly), so they are found by bisection, and none are offered while more than 5000 match: a word's start
// first.
fn starting_with(names, cur) {
    let lo = 0;
    let hi = names.len();
    while lo < hi {
        let mid = (lo + hi) / 2;
        if names[mid] < cur {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }
    let out = [];
    while lo < names.len() && names[lo].starts_with(cur) {
        if out.len() == 5000 {
            return [];
        }
        out.push(names[lo]);
        lo += 1;
    }
    out
}

// The program that lists the names of the file `path` for `what` (`header`: the `@SQ` names of an alignment file's
// header; `fai`: the first column of a FASTA index; `tabix`: the sequences of a tabix index; `vcf`: the sequences of
// a VCF/BCF, from its index (name, length and count); `samples`: its samples).
fn names_argv(what, path) {
    switch what {
        "header" => ["samtools", "view", "-H", path],
        "fai" => ["cat", path],
        "tabix" => ["tabix", "-l", path],
        "vcf" => ["bcftools", "index", "-s", path],
        "samples" => ["bcftools", "query", "-l", path],
        _ => throw `unknown names: ${what}`,
    }
}

// The names of the file `path` (as `names_argv` says) that start with `cur`. Splitting a long list takes long, so
// it is kept, sorted, until one of `files` (`path` and those it is read with) changes; a list too long to split at
// all (an assembly's, over 4 MB) is filtered by awk at each Tab.
fn names_of(what, path, files, cur) {
    let key = what + ":" + path;
    let names = sh::cache_get(key, files);
    if names == () {
        names = read_names(what, path);
        if type_of(names) == "array" {
            names.sort();
        }
        // (a program that failed, or a file being written: read again at the next Tab)
        if names != [] {
            sh::cache_put(key, 3600, files, names);
        }
    }
    if type_of(names) == "array" {
        return starting_with(names, cur);
    }
    if cur == "" {
        return [];    // (more than 5000)
    }
    // (the names in the output of the command that start with $PREFIX, up to 5001)
    let awk = if what == "header" {
        `/^@SQ\t/ { for (i = 2; i <= NF; i++) if (substr($i, 1, 3) == "SN:" && index(substr($i, 4), p) == 1) {
            print substr($i, 4); if (++n > 5000) exit } }`
    } else {
        `index($1, p) == 1 { print $1; if (++n > 5000) exit }`
    };
    let filter = `"$@" | awk -F '\t' 'BEGIN { p = ENVIRON["PREFIX"] } ${awk}'`;
    let out = lines_of(["env", "PREFIX=" + cur, "sh", "-c", filter, "sh"] + names_argv(what, path));
    if out.len() > 5000 { [] } else { out }
}

fn lines_of(argv) {
    sh::capture(["timeout", "5"] + argv).out.split("\n").filter(|l| l != "")
}

// The names, or "big" for a list over 4 MB.
fn read_names(what, path) {
    if what == "fai" && (fs::size(path) ?? 0) > 4000000 {
        return "big";
    }
    let out = sh::capture(["timeout", "5"] + names_argv(what, path)).out;
    if what == "vcf" && out == "" {
        out = sh::capture(["timeout", "5", "tabix", "-l", path]).out;
    }
    if out.len() > 4000000 {
        return "big";
    }
    if what == "header" {
        let names = [];
        for l in out.split("\n") {
            if l.starts_with("@SQ\t") {
                for f in l.split("\t") {
                    if f.starts_with("SN:") {
                        names.push(f.sub_string(3));
                    }
                }
            }
        }
        return names;
    }
    out.split("\n").filter(|l| l != "").map(|l| l.split("\t")[0])
}

// Reference names, for a region: from the header of the first alignment
// file in the line, else from the `.fai` next to the first FASTA file.
fn regions(cur, words) {
    for w in words {
        if is_alignment(w) && fs::is_file(w) {
            return names_of("header", w, [w], cur);
        }
    }
    for w in words {
        if is_fasta(w) && fs::is_file(w + ".fai") {
            return names_of("fai", w + ".fai", [w + ".fai"], cur);
        }
    }
    []
}

// The sequences of the first tabix-indexed file in the line (`tabix -l`).
fn tabix_regions(cur, words) {
    for w in words {
        if (w.ends_with(".gz") || w.ends_with(".bgz")) && fs::is_file(w) {
            return names_of("tabix", w, [w, w + ".tbi", w + ".csi"], cur);
        }
    }
    []
}

fn is_vcf(name) {
    lib_files::compressed([".vcf"]).some(|s| name.ends_with(s)) || name.ends_with(".bcf")
}

// The sequences of the first VCF/BCF in the line.
fn vcf_regions(cur, words) {
    for w in words {
        if is_vcf(w) && fs::is_file(w) {
            return names_of("vcf", w, [w, w + ".tbi", w + ".csi"], cur);
        }
    }
    []
}

// The samples of the first VCF/BCF in the line (`bcftools query -l`); a cohort can have hundreds of thousands.
fn vcf_samples(cur, words) {
    for w in words {
        if is_vcf(w) && fs::is_file(w) {
            return names_of("samples", w, [w], cur);
        }
    }
    []
}

// Trimmomatic's steps (`SLIDINGWINDOW:4:20`), after its input and output
// files: the steps and the files. After `ILLUMINACLIP:`, a FASTA of adapters
// or one of those that come with Trimmomatic (which it finds by name), then
// `:` for the step's numbers.
fn trimmomatic_step(cur) {
    let fasta = lib_files::compressed([".fa", ".fasta", ".fna"]);
    if cur.starts_with("ILLUMINACLIP:") {
        let rest = cur.sub_string(13);
        if rest.contains(":") {
            return [];
        }
        let r = lib_files::with_suffix(rest, fasta);
        r.prefix = "ILLUMINACLIP:" + r.prefix;
        let out = r.candidates.map(|c| if type_of(c) == "map" { c } else { #{value: c, suffix: ":"} });
        if r.prefix == "ILLUMINACLIP:" {
            for a in ["NexteraPE-PE.fa", "TruSeq2-PE.fa", "TruSeq2-SE.fa", "TruSeq3-PE.fa", "TruSeq3-PE-2.fa",
                      "TruSeq3-PE-2-GGGGG.fa", "TruSeq3-SE.fa", "TruSeq3-SE-GGGGG.fa"] {
                if !out.some(|c| c.value == a) {
                    out.push(#{value: a, desc: "comes with Trimmomatic", suffix: ":"});
                }
            }
        }
        r.candidates = out;
        return r;
    }
    let r = std_kinds::listing(cur, "", false);
    if r.prefix == "" {
        for s in [
            ["ILLUMINACLIP:", "cut adapters: FASTA:MISMATCHES:PALINDROME:SIMPLE[:MINLEN:KEEPBOTH]"],
            ["SLIDINGWINDOW:", "cut once the mean quality of a window drops: SIZE:QUALITY"],
            ["MAXINFO:", "adaptive quality trimming: LENGTH:STRICTNESS"],
            ["LEADING:", "cut bases off the start below a quality: QUALITY"],
            ["TRAILING:", "cut bases off the end below a quality: QUALITY"],
            ["CROP:", "cut the read to a length: LENGTH"],
            ["HEADCROP:", "cut bases off the start: LENGTH"],
            ["TAILCROP:", "cut bases off the end: LENGTH"],
            ["MINLEN:", "drop reads shorter than LENGTH"],
            ["MAXLEN:", "drop reads longer than LENGTH"],
            ["AVGQUAL:", "drop reads whose mean quality is below QUALITY"],
            ["BASECOUNT:", "drop reads by the count of some bases: BASES[:MIN[:MAX]]"],
            ["TOPHRED33", "convert the qualities to Phred+33"],
            ["TOPHRED64", "convert the qualities to Phred+64"],
        ] {
            r.candidates.push(if s[0].ends_with(":") { #{value: s[0], desc: s[1], suffix: ""} } else { #{value: s[0], desc: s[1]} });
        }
    }
    r
}

// An adapter of cutadapt: a sequence to type, or `file:` and a FASTA of
// adapters (also `file$:` and `^file:`, anchored).
fn cutadapt_adapter(cur) {
    for p in ["file:", "file$:", "^file:"] {
        if cur.starts_with(p) {
            let r = lib_files::with_suffix(cur.sub_string(p.len()), lib_files::compressed([".fa", ".fasta", ".fna"]));
            r.prefix = p + r.prefix;
            return r;
        }
    }
    [#{value: "file:", desc: "adapters from a FASTA file", suffix: ""}]
}

// The words of `words` (each a string, or `[value, desc]`) with the
// candidates of `r`, a listing of files, when `cur` has no directory.
fn with_words(r, words) {
    if r.prefix == "" {
        for w in words {
            r.candidates.push(if type_of(w) == "array" { #{value: w[0], desc: w[1]} } else { w });
        }
    }
    r
}

// The taxonomic scopes that come with eggnog-mapper (its
// eggnogmapper/annotation/tax_scopes/, 2.1.15), for emapper.py's --tax_scope,
// which also takes a file of tax IDs and names.
fn emapper_tax_scopes() {
    [
        ["auto", "the same as all"], ["auto_broad", "the same as all_broad"], "all", "all_broad", "all_narrow",
        "archaea", "bacteria", "bacteria_broad", "eukaryota", "eukaryota_broad", "prokaryota_broad",
        ["none", "don't filter by taxonomic scope"],
    ]
}

// BUSCO's datasets: those of the list that busco downloads first
// (`file_versions.tsv` in its download directory, `--download_path` or
// `busco_downloads`), with their domain, and those it has downloaded (in
// `lineages` there). For `-l`, also directories, as it takes the path of a
// lineage; for `--download`, also the groups of datasets.
fn busco_datasets(cur, words, download) {
    let base = "busco_downloads";
    for i in 0..words.len() {
        if words[i] == "--download_path" && i + 1 < words.len() {
            base = words[i + 1];
        } else if words[i].starts_with("--download_path=") {
            base = words[i].sub_string(16);
        }
    }
    let r = if download { #{prefix: "", candidates: []} } else { std_kinds::listing(cur, "", true) };
    if r.prefix != "" {
        return r;
    }
    if download {
        for g in ["all", "prokaryota", "eukaryota", "virus"] {
            r.candidates.push(#{value: g, desc: "group of datasets"});
        }
    }
    let got = fs::list_dir(base + "/lineages") ?? [];
    let listed = [];
    for line in (fs::read_file(base + "/file_versions.tsv") ?? "").split("\n") {
        let f = line.split("\t");
        if f.len() == 5 && f[4] == "lineages" {
            r.candidates.push(#{value: f[0], desc: if got.contains(f[0]) { f[3] + ", downloaded" } else { f[3] }});
            listed.push(f[0]);
        }
    }
    for n in got {
        if !listed.contains(n) {
            r.candidates.push(#{value: n, desc: "downloaded"});
        }
    }
    r
}

// The taxonomy groups of an AMRFinder database, for amrfinder's --organism:
// what `amrfinder -l` lists, for the database of -d/--database if the line
// has one.
fn amrfinder_organisms(words) {
    let argv = ["timeout", "5", "amrfinder", "-l"];
    for i in 0..words.len() {
        if (words[i] == "-d" || words[i] == "--database") && i + 1 < words.len() {
            argv += ["-d", words[i + 1]];
        } else if words[i].starts_with("--database=") {
            argv += ["-d", words[i].sub_string(11)];
        }
    }
    let r = sh::capture_cached(300, argv);
    for line in r.out.split("\n") {
        if line.starts_with("Available --organism options: ") {
            return line.sub_string(30).split(", ").filter(|o| o != "");
        }
    }
    []
}

fn kind(name, cur, words) {
    switch name {
        "fasta" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas"])
        ),
        "fastq" => lib_files::with_suffix(cur, lib_files::compressed([".fq", ".fastq"])),
        "sequences" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas", ".fq", ".fastq"])
        ),
        "reads" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".fa", ".fna", ".fasta", ".fq", ".fastq"]) + [".sam", ".bam", ".cram"]
        ),
        "sam" => lib_files::with_suffix(cur, [".sam", ".bam", ".cram"]),
        "bam" => lib_files::with_suffix(cur, [".bam", ".cram"]),
        "sam_header" => lib_files::with_suffix(cur, [".sam", ".hdr", ".txt"]),
        "bam_index" => lib_files::with_suffix(cur, [".bai", ".csi", ".crai"]),
        "vcf" => lib_files::with_suffix(cur, lib_files::compressed([".vcf"]) + [".bcf"]),
        "bed" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".bed", ".bedgraph", ".bdg", ".narrowPeak", ".broadPeak", ".bedpe"])
        ),
        "gff" => lib_files::with_suffix(cur, lib_files::compressed([".gff", ".gff3", ".gtf"])),
        "intervals" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".bed", ".bedgraph", ".bdg", ".gff", ".gff3", ".gtf", ".vcf", ".bedpe"]) + [".bam", ".bcf"]
        ),
        "bwa_index" => union(
            prefixes(cur, [".bwt", ".bwt.2bit.64"]),
            lib_files::with_suffix(cur, lib_files::compressed([".fa", ".fna", ".fasta"]))
        ),
        "bowtie_index" => prefixes(cur, [".1.ebwt", ".1.ebwtl"]),
        "bowtie2_index" => prefixes(cur, [".1.bt2", ".1.bt2l"]),
        "hisat2_index" => prefixes(cur, [".1.ht2", ".1.ht2l"]),
        "minimap2_ref" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".fa", ".fna", ".fasta", ".fq", ".fastq"]) + [".mmi"]
        ),
        "kallisto_index" => lib_files::with_suffix(cur, [".idx", ".kidx"]),
        "blast_db" => blast_db(cur),
        "diamond_db" => lib_files::with_suffix(cur, [".dmnd"]),
        "centrifuge_index" => prefixes(cur, [".1.cf"]),
        "kaiju_db" => lib_files::with_suffix(cur, [".fmi"]),
        "taxdump" => lib_files::with_suffix(cur, [".dmp"]),
        "sai" => lib_files::with_suffix(cur, [".sai"]),
        "msa" => lib_files::with_suffix(
            cur,
            lib_files::compressed([".sto", ".stk", ".sth", ".aln", ".a2m", ".afa", ".pfam", ".phy", ".fa", ".fasta"])
        ),
        "hmm" => lib_files::with_suffix(cur, lib_files::compressed([".hmm"])),
        "ngless" => lib_files::with_suffix(cur, [".ngl"]),
        "genome" => lib_files::with_suffix(cur, [".genome", ".sizes", ".fai", ".len", ".txt"]),
        "bgzipped" => lib_files::with_suffix(cur, [".gz", ".bgz"]),
        "regions" => regions(cur, words),
        "tabix_regions" => tabix_regions(cur, words),
        "vcf_regions" => vcf_regions(cur, words),
        "vcf_samples" => vcf_samples(cur, words),
        "trimmomatic_step" => trimmomatic_step(cur),
        "cutadapt_adapter" => cutadapt_adapter(cur),
        "emapper_tax_scope" => with_words(std_kinds::listing(cur, "", false), emapper_tax_scopes()),
        // the clade of the seed ortholog, or a second scope as in --tax_scope
        "emapper_tax_scope_mode" => with_words(
            std_kinds::listing(cur, "", false),
            [
                ["broadest", "the broadest clade"],
                ["inner_broadest", "the broadest clade in --tax_scope"],
                ["inner_narrowest", "the narrowest clade in --tax_scope"],
                ["narrowest", "the narrowest clade"],
            ] + emapper_tax_scopes()
        ),
        "emapper_gff" => with_words(
            kind("gff", cur, words),
            [["no", "no GFF decoration"], ["yes", "decorate the GFF of gene prediction"]]
        ),
        "busco_lineage" => busco_datasets(cur, words, false),
        "busco_download" => busco_datasets(cur, words, true),
        "amrfinder_organism" => amrfinder_organisms(words),
        _ => throw `unknown kind: ${name}`,
    }
}
