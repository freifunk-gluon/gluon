local uci = require('simple-uci').cursor()

local gw_mode = uci:get('network', 'gluon_bat0', 'gw_mode')

if gw_mode ~= 'server' then
	bridge_rule('FORWARD', 'ip version 4 udp dport 67 jump out_only')
	bridge_rule('OUTPUT', 'ip version 4 udp dport 67 jump out_only')

	bridge_rule('FORWARD', 'ip version 4 udp dport 68 jump in_only')
	bridge_rule('INPUT', 'ip version 4 udp dport 68 jump in_only')
end
