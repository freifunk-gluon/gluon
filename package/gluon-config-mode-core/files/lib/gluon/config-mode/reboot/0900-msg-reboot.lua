local site = require 'gluon.site_config'

return function () luci.template.render_string(site.config_mode.msg_reboot) end
