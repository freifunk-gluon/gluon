local uci = require("simple-uci").cursor()
local wireless = require 'gluon.wireless'

package 'gluon-web-private-ap'

if wireless.device_uses_wlan(uci) then
	entry({"admin", "privatewifi"}, model("admin/privateap"), _("Private AP"), 30)
end
