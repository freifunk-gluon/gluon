local prefix4 = require('gluon.site').prefix4()

if prefix4 then
	bridge_rule('LOCAL_FORWARD', 'arp saddr ip ' .. prefix4 .. ' arp daddr ip ' .. prefix4 .. ' return')
	bridge_rule('LOCAL_FORWARD', 'arp saddr ip 0.0.0.0 arp daddr ip ' .. prefix4 .. ' return')
end
