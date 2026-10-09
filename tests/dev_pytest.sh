# pytest: test files, the tests in a file (`FILE::CLASS::TEST`), markers from the configuration files,
# the settings of -o, and the options of pytest-xdist and pytest-cov.
__luish_internal plugin load "$EXTRA/completion/dev"
echo "load $?"
c() {
    echo "--- $1"
    __luish_internal complete "$1"
}
mkdir -p tests/__pycache__ src/pkg
cat >tests/test_things.py <<'PY'
import pytest

def helper():
    pass

def test_one():
    pass

@pytest.mark.slow
async def test_two():
    def test_inner():
        pass

class TestThing:
    def setup_method(self):
        pass

    def test_method(self):
        pass

    class TestNested:
        def test_deep(self):
            pass

    def test_after(self):
        pass

class Other:
    def test_not_collected(self):
        pass
PY
touch tests/conftest.py tests/other_test.py tests/data.txt src/pkg/mod.py
cat >pyproject.toml <<'TOML'
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "network",
]
TOML
cat >pytest.ini <<'INI'
[pytest]
markers =
    gpu: needs a GPU
    integration(name): an integration test
addopts = -ra
INI
echo "=== files and tests"
c 'pytest '
c 'pytest tests/'
c 'pytest tests/test_things.py::'
c 'pytest tests/test_things.py::test_'
c 'pytest tests/test_things.py::TestThing::'
c 'pytest tests/test_things.py::TestThing::TestNested::'
c 'pytest tests/test_things.py::Other::'
c 'pytest tests/nosuch.py::'
c 'pytest --doctest-modules src/pkg/'
c 'pytest --deselect tests/test_things.py::TestT'
echo "=== markers"
c 'pytest -m '
c 'pytest -m "slow and n'
c 'pytest -m "not (g'
echo "=== options and values"
c 'pytest --tb='
c 'pytest --lf'
c 'pytest -o log_c'
c 'pytest --log-level '
c 'pytest -p '
c 'pytest -n '
c 'pytest --dist='
c 'pytest --cov-report '
c 'pytest --cov='
c 'pytest --basetemp '
c 'pytest --pyargs py'
