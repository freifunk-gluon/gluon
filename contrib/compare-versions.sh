#!/bin/bash
set -e

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <version1> <version2>"
	exit 1
fi

GLUONDIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION_C="${GLUONDIR}/packages/gluon/admin/autoupdater/src/version.c"

if [ ! -f "$VERSION_C" ]; then
	echo "Error: autoupdater source not found." >&2
	echo "Please run 'make update' in the gluon root directory to fetch the packages feed before using this script." >&2
	exit 1
fi

if ! command -v gcc >/dev/null 2>&1; then
	echo "Error: gcc is required to compile the version comparison logic." >&2
	exit 1
fi

TMPBIN=$(mktemp)
trap 'rm -f "$TMPBIN"' EXIT

gcc -xc - -o "$TMPBIN" <<C_CODE
#include <stdio.h>
#include <stdlib.h>
#include "${VERSION_C}"

int main(int argc, char *argv[]) {
	if (newer_than(argv[1], argv[2]))
		puts(">");
	else if (newer_than(argv[2], argv[1]))
		puts("<");
	else
		puts("=");
	return 0;
}
C_CODE

"$TMPBIN" "$1" "$2"
