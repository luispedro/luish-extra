// Media and graphics: vlc and cvlc (3.0.24), gimp (3.0.4, and 2.10.36, which lacks --quit), inkscape (1.4.2), krita
// (6.0.4), blender (5.2.2), obs (OBS Studio 32.2.2), audacity (4.0.1, and the options of 3.7.5 that 4 dropped) and eog
// (45.3). mpv has a module of its own.
import "qt" as qt;

fn k(name) { "@extra-complete/gui/kinds:" + name }

// vlc [OPTIONS] [STREAM]...: the options of VLC's core (`src/libvlc-module.c`) that are used most, of the thousands
// that its modules add (`vlc -H`). A flag `--NAME` also has `--no-NAME`, written here for those that are on by
// default. cvlc is vlc with the dummy interface.
fn vlc() {
    #{
        opts: `
            -h, --help                  show the help
            -H, --full-help             show the help of VLC and all its modules
            --longhelp                  show the help of VLC and all its modules, with the advanced options
            --help-verbose              show the help, with the advanced options
            -l, --list                  list the modules
            --list-verbose              list the modules, with their capabilities
            -p, --module MODULE         show the help of a module (with --advanced, its advanced options)
            --version                   show the version
            --ignore-config             don't read or write the configuration file
            --reset-config              reset the configuration to the defaults
            --reset-plugins-cache       reset the plugins cache
            --config FILE               the configuration file
            --save-config               save the options of the command line to the configuration file
            --advanced                  show the advanced options
            -I, --intf MODULE           the interface
            --extraintf MODULES         extra interfaces (:-separated)
            --control MODULES           control interfaces (:-separated)
            -v, --verbose LEVEL         the verbosity (0, 1, 2)
            -d, --daemon                run as a daemon
            --pidfile FILE              write the process id to a file
            --color                     color the messages on the console
            --no-color                  don't color the messages on the console
            --one-instance              play in the running VLC
            --playlist-enqueue          add to the playlist of the running VLC (with --one-instance)
            -f, --fullscreen            full-screen video
            --video-on-top              keep the video window on top
            --video                     enable video
            --no-video                  disable video
            --audio                     enable audio
            --no-audio                  disable audio
            --video-title-show          show the media's title on the video
            --no-video-title-show       don't show the media's title on the video
            -V, --vout MODULE           the video output
            -A, --aout MODULE           the audio output
            --width PIXELS              the video width
            --height PIXELS             the video height
            --zoom FACTOR               zoom the video
            --aspect-ratio RATIO        the source aspect ratio (4:3, 16:9, ...)
            --crop GEOMETRY             crop the video (16:9, or WxH+X+Y)
            --deinterlace MODE          deinterlace (-1 automatic, 0 off, 1 on)
            --deinterlace-mode MODE     the deinterlace method
            --video-filter MODULES      video filters (:-separated)
            --audio-filter MODULES      audio filters (:-separated)
            --gain FACTOR               the audio gain (0 to 8)
            --volume-step STEP          the volume step
            --stereo-mode MODE          the stereo audio output mode
            --audio-desync MS           the audio delay, in milliseconds
            --audio-track NUMBER        the audio track
            --sub-track NUMBER          the subtitle track
            --audio-language LANGS      the audio languages (,-separated, any)
            --sub-language LANGS        the subtitle languages (,-separated, any, none)
            --sub-file FILE             a subtitle file
            --sub-autodetect-file       look for subtitle files next to the video
            --no-sub-autodetect-file    don't look for subtitle files next to the video
            --input-slave MRLS          extra inputs (#-separated)
            --start-time SECONDS        start at this time
            --stop-time SECONDS         stop at this time
            --run-time SECONDS          play for this long
            --rate RATE                 the playback speed
            --input-repeat N            repeat the input N times
            --start-paused              start paused
            -Z, --random                play the files in random order, forever
            -L, --loop                  repeat all
            -R, --repeat                repeat the current item
            --play-and-exit             quit at the end of the playlist
            --play-and-stop             stop after each item
            --play-and-pause            pause at the end of each item
            --recursive MODE            what to do with directories
            --network-caching MS        the cache for network streams, in milliseconds
            --file-caching MS           the cache for files, in milliseconds
            --http-proxy PROXY          the HTTP proxy (http://[user@]host[:port]/)
            --sout CHAIN                the stream output chain (#transcode{...}:std{...})
            --sout-keep                 keep the stream output open between items
            --snapshot-path PATH        the directory (or file) of snapshots
            --snapshot-format FORMAT    the format of snapshots
            -S, --services-discovery MODULES  the services discovery modules (:-separated)
        `,
        values: #{
            "--module": "none",
            "--config": "files",
            "--intf": ["qt", "skins2", "dummy", "rc", "oldrc", "ncurses", "http", "telnet", "lua"],
            "--extraintf": "none",
            "--control": "none",
            "--verbose": ["0", "1", "2"],
            "--vout": "none",
            "--aout": "none",
            "--width": "none",
            "--height": "none",
            "--zoom": "none",
            "--aspect-ratio": "none",
            "--crop": "none",
            "--deinterlace": ["-1", "0", "1"],
            "--deinterlace-mode": ["auto", "discard", "blend", "mean", "bob", "linear", "x", "yadif", "yadif2x",
                                   "phosphor", "ivtc"],
            "--video-filter": "none",
            "--audio-filter": "none",
            "--gain": "none",
            "--volume-step": "none",
            "--stereo-mode": [#{value: "0", desc: "unset"}, #{value: "1", desc: "stereo"},
                              #{value: "2", desc: "reverse stereo"}, #{value: "3", desc: "left"},
                              #{value: "4", desc: "right"}, #{value: "5", desc: "Dolby Surround"},
                              #{value: "6", desc: "headphones"}, #{value: "7", desc: "mono"}],
            "--audio-desync": "none",
            "--audio-track": "none",
            "--sub-track": "none",
            "--audio-language": "none",
            "--sub-language": "none",
            "--input-slave": "files",
            "--start-time": "none",
            "--stop-time": "none",
            "--run-time": "none",
            "--rate": "none",
            "--input-repeat": "none",
            "--recursive": ["none", "collapse", "expand"],
            "--network-caching": "none",
            "--file-caching": "none",
            "--http-proxy": "none",
            "--sout": "none",
            "--snapshot-path": "files",
            "--snapshot-format": ["png", "jpg", "tiff"],
            "--services-discovery": "none",
        },
    }
}

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

