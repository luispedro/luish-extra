# xrandr, gsettings, dconf, notify-send, wmctrl, xdotool, swaymsg and hyprctl. xrandr's outputs and modes come from
# `xrandr --query`, gsettings's schemas, keys and values from gsettings, dconf's paths from `dconf list`, and wmctrl's
# windows from `wmctrl -l` (all stand-ins in tests/bin).
__luish_internal plugin load "$EXTRA/completion/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
echo "=== xrandr"
c 'xrandr --output '
c 'xrandr --output DP-1 --mode '
c 'xrandr --output eDP-1 --mode 1920x1080 --output DP-1 --right-of '
c 'xrandr --rot'
c 'xrandr --output DP-1 --rotate '
c 'xrandr -d :1 --output '
c 'xrandr --mode '
echo "=== gsettings"
c 'gsettings '
c 'gsettings g'
c 'gsettings get '
c 'gsettings get org.gnome.desktop.interface '
c 'gsettings --schemadir dir set org.gnome.desktop.interface color-scheme '
c 'gsettings set org.gnome.desktop.interface clock-show-seconds '
c 'gsettings set org.gnome.desktop.interface text-scaling-factor '
c 'gsettings list-keys org.gnome.desktop.wm.preferences '
c 'gsettings list-schemas --'
c 'gsettings help r'
echo "=== dconf"
c 'dconf '
c 'dconf read '
c 'dconf read /'
c 'dconf read /org/gnome/'
c 'dconf list /org/gnome/'
c 'dconf write /org/gnome/version '
c 'dconf reset -'
echo "=== notify-send"
c 'notify-send -u '
c 'notify-send --category=device,email.'
c 'notify-send --hint='
echo "=== wmctrl"
c 'wmctrl -a '
c 'wmctrl -i -c '
c 'wmctrl -r :ACTIVE: -b '
c 'wmctrl -r :ACTIVE: -b toggle,full'
c 'wmctrl -k '
echo "=== xdotool"
c 'xdotool get'
c 'xdotool search --'
c 'xdotool search --name firefox windowa'
c 'xdotool search --class kate windowactivate '
c 'xdotool key --window '
c 'xdotool key super+'
c 'xdotool key ctrl+c windowac'
c 'xdotool click '
c 'xdotool windowstate --toggle F'
c 'xdotool behave %1 '
c 'xdotool behave_screen_edge '
echo "=== swaymsg"
c 'swaymsg -t '
c 'swaymsg work'
echo "=== hyprctl"
c 'hyprctl mon'
c 'hyprctl dispatch toggle'
c 'hyprctl -j monitors '
c 'hyprctl rollinglog -'
c 'hyprctl notify '
