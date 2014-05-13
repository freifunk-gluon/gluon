#!/bin/sh

check_command() {
	which $1 >/dev/null 2>&1
}

if check_command md5sum; then
	ret="$(md5sum "$@")"
elif check_command md5; then
	ret="$(md5 -q "$@")"
else
	echo "$0: no suitable md5sum implementation was found" >&1
	exit 1
fi

[ "$?" -eq 0 ] || exit 1

echo "$ret" | awk '{ print $1 }'
