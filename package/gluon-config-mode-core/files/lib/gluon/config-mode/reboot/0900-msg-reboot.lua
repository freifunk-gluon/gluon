local i18n = require 'luci.i18n'

return function () luci.template.render_string(i18n.translate('gluon-config-mode:reboot')) end
