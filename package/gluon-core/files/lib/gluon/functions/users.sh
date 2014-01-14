add_user() {
	local username="$1"
	local id="$2"

	[ "$username" -a "$id" ] || return 1

	sed -i "/^$username:/d" /etc/passwd
	sed -i "/^$username:/d" /etc/shadow

	echo "$username:*:$id:100:$username:/var:/bin/false" >> /etc/passwd
	echo "$username:*:0:0:99999:7:::" >> /etc/shadow
}
