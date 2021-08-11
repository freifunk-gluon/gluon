
local M = {}

function M.schema(site, platform)
	local altitude = nil

	if site.config_mode.geo_location.show_altitude(false) then
		altitude = { type = 'number' }
	end

	return {
		type = 'object',
		properties = {
			wizard = {
				type = 'object',
				properties = {
					location = {
						type = 'object',
						properties = {
							share_location = { type = 'boolean' },
							lat = { type = 'number' },
							lon = { type = 'number' },
							altitude = altitude
						},
						required = { 'lat', 'lon', 'share_location' }
					}
				}
			}
		},
		required = { 'wizard' }
	}
end

function M.set(config, uci)
	local location = uci:get_first("gluon-node-info", "location")
	local config_location = config.wizard.location

	if config_location then
		uci:set("gluon-node-info", location, "share_location", config_location.share_location)
		uci:set("gluon-node-info", location, "latitude", config_location.lat)
		uci:set("gluon-node-info", location, "longitude", config_location.lon)
		if config_location.altitude then -- altitude is optional
			uci:set("gluon-node-info", location, "altitude", config_location.altitude) -- TODO: check if the "if" is necessary
		else
			uci:delete("gluon-node-info", location, "altitude")
		end
	else
		uci:set("gluon-node-info", location, "share_location", false)
		uci:delete("gluon-node-info", location, "latitude")
		uci:delete("gluon-node-info", location, "longitude")
		uci:delete("gluon-node-info", location, "altitude")
	end

	uci:save("gluon-node-info")
end

function M.get(uci, config)
	config.wizard = config.wizard or {}

	local location = uci:get_first("gluon-node-info", "location")
	local lon = uci:get("gluon-node-info", location, "longitude")

	if lon then
		config.wizard.location = {
			share_location = uci:get_bool("gluon-node-info", location, "share_location"),
			lat = tonumber(uci:get("gluon-node-info", location, "latitude")),
			lon = tonumber(lon),
			-- if uci:get() returns nil, then altitude will not be present in the result
			altitude = tonumber(uci:get("gluon-node-info", location, "altitude"))
		}
	end
end

return M
