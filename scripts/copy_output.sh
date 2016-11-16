#!/usr/bin/env bash

set -e

[ "$GLUON_IMAGEDIR" -a "$LEDE_TARGET" -a "$GLUON_RELEASE" ] || exit 1


output=
profile=
aliases=

factory_ext=
factory_suffix=
sysupgrade_ext=
sysupgrade_suffix=


mkdir -p "${GLUON_IMAGEDIR}/factory" "${GLUON_IMAGEDIR}/sysupgrade"

LEDE_BINDIR="${LEDE_TARGET//-/\/}"

GLUON_SITE_CODE=SITE_CODE


copy() {
	[ "${output}" ] || return 0

	if [ "$factory_ext" ]; then
		rm -f "${GLUON_IMAGEDIR}/factory/gluon-"*"-${output}${factory_ext}"
		cp "lede/bin/targets/${LEDE_BINDIR}/lede-${LEDE_TARGET}${profile}${factory_suffix}${factory_ext}" \
			"${GLUON_IMAGEDIR}/factory/gluon-${GLUON_SITE_CODE}-${GLUON_RELEASE}-${output}${factory_ext}"

		for alias in $aliases; do
			rm -f "${GLUON_IMAGEDIR}/factory/gluon-"*"-${alias}${factory_ext}"
			ln -s "gluon-${GLUON_SITE_CODE}-${GLUON_RELEASE}-${output}${factory_ext}" \
				"${GLUON_IMAGEDIR}/factory/gluon-${GLUON_SITE_CODE}-${GLUON_RELEASE}-${alias}${factory_ext}"
		done
	fi

	if [ "$sysupgrade_ext" ]; then
		rm -f "${GLUON_IMAGEDIR}/sysupgrade/gluon-"*"-${output}-sysupgrade${sysupgrade_ext}"
		cp "lede/bin/targets/${LEDE_BINDIR}/lede-${LEDE_TARGET}${profile}${sysupgrade_suffix}${sysupgrade_ext}" \
			"${GLUON_IMAGEDIR}/sysupgrade/gluon-${GLUON_SITE_CODE}-${GLUON_RELEASE}-${output}-sysupgrade${sysupgrade_ext}"

		for alias in $aliases; do
			rm -f "${GLUON_IMAGEDIR}/sysupgrade/gluon-"*"-${alias}-sysupgrade${sysupgrade_ext}"
			ln -s "gluon-${GLUON_SITE_CODE}-${GLUON_RELEASE}-${output}-sysupgrade${sysupgrade_ext}" \
				"${GLUON_IMAGEDIR}/sysupgrade/gluon-${GLUON_SITE_CODE}-${GLUON_RELEASE}-${alias}-sysupgrade${sysupgrade_ext}"
		done
	fi
}


config() {
	:
}

device() {
	copy

	output="$1"
	profile="-$2"
	aliases=

	factory_ext='.bin'
	factory_suffix='-squashfs-factory'
	sysupgrade_ext='.bin'
	sysupgrade_suffix='-squashfs-sysupgrade'
}

factory_image() {
	copy

	output="$1"
	aliases=

	if [ "$3" ]; then
		profile="-$2"
		factory_ext="$3"
	else
		profile=""
		factory_ext="$2"
	fi

	factory_suffix=
	sysupgrade_ext=
	sysupgrade_suffix=
}

sysupgrade_image() {
	copy

	output="$1"
	aliases=

	if [ "$3" ]; then
		profile="-$2"
		sysupgrade_ext="$3"
	else
		profile=""
		sysupgrade_ext="$2"
	fi

	factory_ext=
	factory_suffix=
	sysupgrade_suffix=
}

alias() {
	aliases="$aliases $1"
}

packages() {
	:
}

factory() {
	if [ "$2" ]; then
		factory_suffix="$1"
		factory_ext="$2"
	else
		factory_ext="$1"
	fi
}

sysupgrade() {
	if [ "$2" ]; then
		sysupgrade_suffix="$1"
		sysupgrade_ext="$2"
	else
		sysupgrade_ext="$1"
	fi
}

. targets/"$1"; copy
