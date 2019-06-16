local osm = require 'gluon.web.model.osm'
local site = require 'gluon.site'


local M = {}

M.MapValue = osm.MapValue

function M.help(i18n)
	local pkg_i18n = i18n 'gluon-config-mode-geo-location-osm'
	return pkg_i18n.translate(
		'You may also select the position on the map displayed below '
		.. 'if your computer is connected to the internet at the moment.'
	)
end

function M.options()
	local config = site.config_mode.geo_location.osm

	return {
		openlayers_url = config.openlayers_url(),
		zoom = config.zoom(12),
		pos = config.center(),
	}
end

return M
