bridge_include_table('pre', 'arp_limit')

bridge_rule('FORWARD', 'obrname "br-client" oifname "bat0" arp operation request jump arp_limit')
