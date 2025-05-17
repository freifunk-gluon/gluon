#!/usr/bin/env bash

set -e
# Script to list all upgrade scripts in a clear manner
# Limitations:
#  * Does only show scripts of packages whose `files'/`luasrc' directories represent the whole image filesystem (which are all Gluon packages)


SUFFIX1=files/lib/gluon/upgrade
SUFFIX2=luasrc/lib/gluon/upgrade


shopt -s nullglob


if tty -s <&1; then
	RED="$(echo -e '\x1b[01;31m')"
	GREEN="$(echo -e '\x1b[01;32m')"
	BLUE="$(echo -e '\x1b[01;34m')"
	RESET="$(echo -e '\x1b[0m')"
else
	RED=
	GREEN=
	BLUE=
	RESET=
fi


pushd "$(dirname "$0")/.." >/dev/null

find ./package packages -name Makefile | grep -v '^packages/packages/' | while read -r makefile; do
	dir="$(dirname "$makefile")"

	pushd "$dir" >/dev/null

	repo="$(dirname "$dir" | cut -d/ -f 2)"
	dirname="$(dirname "$dir" | cut -d/ -f 3-)"
	package="$(basename "$dir")"

	for file in "${SUFFIX1}"/* "${SUFFIX2}"/*; do
		basename="$(basename "${file}")"
		suffix="$(dirname "${file}")"
		printf "%s\t%s\n" "${basename}" "${BLUE}${repo}${RESET}/${dirname}${dirname:+/}${RED}${package}${RESET}/${suffix}/${GREEN}${basename}${RESET}"
	done
	popd >/dev/null
done | sort | cut -f2-

popd >/dev/null
