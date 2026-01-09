#!/usr/bin/env python3

# Update target filters using
#   make update-ci

import re
import os
import sys
import json

# these changes trigger rebuilds on all targets
common = [
    ".github/workflows/build-gluon.yml",
    "modules",
    "Makefile",
    "patches/**",
    "scripts/**",
    "targets/generic",
    "targets/targets.mk",
]

# these changes are only built on x86-64
extra = [
    "contrib/ci/minimal-site/**",
    "package/**"
]

_filter = dict()

# INCLUDE_PATTERN matches:
# include '...'
# include "..."
# include("...")
# include('...')
INCLUDE_PATTERN = "^\\s*include *\\(? *[\"']([^\"']+)[\"']"

# construct filters map from stdin
for target in sys.stdin:
    target = target.strip()

    _filter[target] = [
        f"targets/{target}"
    ] + common

    target_file = os.path.join(os.environ['GLUON_TARGETSDIR'], target)
    with open(target_file) as f:
        includes = re.findall(INCLUDE_PATTERN, f.read(), re.MULTILINE)
        _filter[target].extend([f"targets/{i}" for i in includes])

    if target == "x86-64":
        _filter[target].extend(extra)

# print filters to stdout in json format, because json is stdlib and yaml compatible.
print(json.dumps(_filter, indent=2))
