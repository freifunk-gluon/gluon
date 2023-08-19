-- include('limit_arp', {
--	position = 'ruleset-pre'
-- })

bridge_include_table('pre', 'limit_arp_chain')
bridge_rule('FORWARD', 'oifname "bat0" obrname "br-client" arp operation request counter jump arplimit')
