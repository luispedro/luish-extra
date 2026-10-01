// Media and graphics: gimp (3.0.4, and 2.10.36, which lacks --quit), inkscape (1.4.2), obs (OBS Studio 32.2.2) and
// audacity (4.0.1, and the options of 3.7.5 that 4 dropped). mpv has a module of its own.

fn k(name) { "@extra-complete/gui/kinds:" + name }

// gimp [OPTIONS] [FILES|URIS]: the options of `--help-all` but GTK's, which differ between GTK 2 (GIMP 2.10) and 3.
fn gimp() {
    #{
        opts: `
            -h, --help                  show the help
            --help-all                  show all the help
            --help-gegl                 show GEGL's options
            --help-gtk                  show GTK's options
            -v, --version               show the version
            --license                   show the license
            --verbose                   be more verbose
            -n, --new-instance          start a new GIMP
            -a, --as-new                open images as new
            -i, --no-interface          run without a user interface
            -d, --no-data               don't load brushes, gradients, patterns, ...
            -f, --no-fonts              don't load any fonts
            -s, --no-splash             don't show a splash screen
            --no-shm                    don't use shared memory between GIMP and plug-ins
            --no-cpu-accel              don't use special CPU acceleration functions
            --session NAME              use an alternate sessionrc file (sessionrc.NAME)
            -g, --gimprc FILE           use an alternate user gimprc file
            --system-gimprc FILE        use an alternate system gimprc file
            -b, --batch COMMAND         batch command to run (- for standard input)
            --batch-interpreter PROC    the procedure to run batch commands with
            --quit                      quit after performing the requested actions
            -c, --console-messages      send messages to the console instead of a dialog
            --pdb-compat-mode MODE      PDB compatibility mode
            --stack-trace-mode MODE     debug in case of a crash
            --debug-handlers            enable non-fatal debugging signal handlers
            --g-fatal-warnings          make all warnings fatal
            --dump-gimprc               print a gimprc file with the default settings
            --show-playground           show a preferences page with experimental features
            --display DISPLAY           the X display to use
            --gegl-swap URI             where GEGL stores its swap
            --gegl-swap-compression ALGORITHM  compression of the data in the swap
            --gegl-cache-size MEGABYTES  how much memory to use for caching imagery
            --gegl-tile-size WxH        default size of tiles in GeglBuffers
            --gegl-chunk-size PIXELS    the number of pixels to compute at once
            --gegl-quality QUALITY      the quality of rendering (0.0 fast to 1.0 reference)
            --gegl-threads THREADS      the number of processing threads
            --gegl-disable-opencl       disable OpenCL
        `,
        values: #{
            "--session": k("gimp_sessions"),
            "--batch": "none",
            "--batch-interpreter": ["plug-in-script-fu-eval", "python-fu-eval"],
            "--pdb-compat-mode": ["off", "on", "warn"],
            "--stack-trace-mode": ["never", "query", "always"],
            "--display": "none",
            "--gegl-swap": "dirs",
            "--gegl-swap-compression": ["fast", "balanced", "best", "none"],
            "--gegl-cache-size": "none",
            "--gegl-tile-size": "none",
            "--gegl-chunk-size": "none",
            "--gegl-quality": "none",
            "--gegl-threads": "none",
        },
    }
}

