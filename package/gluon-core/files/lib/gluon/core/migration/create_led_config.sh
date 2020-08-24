#!/bin/sh

CFG=/etc/board.json

. /lib/functions/config-generate.sh

json_init
json_load "$(cat ${CFG})"

umask 077

keys=

json_get_keys keys led
for key in $keys; do generate_led $key; done
