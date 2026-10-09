# firefox, thunderbird, chromium and google-chrome. Mozilla's profiles are the Name= of the [ProfileN] sections of
# profiles.ini (in ~/.mozilla/firefox, or the Snap's directory); Chrome's are the directories of profile.info_cache in
# the Local State of the user data directory (~/.config/google-chrome, or that of --user-data-dir).
__luish_internal plugin load "$EXTRA/completion/gui"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p .mozilla/firefox snap/thunderbird/common/.thunderbird .config/google-chrome other
cat >.mozilla/firefox/profiles.ini <<'INI'
[Profile1]
Name=work
IsRelative=1
Path=abcd1234.work

[Profile0]
Name=default-release
IsRelative=1
Path=wxyz9876.default-release
Default=1

[General]
StartWithLastProfile=1
INI
printf '[Profile0]\nName=mail\nPath=m1.mail\n' >snap/thunderbird/common/.thunderbird/profiles.ini
cat >'.config/google-chrome/Local State' <<'JSON'
{"browser": {"enabled_labs_experiments": []}, "profile": {"info_cache": {"Default": {"name": "Person 1"},
 "Profile 2": {"name": "Work"}}, "last_used": "Default"}}
JSON
echo '{"profile": {"info_cache": {"Default": {"name": "Testing"}}}}' >'other/Local State'
touch page.html
echo "=== firefox"
c 'firefox -P '
c 'firefox --pr'
c 'firefox --private-window'
c 'firefox --profile '
c 'firefox --new-tab x p'
echo "=== thunderbird"
c 'thunderbird -P '
c 'thunderbird -c'
c 'thunderbird --com'
echo "=== chrome"
c 'google-chrome --profile-directory='
c 'chromium --user-data-dir=other --profile-directory='
c 'google-chrome --oz'
c 'google-chrome --ozone-platform-hint='
c 'google-chrome --password-store='
c 'google-chrome --headless --print-to-pdf'
c 'google-chrome-stable --load-extension='
