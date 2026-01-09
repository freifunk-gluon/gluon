#!/bin/sh

check_command() {
	command -v "$1" >/dev/null 2>&1
}

if check_command sha256sum; then
	ret="$(sha256sum "$@")"
elif check_command shasum; then
	ret="$(shasum -a 256 "$@")"
elif check_command cksum; then
	ret="$(cksum -q -a sha256 "$@")"
else
	echo "$0: no suitable sha256sum implementation was found" >&2
	exit 1
fi

# shellcheck disable=SC2181
[ "$?" -eq 0 ] || exit 1

echo "$ret" | awk '{ print $1 }'
