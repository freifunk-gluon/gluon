#!/bin/sh

set -e

is_scriptfile() {
	if echo "$1" | grep -qE '.*\.sh$' || head -n1 "$1" | grep -qE '^#.*(sh|bash)$'; then
		return 0
	fi
	return 1
}

find contrib -type f | while read -r file; do
	if is_scriptfile "$file"; then
		shellcheck -f gcc "$file"
	fi
done

find package -type f | while read -r file; do
	if is_scriptfile "$file"; then
		shellcheck -x -f gcc -s sh -eSC2039,SC1091,SC2155,SC2034 "$file"
	fi
done

find scripts -type f | while read -r file; do
	if is_scriptfile "$file"; then
		shellcheck -f gcc -x -e SC2154,SC1090,SC2181,SC2155,SC2148,SC2034,SC2148  "$file"
	fi
done
