#!/bin/sh

# shellcheck disable=SC1091,SC2154

get_setup_mode_led() {
	. /etc/diag.sh
	get_status_led 2> /dev/null

	if [ -z "$status_led" ]; then
		status_led="$running"
	fi

	if [ -z "$status_led" ]; then
		status_led="$boot"
	fi

	custom_led="$(lua -e 'print(require("gluon.setup-mode").get_status_led() or "")')"
	if [ -z "$status_led" ]; then
		status_led="$custom_led"
	fi
}

MODE="$1"
case "$mode" in
	confirm)
		get_setup_mode_led 2> /dev/null
		status_led_set_timer 100 100
		;;
	running)
		get_setup_mode_led 2> /dev/null
		status_led_set_timer 1000 300
		;;
	*)
		echo "Usage: $0 <running|confirm>"
		exit 1
		;;
esac
