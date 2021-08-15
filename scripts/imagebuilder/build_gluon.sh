#!/bin/sh

set -e

SCRIPT_DIR="$(dirname "$0")"
CUSTOM_DIR="$SCRIPT_DIR/gluon/tmp/custom/"

cd "$SCRIPT_DIR"

BOARD="$(grep -e '^CONFIG_TARGET_BOARD=' .config | cut -d '=' -f 2 | tr -d '"')"
SUBTARGET="$(grep -e '^CONFIG_TARGET_SUBTARGET=' .config | cut -d '=' -f 2 | tr -d '"')"

config2profiles() {
	# Using .profiles.mk is not an option, because we disable a lot of devices
	# in gluon and we do not want them to be built.
	grep -e "^CONFIG_TARGET_DEVICE_${BOARD}_${SUBTARGET}_DEVICE.*=y\$" "$1" | \
		cut -d '=' -f 1 | cut -d '_' -f 7-
}

config2packages() {
	# - some config symbols, which are not a package appear, therefore strip
	#   everything with uppercase characters
	# - installing grub is wrong
	grep -e '^CONFIG_PACKAGE.*=y' "$1" | \
		cut -d '_' -f 3- | cut -d '=' -f 1 | \
		grep -ve '[A-Z]' | \
		grep -ve '^grub2$' | \
		tr -s '\n' ' '

	# Per device packages
	grep -e "^CONFIG_TARGET_DEVICE_PACKAGES_${BOARD}_${SUBTARGET}_DEVICE_$2=" "$1" | \
		cut -d '=' -f 2 | tr -d '"'
}

if [ -z "$INCLUDE_ONLY" ] && [ "$#" -lt 1 ]; then
	echo 'This is the gluon imagebuilder. You can use this to build a '
	echo 'customized gluon:'
	echo
	echo '- Note, that we do not fully support the imagebuilder.'
	echo '- Adding additional packages or removing them is not supported.'
	echo '- Adding arbitrary files is not supported.'
	echo '- The imagebuilder is only used to to add a custom config custom.json'
	echo '  with chosen configuration options to gluon. Please refer to'
	echo '  https://gluon.readthedocs.io/ to see the available options.'
	echo '- Place your custom.json in this directory.'
	echo
	echo 'To continue, run this script with'
	echo
	echo "#> $0 PROFILE"
	echo
	echo 'where PROFILE may be one of the following:'
	config2profiles .config | sed 's/^/- /'
	exit 0
fi


if [ -z "$INCLUDE_ONLY" ]; then
	rm -rf "$CUSTOM_DIR"
	mkdir -p "$CUSTOM_DIR/lib/gluon/"
	cp "custom.json" "$CUSTOM_DIR/lib/gluon/"

	if ! config2profiles .config | grep -e "^$1\$"; then
		echo "Profile $1 not available. Call without argument to see available profiles."
		exit 1
	fi
	# DEVICE_TYPE=other is kind of a hack to ensure kmod-ipt-offload, odhcpd-ipv6only, ppp and
	# ppp-mod-pppoe are not in $DEFAULT_PACKAGES. Otherwise the build will fail, because gluon
	# does not provide them.
	make image \
		FILES="$CUSTOM_DIR" DEVICE_TYPE=other \
		PACKAGES="$(config2packages .config "$1")" PROFILE="$1"
fi
