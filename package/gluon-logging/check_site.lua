need_string({'syslog', 'ip'}, true)
need_number_range({'syslog', 'port'}, 1, 65535, false)
need_one_of({'syslog', 'proto'}, {'tcp', 'udp'}, false)
