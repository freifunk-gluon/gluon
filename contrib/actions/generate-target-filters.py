#!/usr/bin/env python3

# Update target filters using
#   make update-ci

import sys
import json

# these changes trigger rebuilds on all targets
common = [
    "modules",
    "Makefile",
    "patches/**",
    "targets/generic",
    "targets/targets.mk",
]

# these changes are only built on x86-64
extra = [
    "contrib/ci/minimal-site/**",
    "package/**"
]

_filter = dict()

# construct filters map from stdin
for target in sys.stdin:
    target = target.strip()

    _filter[target] = [
        f"targets/{target}"
    ] + common

    if target == "x86-64":
        _filter[target].extend(extra)

# print filters to stdout in json format, because json is stdlib and yaml compatible.
print(json.dumps(_filter, indent=2))
