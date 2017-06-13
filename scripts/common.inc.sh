config() {
	:
}

device() {
	:
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

manifest_alias() {
	:
}

packages() {
	:
}

factory() {
	:
}

sysupgrade() {
	:
}

no_opkg() {
	:
}


unknown_devices="$DEVICES"

want_device() {
	[ "$DEVICES" ] || return 0

	local new_devices=''

	for device in $unknown_devices; do
		if [ "$device" != "$1" ]; then
			new_devices="${new_devices:+${new_devices} }$device"
		fi
	done
	unknown_devices=$new_devices

	for device in $DEVICES; do
		if [ "$device" = "$1" ]; then
			return 0
		fi
	done

	return 1
}

check_devices() {
	if [ "$unknown_devices" ]; then
		echo "Error: unknown devices given: ${unknown_devices}" >&2
		exit 1
	fi
}
