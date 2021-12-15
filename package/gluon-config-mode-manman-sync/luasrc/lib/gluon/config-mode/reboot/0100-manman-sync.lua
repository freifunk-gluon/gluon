local site_i18n = i18n 'gluon-site'

local uci = require("simple-uci").cursor()

local msg

if uci:get_bool("gluon", "manman_sync", "enabled") then
	msg = site_i18n._translate('gluon-config-mode:manman')
else
	msg = site_i18n._translate('gluon-config-mode:no-manman')
end

if not msg then return end

renderer.render_string(msg, {
	node_id = uci:get("gluon", "manman_sync", "node_id")
})
