#!/usr/bin/env python3

import sys

ACTIONS_HEAD = """
# Update this file after adding/removing/renaming a target by running
# `make list-targets BROKEN=1 | ./contrib/actions/generate-actions.py > ./.github/workflows/build-gluon.yml`

name: Build Gluon
on:
  push:
    branches:
      - master
      - next
      - v20*
  pull_request:
    types: [opened, synchronize, reopened]
jobs:
  build_firmware:
    strategy:
      fail-fast: false
      matrix:
        target: [{matrix}]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Install Dependencies
        run: sudo contrib/actions/install-dependencies.sh
      - name: Build
        run: contrib/actions/run-build.sh ${{{{ matrix.target }}}}
      - name: Archive build logs
        if: ${{{{ !cancelled() }}}}
        uses: actions/upload-artifact@v1
        with:
          name: ${{{{ matrix.target }}}}_logs
          path: openwrt/logs
      - name: Archive build output
        uses: actions/upload-artifact@v1
        with:
          name: ${{{{ matrix.target }}}}_output
          path: output
"""

targets = []

for target in sys.stdin:
    targets.append(target.strip())

output = ACTIONS_HEAD.format(matrix=", ".join(targets))

print(output)