// inkscape [OPTIONS] FILES: `-?` is the help, and `-h` --export-height.
fn inkscape() {
    #{
        opts: `
            -?, --help                  show the help
            --help-all                  show all the help
            --help-gapplication         show GApplication's options
            --help-gtk                  show GTK's options
            -V, --version               print the version
            --debug-info                print debugging information
            --system-data-directory     print the system data directory
            --user-data-directory       print the user data directory
            --list-input-types          list the extensions of the files it can open
            --app-id-tag TAG            a unique instance, with the application ID org.inkscape.Inkscape.TAG
            -p, --pipe                  read the input file from standard input
            -n, --pages PAGE[,PAGE]     the pages to import from a multi-page document (PDF)
            --pdf-poppler               import PDF with poppler
            --pdf-font-strategy STRATEGY  how the internal PDF importer handles fonts
            --convert-dpi-method METHOD  how to convert the dpi of a pre-0.92 document
            --no-convert-text-baseline-spacing  don't fix the text baseline spacing of a pre-0.92 document
            -o, --export-filename FILENAME  the output file (- for standard output)
            --export-overwrite          overwrite the input file
            --export-type TYPE[,TYPE]   the file types to export
            --export-extension EXTENSION-ID  the extension to export with
            -C, --export-area-page      export the page
            -D, --export-area-drawing   export the whole drawing (ignoring the page size)
            -a, --export-area x0:y0:x1:y1  the area to export, in SVG user units
            --export-area-snap          snap the bitmap export area outwards to whole pixels
            -d, --export-dpi DPI        resolution of bitmaps and rasterized filters (96)
            -w, --export-width WIDTH    bitmap width in pixels (overrides --export-dpi)
            -h, --export-height HEIGHT  bitmap height in pixels (overrides --export-dpi)
            --export-margin MARGIN      margin around the export area (page units for SVG, mm for PS/PDF)
            --export-page PAGES         the pages to export (all|n[,a-b])
            -i, --export-id OBJECT-ID[;OBJECT-ID]  the objects to export
            -j, --export-id-only        hide all objects but those of --export-id
            -l, --export-plain-svg      remove Inkscape's own SVG attributes and properties
            --export-ps-level LEVEL     PostScript level (3)
            --export-pdf-version VERSION  PDF version (1.5)
            -T, --export-text-to-path   convert text to paths (PS/EPS/PDF/SVG)
            --export-latex              export text separately to a LaTeX file (PS/EPS/PDF)
            --export-ignore-filters     render objects without filters instead of rasterizing (PS/EPS/PDF)
            -t, --export-use-hints      use the stored file name and DPI hints of the --export-id object
            -b, --export-background COLOR  background color of bitmaps (an SVG color)
            -y, --export-background-opacity VALUE  background opacity of bitmaps (0.0 to 1.0, or 1 to 255)
            --export-png-color-mode COLOR-MODE  bit depth and color type of bitmaps
            --export-png-use-dithering BOOL  force dithering or disable it
            --export-png-compression LEVEL  PNG compression level (0 to 9, 6)
            --export-png-antialias LEVEL  PNG antialias level (0 to 3, 2)
            -I, --query-id OBJECT-ID[,OBJECT-ID]  the objects to query
            -S, --query-all             print the bounding boxes of all objects
            -X, --query-x               X coordinate of the drawing or of the --query-id object
            -Y, --query-y               Y coordinate of the drawing or of the --query-id object
            -W, --query-width           width of the drawing or of the --query-id object
            -H, --query-height          height of the drawing or of the --query-id object
            --vacuum-defs               remove unused definitions from <defs>
            --select OBJECT-ID[,OBJECT-ID]  select objects
            --actions ACTION(:ARG)[;ACTION(:ARG)]  the actions to run
            --action-list               list the actions
            --actions-file FILENAME     read the actions from a file
            -g, --with-gui              with the graphical interface (some actions need it)
            --batch-process             close the GUI after running the actions
            --shell                     start an interactive shell
            -q, --active-window         use the active window from the command line
            --display DISPLAY           the X display to use
        `,
        values: #{
            "--app-id-tag": "none",
            "--pages": "none",
            "--pdf-font-strategy": ["draw-missing", "draw-all", "delete-missing", "delete-all", "substitute", "keep"],
            "--convert-dpi-method": ["none", "scale-viewbox", "scale-document"],
            "--export-type": k("inkscape_export_types"),
            "--export-extension": "none",
            "--export-area": "none",
            "--export-dpi": "none",
            "--export-width": "none",
            "--export-height": "none",
            "--export-margin": "none",
            "--export-page": ["all"],
            "--export-id": k("inkscape_ids;"),
            "--export-ps-level": ["2", "3"],
            "--export-pdf-version": ["1.4", "1.5"],
            "--export-background": "none",
            "--export-background-opacity": "none",
            "--export-png-color-mode": ["Gray_1", "Gray_2", "Gray_4", "Gray_8", "Gray_16", "RGB_8", "RGB_16",
                                        "GrayAlpha_8", "GrayAlpha_16", "RGBA_8", "RGBA_16"],
            "--export-png-use-dithering": ["false", "true"],
            "--export-png-compression": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"],
            "--export-png-antialias": ["0", "1", "2", "3"],
            "--query-id": k("inkscape_ids,"),
            "--select": k("inkscape_ids,"),
            "--actions": k("inkscape_actions"),
            "--display": "none",
        },
    }
}

// obs [OPTIONS]: it reads its options itself, and takes no files.
fn obs() {
    #{
        opts: `
            -h, --help                  show the help
            -V, --version               show the version
            --startstreaming            start streaming
            --startrecording            start recording
            --startreplaybuffer         start the replay buffer
            --startvirtualcam           start the virtual camera
            --collection NAME           use this scene collection
            --profile NAME              use this profile
            --scene NAME                start with this scene
            --studio-mode               enable studio mode
            --minimize-to-tray          minimize to the system tray
            -p, --portable              use portable mode
            -m, --multi                 don't warn when launching several instances
            --safe-mode                 run without third-party plugins, scripting and WebSockets
            --only-bundled-plugins      load only the bundled plugins
            --verbose                   make the log more verbose
            --always-on-top             start in 'always on top' mode
            --unfiltered_log            make the log unfiltered
            --disable-updater           disable the built-in updater (Windows and macOS)
            --disable-missing-files-check  disable the missing files dialog at startup
            --allow-opengl              allow the OpenGL renderer (Windows)
        `,
        values: #{
            "--collection": k("obs_collections"),
            "--profile": k("obs_profiles"),
            "--scene": k("obs_scenes"),
        },
        args: ["none"],
    }
}

// audacity [OPTIONS] [FILES]
fn audacity() {
    #{
        opts: `
            -h, -?, --help              show the help
            -v, --version               show the version
            --long-version              show detailed version information (4)
            -d, --debug                 debug mode (4)
            -D, --monitor-resolution DPI  the monitor's resolution (4)
            -F, --factory-settings      use factory settings (4)
            --session-type TYPE         start with this session type (4)
            -u, --url URL               open an audacity:// URL
            --register-audio-plugin PATH  check an audio plugin and register it (4)
            --register-audio-plugin-out PATH  the file to write the plugin check's result to (4)
            --plugin-registration-self-test  check that plugin registration works (4)
            -b, --blocksize BYTES       the largest disk block size (3)
            -j, --journal FILE          replay a journal file (3)
            -t, --test                  run self diagnostics (3)
        `,
        values: #{
            "--monitor-resolution": "none",
            "--session-type": ["start-empty", "continue-last", "start-with-new", "start-with-file"],
            "--url": "none",
            "--blocksize": "none",
        },
    }
}

fn spec(cmd) {
    switch cmd {
        "gimp" => gimp(),
        "inkscape" => inkscape(),
        "obs" => obs(),
        "audacity" => audacity(),
        _ => #{},
    }
}
