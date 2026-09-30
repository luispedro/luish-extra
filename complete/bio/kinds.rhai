// What the arguments and option values of bio commands complete to, named
// `"@extra-complete/bio/kinds:NAME"` in specs: `kind(name, cur, words)`.
import "@std/completion/kinds" as std_kinds;

// Compressions a bio file may have.
fn compressed(suffixes) {
    let out = [];
    for s in suffixes {
        out.push(s);
        for z in [".gz", ".bz2", ".xz", ".zst"] {
            out.push(s + z);
        }
    }
    out
}

// The files of the directory of `cur` whose names end in one of `suffixes`,
// and the directories.
fn with_suffix(cur, suffixes) {
    let r = std_kinds::listing(cur, "", false);
    r.candidates = r.candidates.filter(|c| type_of(c) == "map" || suffixes.some(|s| c.ends_with(s)));
    r
}

// The names of the directory of `cur` without the first of `suffixes` that
// they end with, for files that make up a whole (the index of an aligner
// is `PREFIX.1.bt2`, ...), and the directories. Files of the same prefix
// come once.
fn prefixes(cur, suffixes) {
    let r = std_kinds::listing(cur, "", false);
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
    compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas"]).some(|s| name.ends_with(s))
}

fn is_alignment(name) {
    [".bam", ".cram", ".sam"].some(|s| name.ends_with(s))
}

// The `@SQ` names of an alignment file's header (`samtools view -H`, which
// is quick).
fn header_names(path) {
    let r = sh::capture(`timeout 5 samtools view -H ${sh::quote(path)} 2>/dev/null`);
    let names = [];
    for l in r.out.split("\n") {
        if l.starts_with("@SQ\t") {
            for f in l.split("\t") {
                if f.starts_with("SN:") {
                    names.push(f.sub_string(3));
                }
            }
        }
    }
    names
}

// Reference names, for a region: from the header of the first alignment
// file in the line, else from the `.fai` next to the first FASTA file.
fn regions(words) {
    for w in words {
        if is_alignment(w) && fs::is_file(w) {
            return header_names(w);
        }
    }
    for w in words {
        if is_fasta(w) && fs::is_file(w + ".fai") {
            let fai = fs::read_file(w + ".fai") ?? "";
            return fai.split("\n").filter(|l| l != "").map(|l| l.split("\t")[0]);
        }
    }
    []
}

// The sequences of the first tabix-indexed file in the line (`tabix -l`).
fn tabix_regions(words) {
    for w in words {
        if (w.ends_with(".gz") || w.ends_with(".bgz")) && fs::is_file(w) {
            let r = sh::capture(`timeout 5 tabix -l ${sh::quote(w)} 2>/dev/null`);
            return r.out.split("\n").filter(|l| l != "");
        }
    }
    []
}

fn is_vcf(name) {
    compressed([".vcf"]).some(|s| name.ends_with(s)) || name.ends_with(".bcf")
}

// The sequences of the first VCF/BCF in the line: from its index
// (`bcftools index -s`, name, length and count), else `tabix -l`.
fn vcf_regions(words) {
    for w in words {
        if is_vcf(w) && fs::is_file(w) {
            let r = sh::capture(`timeout 5 bcftools index -s ${sh::quote(w)} 2>/dev/null`);
            let names = r.out.split("\n").filter(|l| l != "").map(|l| l.split("\t")[0]);
            if !names.is_empty() {
                return names;
            }
            let r = sh::capture(`timeout 5 tabix -l ${sh::quote(w)} 2>/dev/null`);
            return r.out.split("\n").filter(|l| l != "");
        }
    }
    []
}

// The samples of the first VCF/BCF in the line (`bcftools query -l`).
fn vcf_samples(words) {
    for w in words {
        if is_vcf(w) && fs::is_file(w) {
            let r = sh::capture(`timeout 5 bcftools query -l ${sh::quote(w)} 2>/dev/null`);
            return r.out.split("\n").filter(|l| l != "");
        }
    }
    []
}

