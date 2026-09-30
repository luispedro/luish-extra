// pandoc 3.11, from `pandoc --help`, with the descriptions of its man page. The formats are asked of the
// installed pandoc (`--list-input-formats`), so that they follow the version in use.

fn spec() {
    #{
        opts: `
            -f, -r, --from, --read FORMAT        specify input format
            -t, -w, --to, --write FORMAT         specify output format
            -o, --output FILE                    write output to FILE instead of stdout
            --data-dir DIRECTORY                 specify the user data directory to search for pandoc data files
            -M, --metadata KEY[=VALUE]           set the metadata field KEY to the value VAL
            --metadata-file FILE                 read metadata from the supplied YAML (or JSON) file
            -d, --defaults FILE                  specify a set of default option settings
            --file-scope                         parse each file individually before combining for multifile documents
            --sandbox                            run pandoc in a sandbox, limiting IO operations in readers and writers
            -s, --standalone                     produce output with an appropriate header and footer
            --template FILE                      use the specified file as a custom template for the generated document
            -V, --variable KEY[=VALUE]           set the template variable KEY to the string value VAL when rendering
            --variable-json KEY[:JSON]           set the template variable KEY to the value specified by a JSON string
            --wrap VALUE                         determine how text is wrapped in the output
            --ascii                              use only ASCII characters in output
            --toc, --table-of-contents           include an automatically generated table of contents
            --toc-depth NUMBER                   specify the number of section levels to include in the table of contents
            --lof, --list-of-figures             include an automatically generated list of figures
            --lot, --list-of-tables              include an automatically generated list of tables
            -N, --number-sections                number section headings in LaTeX, ConTeXt, HTML, Docx, ms, or EPUB
            --number-offset NUMBERS              offsets for section heading numbers
            --top-level-division VALUE           treat top-level headings as the given division type in LaTeX, ConTeXt
            --extract-media PATH                 extract images and other media contained in or linked from the source
            --resource-path SEARCHPATH           list of paths to search for images and other resources
            -H, --include-in-header FILE         include contents of FILE, verbatim, at the end of the header
            -B, --include-before-body FILE       include contents of FILE, verbatim, at the beginning of the document
            -A, --include-after-body FILE        include contents of FILE, verbatim, at the end of the document body
            --no-highlight                       deprecated, use --syntax-highlighting=none instead
            --highlight-style STYLE              deprecated, use --syntax-highlighting=STYLE|FILE instead
            --syntax-definition FILE             instructs pandoc to load a KDE XML syntax definition file, which will
            --syntax-highlighting VALUE          the method to use for code syntax highlighting
            --dpi NUMBER                         specify the default dpi (dots per inch) value for conversion from
            --eol VALUE                          manually specify line endings: crlf (Windows), lf (macOS/Linux/UNIX)
            --columns NUMBER                     specify length of lines in characters
            -p, --preserve-tabs                  preserve tabs instead of converting them to spaces.
            --tab-stop NUMBER                    specify the number of spaces per tab (default is 4)
            --pdf-engine PROGRAM                 use the specified engine when producing PDF output
            --pdf-engine-opt STRING              use the given string as a command-line argument to the pdf-engine
            --reference-doc FILE                 use the specified file as a style reference in producing a docx or ODT
            --self-contained                     deprecated synonym for --embed-resources --standalone
            --embed-resources                    produce a standalone HTML file with no external dependencies, using
            --link-images                        include links to images instead of embedding the images in ODT.
            --request-header NAME=VALUE          set the request header NAME to the value VAL when making HTTP requests
            --no-check-certificate               disable the certificate verification to allow access to unsecure HTTP
            --abbreviations FILE                 specifies a custom abbreviations file, with abbreviations one to a line
            --typst-input KEY=VALUE              set a parameter value that will be made available to the typst parser
            --indented-code-classes STRING       specify classes to use for indented code blocks\
            --default-image-extension extension  specify a default extension to use when image paths/URLs have no
            -F, --filter PROGRAM                 specify an executable to be used as a filter transforming the pandoc
            -L, --lua-filter SCRIPTPATH          transform the document in a similar fashion as JSON filters
            --shift-heading-level-by NUMBER      shift heading levels by a positive or negative integer
            --base-header-level NUMBER           deprecated
            --track-changes VALUE                specifies what to do with insertions, deletions, and comments produced
            --strip-comments                     strip out HTML comments in the Markdown or Textile source, rather than
            --reference-links                    use reference-style links, rather than inline links, in writing
            --reference-location VALUE           specify whether footnotes (and references, if reference-links is set)
            --figure-caption-position VALUE      specify whether figure captions go above or below figures
            --table-caption-position VALUE       specify whether table captions go above or below tables
            --markdown-headings VALUE            specify whether to use ATX-style (#-prefixed) or Setext-style
            --list-tables                        render tables as list tables in RST output
            --listings                           deprecated, use --syntax-highlighting=idiomatic or
            -i, --incremental                    make list items in slide shows display incrementally (one by one)
            --slide-level NUMBER                 specifies that headings with the specified level create slides
            --section-divs                       wrap sections in <section> tags (or <div> tags for html4), and attach
            --html-q-tags                        use <q> tags for quotes in HTML.
            --email-obfuscation VALUE            specify a method for obfuscating mailto: links in HTML documents. none
            --id-prefix STRING                   specify a prefix to be added to all identifiers and internal links in
            -T, --title-prefix STRING            specify STRING as a prefix at the beginning of the title that appears
            -c, --css URL                        link to a CSS style sheet
            --epub-subdirectory DIRNAME          specify the subdirectory in the OCF container that is to hold the
            --epub-cover-image FILE              use the specified image as the EPUB cover
            --epub-title-page                    determines whether a the title page is included in the EPUB
            --epub-metadata FILE                 look in the specified XML file for metadata for the EPUB
            --epub-embed-font FILE               embed the specified font in the EPUB
            --split-level NUMBER                 specify the heading level at which to split an EPUB or chunked HTML
            --chunk-template PATHTEMPLATE        specify a template for the filenames in a chunkedhtml document
            --epub-chapter-level NUMBER          deprecated synonym for --split-level
            --ipynb-output VALUE                 determines how ipynb output cells are treated. all means that all of
            -C, --citeproc                       process the citations in the file, replacing them with rendered
            --bibliography FILE                  set the bibliography field in the document\
            --csl FILE                           set the csl field in the document\
            --citation-abbreviations FILE        set the citation-abbreviations field in the document\
            --natbib                             use natbib for citations in LaTeX output
            --biblatex                           use biblatex for citations in LaTeX output
            --math-method METHOD                 specify the method used to display TeX math
            --mathml                             deprecated
            --webtex[=URL]                       deprecated
            --mathjax[=URL]                      deprecated
            --katex[=URL]                        deprecated
            --gladtex                            deprecated
            --trace                              print diagnostic output tracing parser progress to stderr
            --dump-args                          print information about command-line arguments to stdout, then exit
            --ignore-args                        ignore command-line arguments (for use in wrapper scripts)
            --verbose                            give verbose debugging output
            --quiet                              suppress warning messages
            --fail-if-warnings                   exit with error status if there are any warnings
            --log FILE                           write log messages in machine-readable JSON format to FILE
            --completion SHELL                   generate a shell completion script for the given shell, one of bash
            --bash-completion                    deprecated
            --list-input-formats                 list supported input formats, one per line
            --list-output-formats                list supported output formats, one per line
            --list-extensions[=FORMAT]           list supported extensions for FORMAT, one per line, preceded by a + or
            --list-highlight-languages           list supported languages for syntax highlighting, one per line
            --list-highlight-styles              list supported styles for syntax highlighting, one per line
            -D, --print-default-template FORMAT  print the system default template for an output FORMAT.
            --print-default-data-file FILE       print a system default data file
            --print-highlight-style STYLE        prints a JSON version of a highlighting style, which can be modified
            -v, --version                        print version
            -h, --help                           show usage message
        `,
        values: #{
            "-f": "@extra-complete/science/kinds:pandoc_input_format",
            "-r": "@extra-complete/science/kinds:pandoc_input_format",
            "--from": "@extra-complete/science/kinds:pandoc_input_format",
            "--read": "@extra-complete/science/kinds:pandoc_input_format",
            "-t": "@extra-complete/science/kinds:pandoc_output_format",
            "-w": "@extra-complete/science/kinds:pandoc_output_format",
            "--to": "@extra-complete/science/kinds:pandoc_output_format",
            "--write": "@extra-complete/science/kinds:pandoc_output_format", "-o": "files", "--output": "files",
            "--data-dir": "dirs", "-M": "none", "--metadata": "none", "--metadata-file": "files",
            "-d": "@extra-complete/science/kinds:pandoc_defaults",
            "--defaults": "@extra-complete/science/kinds:pandoc_defaults", "--template": "files", "-V": "none",
            "--variable": "none", "--variable-json": "none", "--wrap": ["auto", "none", "preserve"],
            "--toc-depth": "none", "--number-offset": "none",
            "--top-level-division": ["section", "chapter", "part"], "--extract-media": "dirs",
            "--resource-path": "dirs", "-H": "files", "--include-in-header": "files", "-B": "files",
            "--include-before-body": "files", "-A": "files", "--include-after-body": "files",
            "--highlight-style": "@extra-complete/science/kinds:pandoc_highlight_style",
            "--syntax-definition": "files",
            "--syntax-highlighting": "@extra-complete/science/kinds:pandoc_syntax_highlighting", "--dpi": "none",
            "--eol": ["crlf", "lf", "native"], "--columns": "none", "--tab-stop": "none",
            "--pdf-engine": "@extra-complete/science/kinds:pdf_engine", "--pdf-engine-opt": "none",
            "--reference-doc": "files", "--request-header": "none", "--abbreviations": "files",
            "--typst-input": "none", "--indented-code-classes": "none", "--default-image-extension": "none",
            "-F": "files", "--filter": "files", "-L": "@extra-complete/science/kinds:lua",
            "--lua-filter": "@extra-complete/science/kinds:lua", "--shift-heading-level-by": "none",
            "--base-header-level": "none", "--track-changes": ["accept", "reject", "all"],
            "--reference-location": ["block", "section", "document"],
            "--figure-caption-position": ["above", "below"], "--table-caption-position": ["above", "below"],
            "--markdown-headings": ["setext", "atx"], "--slide-level": "none",
            "--email-obfuscation": ["none", "javascript", "references"], "--id-prefix": "none", "-T": "none",
            "--title-prefix": "none", "-c": "files", "--css": "files", "--epub-subdirectory": "dirs",
            "--epub-cover-image": "files", "--epub-metadata": "files", "--epub-embed-font": "files",
            "--split-level": "none", "--chunk-template": "none", "--epub-chapter-level": "none",
            "--ipynb-output": ["all", "none", "best"],
            "--bibliography": "@extra-complete/science/kinds:bibliography",
            "--csl": "@extra-complete/science/kinds:csl", "--citation-abbreviations": "files",
            "--math-method": "none", "--webtex": "none", "--mathjax": "none", "--katex": "none", "--log": "files",
            "--completion": "none", "--list-extensions": "@extra-complete/science/kinds:pandoc_output_format",
            "-D": "@extra-complete/science/kinds:pandoc_output_format",
            "--print-default-template": "@extra-complete/science/kinds:pandoc_output_format",
            "--print-default-data-file": "none",
            "--print-highlight-style": "@extra-complete/science/kinds:pandoc_highlight_style",
        },
    }
}
