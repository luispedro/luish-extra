# Sphinx configuration for the luish-extra documentation (Markdown via MyST).

project = "luish-extra"
author = "Luis Pedro Coelho"
copyright = "2026, Luis Pedro Coelho"

extensions = ["myst_parser"]
source_suffix = {".md": "markdown"}
exclude_patterns = ["_build"]

myst_heading_anchors = 3

html_theme = "furo"
html_title = "luish-extra"