// krita [OPTIONS] [FILES|URLS]: the options of its source (`libs/ui/KisApplicationArguments.cpp`), and Qt's.
fn krita() {
    let v = qt::values();
    v.mixin(#{
        "--new-image": "none",
        "--workspace": k("krita_workspaces"),
        "--windowlayout": k("krita_windowlayouts"),
        "--load-session": k("krita_sessions"),
        "--dpi": "none",
        "--resource-location": "dirs",
    });
    #{
        opts: `
            -h, --help                  show the help
            --help-all                  show the help, with Qt's options
            -v, --version               show the version
            --template                  open a new document with a template (a .desktop file)
            --new-image COLORSPACE,DEPTH,WIDTH,HEIGHT  create a new image (RGBA, XYZA, LABA, CMYKA, GRAY, YCbCrA; U8, U16, F16, F32)
            --workspace WORKSPACE       the workspace to open with
            --windowlayout WINDOWLAYOUT  the window layout to open with
            --load-session SESSION      the session to open with
            --canvasonly                start in canvas-only mode
            --nosplash                  don't show the splash screen
            --fullscreen                start in full screen
            --dpi DPIX,DPIY             override the display's DPI
            --export                    export to --export-filename and quit
            --export-sequence           export the animation to --export-filename and quit
            --export-filename FILENAME  the file to export to
            --file-layer FILE           a file layer to add to the existing or new file
            --resource-location DIR     the location of the resources, instead of the configured one
        ` + qt::qt_opts(),
        values: v,
    }
}

