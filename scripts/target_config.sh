#!/usr/bin/env bash

set -e

[ "$LEDE_TARGET" ] || exit 1


output=
profile=
default_packages=
profile_packages=


LEDE_CONFIG_TARGET="${LEDE_TARGET//-/_}"


emit() {
	[ "${output}" ] || return 0
	want_device "${output}" || return 0

	profile_packages="${profile_packages} $(site_packages "$output")"

	for package in $profile_packages; do
		[ "${package:0:1}" = '-' ] || echo "CONFIG_PACKAGE_${package}=m"
	done

	echo "CONFIG_TARGET_DEVICE_${LEDE_CONFIG_TARGET}_DEVICE_${profile}=y"
	echo "CONFIG_TARGET_DEVICE_PACKAGES_${LEDE_CONFIG_TARGET}_DEVICE_${profile}=\"${profile_packages}\""
}


. scripts/target_config.inc.sh

config() {
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
				echo "CONFIG_PACKAGE_${package:1}=m"
			else
				echo "CONFIG_PACKAGE_${package}=y"
			fi
		done
	fi
}


# The sort will not only remove duplicate entries,
# but also magically make =y entries override =m ones
(. targets/"$1"; emit) | sort -u
