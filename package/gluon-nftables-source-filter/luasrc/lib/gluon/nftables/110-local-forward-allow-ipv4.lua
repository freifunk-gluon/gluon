local prefix4 = require('gluon.site').prefix4()

if prefix4 then
	bridge_rule('LOCAL_FORWARD', 'ip version 4 udp dport 67 return')
	bridge_rule('LOCAL_FORWARD', 'ip saddr ' .. prefix4 .. ' return')
end
