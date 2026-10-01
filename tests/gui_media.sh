# gimp, inkscape, obs and audacity. GIMP's sessions are the sessionrc.NAME files of each version's directory in
# ~/.config/GIMP; Inkscape's object IDs come from the SVG files on the command line, and its actions from
# `inkscape --action-list` (tests/bin/inkscape, a stand-in); OBS's profiles, scene collections and scenes come from
# ~/.config/obs-studio.
__luish_internal plugin load "$EXTRA/complete/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p .config/GIMP/2.10 .config/GIMP/3.0 out
touch .config/GIMP/2.10/sessionrc .config/GIMP/2.10/sessionrc.photo .config/GIMP/3.0/sessionrc.photo \
    .config/GIMP/3.0/sessionrc.batch photo.jpg drawing.png
cat >figure.svg <<'SVG'
<?xml version="1.0" encoding="UTF-8"?>
<!-- id="not-an-element" -->
<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
     width="100" height="100" id="svg1">
  <g inkscape:label="Layer 1" inkscape:groupmode="layer" id="layer1">
    <rect
       id="panel-a" x="0" y="0" width="10" height="10" data-id="no" />
    <path d="M 0,0 L 1,1" id="arrow&amp;1"/>
    <text xml:id="no" x="1" y="1">grid="no" id="no"</text>
  </g>
</svg>
SVG
obs=.config/obs-studio
mkdir -p $obs/basic/profiles/Untitled $obs/basic/profiles/Talks $obs/basic/scenes
printf '[General]\nName=Untitled\n\n[Video]\nBaseCX=1920\n' >.config/obs-studio/basic/profiles/Untitled/basic.ini
printf '[General]\nName=Conference talks\n' >.config/obs-studio/basic/profiles/Talks/basic.ini
cat >.config/obs-studio/basic/scenes/Untitled.json <<'JSON'
{"current_scene": "Main", "name": "Untitled", "scene_order": [{"name": "Main"}, {"name": "Be right back"}],
 "sources": [{"id": "scene", "name": "Main"}]}
JSON
cat >.config/obs-studio/basic/scenes/Lectures.json <<'JSON'
{"name": "Lectures", "scene_order": [{"name": "Slides"}, {"name": "Camera"}]}
JSON
echo '{"name": "Old"}' >.config/obs-studio/basic/scenes/Lectures.json.bak
printf '[Basic]\nProfile=Untitled\nProfileDir=Untitled\nSceneCollection=Lectures\nSceneCollectionFile=Lectures\n' \
    >.config/obs-studio/user.ini
echo "=== gimp"
c 'gimp --s'
c 'gimp -'
c 'gimp --session '
c 'gimp --session=b'
c 'gimp --batch-interpreter '
c 'gimp --stack-trace-mode='
c 'gimp -i -b - p'
c 'gimp --gegl-swap-compression '
echo "=== inkscape"
c 'inkscape --export-'
c 'inkscape -h 100 -'
c 'inkscape --export-type='
c 'inkscape --export-type=png,p'
c 'inkscape --export-type pdf --export-filename '
c 'inkscape --export-filename=out/ '
c 'inkscape figure.svg --export-id='
c 'inkscape figure.svg --export-id="layer1;p'
c 'inkscape figure.svg --query-id panel-a,a'
c 'inkscape --query-id='
c 'inkscape figure.svg --select '
c 'inkscape --actions='
c 'inkscape --actions="export-type:png;export-'
c 'inkscape --actions=export-type:p'
c 'inkscape --convert-dpi-method '
c 'inkscape --export-png-color-mode=RGB'
echo "=== obs"
c 'obs --'
c 'obs --profile '
c 'obs --collection '
c 'obs --scene '
c 'obs --collection Untitled --scene '
c 'obs --collection=Untitled --scene='
c 'obs --startrecording '
echo "=== audacity"
c 'audacity -'
c 'audacity --session-type '
c 'audacity -d p'
echo "=== without configuration"
HOME=$PWD/out
c 'gimp --session '
c 'obs --profile '
c 'obs --scene '
