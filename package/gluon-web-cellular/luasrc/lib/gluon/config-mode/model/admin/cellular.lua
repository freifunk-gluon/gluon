local uci = require("simple-uci").cursor()

local f = Form(translate("Cellular"))

local s = f:section(Section, nil, translate(
	'You can enable uplink via cellular service. If you decide so, the VPN connection is established '
	.. 'using the integrated WWAN modem.'
))

local enabled = s:option(Flag, "enabled", translate("Enabled"))
enabled.default = uci:get('gluon', 'cellular') and uci:get_bool('gluon', 'cellular', 'enabled')

local pin = s:option(Value, "pin", translate("SIM PIN"))
pin:depends(enabled, true)
pin.default = uci:get('gluon', 'cellular', 'pin')

local apn = s:option(Value, "apn", translate("APN"))
apn:depends(enabled, true)
apn.default = uci:get('gluon', 'cellular', 'apn')

local pdptype = s:option(ListValue, "type", translate("Type"))
pdptype:depends(enabled, true)
pdptype:value("IP", translate("IPv4"))
pdptype:value("IPV6", translate("IPv6"))
pdptype:value("IPV4V6", translate("IPv4/IPv6"))
pdptype.default = uci:get('gluon', 'cellular', 'pdptype') or "IP"

local username = s:option(Value, "username", translate("Username"))
username:depends(enabled, true)
username.default = uci:get('gluon', 'cellular', 'username')

local password = s:option(Value, "password", translate("Password"))
password:depends(enabled, true)
password.default = uci:get('gluon', 'cellular', 'password')

local auth = s:option(ListValue, "auth", translate("Authentication"))
auth:depends(enabled, true)
auth:value("none", translate("None"))
auth:value("pap", translate("PAP"))
auth:value("chap", translate("CHAP"))
auth:value("both", translate("Both"))
auth.default = uci:get('gluon', 'cellular', 'auth') or "none"

function f:write()
	local cellular_enabled = false
	if enabled.data then
		cellular_enabled = true
	end

	uci:section('gluon', 'cellular', 'cellular', {
		enabled = cellular_enabled,
		apn = apn.data,
		pdptype = pdptype.data,
		pin = pin.data,
		username = username.data,
		password = password.data,
		auth = auth.data,
	})

	uci:commit('gluon')
end

return f
