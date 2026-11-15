# mplayer: its options (MPlayer 1.5's), and the drivers, filters, codecs and demuxers of `mplayer -NAME help`, of
# tests/bin/mplayer, a stand-in (cut short); the profiles from ~/.mplayer/config.
__luish_internal plugin load "$EXTRA/completion/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p .mplayer subs/en
touch movie.mkv movie.srt movie.ass
cat > .mplayer/config <<'CONF'
vo=xv
[fast]
profile-desc="no frills"
vo=x11
[default]
[hq]
vf=yadif
CONF
echo "=== options"
c 'mplayer -fs'
c 'mplayer -sub'
c 'mplayer -nos'
echo "=== values"
c 'mplayer -vo '
c 'mplayer -vo xv,'
c 'mplayer -vo gl:yuv=2,x'
c 'mplayer -ao p'
c 'mplayer -vf '
c 'mplayer -vf scale=640:480,y'
c 'mplayer -vf scale='
c 'mplayer -af-add v'
c 'mplayer -vc ffh'
c 'mplayer -vc -ffh264,ffh'
c 'mplayer -ac wma9'
c 'mplayer -vfm '
c 'mplayer -afm hw'
c 'mplayer -demuxer '
c 'mplayer -demuxer +m'
c 'mplayer -sub-demuxer l'
c 'mplayer -profile '
c 'mplayer -profile fast,'
c 'mplayer -show-profile h'
c 'mplayer -sws '
c 'mplayer -osdlevel '
c 'mplayer -fstype layer,s'
c 'mplayer -sub movie.srt,movie.a'
c 'mplayer -sub-paths subs/'
c 'mplayer -ss '
c 'mplayer -ss 10 m'
c 'mplayer -noconfig '
echo "=== arguments"
c 'mplayer m'
c 'mplayer -fs -loop 0 m'
echo "=== without mplayer"
PATH=/nonexistent
c 'mplayer -vo '
c 'mplayer m'
