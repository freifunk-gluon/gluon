#!/bin/sh

set -e

is_scriptfile() {
	echo "$1" | grep -qE '.*\.sh$' || head -n1 "$1" | grep -qE '^#.*(sh|bash)$'
}

find contrib -type f | while read -r file; do
	is_scriptfile "$file" || continue

	echo "Checking $file"
	shellcheck -f gcc "$file"
done

find package -type f | while read -r file; do
	is_scriptfile "$file" || continue

	echo "Checking $file"
	shellcheck -f gcc -x -s sh -e SC2039,SC1091,SC2155,SC2034 "$file"
done

find scripts -type f | while read -r file; do
	is_scriptfile "$file" || continue

	echo "Checking $file"
	shellcheck -f gcc -x -e SC2154,SC1090,SC2181,SC2155,SC2148,SC2034,SC2148 "$file"
done
