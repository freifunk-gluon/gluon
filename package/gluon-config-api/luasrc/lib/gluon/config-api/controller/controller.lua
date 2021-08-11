local json = require 'jsonc'
local site = require 'gluon.site'
local util = require 'gluon.util'
local ubus = require 'ubus'
local os = require 'os'
local glob = require 'posix.glob'
local libgen = require 'posix.libgen'
local simpleuci = require 'simple-uci'
local schema = require 'schema'

package 'gluon-config-api'

function load_parts()
	local parts = {}
	for _, f in pairs(glob.glob('/lib/gluon/config-api/parts/*.lua')) do
		table.insert(parts, dofile(f))
	end
	return parts
end

function config_get(parts)
	local config = {}
	local uci = simpleuci.cursor()

	for _, part in pairs(parts) do
		part.get(uci, config)
	end

	return config
end

local parts = load_parts()


entry({"config"}, call(function(http, renderer)

	http:write(json.stringify(config_get(parts), true))
	http:close()
end))

entry({"schema"}, call(function(http, renderer)
	local total_schema = {}
	for _, part in pairs(parts) do
		total_schema = schema.merge_schemas(total_schema, part.schema())
	end
	http:write(json.stringify(total_schema, true))
	http:close()
end))
