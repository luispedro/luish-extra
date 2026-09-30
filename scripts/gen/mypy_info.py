"""mypy's error codes, for `--enable-error-code` and `--disable-error-code`, and the Python versions it checks for
(`--python-version`), as JSON: {"codes": [[code, description], ...], "versions": ["3.9", ...]}.

    python mypy_info.py
"""
import json, sys
from mypy import defaults, errorcodes

lo = defaults.PYTHON3_VERSION_MIN[1]
hi = max(sys.version_info[1], defaults.PYTHON3_VERSION[1])
json.dump(dict(codes=sorted([c.code, c.description] for c in errorcodes.error_codes.values()),
               versions=[f"3.{v}" for v in range(lo, hi + 1)]), sys.stdout)
