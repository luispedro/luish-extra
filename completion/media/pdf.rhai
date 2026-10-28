// Poppler's tools (poppler 26.10.0): pdftotext, pdfinfo, pdftoppm, pdfimages, pdfunite, pdfseparate, pdffonts,
// pdftocairo, pdftohtml, pdftops, pdfdetach, pdfattach and pdfsig, from their `-h` (and the values of some options
// from the manual pages or the source). Their long options start with one dash, and take their value as the next word.
import "../extra-lib/files" as lib_files;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("pdf:") + name }

// The options of the tools that read a page range, an encrypted file, or print their version and help.
fn pages_opts() {
    `
        -f PAGE                 first page
        -l PAGE                 last page
    `
}

fn password_opts() {
    `
        -opw PASSWORD           owner password (for encrypted files)
        -upw PASSWORD           user password (for encrypted files)
    `
}

fn common_opts() {
    `
        -v                      print copyright and version info
        -h, -help, --help, -?   print usage information
    `
}

fn common_values() {
    #{"-f": "none", "-l": "none", "-opw": "none", "-upw": "none"}
}

// The paper options of pdftocairo and pdftops.
fn paper_opts() {
    `
        -paper SIZE             paper size
        -paperw POINTS          paper width, in points
        -paperh POINTS          paper height, in points
        -nocrop                 don't crop pages to the crop box
        -expand                 expand pages smaller than the paper
        -noshrink               don't shrink pages larger than the paper
        -nocenter               don't centre pages smaller than the paper
        -duplex                 enable duplex printing
    `
}

fn paper_values() {
    #{
        "-paper": [#{value: "letter"}, #{value: "legal"}, #{value: "A4"}, #{value: "A3"},
                   #{value: "match", desc: "the size of each page"}],
        "-paperw": "none",
        "-paperh": "none",
    }
}

