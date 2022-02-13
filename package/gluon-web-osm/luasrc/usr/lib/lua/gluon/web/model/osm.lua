local classes = require 'gluon.web.model.classes'
local util = require "gluon.web.util"

local class = util.class


local DEFAULT_URL =
	'https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@35ffe7626ce16c372143f3c903950750075e7068/en/v5.3.0'


local M = {}

local MapValue = class(classes.AbstractValue)
M.MapValue = MapValue

function MapValue:__init__(title, options)
	classes.AbstractValue.__init__(self, title)
	self.subtemplate  = "model/osm/map"
	self.options = {
		openlayers_url = options.openlayers_url or DEFAULT_URL,
		tile_layer = options.tile_layer,
	}
	self.lon = options.lon
	self.lat = options.lat

	self.pos = options.pos or {lon = 0, lat = 0}
	self.zoom = options.zoom or 0
	self.set = options.set or false
end

function MapValue:cfgvalue()
	local pos_lon = tonumber(self.lon and self.lon:cfgvalue())
	local pos_lat = tonumber(self.lat and self.lat:cfgvalue())

	if pos_lon and pos_lat then
		return {
			zoom = 18,
			pos = { lon = pos_lon, lat = pos_lat },
			set = true,
		}
	else
		return self
	end
end

function MapValue:validate()
	return true
end

return M
