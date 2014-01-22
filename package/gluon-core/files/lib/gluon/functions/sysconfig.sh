SYSCONFIGDIR=/lib/gluon/core/sysconfig


sysconfig() {
	cat "$SYSCONFIGDIR/$1" 2>/dev/null
}

sysconfig_set() {
	echo -n "$2" > "$SYSCONFIGDIR/$1"
}
