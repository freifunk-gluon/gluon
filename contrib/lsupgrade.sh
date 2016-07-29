#!/bin/bash

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

find ./package packages -name Makefile | while read makefile; do
	dir="$(dirname "$makefile")"

	pushd "$dir" >/dev/null

	repo="$(dirname "$dir" | cut -d/ -f 2)"
	dirname="$(dirname "$dir" | cut -d/ -f 3-)"
	package="$(basename "$dir")"

	for file in "${SUFFIX1}"/*; do
		echo "${GREEN}$(basename "${file}")${RESET}" "(${BLUE}${repo}${RESET}/${dirname}${dirname:+/}${RED}${package}${RESET}/${SUFFIX1})"
	done
	for file in "${SUFFIX2}"/*; do
		echo "${GREEN}$(basename "${file}")${RESET}" "(${BLUE}${repo}${RESET}/${dirname}${dirname:+/}${RED}${package}${RESET}/${SUFFIX2})"
	done
	popd >/dev/null
done | sort

popd >/dev/null
