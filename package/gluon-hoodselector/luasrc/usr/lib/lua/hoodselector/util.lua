local unistd = require('posix.unistd')
local util = require 'gluon.util'
local math_polygon = require('math-polygon')
local json = require 'jsonc'
local uci = require('simple-uci').cursor()
local site = require 'gluon.site'
local logger = require('posix.syslog')
local M = {}

function M.log(msg)
	io.stdout:write(msg..'\n')
	logger.openlog(msg, logger.LOG_PID)
end

function M.get_domains()
	local list = {}
	for _, domain_path in ipairs(util.glob('/lib/gluon/domains/*.json')) do
		table.insert(list, {
			domain_code = domain_path:match('([^/]+)%.json$'),
			domain = assert(json.load(domain_path)),
		})
	end
	return list
end

-- Return the default domain from the domain list.
-- This method can return the following data:
-- * default domain
-- * nil if no default domain has been defined
function M.get_default_domain(jdomains)
	for _, domain in pairs(jdomains) do
		if domain.domain_code == site.default_domain() then
			return domain
		end
	end
	return nil
end

-- Get Geoposition.
-- This method can return the following data:
-- * table {lat, lon}
-- * nil for no position
function M.get_geolocation()
	return {
		lat = tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'latitude')),
		lon = tonumber(uci:get('gluon-node-info', uci:get_first('gluon-node-info', 'location'), 'longitude'))
	}
end

-- Return domain from the domain list based on geo position or nil if no geo based domain could be
-- determined.
function M.get_domain_by_geo(jdomains,geo)
	for _, domain in pairs(jdomains) do
		if domain.domain_code ~= site.default_domain() then
			-- Keep record of how many nested shapes we are in, e.g. a polyon with holes.
			local nesting = 1
			for _, area in pairs(domain.domain.hoodselector.shapes) do
				-- Convert rectangle, defined by to points, into polygon
				if #area == 2 then
					area = math_polygon.two_point_rec_to_poly(area)
				end
				if (math_polygon.point_in_polygon(area,geo) == 1) then
					nesting = nesting * (-1)
				end
			end
			if nesting == -1 then return domain end
		end
	end
	return nil
end

function M.set_domain_config(domain)
	if uci:get('gluon', 'core', 'domain') ~= domain.domain_code then
		uci:set('gluon', 'core', 'domain', domain.domain_code)
		uci:commit('gluon')
		os.execute('gluon-reconfigure')
		M.log('Set domain "'..domain.domain.domain_names[domain.domain_code]..'"')
		return true
	end
	return false
end

return M
