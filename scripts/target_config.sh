#!/usr/bin/env bash

set -e

[ "$LEDE_TARGET" ] || exit 1


profile=
default_packages=
profile_packages=


LEDE_CONFIG_TARGET="${LEDE_TARGET//-/_}"


emit() {
	[ "${profile}" ] || return 0

	echo "CONFIG_TARGET_DEVICE_${LEDE_CONFIG_TARGET}_DEVICE_${profile}=y"
	echo "CONFIG_TARGET_DEVICE_PACKAGES_${LEDE_CONFIG_TARGET}_DEVICE_${profile}=\"${profile_packages}\""
}


config() {
	echo "$1"
}

device() {
	emit

	profile="$3"
	if [ -z "$profile" ]; then
		profile="$2"
	fi

	profile_packages="${default_packages}"
}

factory_image() {
	:
}

sysupgrade_image() {
	:
}

alias() {
	:
}

packages() {
	if [ "${profile}" ]; then
		for package in "$@"; do
			[ "${package:0:1}" = '-' ] || echo "CONFIG_PACKAGE_${package}=m"
		done

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

factory() {
	:
}

sysupgrade() {
	:
}


# The sort will not only remove duplicate entries,
# but also magically make =y entries override =m ones
(. targets/"$1"; emit) | sort -u
