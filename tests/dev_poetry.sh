# poetry: its commands (and those of its namespaces: `cache clear`, `self show plugins`), and what the
# project's pyproject.toml and poetry.lock have: groups, extras, dependencies, scripts, sources.
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir bin
touch bin/python3.12 bin/pypy3 bin/xtool
chmod +x bin/*
cat >pyproject.toml <<'TOML'
[project]
name = "demo"
dependencies = ["numpy>=2", "requests"]

[project.optional-dependencies]
plot = ["matplotlib"]

[project.scripts]
xdemo = "demo:main"

[dependency-groups]
lint = ["ruff"]

[tool.poetry.dependencies]
python = "^3.11"
click = "^8"

[tool.poetry.group.dev.dependencies]
pytest = "^8"

[tool.poetry.group.docs]
optional = true

[tool.poetry.extras]
cli = ["click"]

[[tool.poetry.source]]
name = "private"
url = "https://example.org/simple"
priority = "supplemental"
TOML
cat >poetry.lock <<'LOCK'
[[package]]
name = "certifi"
version = "2026.9.1"

[[package]]
name = "numpy"
version = "2.3.1"
LOCK
PATH=$PWD/bin
c 'poetry '
c 'poetry --'
c 'poetry -C '
c 'poetry add --'
c 'poetry add -G '
c 'poetry add --extras '
c 'poetry install --with '
c 'poetry install --only='
c 'poetry sync -E '
c 'poetry remove '
c 'poetry update '
c 'poetry show '
c 'poetry show --format '
c 'poetry run x'
c 'poetry build -f '
c 'poetry cache '
c 'poetry cache clear --'
c 'poetry self '
c 'poetry self show '
c 'poetry source '
c 'poetry source remove '
c 'poetry source add --priority '
c 'poetry env use '
c 'poetry config '
c 'poetry config virtualenvs.'
c 'poetry version '
c 'poetry help '
c 'poetry list '
c 'poetry --verbose check --'
