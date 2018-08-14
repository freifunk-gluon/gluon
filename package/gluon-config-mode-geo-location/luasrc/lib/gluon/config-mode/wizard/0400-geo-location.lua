return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-geo-location'
	local site_i18n = i18n 'gluon-site'

	local site = require 'gluon.site'

	local location = uci:get_first("gluon-node-info", "location")

	local function show_altitude()
		if site.config_mode.geo_location.show_altitude(true) then
			return true
		end

		return uci:get_bool("gluon-node-info", location, "altitude")
	end

	local text = site_i18n._translate("gluon-config-mode:geo-location-help") or pkg_i18n.translate(
		'If you want the location of your node to ' ..
		'be displayed on the map, you can enter its coordinates here.'
	)
	if show_altitude() then
		text = text .. ' ' .. site_i18n.translate("gluon-config-mode:altitude-help")
	end

	local s = form:section(Section, nil, text)

	local o

	local share_location = s:option(Flag, "location", pkg_i18n.translate("Show node on the map"))
	share_location.default = uci:get_bool("gluon-node-info", location, "share_location")
	function share_location:write(data)
		uci:set("gluon-node-info", location, "share_location", data)
	end

	o = s:option(Value, "latitude", pkg_i18n.translate("Latitude"), pkg_i18n.translatef("e.g. %s", "53.873621"))
	o.default = uci:get("gluon-node-info", location, "latitude")
	o:depends(share_location, true)
	o.datatype = "float"
	function o:write(data)
		uci:set("gluon-node-info", location, "latitude", data)
	end

	o = s:option(Value, "longitude", pkg_i18n.translate("Longitude"), pkg_i18n.translatef("e.g. %s", "10.689901"))
	o.default = uci:get("gluon-node-info", location, "longitude")
	o:depends(share_location, true)
	o.datatype = "float"
	function o:write(data)
		uci:set("gluon-node-info", location, "longitude", data)
	end

	if show_altitude() then
		o = s:option(Value, "altitude", site_i18n.translate("gluon-config-mode:altitude-label"), pkg_i18n.translatef("e.g. %s", "11.51"))
		o.default = uci:get("gluon-node-info", location, "altitude")
		o:depends(share_location, true)
		o.datatype = "float"
		o.optional = true
		function o:write(data)
			uci:set("gluon-node-info", location, "altitude", data)
		end
	end

	return {'gluon-node-info'}
end