// Trimmomatic's steps (`SLIDINGWINDOW:4:20`), after its input and output
// files: the steps and the files. After `ILLUMINACLIP:`, a FASTA of adapters
// or one of those that come with Trimmomatic (which it finds by name), then
// `:` for the step's numbers.
fn trimmomatic_step(cur) {
    let fasta = compressed([".fa", ".fasta", ".fna"]);
    if cur.starts_with("ILLUMINACLIP:") {
        let rest = cur.sub_string(13);
        if rest.contains(":") {
            return [];
        }
        let r = std_kinds::listing(rest, "ILLUMINACLIP:", false);
        let out = [];
        for c in r.candidates {
            if type_of(c) == "map" {
                out.push(c);
            } else if fasta.some(|s| c.ends_with(s)) {
                out.push(#{value: c, suffix: ":"});
            }
        }
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
            let r = std_kinds::listing(cur.sub_string(p.len()), p, false);
            let fasta = compressed([".fa", ".fasta", ".fna"]);
            r.candidates = r.candidates.filter(|c| type_of(c) == "map" || fasta.some(|s| c.ends_with(s)));
            return r;
        }
    }
    [#{value: "file:", desc: "adapters from a FASTA file", suffix: ""}]
}

fn kind(name, cur, words) {
    switch name {
        "fasta" => with_suffix(cur, compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas"])),
        "fastq" => with_suffix(cur, compressed([".fq", ".fastq"])),
        "sequences" => with_suffix(cur, compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas", ".fq", ".fastq"])),
        "reads" => with_suffix(cur, compressed([".fa", ".fna", ".fasta", ".fq", ".fastq"]) + [".sam", ".bam", ".cram"]),
        "sam" => with_suffix(cur, [".sam", ".bam", ".cram"]),
        "bam" => with_suffix(cur, [".bam", ".cram"]),
        "sam_header" => with_suffix(cur, [".sam", ".hdr", ".txt"]),
        "bam_index" => with_suffix(cur, [".bai", ".csi", ".crai"]),
        "vcf" => with_suffix(cur, compressed([".vcf"]) + [".bcf"]),
        "bed" => with_suffix(cur, compressed([".bed", ".bedgraph", ".bdg", ".narrowPeak", ".broadPeak", ".bedpe"])),
        "gff" => with_suffix(cur, compressed([".gff", ".gff3", ".gtf"])),
        "intervals" => with_suffix(
            cur,
            compressed([".bed", ".bedgraph", ".bdg", ".gff", ".gff3", ".gtf", ".vcf", ".bedpe"]) + [".bam", ".bcf"]
        ),
        "bwa_index" => union(prefixes(cur, [".bwt", ".bwt.2bit.64"]), with_suffix(cur, compressed([".fa", ".fna", ".fasta"]))),
        "bowtie_index" => prefixes(cur, [".1.ebwt", ".1.ebwtl"]),
        "bowtie2_index" => prefixes(cur, [".1.bt2", ".1.bt2l"]),
        "hisat2_index" => prefixes(cur, [".1.ht2", ".1.ht2l"]),
        "minimap2_ref" => with_suffix(cur, compressed([".fa", ".fna", ".fasta", ".fq", ".fastq"]) + [".mmi"]),
        "kallisto_index" => with_suffix(cur, [".idx", ".kidx"]),
        "blast_db" => blast_db(cur),
        "diamond_db" => with_suffix(cur, [".dmnd"]),
        "sai" => with_suffix(cur, [".sai"]),
        "msa" => with_suffix(cur, compressed([".sto", ".stk", ".sth", ".aln", ".a2m", ".afa", ".pfam", ".phy", ".fa", ".fasta"])),
        "hmm" => with_suffix(cur, compressed([".hmm"])),
        "ngless" => with_suffix(cur, [".ngl"]),
        "genome" => with_suffix(cur, [".genome", ".sizes", ".fai", ".len", ".txt"]),
        "bgzipped" => with_suffix(cur, [".gz", ".bgz"]),
        "regions" => regions(words),
        "tabix_regions" => tabix_regions(words),
        "vcf_regions" => vcf_regions(words),
        "vcf_samples" => vcf_samples(words),
        "trimmomatic_step" => trimmomatic_step(cur),
        "cutadapt_adapter" => cutadapt_adapter(cur),
        _ => throw `unknown kind: ${name}`,
    }
}
