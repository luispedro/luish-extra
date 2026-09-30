// Programs that complete themselves in their own way, which is asked for the candidates.

// The AWS CLI: `aws_completer` reads the line in COMP_LINE, up to COMP_POINT, and prints the candidates, one per
// line, whole (`--recursive`, not the rest of it). Nothing means that the word is a filename or a value to type.
fn aws(words, i) {
    let line = "";
    for j in 0..i {
        line += words[j] + " ";
    }
    line += words[i];
    let r = sh::capture("COMP_LINE=" + sh::quote(line) + " COMP_POINT=" + line.len() + " aws_completer 2>/dev/null");
    if r.status != 0 {
        return ();
    }
    let out = r.out.split("\n").filter(|l| l != "");
    if out.is_empty() { () } else { out }
}
