#!/usr/bin/env bash

set -e

[ "$OPENWRT_TARGET" ] || exit 1

target="$1"
packages=$2

output=

ret=0

OPENWRT_CONFIG_TARGET="${OPENWRT_TARGET//-/_}"


fail() {
	local message="$1"

	if [ $ret -eq 0 ]; then
		ret=1
		echo "Configuration failed:" >&2
	fi

	echo " * $message" >&2
}

check_config() {
	grep -q "$1" openwrt/.config
}

check_package() {
	local package="$1"
	local value="$2"

	if ! check_config "^CONFIG_PACKAGE_${package}=${value}"; then
		fail "unable to enable package '${package}'"
	fi
}


. scripts/target_config.inc.sh

config() {
	local config="$1"

	if ! check_config "^${config}\$"; then
		fail "unable to set '${config}'"
	fi
}

device() {
	output="$1"
	want_device "${output}" || return 0

	local profile="$3"
	if [ -z "$profile" ]; then
		profile="$2"
	fi

	if ! check_config "CONFIG_TARGET_DEVICE_${OPENWRT_CONFIG_TARGET}_DEVICE_${profile}=y"; then
		fail "unable to enable device '${profile}'"
	fi

	for package in $(site_packages "$output"); do
		[ "${package:0:1}" = '-' ] || check_package "$package"
	done
}

factory_image() {
	output="$1"
	want_device "${output}" || return 0
}

sysupgrade_image() {
	output="$1"
	want_device "${output}" || return 0
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


. targets/generic
packages $packages

. targets/"$target"
check_devices


exit $ret
