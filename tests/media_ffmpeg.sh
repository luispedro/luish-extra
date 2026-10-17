# ffmpeg: its options and those of libavcodec and libavformat from ffmpeg_opts.rhai, for an input (before the first
# -i) or an output, with the private options of the codecs and the format chosen, and the values from the listings
# and the help of tests/bin/ffmpeg (ffmpeg 9.0.2's, cut short); -map's streams from tests/bin/ffprobe.
__luish_internal plugin load "$EXTRA/completion/media"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
touch in.mp4 graph.txt
echo "=== options"
c 'ffmpeg -ss'
c 'ffmpeg -hwacc'
c 'ffmpeg -i in.mp4 -hwacc'
c 'ffmpeg -i in.mp4 -mov'
c 'ffmpeg -i in.mp4 -probes'
c 'ffmpeg -probes'
c 'ffmpeg -nost'
c 'ffmpeg -i in.mp4 -c:'
c 'ffmpeg -i in.mp4 -b:'
c 'ffmpeg -i in.mp4 -c:v:'
c 'ffmpeg -i in.mp4 -metadata:'
c 'ffmpeg -i in.mp4 -metadata:s:'
c 'ffmpeg -i in.mp4 -y:'
echo "=== private options"
c 'ffmpeg -i in.mp4 -c:v libx264 -pr'
c 'ffmpeg -i in.mp4 -c:v libx264 -c:a aac -aac_'
c 'ffmpeg -i in.mp4 -c:v libx264 -preset:'
c 'ffmpeg -i in.mp4 -c:v libx264 out.mp4 -pr'
c 'ffmpeg -i in.mp4 -c:v copy -pr'
c 'ffmpeg -i in.mp4 -f mp4 -movfl'
echo "=== codecs and formats"
c 'ffmpeg -i in.mp4 -c:v '
c 'ffmpeg -i in.mp4 -c:a '
c 'ffmpeg -i in.mp4 -acodec '
c 'ffmpeg -i in.mp4 -c:s:0 '
c 'ffmpeg -i in.mp4 -codec '
c 'ffmpeg -c:v '
c 'ffmpeg -i in.mp4 -f '
c 'ffmpeg -f '
c 'ffmpeg -h '
c 'ffmpeg -h muxer='
echo "=== values"
c 'ffmpeg -i in.mp4 -c:v libx264 -aq-mode '
c 'ffmpeg -i in.mp4 -f mp4 -movflags '
c 'ffmpeg -i in.mp4 -f mp4 -movflags +faststart+frag_'
c 'ffmpeg -fflags +gen'
c 'ffmpeg -i in.mp4 -fflags '
c 'ffmpeg -i in.mp4 -strict '
c 'ffmpeg -i in.mp4 -pix_fmt '
c 'ffmpeg -i in.mp4 -sample_fmt '
c 'ffmpeg -i in.mp4 -ch_layout '
c 'ffmpeg -i in.mp4 -ch_layout FL+'
c 'ffmpeg -i in.mp4 -bsf:v h264_mp4toannexb,'
c 'ffmpeg -hwaccel '
c 'ffmpeg -init_hw_device '
c 'ffmpeg -i in.mp4 -disposition:a:0 default+'
c 'ffmpeg -i in.mp4 -s hd'
c 'ffmpeg -r '
c 'ffmpeg -loglevel repeat+'
c 'ffmpeg -i in.mp4 -metadata ti'
c 'ffmpeg -protocol_whitelist file,'
c 'ffmpeg -i in.mp4 -target pal-'
c 'ffmpeg -i in.mp4 -/vf '
c 'ffmpeg -i '
c 'ffmpeg -i in.mp4 -c:v libx264 '
echo "=== filtergraphs"
c 'ffmpeg -i in.mp4 -vf '
c 'ffmpeg -i in.mp4 -vf scale=w=1280:h=-1,f'
c 'ffmpeg -i in.mp4 -af '
c 'ffmpeg -i in.mp4 -filter:a '
c 'ffmpeg -i in.mp4 -vf scale='
c 'ffmpeg -i in.mp4 -vf scale=w=1280:in_r'
c 'ffmpeg -i in.mp4 -vf scale=in_range='
c 'ffmpeg -i in.mp4 -vf format=pix_fmts='
c 'ffmpeg -i in.mp4 -i in.mp4 -filter_complex "[0:v][1:v]overlay[v];['
c 'ffmpeg -i in.mp4 -filter_complex "hflip[a];[a]spl'
echo "=== map"
c 'ffmpeg -i in.mp4 -i missing.mkv -map '
c 'ffmpeg -i in.mp4 -map -0:'
c 'ffmpeg -i in.mp4 -filter_complex "[0:v]split[a][b];[a]hflip[c]" -map ['
c 'ffmpeg -i in.mp4 -map_metadata '
echo "=== without ffmpeg"
PATH=/nonexistent
c 'ffmpeg -i in.mp4 -c:v '
c 'ffmpeg -i in.mp4 -c:v libx264 -pres'
c 'ffmpeg -i in.mp4 -map '
