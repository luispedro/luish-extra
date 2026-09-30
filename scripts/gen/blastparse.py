import os
import re, gen

def parse_blast(text):
    """Options of an NCBI C++ toolkit app's -help: [(name, type, [values] or None, desc)]."""
    m = re.search(r"^(?:REQUIRED|OPTIONAL) ARGUMENTS", text, re.M)
    body = text[m.start():] if m else text
    lines = body.splitlines()
    opts = []
    i = 0
    while i < len(lines):
        l = lines[i]
        mm = re.match(r"^ -(\S+)(?: <(.*))?$", l)
        if not mm:
            i += 1
            continue
        name, ty = mm.group(1), mm.group(2)
        if ty is not None:
            while not ty.rstrip().endswith(">") and i + 1 < len(lines):
                i += 1
                ty += " " + lines[i].strip()
            ty = ty.rstrip()[:-1]
        i += 1
        desc = []
        while i < len(lines) and (lines[i].startswith("   ") or lines[i].strip() == "") and not re.match(r"^ \*\*\*", lines[i]):
            if lines[i].strip() == "":
                if desc:
                    break
            elif lines[i].strip().startswith(("Default =", "* ")):
                break
            else:
                desc.append(lines[i].strip())
            i += 1
        d = " ".join(desc)
        vals = None
        if ty:
            pv = re.findall(r"'([^']+)'", ty) if "Permissible" in ty else re.findall(r"`([^']+)'", ty)
            if pv:
                vals = pv
            ty = ty.split(",")[0].strip()
        opts.append((name, ty, vals, d))
    return opts

def sentence(d):
    d = re.sub(r"\s+", " ", d).replace("`", "'").replace("${", "$ {").strip()
    m = re.match(r"^(.*?[a-z0-9)\]])\.(?:\s|$)", d)
    if m: d = m.group(1)
    d = d.rstrip(".")
    if len(d) > 90:
        d = d[:90].rsplit(" ", 1)[0].rstrip(" ,;:(-")
    if d.count("(") > d.count(")"): d = d[:d.rindex("(")].rstrip(" ,;:-")
    if d and d[0].isupper() and not (len(d) > 1 and d[1].isupper()): d = d[0].lower() + d[1:]
    return d

if __name__ == "__main__":
    t = gen.helptext("blast", "blastn -help")
    for o in parse_blast(t)[:200]: print(o)
