// mplayer [OPTIONS] [FILE|URL]...: MPlayer 1.5 (Debian's 1.5+svn38681), the options used most of its manual page's
// sections on general, player, demuxer and stream, OSD and subtitle, audio and video output, and decoding and
// filtering options (it has some six hundred, many of them for one driver or device). Its options start with one
// dash and take their value as the next word; a flag `-NAME` is also `-noNAME`, written here for the usual ones.
//
// `mplayer -list-options` cuts names off at 20 characters, so the table can't be read from the installed program, as
// mpv's is; what depends on how it was built is: the drivers, filters, codecs and demuxers of `mplayer -vo help`
// (`-ao`, `-vf`, `-af`, `-vc`, `-ac`, `-vfm`, `-afm`, `-demuxer`). mplayer makes `~/.mplayer/config` when it doesn't
// exist, so it is run with a HOME that doesn't. The profiles are read from its configuration files.
import "@std/completion/kinds" as std_kinds;
import "../extra-lib/text" as lib_text;

// This plugin's `MODULE:NAME` (a kind or sub_spec) by the module's path, whatever the source is called.
fn own(name) { sh::plugin_dir() + "/" + name }

fn k(name) { own("mplayer:") + name }

fn spec(cmd) {
    #{
        single_dash: true,
        opts: `
            -h, -help, --help           show the help
            -list-options               list all the options
            -list-properties            list the properties of the slave mode
            -include FILE               read a configuration file
            -noconfig WHICH             don't read the configuration files (all, gui, system, user)
            -profile PROFILES           use these profiles (,-separated)
            -show-profile PROFILE       show a profile's options
            -use-filedir-conf           read a configuration file in the file's directory
            -quiet                      print less
            -really-quiet               print nothing but errors
            -v                          print more (more -v: even more)
            -msglevel LEVELS            the verbosity of each module (all=LEVEL:MODULE=LEVEL:...)
            -msgcolor                   color the messages
            -msgmodule                  prefix the messages with their module
            -msgcharset CHARSET         the character set of the messages
            -codecs-file FILE           the codecs.conf to use
            -codecpath DIR              the directory of binary codecs
            -identify                   print the file's properties, in a form to parse
            -idle                       wait for commands when there is nothing to play
            -slave                      take commands from standard input (slave mode)
            -input OPTIONS              input options (conf=FILE, keylist, cmdlist, file=FIFO, ...)
            -noconsolecontrols          don't read keys from standard input
            -nojoystick                 don't use a joystick
            -nolirc                     don't use LIRC
            -lircconf FILE              the LIRC configuration file
            -nomouseinput               ignore mouse input
            -nograbpointer              don't grab the mouse pointer when the video mode changes
            -loop NUMBER                play it NUMBER times (0: forever)
            -shuffle                    play the files in random order
            -playlist FILE              play the files of a playlist
            -allow-dangerous-playlist-parsing  allow playlist formats that aren't safe
            -pausing MODE               whether commands pause playback
            -playing-msg STRING         print a message when playback starts (with properties, of -list-properties)
            -fixed-vo                   keep the video window open between files
            -framedrop                  drop frames to keep A/V sync on slow systems
            -hardframedrop              drop frames more, even decoding them
            -autosync FACTOR            adjust the A/V sync gradually (30: a good value)
            -benchmark                  print statistics at the end (with -nosound -vo null)
            -correct-pts                compute the timestamps of the video frames
            -nocorrect-pts              don't compute the timestamps of the video frames
            -heartbeat-cmd COMMAND      a command to run every 30 seconds while playing
            -edl FILE                   an edit decision list (skip and mute)
            -edlout FILE                write an edit decision list (with the i key)
            -softsleep                  time frames with the CPU, not the kernel's timer
            -sstep SECONDS              skip SECONDS between frames
            -ss TIME                    start at this time ([[hh:]mm:]ss[.ms])
            -sb BYTES                   start at this byte
            -endpos TIME                stop at this time, or size ([[hh:]mm:]ss[.ms], or N[b|kb|mb])
            -frames NUMBER              play this many frames
            -speed FACTOR               the playback speed (0.01 to 100)
            -chapter CHAPTERS           play these chapters (N or N-M)
            -fps FPS                    the video frame rate
            -delay SECONDS              the audio delay (negative: the video's)
            -aid ID                     the audio stream
            -vid ID                     the video stream
            -sid ID                     the subtitle stream
            -alang LANGUAGES            the audio languages, in order (,-separated)
            -slang LANGUAGES            the subtitle languages, in order (,-separated)
            -audiofile FILE             play the audio of a file with the video
            -audio-demuxer DEMUXER      the demuxer of -audiofile
            -demuxer DEMUXER            the demuxer (+NAME: force it)
            -cache KBYTES               the size of the cache, in kilobytes
            -nocache                    don't use a cache
            -cache-min PERCENT          fill the cache this much before playing
            -cache-seek-min PERCENT     seek in the cache if the target is this close
            -forceidx                   rebuild the index
            -idx                        rebuild the index if there is none
            -noidx                      don't rebuild the index
            -loadidx FILE               read the index from a file
            -saveidx FILE               write the index to a file
            -ni                         force the non-interleaved AVI parser
            -noextbased                 don't choose the demuxer by the extension
            -rawaudio OPTIONS           read raw audio (channels=N:rate=N:samplesize=N:format=F)
            -rawvideo OPTIONS           read raw video (w=N:h=N:fps=N:format=F:size=N:...)
            -mf OPTIONS                 play a series of images (fps=N:type=T:...; with mf://PATTERN)
            -tv OPTIONS                 TV capture (driver=D:device=FILE:input=N:norm=N:...)
            -dumpstream                 write the raw stream to stream.dump (or -dumpfile)
            -dumpaudio                  write the raw audio stream to stream.dump (or -dumpfile)
            -dumpvideo                  write the raw video stream to stream.dump (or -dumpfile)
            -dumpfile FILE              the file of -dump*
            -capture                    write the stream to -dumpfile when the c key is pressed
            -cdrom-device DEVICE        the CD-ROM device
            -dvd-device DEVICE          the DVD device (or a directory, or an ISO image)
            -dvd-speed SPEED            the DVD drive's speed (a factor, or KB/s)
            -dvdangle ID                the DVD angle
            -bluray-device DEVICE       the Blu-ray device (or a directory, or an ISO image)
            -bluray-angle ID            the Blu-ray angle
            -cdda OPTIONS               CDDA options (speed=N:paranoia=N:...)
            -user USER                  the user name (HTTP)
            -passwd PASSWORD            the password (HTTP)
            -user-agent STRING          the User-Agent of HTTP requests
            -referrer STRING            the Referer of HTTP requests
            -http-header-fields FIELDS  extra HTTP header fields (,-separated)
            -cookies                    send cookies with HTTP requests
            -cookies-file FILE          read cookies from a file
            -bandwidth BYTES            the maximum bandwidth of network streams (bytes per second)
            -prefer-ipv4                prefer IPv4
            -prefer-ipv6                prefer IPv6
            -rtsp-stream-over-tcp       stream RTSP over TCP
            -rtsp-stream-over-http      stream RTSP over HTTP
            -sub FILES                  subtitle files (,-separated)
            -subfile FILE               a subtitle file of a format that has a demuxer
            -sub-demuxer DEMUXER        the demuxer of -subfile
            -sub-paths DIRS             more directories to look for subtitles in (,-separated)
            -sub-fuzziness MODE         which subtitle files to load
            -noautosub                  don't load subtitle files that aren't named
            -nosub                      don't show subtitles from the file
            -forcedsubsonly             show only the forced subtitles of DVDs
            -subcp CODEPAGE             the code page of the subtitles (enca:LANG:FALLBACK: guess it)
            -subdelay SECONDS           the subtitle delay
            -subfps FPS                 the frame rate of the subtitle file
            -subpos PERCENT             the subtitles' height (0 to 150, 100: the bottom)
            -subalign MODE              which edge of the subtitles is at -subpos
            -subwidth PERCENT           the subtitles' width (10 to 100)
            -subcc CHANNEL              show the DVD closed captions of a channel (1 to 8)
            -sub-bg-color VALUE         the subtitles' background (0 to 255)
            -sub-bg-alpha VALUE         the opacity of the subtitles' background (0 to 255)
            -overlapsub                 allow subtitles to overlap
            -unicode                    the subtitles are in Unicode
            -utf8                       the subtitles are in UTF-8
            -vobsub FILE                VOBsub subtitles (FILE.idx and FILE.sub, without the extension)
            -vobsubid ID                the VOBsub subtitle stream (0 to 31)
            -ifo FILE                   the VOBsub IFO file (for the palette)
            -ass                        render subtitles with libass
            -noass                      don't render subtitles with libass
            -ass-styles FILE            an SSA/ASS style file
            -ass-force-style STYLES     override styles ([Style.]Param=Value,...)
            -ass-font-scale SCALE       the scale of libass's fonts
            -ass-line-spacing PIXELS    the line spacing of libass
            -ass-color COLOR            the color of text subtitles (RRGGBBAA)
            -ass-border-color COLOR     the border color of text subtitles (RRGGBBAA)
            -ass-hinting TYPE           libass's font hinting
            -ass-use-margins            render subtitles in the black borders
            -ass-top-margin PIXELS      add a black border at the top
            -ass-bottom-margin PIXELS   add a black border at the bottom
            -embeddedfonts              use the fonts embedded in Matroska files
            -noembeddedfonts            don't use the fonts embedded in Matroska files
            -font FONT                  the OSD font (a font.desc, a font file, or a fontconfig pattern)
            -subfont FONT               the subtitle font (a font file, or a fontconfig pattern)
            -fontconfig                 find fonts with fontconfig
            -nofontconfig               don't find fonts with fontconfig
            -subfont-autoscale MODE     how the text is scaled
            -subfont-text-scale SCALE   the size of subtitle text (0 to 100)
            -subfont-osd-scale SCALE    the size of the OSD (0 to 100)
            -subfont-blur RADIUS        the font's blur radius (0 to 8)
            -subfont-outline WIDTH      the font's outline width (0 to 8)
            -subfont-encoding ENCODING  the font's encoding
            -osdlevel LEVEL             what the OSD shows at the start
            -osd-duration MS            how long OSD messages stay, in milliseconds
            -osd-fractions MODE         how fractions of seconds are shown on the OSD
            -noterm-osd                 don't show OSD messages on the terminal
            -term-osd-esc ESCAPE        the escape sequence before OSD messages on the terminal
            -dumpsrtsub                 write the subtitles to dumpsub.srt
            -dumpsub                    write the subtitles of a VOB to dumpsub.sub
            -ao DRIVERS                 the audio output drivers, in order (,-separated, a trailing , for the others)
            -nosound                    play no audio
            -volume LEVEL               the initial volume (0 to 100; -1: the mixer's)
            -volstep PERCENT            the volume step (0 to 100)
            -softvol                    change the volume with the software mixer
            -softvol-max PERCENT        the maximum volume of -softvol (10 to 10000)
            -mixer DEVICE               the mixer device
            -mixer-channel CHANNEL      the mixer channel (-ao oss and alsa)
            -format FORMAT              the sample format of the audio output
            -channels NUMBER            the number of audio channels
            -srate HZ                   the audio sample rate
            -af FILTERS                 the audio filters (,-separated)
            -af-add FILTERS             add audio filters at the end
            -af-pre FILTERS             add audio filters at the start
            -af-del INDEXES             remove audio filters by their indexes
            -af-clr                     remove all audio filters
            -vo DRIVERS                 the video output drivers, in order (,-separated, a trailing , for the others)
            -novideo                    play no video
            -fs                         play full screen
            -nofs                       don't play full screen
            -fstype TYPES               the full-screen modes, in order (X11)
            -ontop                      keep the window on top
            -noontop                    don't keep the window on top
            -rootwin                    play on the root window
            -border                     decorate the window
            -noborder                   don't decorate the window
            -geometry GEOMETRY          the window's position and size ([WxH][+-X+-Y], or X[%][:Y[%]])
            -title TITLE                the window title
            -use-filename-title         make the file's name the window title
            -wid ID                     play in this window (X11)
            -display NAME               the X display
            -xineramascreen SCREEN      the screen to play on (-2: all, -1: the window's)
            -screen SCREEN              the screen to play on (-2: all, -1: the window's)
            -stop-xscreensaver          turn off the screensaver while playing
            -nostop-xscreensaver        don't turn off the screensaver while playing
            -aspect RATIO               the movie's aspect ratio (4:3, 16:9, 1.85, ...)
            -noaspect                   ignore the movie's aspect ratio
            -monitoraspect RATIO        the monitor's aspect ratio
            -monitorpixelaspect RATIO   the aspect ratio of the monitor's pixels
            -nokeepaspect               don't keep the aspect ratio when the window is resized
            -panscan AMOUNT             crop the sides of a wide movie (0.0 to 1.0)
            -x WIDTH                    scale to this width
            -y HEIGHT                   scale to this height
            -xy SIZE                    scale to this width (or by this factor, if 16 or less)
            -zoom                       allow software scaling
            -screenw PIXELS             the screen's width
            -screenh PIXELS             the screen's height
            -refreshrate HZ             the monitor's refresh rate
            -vm                         change the video mode
            -vsync                      sync to the monitor's refresh
            -dr                         use direct rendering
            -double                     use double buffering
            -nodouble                   don't use double buffering
            -bpp DEPTH                  the color depth
            -brightness VALUE           the brightness (-100 to 100)
            -contrast VALUE             the contrast (-100 to 100)
            -gamma VALUE                the gamma (-100 to 100)
            -hue VALUE                  the hue (-100 to 100)
            -saturation VALUE           the saturation (-100 to 100)
            -vf FILTERS                 the video filters (,-separated)
            -vf-add FILTERS             add video filters at the end
            -vf-pre FILTERS             add video filters at the start
            -vf-del INDEXES             remove video filters by their indexes
            -vf-clr                     remove all video filters
            -vc CODECS                  the video codecs, in order (,-separated; -NAME: skip it; a trailing , for the others)
            -ac CODECS                  the audio codecs, in order (,-separated; -NAME: skip it; a trailing , for the others)
            -vfm DRIVERS                the video codec families, in order (,-separated)
            -afm DRIVERS                the audio codec families, in order (,-separated)
            -lavdopts OPTIONS           libavcodec's decoding options (threads=N:skiploopfilter=S:...)
            -sws TYPE                   the software scaler of -zoom
            -ssf OPTIONS                options of the software scaler (lgb=N:cgb=N:ls=N:cs=N:...)
            -flip                       flip the image upside down
            -field-dominance MODE       which field is first (-1: auto, 0: top, 1: bottom)
            -noslices                   draw the video whole, not in bands
            -stereo MODE                the MP2/MP3 stereo output
        `,
        values: #{
            "-include": "files", "-noconfig": ["all", "gui", "system", "user"], "-profile": k("profiles"),
            "-show-profile": k("profile"), "-msglevel": "none", "-msgcharset": "none", "-codecs-file": "files",
            "-codecpath": "dirs", "-input": "none", "-lircconf": "files", "-loop": "none", "-playlist": "files",
            "-pausing": [#{value: "0", desc: "resume"}, #{value: "1", desc: "pause"},
                         #{value: "2", desc: "keep the paused or playing status"},
                         #{value: "3", desc: "toggle the paused or playing status"},
                         #{value: "4", desc: "pause without frame step"}],
            "-playing-msg": "none", "-autosync": "none", "-heartbeat-cmd": "none", "-edl": "files",
            "-edlout": "files", "-sstep": "none", "-ss": "none", "-sb": "none", "-endpos": "none", "-frames": "none",
            "-speed": "none", "-chapter": "none", "-fps": "none", "-delay": "none", "-aid": "none", "-vid": "none",
            "-sid": "none", "-alang": "none", "-slang": "none", "-audiofile": "files",
            "-audio-demuxer": k("demuxer"), "-demuxer": k("demuxer"), "-cache": "none", "-cache-min": "none",
            "-cache-seek-min": "none", "-loadidx": "files", "-saveidx": "files", "-rawaudio": "none",
            "-rawvideo": "none", "-mf": "none", "-tv": "none", "-dumpfile": "files", "-cdrom-device": "files",
            "-dvd-device": "files", "-dvd-speed": "none", "-dvdangle": "none", "-bluray-device": "files",
            "-bluray-angle": "none", "-cdda": "none", "-user": "none", "-passwd": "none", "-user-agent": "none",
            "-referrer": "none", "-http-header-fields": "none", "-cookies-file": "files", "-bandwidth": "none",
            "-sub": k("files,"), "-subfile": "files", "-sub-demuxer": k("demuxer"), "-sub-paths": k("dirs,"),
            "-sub-fuzziness": [#{value: "0", desc: "the file's name, exactly (default)"},
                               #{value: "1", desc: "those that contain the file's name"},
                               #{value: "2", desc: "all those in the directory and -sub-paths"}],
            "-subcp": "none", "-subdelay": "none", "-subfps": "none", "-subpos": "none",
            "-subalign": [#{value: "0", desc: "top"}, #{value: "1", desc: "center"},
                          #{value: "2", desc: "bottom (default)"}],
            "-subwidth": "none", "-subcc": ["1", "2", "3", "4", "5", "6", "7", "8"], "-sub-bg-color": "none",
            "-sub-bg-alpha": "none", "-vobsub": "files", "-vobsubid": "none", "-ifo": "files",
            "-ass-styles": "files", "-ass-force-style": "none", "-ass-font-scale": "none",
            "-ass-line-spacing": "none", "-ass-color": "none", "-ass-border-color": "none",
            "-ass-hinting": [#{value: "0", desc: "none"}, #{value: "1", desc: "FreeType's autohinter, light"},
                             #{value: "2", desc: "FreeType's autohinter, normal"},
                             #{value: "3", desc: "the font's hinter"},
                             #{value: "4", desc: "none, if the OSD is scaled"},
                             #{value: "5", desc: "FreeType's autohinter, light, if the OSD isn't scaled"},
                             #{value: "6", desc: "FreeType's autohinter, normal, if the OSD isn't scaled"},
                             #{value: "7", desc: "the font's hinter, if the OSD isn't scaled (default)"}],
            "-ass-top-margin": "none", "-ass-bottom-margin": "none", "-font": "files", "-subfont": "files",
            "-subfont-autoscale": [#{value: "0", desc: "none"}, #{value: "1", desc: "with the movie's height"},
                                   #{value: "2", desc: "with the movie's width"},
                                   #{value: "3", desc: "with the movie's diagonal (default)"}],
            "-subfont-text-scale": "none", "-subfont-osd-scale": "none", "-subfont-blur": "none",
            "-subfont-outline": "none", "-subfont-encoding": "none",
            "-osdlevel": [#{value: "0", desc: "subtitles only"}, #{value: "1", desc: "volume and seek (default)"},
                          #{value: "2", desc: "volume, seek, time and percentage"},
                          #{value: "3", desc: "volume, seek, time, percentage and total time"}],
            "-osd-duration": "none",
            "-osd-fractions": [#{value: "0", desc: "none (default)"}, #{value: "1", desc: "two decimals"},
                               #{value: "2", desc: "the frame in the second (approximate)"}],
            "-term-osd-esc": "none",
            "-ao": k("ao"), "-volume": "none", "-volstep": "none", "-softvol-max": "none", "-mixer": "files",
            "-mixer-channel": "none", "-format": "none", "-channels": "none", "-srate": "none",
            "-af": k("af"), "-af-add": k("af"), "-af-pre": k("af"), "-af-del": "none",
            "-vo": k("vo"), "-fstype": k("fstype"), "-geometry": "none", "-title": "none", "-wid": "none",
            "-display": "none", "-xineramascreen": "none", "-screen": "none", "-aspect": "none",
            "-monitoraspect": "none", "-monitorpixelaspect": "none", "-panscan": "none", "-x": "none", "-y": "none",
            "-xy": "none", "-screenw": "none", "-screenh": "none", "-refreshrate": "none", "-bpp": "none",
            "-brightness": "none", "-contrast": "none", "-gamma": "none", "-hue": "none", "-saturation": "none",
            "-vf": k("vf"), "-vf-add": k("vf"), "-vf-pre": k("vf"), "-vf-del": "none",
            "-vc": k("vc"), "-ac": k("ac"), "-vfm": k("vfm"), "-afm": k("afm"), "-lavdopts": "none",
            "-sws": [#{value: "0", desc: "fast bilinear"}, #{value: "1", desc: "bilinear"},
                     #{value: "2", desc: "bicubic (default)"}, #{value: "3", desc: "experimental"},
                     #{value: "4", desc: "nearest neighbour"}, #{value: "5", desc: "area"},
                     #{value: "6", desc: "luma bicubic, chroma bilinear"}, #{value: "7", desc: "gauss"},
                     #{value: "8", desc: "sincR"}, #{value: "9", desc: "lanczos"},
                     #{value: "10", desc: "natural bicubic spline"}],
            "-ssf": "none", "-field-dominance": ["-1", "0", "1"],
            "-stereo": [#{value: "0", desc: "stereo"}, #{value: "1", desc: "left channel"},
                        #{value: "2", desc: "right channel"}],
        },
    }
}

// What `mplayer -NAME help` prints. mplayer's banner (`MPlayer 1.5 (Debian)`), with no newline, starts its first
// line.
fn help_text(words, name) {
    sh::capture_cached(300, ["env", "HOME=/nonexistent", words[0], "-" + name, "help"]).out
}

// The drivers of `-vo help` and `-ao help`: `\tNAME\tDESCRIPTION`.
fn drivers(text) {
    let out = [];
    for line in text.split("\n") {
        if !line.starts_with("\t") {
            continue;
        }
        let f = line.sub_string(1).split("\t");
        out.push(#{value: f[0], desc: if f.len() > 1 { f[1] } else { "" }});
    }
    out
}

// The filters of `-vf help` and `-af help`: `  NAME  : DESCRIPTION` (some, such as `scale`, are listed twice).
fn filters(text) {
    let out = [];
    let seen = #{};
    for line in text.split("\n") {
        let c = line.index_of(" : ");
        if !line.starts_with("  ") || c < 0 {
            continue;
        }
        let name = line.sub_string(0, c);
        name.trim();
        if seen[name] != () {
            continue;
        }
        seen[name] = true;
        let desc = line.sub_string(c + 3);
        desc.trim();
        out.push(#{value: name, desc: desc});
    }
    out
}

// The rows of a table whose header starts with `head` (`vc:`, `afm:`, `demuxer:`), and whose description is from
// its field `col` on: the codecs (`ffh264  ffmpeg  working  FFmpeg H.264  [h264]`), the codec families
// (`ffmpeg  FFmpeg's libavcodec codec family (native codecs)`) and the demuxers (`mkv  31  Matroska demuxer`).
// A name listed more than once is offered once, with its first description.
fn table(text, head, col) {
    let out = [];
    let seen = #{};
    let rows = false;
    for line in text.split("\n") {
        let t = line;
        t.trim();
        if !rows {
            rows = t.starts_with(head);
            continue;
        }
        let f = t.split(" ").filter(|w| w != "");
        if f.len() < col || seen[f[0]] != () {
            continue;
        }
        seen[f[0]] = true;
        let desc = f.extract(col).reduce(|s, w| if s == "" { w } else { s + " " + w }, "");
        let b = desc.index_of(" [");
        if b >= 0 {
            desc = desc.sub_string(0, b);
        }
        out.push(#{value: f[0], desc: desc});
    }
    out
}

// The profiles of mplayer's configuration files, the `[NAME]` sections, with their `profile-desc`.
fn profiles() {
    let out = [];
    let home = std_kinds::home();
    for file in ["/etc/mplayer/mplayer.conf", "/usr/local/etc/mplayer/mplayer.conf", home + "/.mplayer/config"] {
        let text = fs::read_file(file) ?? "";
        for line in text.split("\n") {
            line.trim();
            if line.starts_with("[") && line.ends_with("]") {
                let name = line.sub_string(1, line.len() - 2);
                if name != "default" && !out.some(|c| c.value == name) {
                    out.push(#{value: name, desc: ""});
                }
            } else if line.starts_with("profile-desc=") && !out.is_empty() {
                let d = line.sub_string(13);
                if d.len() > 1 && d.starts_with("\"") && d.ends_with("\"") {
                    d = d.sub_string(1, d.len() - 2);
                }
                out[out.len() - 1].desc = d;
            }
        }
    }
    out
}

// The candidates of `-NAME help`. The codecs are hundreds, and reading them takes milliseconds, so what is read is
// kept, by the text it is read from.
fn help_list(words, name) {
    let text = help_text(words, name);
    let key = `mplayer-${name}:` + text;
    sh::cache_get(key) ?? sh::cache_put(key, 3600, switch name {
        "vo" | "ao" => drivers(text),
        "vf" | "af" => filters(text),
        "vc" | "ac" => table(text, name + ":", 3),
        "vfm" | "afm" => table(text, name + ":", 1),
        _ => table(text, "demuxer:", 2),
    })
}

// The item after the last comma of `cur` among `candidates`, but those already in the list (by name: `xv:port=1`
// is `xv`, `-ffh264` is `ffh264`) unless `repeats`, or nothing if the item has the suboptions of a driver
// (`xv:port=1`) or the parameters of a filter (`scale=1280`), whose separator is `stop`. A `-` or `+` before a codec
// (`-ffh264`: skip it) or a demuxer (`+mkv`: force it) is kept.
fn list_item(cur, candidates, stop, repeats) {
    let c = lib_text::last_of(cur, [',']);
    let item = cur.sub_string(c + 1);
    if item.contains(stop) {
        return [];
    }
    let prefix = cur.sub_string(0, c + 1);
    if item.starts_with("-") || item.starts_with("+") {
        prefix += item.sub_string(0, 1);
    }
    if !repeats && c >= 0 {
        let given = [];
        for g in cur.sub_string(0, c).split(",") {
            if g.starts_with("-") || g.starts_with("+") {
                g = g.sub_string(1);
            }
            for sep in [":", "="] {
                let x = g.index_of(sep);
                if x >= 0 {
                    g = g.sub_string(0, x);
                }
            }
            given.push(g);
        }
        candidates = candidates.filter(|x| !given.contains(x.value));
    }
    #{prefix: prefix, candidates: candidates}
}

fn kind(name, cur, words) {
    switch name {
        "vo" | "ao" => list_item(cur, help_list(words, name), ":", false),
        "vf" | "af" => list_item(cur, help_list(words, name), "=", true),
        "vc" | "ac" | "vfm" | "afm" => list_item(cur, help_list(words, name), ":", false),
        // One demuxer, not a list.
        "demuxer" => list_item(cur, help_list(words, name), ",", false),
        "profiles" => lib_text::comma_list(cur, profiles()),
        "profile" => profiles(),
        "fstype" => list_item(cur, [
            #{value: "above", desc: "_NETWM_STATE_ABOVE"}, #{value: "below", desc: "_NETWM_STATE_BELOW"},
            #{value: "fullscreen", desc: "_NETWM_STATE_FULLSCREEN"}, #{value: "layer", desc: "_WIN_LAYER"},
            #{value: "netwm", desc: "force NETWM style"}, #{value: "none", desc: "clear the list"},
            #{value: "stays_on_top", desc: "_NETWM_STATE_STAYS_ON_TOP"}], "=", false),
        "files," | "dirs," => {
            let c = lib_text::last_of(cur, [',']);
            std_kinds::listing(cur.sub_string(c + 1), cur.sub_string(0, c + 1), name == "dirs,")
        }
        _ => throw `unknown kind: ${name}`,
    }
}
