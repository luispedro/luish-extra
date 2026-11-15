# The plugin themes: its plugin.toml defines colour schemes, which luish reads only in interactive shells, so this
# runs luish -i. Every scheme is listed, every value in it is one style takes (luish reports one it doesn't on
# stderr, which goes to the output here), with the terminal's colours that each sets itself (the light ones inherit the
# rest), and a pair is chosen by the background.
# The styles luish added after 0.8 (they fall back to ui.* or menu) are left out, so that the output is the same with
# luish 0.8.0 and main; drop the filter when luish-version goes past 0.8 and the schemes can set them.
new_styles='^(warning|menu\.prefix|menu\.group|menu\.directory|menu\.executable) '
run() {
    LUISH_BACKGROUND=$1 "$LUISH" -i -c "__luish_internal plugin load '$EXTRA/themes'; s() { __luish_internal style \"\$@\"; }; $2" \
        </dev/null 2>&1 | grep -v 'job control' | grep -Ev "$new_styles"
}
echo '--- the schemes'
run dark 's -c'
for scheme in ansi-dark ansi-light solarized-dark solarized-light gruvbox-dark gruvbox-light \
    catppuccin-mocha catppuccin-latte tokyonight-night tokyonight-day; do
    echo "--- $scheme"
    run dark "s -c $scheme && s && s -s $scheme | grep '^terminal'"
done
echo '--- a pair, by the background'
run dark 's -c gruvbox-dark gruvbox-light; s keyword'
run light 's -c gruvbox-dark gruvbox-light; s keyword'
