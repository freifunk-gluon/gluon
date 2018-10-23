#!/usr/bin/env bash

set -e

[ "$GLUON_IMAGEDIR" -a "$GLUON_RELEASE" -a "$GLUON_SITEDIR" -a "$GLUON_TARGETSDIR" ] || exit 1


default_sysupgrade_ext='.bin'

output=
aliases=
manifest_aliases=

sysupgrade_ext=


SITE_CODE="$(scripts/site.sh site_code)"


get_filename() {
	local name="$1"
	echo -n "gluon-${SITE_CODE}-${GLUON_RELEASE}-${name}-sysupgrade${sysupgrade_ext}"
}

get_filepath() {
	local filename="$1"
	echo -n "${GLUON_IMAGEDIR}/sysupgrade/${filename}"
}

generate_line() {
	local model="$1"
	local filename="$2"
	local filesize="$3"

	local filepath="$(get_filepath "$filename")"
	[ -e "$filepath" ] || return 0

	local file256sum="$(scripts/sha256sum.sh "$filepath")"
	local file512sum="$(scripts/sha512sum.sh "$filepath")"

	echo "$model $GLUON_RELEASE $file256sum $filesize $filename"
	echo "$model $GLUON_RELEASE $file256sum $filename"
	echo "$model $GLUON_RELEASE $file512sum $filename"
}

generate() {
	[ "${output}" ] || return 0
	[ "$sysupgrade_ext" ] || return 0

	local filename="$(get_filename "$output")"
	local filepath="$(get_filepath "$filename")"
	[ -e "$filepath" ] || return 0
	local filesize="$(scripts/filesize.sh "$filepath")"

	generate_line "$output" "$filename" "$filesize"

	for alias in $aliases; do
		generate_line "$alias" "$(get_filename "$alias")" "$filesize"
	done

	for alias in $manifest_aliases; do
		generate_line "$alias" "$filename" "$filesize"
	done
}


. scripts/common.inc.sh

device() {
	generate

	output="$1"
	aliases=
	manifest_aliases=

	sysupgrade_ext="$default_sysupgrade_ext"
}

sysupgrade_image() {
	generate

	output="$1"
	aliases=
	manifest_aliases=

	if [ "$3" ]; then
		sysupgrade_ext="$3"
	else
		sysupgrade_ext="$2"
	fi
}

alias() {
	aliases="$aliases $1"
}

manifest_alias() {
	manifest_aliases="$manifest_aliases $1"
}

sysupgrade() {
	if [ "$2" ]; then
		sysupgrade_ext="$2"
	else
		sysupgrade_ext="$1"
	fi

	if [ -z "$output" ]; then
		default_sysupgrade_ext="$sysupgrade_ext"
	fi
}

. "${GLUON_TARGETSDIR}/$1"; generate
