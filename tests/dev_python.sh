# mypy (with the inverses of its flags, and its error codes), ruff (its help, linters and rules are asked of
# tests/bin/ruff, a stand-in) and twine.
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p pkg/__pycache__ dist
touch pkg/__init__.py pkg/core.py pkg/core.pyi pkg/notes.md analysis.ipynb main.py dist/x-1.0-py3-none-any.whl dist/x-1.0.tar.gz
printf '[distutils]\nindex-servers =\n    private\n\n[private]\nrepository = https://example.org/\n' >.pypirc
echo "=== mypy"
c 'mypy '
c 'mypy pkg/'
c 'mypy --strict-o'
c 'mypy --no-strict-o'
c 'mypy --allow-untyped-d'
c 'mypy --python-version '
c 'mypy --follow-imports='
c 'mypy --disable-error-code '
c 'mypy --enable-error-code unused-'
c 'mypy --html-report '
c 'mypy -m '
c 'mypy -c '
c 'mypy -p pk'
echo "=== ruff"
c 'ruff '
c 'ruff check --fi'
c 'ruff check --output-format '
c 'ruff check --target-version='
c 'ruff check --select '
c 'ruff check --select F'
c 'ruff check --select F4'
c 'ruff check --ignore E501,B'
c 'ruff check --extend-select PL'
c 'ruff check --select PLR0'
c 'ruff check --color '
c 'ruff check '
c 'ruff check pkg/'
c 'ruff format --line'
c 'ruff rule '
c 'ruff rule E5'
c 'ruff config '
c 'ruff config lint.'
c 'ruff config lint.f'
c 'ruff help '
c 'ruff nosuch --'
echo "=== twine"
c 'twine '
c 'twine upload '
c 'twine upload dist/'
c 'twine upload -r '
c 'twine upload --repository-url '
c 'twine check --'
