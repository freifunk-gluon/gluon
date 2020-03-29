#!/usr/bin/env python3

import sys

ACTIONS_HEAD = """
# Update this file after adding/removing/renaming a target by running
# `make list-targets BROKEN=1 | ./contrib/actions/generate-actions.py > ./.github/workflows/build-gluon.yml`

name: Build Gluon
on:
  push:
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
"""

ACTIONS_TARGET="""
  {target_name}:
    name: {target_name}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Build
        run: bash contrib/actions/run-build.sh {target_name}
      - name: Archive build output
        uses: actions/upload-artifact@v1
        with:
          name: output
          path: output
"""

output = ACTIONS_HEAD

for target in sys.stdin:
	output += ACTIONS_TARGET.format(target_name=target.strip())

print(output)
