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
"""

ACTIONS_TARGET="""
  {target_name}:
    name: {target_name}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - uses: actions/cache@v2
        id: cache-dl
        with:
          path: dl_target
          key: openwrt-dl-{target_name}-${{{{ hashFiles('modules') }}}}
      - name: Prepare download cache
        if: steps.cache-dl.outputs.cache-hit == 'true'
        run: mkdir -p openwrt/dl; mv dl_target/* openwrt/dl/; ls openwrt/dl
      - name: Install Dependencies
        run: sudo contrib/actions/install-dependencies.sh
      - name: Build
        run: contrib/actions/run-build.sh {target_name}
      - name: Create cache to save
        if: steps.cache-dl.outputs.cache-hit != 'true'
        run: mkdir dl_target; mv openwrt/dl/* dl_target/; find dl_target/ -size +20M -delete
      - name: Archive build logs
        if: ${{{{ !cancelled() }}}}
        uses: actions/upload-artifact@v1
        with:
          name: {target_name}_logs
          path: openwrt/logs
      - name: Archive build output
        uses: actions/upload-artifact@v1
        with:
          name: {target_name}_output
          path: output
"""

output = ACTIONS_HEAD

for target in sys.stdin:
	output += ACTIONS_TARGET.format(target_name=target.strip())

print(output)
