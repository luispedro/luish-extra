# pylint (its messages, by symbol and by ID, categories, extensions), flake8 (the codes of pycodestyle, pyflakes and
# mccabe) and autopep8 (its fixes).
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p pkg
touch pkg/__init__.py pkg/core.py notes.md setup.py
echo "=== pylint"
c 'pylint '
c 'pylint --disable '
c 'pylint --disable=unused-i'
c 'pylint -d missing-module-docstring,missing-f'
c 'pylint --enable W06'
c 'pylint --enable C0114,C01'
c 'pylint --fail-on '
c 'pylint --load-plugins pylint.extensions.doc'
c 'pylint --output-format '
c 'pylint --confidence HIGH,'
c 'pylint --persistent '
c 'pylint --const-naming-style '
c 'pylint --max-line'
c 'pylint --rcfile '
c 'pylint --help-msg W061'
echo "=== flake8"
c 'flake8 '
c 'flake8 --select '
c 'flake8 --select E5'
c 'flake8 --extend-ignore W503,E2'
c 'flake8 --ignore F40'
c 'flake8 --format '
c 'flake8 --color='
c 'flake8 --max-'
echo "=== autopep8"
c 'autopep8 '
c 'autopep8 --select '
c 'autopep8 --ignore E7'
c 'autopep8 --in'
c 'autopep8 --line-range '
