
local M = {}

function M.schema(site, platform)
	local altitude = nil

	if site.config_mode.geo_location.show_altitude(false) then
		altitude = { type = 'number' }
	end

	return {
		properties = {
			wizard = {
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
	}
end

function M.set(config, uci)
	local location = uci:get_first("gluon-node-info", "location")
	local config_location = config.wizard.location or {}

	uci:set("gluon-node-info", location, "share_location",
		config_location.share_location or false)
	uci:set("gluon-node-info", location, "latitude", config_location.lat)
	uci:set("gluon-node-info", location, "longitude", config_location.lon)
	uci:set("gluon-node-info", location, "altitude", config_location.altitude)

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
