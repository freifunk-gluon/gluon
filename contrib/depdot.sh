#!/usr/bin/env bash

# Script to output the dependency graph of Gluon's packages
# Limitations:
#  * Doesn't show dependencies through virtual packages correctly

set -e
shopt -s nullglob


pushd "$(dirname "$0")/.." >/dev/null


escape_name() {
	echo -n "_$1" | tr -c '[:alnum:]' _
}

print_node() {
	echo "$(escape_name "$1") [label=\"$1\", shape=box];"
}

print_dep() {
	echo "$(escape_name "$1") -> $(escape_name "$2");"
}

print_package() {
	local package="$1" depends="$2"
	# shellcheck disable=SC2086
	set -- $depends

	print_node "$package"
	for dep in "$@"; do
		print_node "$dep"
		print_dep "$package" "$dep"
	done
}

make -C openwrt -s prepare-tmpinfo

echo 'digraph G {'

cat ./openwrt/tmp/info/.packageinfo-feeds_gluon_base_* | while read -r key value; do
	case "$key" in
	'Package:')
		package="$value"
		;;
	'Depends:')
		depends="${value//+/}"
		;;
	'@@')
		print_package "$package" "$depends"
		;;
	esac
done | sort -u

popd >/dev/null

echo '}'
