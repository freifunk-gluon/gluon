#!/usr/bin/env bash

set -e

[ "$OPENWRT_TARGET" ] || exit 1

target="$1"
packages=$2


output=
profile=
default_packages=
profile_packages=


OPENWRT_CONFIG_TARGET="${OPENWRT_TARGET//-/_}"


emit() {
	[ "${output}" ] || return 0
	want_device "${output}" || return 0

	profile_packages="${profile_packages} $(site_packages "$output")"

	for package in $profile_packages; do
		[ "${package:0:1}" = '-' ] || echo "CONFIG_PACKAGE_${package}=m"
	done

	echo "CONFIG_TARGET_DEVICE_${OPENWRT_CONFIG_TARGET}_DEVICE_${profile}=y"
	echo "CONFIG_TARGET_DEVICE_PACKAGES_${OPENWRT_CONFIG_TARGET}_DEVICE_${profile}=\"${profile_packages}\""
}


. scripts/target_config.inc.sh

config() {
	echo "$1"
}

try_config() {
	echo "$1"
}

device() {
	emit

	output="$1"
	profile="$3"
	if [ -z "$profile" ]; then
		profile="$2"
	fi

	profile_packages="${default_packages}"
}

packages() {
	if [ "${output}" ]; then
		profile_packages="${profile_packages} $@"
	else
		default_packages="${default_packages} $@"

		for package in "$@"; do
			if [ "${package:0:1}" = '-' ]; then
				echo "# CONFIG_PACKAGE_${package:1} is not set"
			else
				echo "CONFIG_PACKAGE_${package}=y"
			fi
		done
	fi
}


# The sort will not only remove duplicate entries,
# but also magically make =y entries override =m ones
(
	. targets/generic
	packages $packages

	. targets/"$target"
	emit
) | sort -u
