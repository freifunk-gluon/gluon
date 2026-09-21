bridge_rule('FORWARD', 'ibrname "br-client" iifname != "bat0" jump local_forward')

-- DROP policy of the previous ebtables chain; this file sorts after
-- all 1xx files adding allow rules to the chain
bridge_rule('LOCAL_FORWARD', 'counter drop')
