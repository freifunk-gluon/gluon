#!/bin/sh

domain_code=$(uci get gluon.system.domain_code)

[ -f /lib/gluon/domains/${domain_code}.json ] || (echo "file not found: /lib/gluon/domains/${domain_code}.json" >&2; exit 1) || exit 1

for s in /lib/gluon/upgrade/*; do
	echo -n ${s}:
	(${s} && echo " ok") || echo " error"
done
