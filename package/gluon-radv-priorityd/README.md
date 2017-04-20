gluon-radv-priorityd
====================

This package tries to prioritize the router advertisements of the gateway
selected by the B.A.T.M.A.N. advanced gateway selection. It does this by
inserting rules into the firewall to hand all router advertisements via the
NFQUEUE mechanism to a userspace daemon, which then examines them and changes
the preference field to "high" if appropriate.
