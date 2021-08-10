#!/bin/sh -e

make --no-print-directory list-targets BROKEN=1 | ./contrib/actions/generate-target-filters.py > .github/filters.yml