// blender [OPTIONS] [FILE] [OPTIONS] [-- ARGS]: the options of its source (`source/creator/creator_args.cc`), in the
// order of its help, with their values as the next word only. The options are applied in order, so most of them go after the .blend file; the arguments
// after `--` are left for Python's `sys.argv` (and Cycles's options, `--cycles-device`).
fn blender() {
    #{
        opts: `
            -b, --background            run in the background (for rendering without a UI)
            -a, --render-anim           render the frames from start to end
            -S, --scene NAME            the active scene for rendering
            -f, --render-frame FRAME    render frames and save them (N, +N, -N, A..B, comma-separated)
            -s, --frame-start FRAME     the start frame (+/- for relative frames)
            -e, --frame-end FRAME       the end frame (+/- for relative frames)
            -j, --frame-jump FRAMES     the frames to step after each rendered frame
            -o, --render-output PATH    the render path and file name (# for the frame number)
            -E, --engine ENGINE         the render engine (help to list them)
            -t, --threads THREADS       the number of threads (0 for the processors)
            -F, --render-format FORMAT  the render format
            -x, --use-extension BOOL    add the file extension to the file name
            -w, --window-border         open with borders, not maximized
            -M, --window-maximized      open maximized
            -W, --window-fullscreen     open in full screen
            -p, --window-geometry SX SY W H  open with the lower left corner at SX,SY and size W×H
            -con, --start-console       start with the console window open (Windows only)
            --no-native-pixels          don't use native pixel size, on high resolution displays
            --no-window-frame           disable all window decorations (Linux only)
            --no-window-focus           open behind other windows, without taking focus
            -y, --enable-autoexec       enable automatic Python script execution
            -Y, --disable-autoexec      disable automatic Python script execution (drivers and startup scripts)
            -P, --python FILEPATH       run a Python script file
            --python-text NAME          run a Python script text block
            --python-expr EXPRESSION    run a Python expression
            --python-console            run with an interactive console
            --python-exit-code CODE     the exit code (0 to 255) on a Python exception
            --python-use-system-env     let Python use environment variables such as PYTHONPATH
            --python-use-user-env       let Python use the user's site-packages directory
            --addons ADDONS             add-ons to enable, besides the default ones (comma-separated)
            --online-mode               allow internet access, overriding the preference
            --offline-mode              disallow internet access, overriding the preference
            --log MATCH                 enable logging categories (comma-separated; * wildcards, ^ to exclude)
            --log-level LEVEL           the logging verbosity level
            --log-show-memory           show the memory usage of each log message
            --log-show-source           show the source file and function of each log message
            --log-show-backtrace        show a backtrace for each log message (debug builds)
            --log-file FILEPATH         write the log to a file
            --log-list-categories       list the logging categories and quit
            -d, --debug                 turn debugging on
            --debug-value VALUE         the debug value on startup
            --debug-events              debug messages for the event handler
            --debug-handlers            debug messages for event handling
            --debug-libmv               debug messages from libmv
            --debug-memory              fully guarded memory allocation and debugging
            --debug-jobs                debug messages for the job system
            --debug-python              debug messages for Python
            --debug-depsgraph           all debug messages of the dependency graph
            --debug-depsgraph-eval      debug messages of the dependency graph's evaluation
            --debug-depsgraph-build     debug messages of the dependency graph's building
            --debug-depsgraph-tag       debug messages of the dependency graph's tagging
            --debug-depsgraph-no-threads  evaluate the dependency graph in a single thread
            --debug-depsgraph-time      debug messages of the dependency graph's timing
            --debug-depsgraph-pretty    colors in the dependency graph's debug messages
            --debug-depsgraph-uid       verify the uniqueness of the dependency graph's session identifiers
            --debug-ghost               debug messages for GHOST (the window system)
            --debug-wintab              debug messages for Wintab
            --debug-gpu                 GPU debug context and information (OpenGL 4.3+)
            --debug-gpu-force-workarounds  enable workarounds for GPU issues and disable GPU extensions
            --debug-gpu-compile-shaders  compile all static shaders, to test the platform
            --debug-gpu-shader-debug-info  generate shader debug info (Vulkan only)
            --debug-gpu-scope-capture NAME  capture the GPU commands in a scope
            --debug-gpu-shader-source NAME  save the compiled source of shaders (* wildcards) to Shaders/
            --debug-gpu-shader-no-preprocessor  skip the preprocessor pass of shaders
            --debug-gpu-shader-no-dce   skip dead code elimination in shaders
            --debug-gpu-no-texture-pool  disable memory aliasing in the GPU texture pool
            --debug-gpu-renderdoc       enable RenderDoc integration
            --debug-gpu-vulkan-local-read  force Vulkan dynamic rendering local read
            --debug-wm                  debug messages for the window manager
            --debug-xr                  debug messages for virtual reality
            --debug-xr-time             debug messages for virtual reality frame timing
            --debug-all                 all debug messages
            --debug-io                  debug messages for I/O
            --debug-fpe                 enable floating-point exceptions
            --debug-exit-on-error       exit when internal errors are detected
            --debug-freestyle           debug messages for Freestyle
            --console-crash-handler     report crashes on the console
            --disable-crash-handler     disable the crash handler
            --disable-abort-handler     disable the abort handler
            --verbose VERBOSE           the verbosity of debug messages that support it
            -q, --quiet                 don't print the status (warnings and errors are still printed)
            --gpu-backend BACKEND       the GPU backend
            --gpu-device DEVICE         the GPU device (VENDOR/DEVICE/INDEX in hex, or an index; help to list them)
            --gpu-device-no-fallback    fail if --gpu-device matches no usable Vulkan device
            --gpu-vsync VSYNC           VSync
            --gpu-compilation-subprocesses COUNT  the number of shader compilation subprocesses (OpenGL only)
            --profile-gpu               profile the CPU and GPU in GPU debug groups
            --open-last                 open the last opened .blend file, not the startup file
            --app-template TEMPLATE     the application template (default for none)
            -X, --factory-startup       don't read the user's startup.blend
            --enable-event-simulate     enable event simulation (bpy.types.Window.event_simulate)
            --env-system-datafiles PATH  set $BLENDER_SYSTEM_DATAFILES
            --env-system-scripts PATH   set $BLENDER_SYSTEM_SCRIPTS
            --env-system-extensions PATH  set $BLENDER_SYSTEM_EXTENSIONS
            --env-system-python PATH    set $BLENDER_SYSTEM_PYTHON
            -c, --command COMMAND       run a command, with the rest of the arguments
            -h, --help                  show the help
            -r, --register              register the .blend extension for the user (Windows and Linux)
            --register-allusers         register the .blend extension for all users (Windows and Linux)
            --unregister                unregister the .blend extension for the user (Windows and Linux)
            --unregister-allusers       unregister the .blend extension for all users (Windows and Linux)
            --qos LEVEL                 the Quality of Service mode on hybrid CPUs (Windows only)
            -v, --version               show the version
        `,
        values: #{
            "--scene": "none",
            "--render-frame": "none",
            "--frame-start": "none",
            "--frame-end": "none",
            "--frame-jump": "none",
            "--render-output": "files",
            "--engine": ["BLENDER_EEVEE", "BLENDER_WORKBENCH", "CYCLES", "help"],
            "--threads": "none",
            "--render-format": ["TGA", "RAWTGA", "JPEG", "IRIS", "PNG", "BMP", "HDR", "TIFF", "OPEN_EXR",
                                "OPEN_EXR_MULTILAYER", "FFMPEG", "CINEON", "DPX", "JP2", "WEBP"],
            "--use-extension": ["0", "1"],
            "--window-geometry": "none",
            "--python": k("py"),
            "--python-text": "none",
            "--python-expr": "none",
            "--python-exit-code": "none",
            "--addons": "none",
            "--log": "none",
            "--log-level": ["fatal", "error", "warning", "info", "debug", "trace"],
            "--debug-value": "none",
            "--debug-gpu-scope-capture": "none",
            "--debug-gpu-shader-source": "none",
            "--verbose": "none",
            "--gpu-backend": ["vulkan", "opengl", "metal"],
            "--gpu-device": ["help"],
            "--gpu-vsync": ["on", "off", "auto"],
            "--gpu-compilation-subprocesses": "none",
            "--app-template": "none",
            "--env-system-datafiles": "dirs",
            "--env-system-scripts": "dirs",
            "--env-system-extensions": "dirs",
            "--env-system-python": "dirs",
            "--command": ["extension", "help"],
            "--qos": ["default", "high", "eco"],
        },
        args: [k("blend")],
        strict_eq: true,
    }
}

// eog [OPTIONS] [FILES]
fn eog() {
    #{
        opts: `
            -h, --help                  show the help
            --help-all                  show all the help
            --help-gtk                  show GTK's options
            --version                   show the version
            -f, --fullscreen            open in full screen
            -g, --disable-gallery       disable the image gallery
            -s, --slide-show            open in slideshow mode
            -n, --new-instance          start a new eog, instead of reusing the running one
            -w, --single-window         open in a single window (the first one, if there are several)
            --class=CLASS               program class, for the window manager
            --name=NAME                 program name, for the window manager
            --gtk-module=MODULES        load additional GTK modules
            --g-fatal-warnings          make all warnings fatal
            --display=DISPLAY           X display to use
        `,
        values: #{"--class": "none", "--name": "none", "--gtk-module": "none", "--display": "none"},
    }
}

fn spec(cmd) {
    switch cmd {
        "vlc" | "cvlc" => vlc(),
        "gimp" => gimp(),
        "inkscape" => inkscape(),
        "obs" => obs(),
        "audacity" => audacity(),
        "krita" => krita(),
        "blender" => blender(),
        "eog" => eog(),
        _ => #{},
    }
}
