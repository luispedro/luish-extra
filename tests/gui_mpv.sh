# mpv: its options are read from `mpv --list-options`, and the values of --vo, --vf, --hwdec, --profile and
# --audio-device from `mpv --NAME=help`, of tests/bin/mpv, a stand-in (mpv 0.41.0's, cut short).
__luish_internal plugin load "$EXTRA/complete/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p shots
touch movie.mkv movie.srt
echo "=== options"
c 'mpv --'
c 'mpv --f'
c 'mpv --no-f'
c 'mpv --alang-'
c 'mpv --sub-file'
c 'mpv --sub-files-'
c 'mpv --gam'
c 'mpv --override'
echo "=== values"
c 'mpv --screenshot-format='
c 'mpv --loop='
c 'mpv --loop-file '
c 'mpv --fs='
c 'mpv --start='
c 'mpv --start 10 m'
c 'mpv --alang-add en m'
c 'mpv --screenshot-dir '
c 'mpv --sub-file movie.mkv --sub-file='
c 'mpv --vo='
c 'mpv --vo=gpu-next,g'
c 'mpv --vf='
c 'mpv --vf=scale=w=1280,f'
c 'mpv --vf=scale=w='
c 'mpv --hwdec='
c 'mpv --profile=fast,'
c 'mpv --audio-device='
echo "=== arguments"
c 'mpv m'
c 'mpv --fs -- --'
echo "=== without mpv"
PATH=/nonexistent
c 'mpv --'
c 'mpv m'
