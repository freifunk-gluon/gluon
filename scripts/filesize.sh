#!/bin/sh

check_command() {
	command -v "$1" >/dev/null 2>&1
}

if check_command gnustat; then
	gnustat -c%s "$@"
elif check_command gstat; then
	gstat -c%s "$@"
elif check_command stat; then
	stat -c%s "$@"
else
	echo "$0: no suitable stat implementation was found" >&2
	exit 1
fi
