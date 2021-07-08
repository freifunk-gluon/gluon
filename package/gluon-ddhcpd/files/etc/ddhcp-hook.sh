#!/bin/sh

for i in /etc/ddhcpd.d/*
do
	$i "$@"
done
