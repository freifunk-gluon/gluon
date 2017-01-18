#!/usr/bin/env bash

set -e

[ "$LEDE_TARGET" ] || exit 1

target="$1"
packages=$2

output=

LEDE_CONFIG_TARGET="${LEDE_TARGET//-/_}"


site_packages() {
	MAKEFLAGS= make PROFILE="$1" --no-print-directory -s -f - <<'END_MAKE'
include $(GLUON_SITEDIR)/site.mk

all:
	echo '$(GLUON_$(PROFILE)_SITE_PACKAGES)'
END_MAKE
}


check_config() {
	grep -q "$1" lede/.config
}

check_package() {
	local package="$1"
	local value="$2"

	if ! check_config "^CONFIG_PACKAGE_${package}=${value}"; then
		echo "Configuration failed: unable to enable package '${package}'" >&2
		exit 1
	fi
}


. scripts/common.inc.sh

config() {
	local config="$1"

	if ! check_config "^${config}\$"; then
		echo "Configuration failed: unable to set '${config}'" >&2
		exit 1
	fi
}

device() {
	output="$1"
	want_device "${output}" || return 0

	local profile="$3"
	if [ -z "$profile" ]; then
		profile="$2"
	fi

	if ! check_config "CONFIG_TARGET_DEVICE_${LEDE_CONFIG_TARGET}_DEVICE_${profile}=y"; then
		echo "Configuration failed: unable to enable device '${profile}'" >&2
		exit 1
	fi

	for package in $(site_packages "$output"); do
		[ "${package:0:1}" = '-' ] || check_package "$package"
	done
}

packages() {
	if [ "${output}" ]; then
		want_device "${output}" || return 0

		for package in "$@"; do
			[ "${package:0:1}" = '-' ] || check_package "$package"
		done
	else
		for package in "$@"; do
			[ "${package:0:1}" = '-' ] || check_package "$package" 'y'
		done
	fi
}


. targets/"$target"
check_devices


for package in $packages; do
	check_package "$package" 'y'
done
