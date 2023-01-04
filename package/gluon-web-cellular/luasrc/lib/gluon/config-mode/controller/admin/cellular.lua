local platform = require 'gluon.platform'

package 'gluon-web-cellular'

if platform.is_cellular_device() then
	entry({"admin", "cellular"}, model("admin/cellular"), _("Cellular"), 30)
end
