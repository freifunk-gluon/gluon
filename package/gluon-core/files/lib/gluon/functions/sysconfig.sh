SYSCONFIGDIR=/lib/gluon/core/sysconfig


sysconfig() {
	cat "$SYSCONFIGDIR/$1"
}

sysconfig_set() {
	echo -n "$2" > "$SYSCONFIGDIR/$1"
}
