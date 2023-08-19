local client_bridge = require 'gluon.client_bridge'
local site = require 'gluon.site'
local next_node = site.next_node({})

local macaddr = client_bridge.next_node_macaddr()

bridge_rule('FORWARD', 'obrname "br-client" iifname "bat0" oifname "bat0" drop')
bridge_rule('FORWARD', 'obrname "br-client" iifname "local-port" oifname "bat0" drop')

bridge_rule('PREROUTING', 'ibrname "br-client" iifname "bat0" ether saddr ' .. macaddr .. ' drop', 'nat')
bridge_rule('PREROUTING', 'ibrname "br-client" iifname "bat0" ether daddr ' .. macaddr .. ' drop', 'nat')

bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" ether daddr ' .. macaddr .. ' drop')
bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" ether daddr ' .. macaddr .. ' drop')
bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" ether saddr ' .. macaddr .. ' drop')
bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" ether saddr ' .. macaddr .. ' drop')

if next_node.ip4 then
	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" arp saddr ip ' .. next_node.ip4 .. ' drop')
	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" arp daddr ip ' .. next_node.ip4 .. ' drop')
	bridge_rule('FORWARD', 'obrname "br-client" iifname "bat0" arp saddr ip ' .. next_node.ip4 .. ' drop')
	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" arp daddr ip ' .. next_node.ip4 .. ' drop')

	bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" arp saddr ip ' .. next_node.ip4 .. ' drop')
	bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" arp daddr ip ' .. next_node.ip4 .. ' drop')

	bridge_rule('INPUT', 'iifname "bat0" arp saddr ip ' .. next_node.ip4 .. ' drop')
	bridge_rule('INPUT', 'iifname "bat0" arp daddr ip ' .. next_node.ip4 .. ' drop')

	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" ip daddr ' .. next_node.ip4 .. ' drop')
	bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" ip daddr ' .. next_node.ip4 .. ' drop')
	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" ip saddr ' .. next_node.ip4 .. ' drop')
	bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" ip saddr ' .. next_node.ip4 .. ' drop')
end

if next_node.ip6 then
	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" ip6 daddr ' .. next_node.ip6 .. ' drop')
	bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" ip6 daddr ' .. next_node.ip6 .. ' drop')
	bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" ip6 saddr ' .. next_node.ip6 .. ' drop')
	bridge_rule('OUTPUT', 'obrname "br-client" oifname "bat0" ip6 saddr ' .. next_node.ip6 .. ' drop')
end
