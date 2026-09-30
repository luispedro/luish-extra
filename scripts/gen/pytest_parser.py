"""pytest's parser, with the options of the plugins installed in the environment (pytest-xdist, pytest-cov), for
argparse_dump.py: `python argparse_dump.py pytest_parser.py parser`.

    python pytest_parser.py      # the configuration options (`-o NAME=VALUE`), as JSON [[name, help], ...]
"""
import json
from _pytest.config import get_config


def config():
    c = get_config()
    c.pluginmanager.load_setuptools_entrypoints("pytest11")
    return c


def parser():
    return config()._parser.optparser


if __name__ == "__main__":
    ini = config()._parser._inidict
    json.dump(sorted([name, v[0]] for name, v in ini.items()), __import__("sys").stdout)
