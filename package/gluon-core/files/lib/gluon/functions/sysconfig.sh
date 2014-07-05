SYSCONFIGDIR=/lib/gluon/core/sysconfig


sysconfig() {
	cat "$SYSCONFIGDIR/$1" 2>/dev/null
}

sysconfig_isset() {
	test -e "$SYSCONFIGDIR/$1"
}

sysconfig_set() {
	echo -n "$2" > "$SYSCONFIGDIR/$1"
}

sysconfig_unset() {
	rm -f "$SYSCONFIGDIR/$1"
}
