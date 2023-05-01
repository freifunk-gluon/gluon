bridge_rule('IN_ONLY', 'ibrname "br-client" iifname { "bat0", "local-port" } return')
bridge_rule('IN_ONLY', 'drop')

bridge_rule('OUT_ONLY', 'obrname "br-client" oifname { "bat0", "local-port" } return')
bridge_rule('OUT_ONLY', 'drop')
