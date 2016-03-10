#!/bin/bash

# Script to output the dependency graph of Gluon's packages
# Limitations:
#  * Works only if directory names and package names are the same (true for all Gluon packages)
#  * Doesn't show dependencies through virtual packages correctly



shopt -s nullglob


pushd "$(dirname "$0")/.." >/dev/null


escape_name() {
	echo -n "_$1" | tr -c '[:alnum:]' _
}

print_node () {
	echo "$(escape_name "$1") [label=\"$1\", shape=box];"
}

print_dep() {
	echo "$(escape_name "$1") -> $(escape_name "$2");"
}

echo 'digraph G {'

for makefile in ./package/*/Makefile; do
	dir="$(dirname "$makefile")"
	package="$(basename "$dir")"

	deps=$(grep -w DEPENDS "$makefile" | cut -d= -f2 | tr -d +)

	print_node "$package"
	for dep in $deps; do
		print_node "$dep"
		print_dep "$package" "$dep"
	done
done | sort -u

popd >/dev/null

echo '}'
