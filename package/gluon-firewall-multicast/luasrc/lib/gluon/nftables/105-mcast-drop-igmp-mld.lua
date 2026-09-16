local site = require 'gluon.site'

bridge_rule('MULTICAST_IN', 'igmp type membership-query counter drop')
bridge_rule('MULTICAST_OUT', 'igmp type membership-query counter drop')

bridge_rule('MULTICAST_IN_ICMPV6', 'icmpv6 type 130 counter drop comment "MLD Query"')
bridge_rule('MULTICAST_OUT_ICMPV6', 'icmpv6 type 130 counter drop comment "MLD Query"')

if site.mesh.filter_membership_reports(true) then
	bridge_rule('MULTICAST_IN', 'ip protocol igmp counter drop')
	bridge_rule('MULTICAST_OUT', 'ip protocol igmp counter drop')

	bridge_rule('MULTICAST_IN_ICMPV6',
		'icmpv6 type { 131, 132, 143 } counter drop comment "MLDv1 Report, MLDv1 Done, MLDv2 Report"')
	bridge_rule('MULTICAST_OUT_ICMPV6',
		'icmpv6 type { 131, 132, 143 } counter drop comment "MLDv1 Report, MLDv1 Done, MLDv2 Report"')
end
