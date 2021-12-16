local uci = require("simple-uci").cursor()
local wireless = require 'gluon.wireless'

package 'gluon-web-wifi-config'

if wireless.device_uses_wlan(uci) then
	entry({"admin", "wifi-config"}, model("admin/wifi-config"), _("WLAN"), 20)
end
