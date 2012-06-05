#!/bin/sh
# Call the hotplug network interface setup script so our new L2TPv3 tunnel
# interface gets configured with required addresses
ACTION="add" INTERFACE="$1" /sbin/hotplug-call net
