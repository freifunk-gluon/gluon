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

packages() {
	:
}

factory() {
	:
}

sysupgrade() {
	:
}


if [ "$DEVICES" ]; then
	has_devices=1
else
	has_devices=
fi

want_device() {
	[ "$has_devices" ] || return 0

	local new_devices=''
	local ret=1

	for device in $DEVICES; do
		if [ "$device" = "$1" ]; then
			ret=0
		else
			new_devices="${new_devices:+${new_devices} }$device"
		fi
	done

	DEVICES=$new_devices

	return $ret
}

check_devices() {
	[ "$has_devices" ] || return 0

	if [ "$DEVICES" ]; then
		echo "Error: unknown devices given: $DEVICES" >&2
		exit 1
	fi
}
