#!/usr/bin/env bash

set -e

[ "$GLUON_IMAGEDIR" -a "$GLUON_PACKAGEDIR" -a "$OPENWRT_TARGET" -a "$GLUON_RELEASE" -a "$GLUON_SITEDIR" ] || exit 1


default_factory_ext='.bin'
default_factory_suffix='-squashfs-factory'
default_sysupgrade_ext='.bin'
default_sysupgrade_suffix='-squashfs-sysupgrade'

output=
profile=
aliases=

factory_ext=
factory_suffix=
sysupgrade_ext=
sysupgrade_suffix=

no_opkg=


mkdir -p "${GLUON_IMAGEDIR}/factory" "${GLUON_IMAGEDIR}/sysupgrade"

if [ "$(expr match "$OPENWRT_TARGET" '.*-.*')" -gt 0 ]; then
	OPENWRT_BINDIR="${OPENWRT_TARGET//-/\/}"
else
	OPENWRT_BINDIR="${OPENWRT_TARGET}/generic"
fi

SITE_CODE="$(scripts/site.sh site_code)"
PACKAGE_PREFIX="gluon-${SITE_CODE}-${GLUON_RELEASE}"

copy() {
	[ "${output}" ] || return 0
	want_device "${output}" || return 0

	if [ "$factory_ext" ]; then
		rm -f "${GLUON_IMAGEDIR}/factory/gluon-"*"-${output}${factory_ext}"
		cp "openwrt/bin/targets/${OPENWRT_BINDIR}/openwrt-${OPENWRT_TARGET}${profile}${factory_suffix}${factory_ext}" \
			"${GLUON_IMAGEDIR}/factory/gluon-${SITE_CODE}-${GLUON_RELEASE}-${output}${factory_ext}"

		for alias in $aliases; do
			rm -f "${GLUON_IMAGEDIR}/factory/gluon-"*"-${alias}${factory_ext}"
			ln -s "gluon-${SITE_CODE}-${GLUON_RELEASE}-${output}${factory_ext}" \
				"${GLUON_IMAGEDIR}/factory/gluon-${SITE_CODE}-${GLUON_RELEASE}-${alias}${factory_ext}"
		done
	fi

	if [ "$sysupgrade_ext" ]; then
		rm -f "${GLUON_IMAGEDIR}/sysupgrade/gluon-"*"-${output}-sysupgrade${sysupgrade_ext}"
		cp "openwrt/bin/targets/${OPENWRT_BINDIR}/openwrt-${OPENWRT_TARGET}${profile}${sysupgrade_suffix}${sysupgrade_ext}" \
			"${GLUON_IMAGEDIR}/sysupgrade/gluon-${SITE_CODE}-${GLUON_RELEASE}-${output}-sysupgrade${sysupgrade_ext}"

		for alias in $aliases; do
			rm -f "${GLUON_IMAGEDIR}/sysupgrade/gluon-"*"-${alias}-sysupgrade${sysupgrade_ext}"
			ln -s "gluon-${SITE_CODE}-${GLUON_RELEASE}-${output}-sysupgrade${sysupgrade_ext}" \
				"${GLUON_IMAGEDIR}/sysupgrade/gluon-${SITE_CODE}-${GLUON_RELEASE}-${alias}-sysupgrade${sysupgrade_ext}"
		done
	fi
}


. scripts/common.inc.sh

device() {
	copy

	output="$1"
	profile="-$2"
	aliases=

	factory_ext="$default_factory_ext"
	factory_suffix="$default_factory_suffix"
	sysupgrade_ext="$default_sysupgrade_ext"
	sysupgrade_suffix="$default_sysupgrade_suffix"
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

factory() {
	if [ "$2" ]; then
		factory_suffix="$1"
		factory_ext="$2"
	else
		factory_ext="$1"
	fi

	if [ -z "$profile" ]; then
		default_factory_ext="$factory_ext"
		default_factory_suffix="$factory_suffix"
	fi
}

sysupgrade() {
	if [ "$2" ]; then
		sysupgrade_suffix="$1"
		sysupgrade_ext="$2"
	else
		sysupgrade_ext="$1"
	fi

	if [ -z "$output" ]; then
		default_sysupgrade_ext="$sysupgrade_ext"
		default_sysupgrade_suffix="$sysupgrade_suffix"
	fi
}

no_opkg() {
	no_opkg=1
}


. targets/"$1"; copy

# Copy opkg repo
if [ -z "$no_opkg" -a -z "$DEVICES" ]; then
	rm -f "$GLUON_PACKAGEDIR"/*/"$OPENWRT_BINDIR"/*
	rmdir -p "$GLUON_PACKAGEDIR"/*/"$OPENWRT_BINDIR" 2>/dev/null || true
	mkdir -p "${GLUON_PACKAGEDIR}/${PACKAGE_PREFIX}/${OPENWRT_BINDIR}"
	cp "openwrt/bin/targets/${OPENWRT_BINDIR}/packages"/* "${GLUON_PACKAGEDIR}/${PACKAGE_PREFIX}/${OPENWRT_BINDIR}"
fi
