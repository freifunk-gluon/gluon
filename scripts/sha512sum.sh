#!/bin/sh

check_command() {
	which "$1" >/dev/null 2>&1
}

if check_command sha512sum; then
	ret="$(sha512sum "$@")"
elif check_command shasum; then
	ret="$(shasum -a 512 "$@")"
elif check_command cksum; then
	ret="$(cksum -q -a sha512 "$@")"
else
	echo "$0: no suitable sha512sum implementation was found" >&2
	exit 1
fi

[ "$?" -eq 0 ] || exit 1

echo "$ret" | awk '{ print $1 }'
