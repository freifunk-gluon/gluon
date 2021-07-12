need_string(in_site_or_domain({'syslog', 'ip'}), true)
need_number_range(in_site_or_domain({'syslog', 'port'}), 1, 65535, false)
need_one_of(in_site_or_domain({'syslog', 'proto'}), {'tcp', 'udp'}, false)
