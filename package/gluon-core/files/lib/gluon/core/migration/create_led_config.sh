#!/bin/sh

CFG=/etc/board.json

. /bin/config_generate source-only

json_init
json_load "$(cat ${CFG})"

umask 077

keys=

json_get_keys keys led
for key in $keys; do generate_led $key; done
