# list feeds which don't start with #
DEFAULT_FEEDS="$(awk '!/^#/ {print $2}' openwrt/feeds.conf.default)"
