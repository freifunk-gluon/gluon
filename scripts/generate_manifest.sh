#!/usr/bin/env bash

set -e

[ "$GLUON_IMAGEDIR" -a "$GLUON_RELEASE" -a "$GLUON_SITEDIR" ] || exit 1


default_sysupgrade_ext='.bin'

output=
aliases=
manifest_aliases=

sysupgrade_ext=


SITE_CODE="$(scripts/site.sh site_code)"


generate_line() {
	local model="$1"
	local file="$2"

	[ ! -e "${GLUON_IMAGEDIR}/sysupgrade/$file" ] || echo "$model" "$GLUON_RELEASE" "$(scripts/sha256sum.sh "${GLUON_IMAGEDIR}/sysupgrade/$file")" "$file"
	[ ! -e "${GLUON_IMAGEDIR}/sysupgrade/$file" ] || echo "$model" "$GLUON_RELEASE" "$(scripts/sha512sum.sh "${GLUON_IMAGEDIR}/sysupgrade/$file")" "$file"
}

generate() {
	[ "${output}" ] || return 0

	if [ "$sysupgrade_ext" ]; then
		generate_line "$output" "gluon-${SITE_CODE}-${GLUON_RELEASE}-${output}-sysupgrade${sysupgrade_ext}"

		for alias in $aliases; do
			generate_line "$alias" "gluon-${SITE_CODE}-${GLUON_RELEASE}-${alias}-sysupgrade${sysupgrade_ext}"
		done

		for alias in $manifest_aliases; do
			generate_line "$alias" "gluon-${SITE_CODE}-${GLUON_RELEASE}-${output}-sysupgrade${sysupgrade_ext}"
		done
	fi
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

. targets/"$1"; generate
