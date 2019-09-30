#!/bin/bash --norc

set -e
shopt -s nullglob


nodefault() {
	# We define a function instead of a variable, as variables could
	# be predefined in the environment (in theory)
	eval "gluon_feature_nodefault_$1() {
		:
	}"
}

packages() {
	:
}

for f in package/features packages/*/features; do
	. "$f"
done


# Shell variables can't contain minus signs, so we escape them
# using underscores (and also escape underscores to avoid mapping
# multiple inputs to the same output)
sanitize() {
	local v="$1"
	v="${v//_/_1}"
	v="${v//-/_2}"
	echo -n "$v"
}

vars=()

for feature in $1; do
	if [ "$(type -t "gluon_feature_nodefault_${feature}")" != 'function' ]; then
		echo "gluon-${feature}"
	fi

	vars+=("$(sanitize "$feature")=1")
done


nodefault() {
	:
}

# shellcheck disable=SC2086
packages() {
	local cond="$(sanitize "$1")"
	shift

	# We only allow variable names, parentheses and the operators: & | !
	if grep -q '[^A-Za-z0-9_()&|! ]' <<< "$cond"; then
		exit 1
	fi

	# Let will return false when the result of the passed expression is 0,
	# so we always add 1. This way false is only returned for syntax errors.
	local ret="$(env -i "${vars[@]}" bash --norc -ec "let _result_='1+($cond)'; echo -n \"\$_result_\"" 2>/dev/null)"
	case "$ret" in
	2)
		for pkg in "$@"; do
			echo "$pkg"
		done
		;;
	1)
		;;
	*)
		exit 1
	esac
}

for f in package/features packages/*/features; do
	. "$f"
done
