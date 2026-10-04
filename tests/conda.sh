# The plugin conda, loaded from luishrc with its options (and, at the end, enabled in config.toml): conda's hook and `conda activate ENV` run once, and later
# shells restore what they did, until something the block is keyed on changes. conda is stood in for by a script in
# ~/miniconda3 (one of the places looked in when the option root isn't given), which logs its calls and prints what the
# real one does, in short: the hook defines the function conda (and puts condabin in PATH), and activate sets the
# variables and reads the scripts of the environment's etc/conda/activate.d.
root=$HOME/miniconda3
mkdir -p "$root/bin" "$root/conda-meta" "$root/envs/py/conda-meta" "$root/envs/py/etc/conda/activate.d"
cat > "$root/bin/conda" <<'X'
#!/bin/sh
root=$(cd "$(dirname "$0")/.." && pwd)
echo "conda $*" >> "$HOME/conda.log"
case "$1 $2" in
"shell.bash hook")
    cat <<EOF
export CONDA_EXE='$root/bin/conda'
conda() {
    if [ "\$1" != activate ]; then "\$CONDA_EXE" "\$@"; return; fi
    ask_conda=\$("\$CONDA_EXE" shell.posix "\$@") || return
    eval "\$ask_conda"
    unset ask_conda
}
if [ -z "\${CONDA_SHLVL+x}" ]; then export CONDA_SHLVL=0 PATH='$root/condabin':\$PATH; fi
EOF
    ;;
"shell.posix activate")
    prefix=$root/envs/$3
    if [ ! -d "$prefix" ]; then echo "EnvironmentNameNotFound: $3" >&2; exit 1; fi
    echo "PS1='($3) '\"\$PS1\""
    echo "export PATH='$prefix/bin':\$PATH CONDA_PREFIX='$prefix' CONDA_DEFAULT_ENV='$3' CONDA_SHLVL=\$((CONDA_SHLVL + 1))"
    for f in "$prefix"/etc/conda/activate.d/*.sh; do [ -f "$f" ] && echo ". '$f'"; done
    ;;
esac
X
chmod +x "$root/bin/conda"
echo 'export FROM_SCRIPT=1' > "$root/envs/py/etc/conda/activate.d/a.sh"
C=$HOME/.config/luish
# Not the machine's PATH, which may have a conda of its own (a CI runner has /usr/bin/conda): the system's programs,
# linked here without it.
mkdir -p "$HOME/sysbin"
for f in /usr/bin/* /bin/*; do [ -e "$HOME/sysbin/${f##*/}" ] || ln -s "$f" "$HOME/sysbin/${f##*/}"; done
rm -f "$HOME/sysbin/conda" "$HOME/sysbin/mamba" "$HOME/sysbin/micromamba"
PATH=$HOME/sysbin
show='echo "PATH=$PATH"; echo "PS1=$PS1 CONDA_SHLVL=$CONDA_SHLVL CONDA_PREFIX=$CONDA_PREFIX"
echo "CONDA_DEFAULT_ENV=$CONDA_DEFAULT_ENV FROM_SCRIPT=$FROM_SCRIPT FROM_NEW=$FROM_NEW"; type conda | head -1
set | grep -c "^_luish_conda"'
run() {
    : > "$HOME/conda.log"
    PS1='$ ' "$LUISH" -i -c "$show" 2>&1 | grep -v 'job control' | sed "s|$HOME|~|g"
    sed "s|$HOME|~|g; s/^/ran: /" "$HOME/conda.log"
}
echo 'plugin load "$EXTRA/conda" env=py' > "$C/luishrc"
echo '--- the first shell runs conda'
run
echo '--- the next restores what it did'
run
echo '--- a changed activation script (read with .)'
echo 'export FROM_SCRIPT=2' > "$root/envs/py/etc/conda/activate.d/a.sh"
run
run
echo '--- a new activation script'
echo 'export FROM_NEW=1' > "$root/envs/py/etc/conda/activate.d/b.sh"
run
echo '--- a package installed in the environment, or in the installation'
touch "$root/envs/py/conda-meta/pkg-1.0.json"
run
touch "$root/conda-meta/conda-99.json"
run
echo '--- a .condarc'
echo 'auto_activate: false' > "$HOME/.condarc"
run
echo '--- a shell started with conda set up'
export CONDA_SHLVL=1
run
unset CONDA_SHLVL
echo '--- an environment that does not exist: an error, not cached'
echo 'plugin load "$EXTRA/conda" env=nope' > "$C/luishrc"
run
run
echo '--- no env: only the hook'
echo 'plugin load "$EXTRA/conda"' > "$C/luishrc"
run
echo '--- no conda'
echo 'plugin load "$EXTRA/conda" root=~/nowhere' > "$C/luishrc"
run
echo '--- enabled in config.toml, with its options: the block is cached on its own there too'
rm "$C/luishrc" "$HOME/.condarc"
printf '[plugins.enabled]\nconda = { path = "%s/conda", options = { env = "py" } }\n' "$EXTRA" >> "$C/config.toml"
run
run
echo 'export FROM_NEW=2' > "$root/envs/py/etc/conda/activate.d/b.sh"
run
run
