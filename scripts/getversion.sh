#!/bin/sh

if [ $# -ne 1 ]; then
	echo >&2 "Usage: getversion.sh <directory>"
	exit 1
fi

cd "$1" || exit 1

cat .scmversion 2>/dev/null && exit 0
git --git-dir=.git describe --tags --always --abbrev=7 --dirty=+ 2>/dev/null && exit 0

echo unknown
