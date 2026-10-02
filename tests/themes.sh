# The plugin themes: its plugin.toml defines colour schemes, which luish reads only in interactive shells, so this
# runs luish -i. Every scheme is listed, every value in it is one style takes (luish reports one it doesn't on
# stderr, which goes to the output here), with the terminal's colours that each sets itself (the light ones inherit the
# rest), and a pair is chosen by the background.
run() {
    LUISH_BACKGROUND=$1 "$LUISH" -i -c "__luish_internal plugin load '$EXTRA/themes'; s() { __luish_internal style \"\$@\"; }; $2" \
        </dev/null 2>&1 | grep -v 'job control'
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
