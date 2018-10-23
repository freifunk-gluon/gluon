#!/usr/bin/env bash

set -e

[ "$GLUON_IMAGEDIR" -a "$GLUON_PACKAGEDIR" -a "$OPENWRT_TARGET" -a "$GLUON_RELEASE" -a "$GLUON_SITEDIR" -a "$GLUON_TARGETSDIR" ] || exit 1


default_factory_ext='.bin'
default_factory_suffix='-squashfs-factory'
default_sysupgrade_ext='.bin'
default_sysupgrade_suffix='-squashfs-sysupgrade'
default_extra_images=

output=
profile=
aliases=

factory_ext=
factory_suffix=
sysupgrade_ext=
sysupgrade_suffix=
extra_images=

no_opkg=


mkdir -p "${GLUON_IMAGEDIR}/factory" "${GLUON_IMAGEDIR}/sysupgrade" "${GLUON_IMAGEDIR}/other"

if [ "$(expr match "$OPENWRT_TARGET" '.*-.*')" -gt 0 ]; then
	OPENWRT_BINDIR="${OPENWRT_TARGET//-/\/}"
else
	OPENWRT_BINDIR="${OPENWRT_TARGET}/generic"
fi

SITE_CODE="$(scripts/site.sh site_code)"
PACKAGE_PREFIX="gluon-${SITE_CODE}-${GLUON_RELEASE}"


do_clean() {
	local dir="$1"
	local out_suffix="$2"
	local ext="$3"
	local name="$4"

	rm -f "${GLUON_IMAGEDIR}/${dir}/gluon-"*"-${name}${out_suffix}${ext}"
}

get_file() {
	local dir="$1"
	local out_suffix="$2"
	local ext="$3"
	local name="$4"

	echo "${GLUON_IMAGEDIR}/${dir}/gluon-${SITE_CODE}-${GLUON_RELEASE}-${name}${out_suffix}${ext}"
}

do_copy() {
	local dir="$1"
	local in_suffix="$2"
	local out_suffix="$3"
	local ext="$4"
	local aliases="$5"

	local file="$(get_file "$dir" "$out_suffix" "$ext" "$output")"

	do_clean "$dir" "$out_suffix" "$ext" "$output"
	cp "openwrt/bin/targets/${OPENWRT_BINDIR}/openwrt-${OPENWRT_TARGET}${profile}${in_suffix}${ext}" "$file"

	for alias in $aliases; do
		do_clean "$dir" "$out_suffix" "$ext" "$alias"
		ln -s "$(basename "$file")" "$(get_file "$dir" "$out_suffix" "$ext" "$alias")"
	done
}

copy() {
	[ "$output" ] || return 0
	want_device "$output" || return 0

	[ -z "$factory_ext" ] || do_copy 'factory' "$factory_suffix" '' "$factory_ext" "$aliases"
	[ -z "$sysupgrade_ext" ] || do_copy 'sysupgrade' "$sysupgrade_suffix" '-sysupgrade' "$sysupgrade_ext" "$aliases"

	echo -n "$extra_images" | while read in_suffix && read out_suffix && read ext; do
		do_copy 'other' "$in_suffix" "$out_suffix" "$ext" "$aliases"
	done
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
	extra_images="$default_extra_images"
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

extra_image() {
	local in_suffix="$1"
	local out_suffix="$2"
	local ext="$3"

	extra_images="$in_suffix
$out_suffix
$ext
$extra_images"

	if [ -z "$output" ]; then
		default_extra_images="$extra_images"
	fi
}

no_opkg() {
	no_opkg=1
}


. "${GLUON_TARGETSDIR}/$1"; copy

# Copy opkg repo
if [ -z "$no_opkg" -a -z "$GLUON_DEVICES" ]; then
	rm -f "$GLUON_PACKAGEDIR"/*/"$OPENWRT_BINDIR"/*
	rmdir -p "$GLUON_PACKAGEDIR"/*/"$OPENWRT_BINDIR" 2>/dev/null || true
	mkdir -p "${GLUON_PACKAGEDIR}/${PACKAGE_PREFIX}/${OPENWRT_BINDIR}"
	cp "openwrt/bin/targets/${OPENWRT_BINDIR}/packages"/* "${GLUON_PACKAGEDIR}/${PACKAGE_PREFIX}/${OPENWRT_BINDIR}"
fi
