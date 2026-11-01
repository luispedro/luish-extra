# virtualenv, tox (its environments and labels, read from tox.ini, setup.cfg, pyproject.toml and tox.toml) and pipx
# (the environments in its home, and their apps and injected packages).
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p ini/sub cfg legacy toml dists
cat >ini/tox.ini <<'INI'
[tox]
envlist = py3{11-13}, lint,
    docs
    django{42,52}-db{sqlite,pg}
labels =
    test = py311, py312
    static = lint

[testenv]
deps = pytest

[testenv:lint]
description = run the linters
commands = ruff check

[testenv:{docs,type}]
description = docs and types
INI
cat >cfg/setup.cfg <<'INI'
[metadata]
name = x

[tox:tox]
envlist = py312, flake8

[testenv:flake8]
description = flake8
INI
cat >legacy/pyproject.toml <<'TOML'
[project]
name = "x"

[tool.tox]
legacy_tox_ini = """
[tox]
env_list = py310, mypy

[testenv:mypy]
description = type checks
"""
TOML
cat >toml/tox.toml <<'TOML'
requires = ["tox>=4.20"]
env_list = ["3.13", "3.12", "lint", { product = [["a", "b"], ["c"]] }]
labels = { checks = ["lint", "type"], tests = ["3.12", "3.13"] }

[env_run_base]
commands = [["pytest"]]

[env.lint]
description = "run the linters"

[env."type"]
description = "type checks"
TOML
touch dists/x-1.0.tar.gz dists/x-1.0-py3-none-any.whl
v=.local/share/pipx/venvs
mkdir -p $v/black $v/httpie $v/.cache opt/pipx/venvs/ruff
printf '{"main_package": {"package": "black", "apps": ["black", "blackd"]}, "injected_packages": {"tomli": {"apps": []}, "jupyter-black": {"apps": ["jblack"]}}, "pipx_metadata_version": "0.5"}\n' >$v/black/pipx_metadata.json
printf '{"main_package": {"package": "httpie", "apps": ["http", "https"' >$v/httpie/pipx_metadata.json
echo "=== virtualenv"
c 'virtualenv --cr'
c 'virtualenv --creator '
c 'virtualenv --seeder='
c 'virtualenv --activators '
c 'virtualenv --activators bash,f'
c 'virtualenv --activators bash,fish,'
c 'virtualenv --pip '
c 'virtualenv -'
c 'virtualenv '
echo "=== tox"
c 'tox '
c 'tox --c'
cd ini
c 'tox -e '
c 'tox -e lint,py3'
c 'tox -e django42-'
c 'tox run -e '
c 'tox r -m '
c 'tox p -p '
mkdir -p ../bin
touch ../bin/pytest ../bin/python3
chmod +x ../bin/pytest ../bin/python3
old=$PATH
PATH=$PWD/../bin
c 'tox exec -e lint -- py'
PATH=$old
c 'tox --installpkg ../dists/'
c 'tox list --'
c 'tox -s'
cd sub
c 'tox -e l'
cd ../../cfg
c 'tox -e '
cd ../legacy
c 'tox -e '
cd ../toml
c 'tox -e '
c 'tox -m '
cd ..
c 'tox -e '
echo "=== pipx"
c 'pipx '
c 'pipx in'
c 'pipx uninstall '
c 'pipx upgrade --'
c 'pipx uninject black '
c 'pipx uninject --leave-deps black t'
c 'pipx exec black '
c 'pipx exec httpie '
c 'pipx inject b'
c 'pipx install --backend '
c 'pipx interpreter '
c 'pipx manifest '
c 'pipx help '
c 'pipx environment --value '
c 'pipx --global uninstall '
PIPX_GLOBAL_HOME=$PWD/opt/pipx
export PIPX_GLOBAL_HOME
c 'pipx uninstall --global '
PIPX_HOME=$PWD/opt/pipx
export PIPX_HOME
c 'pipx reinstall '
