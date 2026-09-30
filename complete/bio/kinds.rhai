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

fn kind(name, cur, words) {
    switch name {
        "fasta" => with_suffix(cur, compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas"])),
        "fastq" => with_suffix(cur, compressed([".fq", ".fastq"])),
        "sequences" => with_suffix(cur, compressed([".fa", ".fna", ".fasta", ".faa", ".ffn", ".fas", ".fq", ".fastq"])),
        "sam" => with_suffix(cur, [".sam", ".bam", ".cram"]),
        "bam" => with_suffix(cur, [".bam", ".cram"]),
        "bam_index" => with_suffix(cur, [".bai", ".csi", ".crai"]),
        "vcf" => with_suffix(cur, compressed([".vcf"]) + [".bcf"]),
        "bed" => with_suffix(cur, compressed([".bed", ".bedgraph", ".bdg", ".narrowPeak", ".broadPeak", ".bedpe"])),
        "gff" => with_suffix(cur, compressed([".gff", ".gff3", ".gtf"])),
        "intervals" => with_suffix(
            cur,
            compressed([".bed", ".bedgraph", ".bdg", ".gff", ".gff3", ".gtf", ".vcf", ".bedpe"]) + [".bam", ".bcf"]
        ),
        "hmm" => with_suffix(cur, compressed([".hmm"])),
        "ngless" => with_suffix(cur, [".ngl"]),
        "genome" => with_suffix(cur, [".genome", ".sizes", ".fai", ".len", ".txt"]),
        "bgzipped" => with_suffix(cur, [".gz", ".bgz"]),
        "regions" => regions(words),
        "tabix_regions" => tabix_regions(words),
        _ => throw `unknown kind: ${name}`,
    }
}
