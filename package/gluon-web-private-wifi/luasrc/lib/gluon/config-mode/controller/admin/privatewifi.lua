local uci = require("simple-uci").cursor()
local wireless = require 'gluon.wireless'

package 'gluon-web-private-wifi'

if wireless.device_uses_wlan(uci) then
	entry({"admin", "privatewifi"}, model("admin/privatewifi"), _("Private WLAN"), 30)
end