// pdftotext [OPTIONS] PDF [TEXT]: the text file `-` is standard output.
fn pdftotext() {
    let v = common_values();
    v.mixin(#{
        "-r": "none", "-x": "none", "-y": "none", "-W": "none", "-H": "none", "-fixed": "none", "-colspacing": "none",
        "-remove-hyphens": [#{value: "none", desc: "keep end-of-line hyphens"},
                            #{value: "soft", desc: "remove soft hyphens only"},
                            #{value: "all", desc: "remove all end-of-line hyphens (default)"}],
        "-enc": k("encodings"),
        "-eol": ["unix", "dos", "mac"],
    });
    #{
        opts: pages_opts() + `
            -r DPI                  resolution, in DPI (default 72)
            -x X                    x-coordinate of the crop area's top left corner
            -y Y                    y-coordinate of the crop area's top left corner
            -W WIDTH                width of the crop area in pixels
            -H HEIGHT               height of the crop area in pixels
            -layout                 keep the original physical layout
            -fixed PITCH            assume fixed-pitch (or tabular) text
            -raw                    keep strings in content stream order
            -remove-hyphens MODE    end-of-line hyphens to remove
            -nodiag                 discard diagonal text
            -htmlmeta               write a simple HTML file, with the meta information
            -tsv                    write a TSV file, with the bounding boxes
            -enc ENCODING           output text encoding
            -listenc                list the available encodings
            -eol EOL                end-of-line convention
            -nopgbrk                don't insert page breaks between pages
            -urls                   print the URL of each link next to its text
            -bbox                   write each word's bounding box and the page size to HTML
            -bbox-layout            like -bbox, with the layout's bounding boxes
            -cropbox                use the crop box rather than the media box
            -colspacing FRACTION    spacing after a word that starts a new column (of the font size, default 0.7)
            -q                      don't print any messages or errors
        ` + password_opts() + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdfinfo [OPTIONS] PDF
fn pdfinfo() {
    let v = common_values();
    v.mixin(#{"-enc": k("encodings")});
    #{
        opts: pages_opts() + `
            -box                    print the page bounding boxes
            -meta                   print the document metadata (XML)
            -custom                 print both custom and standard metadata
            -js                     print all JavaScript in the PDF
            -struct                 print the logical document structure (tagged files)
            -struct-text            print the text along with the document structure (tagged files)
            -isodates               print the dates in ISO-8601 format
            -rawdates               print the undecoded date strings
            -dests                  print all named destinations
            -url                    print all URLs inside PDF objects
            -enc ENCODING           output text encoding
            -listenc                list the available encodings
        ` + password_opts() + common_opts(),
        values: v,
        args: [k("pdf"), "none"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdftoppm [OPTIONS] [PDF [PREFIX]]
fn pdftoppm() {
    let v = common_values();
    let yes_no = ["yes", "no"];
    v.mixin(#{
        "-r": "none", "-rx": "none", "-ry": "none",
        "-scale-to": "none", "-scale-to-x": "none", "-scale-to-y": "none",
        "-x": "none", "-y": "none", "-W": "none", "-H": "none", "-sz": "none",
        "-displayprofile": k("icc"), "-defaultgrayprofile": k("icc"), "-defaultrgbprofile": k("icc"),
        "-defaultcmykprofile": k("icc"),
        "-sep": "none",
        "-jpegopt": k("jpegopt"),
        "-tiffcompression": ["none", "packbits", "jpeg", "lzw", "deflate"],
        "-freetype": yes_no,
        "-thinlinemode": ["none", "solid", "shape"],
        "-aa": yes_no,
        "-aaVector": yes_no,
    });
    #{
        opts: pages_opts() + `
            -o                      only odd pages
            -e                      only even pages
            -singlefile             write only the first page, without digits
            -scale-dimension-before-rotation  for a rotated PDF, resize before the rotation
            -r DPI                  resolution, in DPI (default 150)
            -rx DPI                 X resolution, in DPI (default 150)
            -ry DPI                 Y resolution, in DPI (default 150)
            -scale-to PIXELS        scale each page to fit in a square of PIXELS
            -scale-to-x PIXELS      scale each page to PIXELS wide
            -scale-to-y PIXELS      scale each page to PIXELS high
            -x X                    x-coordinate of the crop area's top left corner
            -y Y                    y-coordinate of the crop area's top left corner
            -W WIDTH                width of the crop area in pixels
            -H HEIGHT               height of the crop area in pixels
            -sz SIZE                size of a crop square in pixels (sets -W and -H)
            -cropbox                use the crop box rather than the media box
            -hide-annotations       don't show annotations
            -mono                   write a monochrome PBM file
            -gray                   write a grayscale PGM file
            -displayprofile FILE    ICC colour profile of the display
            -defaultgrayprofile FILE  ICC colour profile for the DefaultGray colour space
            -defaultrgbprofile FILE   ICC colour profile for the DefaultRGB colour space
            -defaultcmykprofile FILE  ICC colour profile for the DefaultCMYK colour space
            -sep CHAR               separator between the name and the page number (default -)
            -forcenum               add the page number even with a single page
            -png                    write a PNG file
            -jpeg                   write a JPEG file
            -jpegcmyk               write a CMYK JPEG file
            -jpegopt OPTIONS        JPEG options (OPT=VALUE,...)
            -overprint              enable overprint
            -tiff                   write a TIFF file
            -tiffcompression TYPE   TIFF compression
            -freetype YES|NO        the FreeType font rasterizer
            -thinlinemode MODE      thin line mode (default none)
            -aa YES|NO              font anti-aliasing
            -aaVector YES|NO        vector anti-aliasing
        ` + password_opts() + `
            -q                      don't print any messages or errors
            -progress               print progress information
        ` + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdfimages [OPTIONS] PDF ROOT
fn pdfimages() {
    let v = common_values();
    v.mixin(#{"-min-height": "none", "-min-width": "none"});
    #{
        opts: pages_opts() + `
            -png                    write PNG files by default
            -tiff                   write TIFF files by default
            -j                      write JPEG images as JPEG files
            -jp2                    write JPEG2000 images as JP2 files
            -jbig2                  write JBIG2 images as JBIG2 files
            -ccitt                  write CCITT images as CCITT files
            -all                    the same as -png -tiff -j -jp2 -jbig2 -ccitt
            -list                   list the images instead of saving them
            -p                      include page numbers in the file names
            -print-filenames        print the names of the image files
            -min-height PIXELS      ignore images less high
            -min-width PIXELS       ignore images less wide
            -q                      don't print any messages or errors
        ` + password_opts() + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdfunite [OPTIONS] PDF... OUTPUT
fn pdfunite() {
    #{
        opts: common_opts(),
        args: [k("pdf")],
        single_dash: true,
    }
}

// pdfseparate [OPTIONS] PDF PATTERN: the pattern has a `%d`, the page number.
fn pdfseparate() {
    #{
        opts: `
            -f PAGE                 first page to extract
            -l PAGE                 last page to extract
        ` + common_opts(),
        values: #{"-f": "none", "-l": "none"},
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdffonts [OPTIONS] PDF
fn pdffonts() {
    #{
        opts: pages_opts() + `
            -subst                  show font substitutions
        ` + password_opts() + common_opts(),
        values: common_values(),
        args: [k("pdf"), "none"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdftocairo [OPTIONS] PDF [OUTPUT]: the output `-` is standard output.
fn pdftocairo() {
    let v = common_values();
    v.mixin(paper_values());
    v.mixin(#{
        "-jpegopt": k("jpegopt"),
        "-tiffcompression": ["none", "packbits", "jpeg", "lzw", "deflate"],
        "-r": "none", "-rx": "none", "-ry": "none",
        "-scale-to": "none", "-scale-to-x": "none", "-scale-to-y": "none",
        "-x": "none", "-y": "none", "-W": "none", "-H": "none", "-sz": "none",
        "-antialias": [#{value: "default", desc: "the target device's (default)"}, #{value: "none", desc: "disabled"},
                       #{value: "gray", desc: "shades of gray"}, #{value: "subpixel", desc: "using the LCD's subpixels"},
                       #{value: "fast", desc: "prefer speed"}, #{value: "good", desc: "balance quality and speed"},
                       #{value: "best", desc: "prefer quality"}],
        "-icc": k("icc"),
    });
    #{
        opts: `
            -png                    write a PNG file
            -jpeg                   write a JPEG file
            -jpegopt OPTIONS        JPEG options (OPT=VALUE,...)
            -tiff                   write a TIFF file
            -tiffcompression TYPE   TIFF compression
            -ps                     write a PostScript file
            -eps                    write an Encapsulated PostScript file
            -pdf                    write a PDF file
            -svg                    write an SVG file
        ` + pages_opts() + `
            -o                      only odd pages
            -e                      only even pages
            -singlefile             write only the first page, without digits
            -r PPI                  resolution, in PPI (default 150)
            -rx PPI                 X resolution, in PPI (default 150)
            -ry PPI                 Y resolution, in PPI (default 150)
            -scale-to PIXELS        scale each page to fit in a square of PIXELS
            -scale-to-x PIXELS      scale each page to PIXELS wide
            -scale-to-y PIXELS      scale each page to PIXELS high
            -x X                    x-coordinate of the crop area's top left corner
            -y Y                    y-coordinate of the crop area's top left corner
            -W WIDTH                width of the crop area in pixels
            -H HEIGHT               height of the crop area in pixels
            -sz SIZE                size of a crop square in pixels (sets -W and -H)
            -cropbox                use the crop box rather than the media box
            -mono                   write a monochrome image (PNG, JPEG)
            -gray                   write a grayscale image (PNG, JPEG)
            -transp                 a transparent background instead of white (PNG)
            -antialias MODE         cairo's antialiasing
            -icc FILE               ICC colour profile
            -level2                 write Level 2 PostScript (PS, EPS)
            -level3                 write Level 3 PostScript (PS, EPS)
            -origpagesizes          keep the original page sizes (PS, PDF, SVG)
        ` + paper_opts() + `
            -struct                 enable the logical document structure
        ` + password_opts() + `
            -q                      don't print any messages or errors
        ` + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdftohtml [OPTIONS] PDF [HTML [XML]]
fn pdftohtml() {
    let v = common_values();
    v.mixin(#{"-zoom": "none", "-enc": k("encodings"), "-fmt": ["png", "jpg"], "-wbt": "none"});
    #{
        opts: pages_opts() + `
            -q                      don't print any messages or errors
            -p                      replace links to .pdf by links to .html
            -c                      write a complex document
            -s                      write a single document with all the pages
            -dataurls               data URLs instead of external images
            -i                      ignore images
            -noframes               write no frames
            -stdout                 write to standard output
            -zoom FACTOR            zoom (default 1.5)
            -xml                    write XML, for post-processing
            -noroundcoord           don't round coordinates (XML only)
            -hidden                 write hidden text
            -nomerge                don't merge paragraphs
            -enc ENCODING           output text encoding
            -fmt FORMAT             image format of the Splash output
            -nodrm                  override the document's DRM settings
            -wbt PERCENT            word break threshold (default 10)
            -fontfullname           write the fonts' full names
        ` + password_opts() + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdftops [OPTIONS] PDF [PS]: the output `-` is standard output.
fn pdftops() {
    let v = common_values();
    v.mixin(paper_values());
    v.mixin(#{
        "-r": "none",
        "-aaRaster": ["yes", "no"],
        "-rasterize": ["always", "never", "whenneeded"],
        "-processcolorformat": ["MONO8", "RGB8", "CMYK8"],
        "-processcolorprofile": k("icc"), "-defaultgrayprofile": k("icc"), "-defaultrgbprofile": k("icc"),
        "-defaultcmykprofile": k("icc"),
    });
    #{
        opts: pages_opts() + `
            -level1                 write Level 1 PostScript
            -level1sep              write Level 1 separable PostScript
            -level2                 write Level 2 PostScript
            -level2sep              write Level 2 separable PostScript
            -level3                 write Level 3 PostScript
            -level3sep              write Level 3 separable PostScript
            -origpagesizes          keep the original page sizes
            -eps                    write Encapsulated PostScript
            -form                   write a PostScript form
            -opi                    write OPI comments
            -r DPI                  resolution of rasterization, in DPI (default 300)
            -binary                 write binary data in Level 1 PostScript
            -noembt1                don't embed Type 1 fonts
            -noembtt                don't embed TrueType fonts
            -noembcidps             don't embed CID PostScript fonts
            -noembcidtt             don't embed CID TrueType fonts
            -passfonts              don't substitute missing fonts
            -aaRaster YES|NO        anti-aliasing on rasterization
            -rasterize WHEN         when to rasterize
            -processcolorformat FORMAT  colour format of rasterization and transparency reduction
            -processcolorprofile FILE   ICC colour profile of rasterization and transparency reduction
            -defaultgrayprofile FILE    ICC colour profile for the DefaultGray colour space
            -defaultrgbprofile FILE     ICC colour profile for the DefaultRGB colour space
            -defaultcmykprofile FILE    ICC colour profile for the DefaultCMYK colour space
            -optimizecolorspace     convert gray RGB images to the gray colour space
            -passlevel1customcolor  pass custom colours in -level1sep
            -preload                preload images and forms
        ` + paper_opts() + password_opts() + `
            -overprint              emulate overprint during rasterization
            -q                      don't print any messages or errors
        ` + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdfdetach [OPTIONS] PDF: -save and -savefile name a file embedded in the PDF on the line.
fn pdfdetach() {
    let v = common_values();
    v.mixin(#{"-save": k("embedded_numbers"), "-savefile": k("embedded"), "-o": "files", "-enc": k("encodings")});
    #{
        opts: `
            -list                   list the embedded files
            -save NUMBER            save an embedded file, by number
            -savefile NAME          save an embedded file, by name
            -saveall                save all the embedded files
            -o PATH                 file name of the saved file (directory, with -saveall)
            -enc ENCODING           output text encoding
        ` + password_opts() + common_opts(),
        values: v,
        args: [k("pdf"), "none"],
        single_dash: true,
        strict_eq: true,
    }
}

// pdfattach [OPTIONS] PDF FILE OUTPUT
fn pdfattach() {
    #{
        opts: `
            -replace                replace an embedded file of the same name
        ` + common_opts(),
        args: [k("pdf"), "files", k("pdf"), "none"],
        single_dash: true,
    }
}

// pdfsig [OPTIONS] PDF [OUTPUT]: the backends are those of the source's `typeFromString`, and SHA256 is the only
// digest that signing takes.
fn pdfsig() {
    let v = common_values();
    v.mixin(#{
        "-nssdir": "dirs", "-nss-pwd": "none", "-assert-signer": "files", "-new-signature-field-name": "none",
        "-sign": "none",
        "-backend": [#{value: "NSS", desc: "Mozilla's NSS"}, #{value: "GPG", desc: "GnuPG (GPGME)"}],
        "-nick": "none", "-kpw": "none", "-digest": ["SHA256"], "-reason": "none",
    });
    #{
        opts: `
            -nssdir DIR             directory of the libnss3 database
            -nss-pwd PASSWORD       password of the NSS database
            -nocert                 don't validate certificates
            -no-ocsp                don't check revocation online (OCSP)
            -no-appearance          don't add appearance information when signing existing fields
            -aia                    fetch certificates through Authority Information Access
            -assert-signer FPR|FILE check that the whole document is signed by this key (GnuPG)
            -dump                   dump all signatures into the current directory
            -add-signature          add a new signature to the document
            -new-signature-field-name NAME  field name of the new signature
            -sign FIELD             sign in this signature field (name or number)
            -etsi-cades-b           an ETSI.CAdES.detached signature (type B)
            -backend BACKEND        backend for signing and verification
            -enable-pgp             enable PGP signatures (GnuPG)
            -nick NICK              the certificate to sign with (nickname or fingerprint)
            -kpw PASSWORD           password of the signing key
            -digest ALGORITHM       digest algorithm (default SHA256)
            -reason REASON          reason for signing
            -list-nicks             list the nicknames in the NSS database
            -list-backends          list the signature backends
        ` + password_opts() + common_opts(),
        values: v,
        args: [k("pdf"), "files"],
        single_dash: true,
        strict_eq: true,
    }
}

fn spec(cmd) {
    switch cmd {
        "pdftotext" => pdftotext(),
        "pdfinfo" => pdfinfo(),
        "pdftoppm" => pdftoppm(),
        "pdfimages" => pdfimages(),
        "pdfunite" => pdfunite(),
        "pdfseparate" => pdfseparate(),
        "pdffonts" => pdffonts(),
        "pdftocairo" => pdftocairo(),
        "pdftohtml" => pdftohtml(),
        "pdftops" => pdftops(),
        "pdfdetach" => pdfdetach(),
        "pdfattach" => pdfattach(),
        "pdfsig" => pdfsig(),
        _ => #{},
    }
}

// The JPEG options of `-jpegopt`, after the last comma: the names, or the values of the one being written.
fn jpegopt(cur) {
    let comma = cur.index_of(",");
    let start = 0;
    while comma >= 0 {
        start = comma + 1;
        comma = cur.index_of(",", start);
    }
    let prefix = cur.sub_string(0, start);
    let word = cur.sub_string(start);
    let eq = word.index_of("=");
    if eq >= 0 {
        let name = word.sub_string(0, eq);
        if name == "progressive" || name == "optimize" {
            return #{prefix: prefix + name + "=", candidates: ["y", "n"].map(|c| #{value: c, suffix: ""})};
        }
        return [];
    }
    let given = prefix.split(",").map(|o| o.split("=")[0]);
    let out = [];
    for o in [["quality", "JPEG quality (0 to 100)"], ["progressive", "progressive JPEG (y, n)"],
              ["optimize", "optimize the Huffman tables (y, n)"]] {
        if !given.contains(o[0]) {
            out.push(#{value: o[0] + "=", desc: o[1], suffix: ""});
        }
    }
    #{prefix: prefix, candidates: out}
}

// The files embedded in the PDF on pdfdetach's line, as `pdfdetach -list` prints them (`N: NAME`), as [number,
// name]: the PDF is the first word that is neither an option nor an option's value.
fn embedded(words) {
    let pdf = ();
    let j = 1;
    while j < words.len() - 1 {
        let w = words[j];
        if ["-save", "-savefile", "-o", "-enc", "-opw", "-upw"].contains(w) {
            j += 1;
        } else if !w.starts_with("-") {
            pdf = w;
            break;
        }
        j += 1;
    }
    if pdf == () {
        return [];
    }
    let r = sh::capture_cached(30, ["pdfdetach", "-list", pdf]);
    let out = [];
    if r.status == 0 {
        for line in r.out.split("\n") {
            let colon = line.index_of(": ");
            if colon > 0 {
                out.push([line.sub_string(0, colon), line.sub_string(colon + 2)]);
            }
        }
    }
    out
}

fn kind(name, cur, words) {
    switch name {
        "pdf" => lib_files::with_suffix(cur, [".pdf", ".PDF"]),
        "icc" => lib_files::with_suffix(cur, [".icc", ".icm", ".ICC", ".ICM"]),
        // pdfinfo's encodings are pdftotext's: both list those of Poppler's GlobalParams.
        "encodings" => {
            let r = sh::capture_cached(300, ["pdftotext", "-listenc"]);
            if r.status != 0 { [] } else { r.out.split("\n").filter(|l| l != "" && !l.starts_with("Available")) }
        }
        "jpegopt" => jpegopt(cur),
        "embedded" => embedded(words).map(|f| f[1]),
        "embedded_numbers" => embedded(words).map(|f| #{value: f[0], desc: f[1]}),
        _ => [],
    }
}
