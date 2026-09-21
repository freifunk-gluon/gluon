local site = require 'gluon.site'

bridge_rule('LOCAL_FORWARD', 'ip6 saddr fe80::/64 return')
bridge_rule('LOCAL_FORWARD', 'ip6 saddr ::/128 meta l4proto ipv6-icmp return')
bridge_rule('LOCAL_FORWARD', 'ip6 saddr ' .. site.prefix6() .. ' return')

for _, prefix in ipairs(site.extra_prefixes6({})) do
	bridge_rule('LOCAL_FORWARD', 'ip6 saddr ' .. prefix .. ' return')
end
