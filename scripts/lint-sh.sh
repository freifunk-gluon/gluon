#!/bin/sh

set -e

is_scriptfile() {
	echo "$1" | grep -q '\.sh$' || head -n1 "$1" | grep -qE '^#!(.*\<bash|/bin/sh)$'
}

is_initscript() {
	head -n1 "$1" | grep -qxF '#!/bin/sh /etc/rc.common'
}

find contrib -type f | while read -r file; do
	is_scriptfile "$file" || continue

	echo "Checking $file"
	shellcheck -f gcc "$file"
done

find package -type f | while read -r file; do
	if is_scriptfile "$file"; then
		echo "Checking $file"
		shellcheck -f gcc -x -s sh -e SC2039,SC3043,SC3037,SC3057 "$file"
	elif is_initscript "$file"; then
		echo "Checking $file (initscript)"
		shellcheck -f gcc -x -s sh -e SC2034,SC2039,SC3043,SC3037,SC3057 "$file"
	fi
done

find scripts -type f | while read -r file; do
	is_scriptfile "$file" || continue

	echo "Checking $file"
	shellcheck -f gcc -x "$file"
done
