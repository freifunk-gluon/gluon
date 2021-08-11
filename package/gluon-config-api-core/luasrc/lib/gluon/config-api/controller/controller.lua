local json = require 'jsonc'
local site = require 'gluon.site'
local util = require 'gluon.util'
local ubus = require 'ubus'
local os = require 'os'
local glob = require 'posix.glob'
local libgen = require 'posix.libgen'
local simpleuci = require 'simple-uci'
local schema = dofile('/lib/gluon/config-api/controller/schema.lua')
local ucl = require "ucl"

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

function schema_get(parts)
	local total_schema = {}
	for _, part in pairs(parts) do
		total_schema = schema.merge_schemas(total_schema, part.schema(site, nil))
	end
	return total_schema
end

function config_set(parts, config)
	local uci = simpleuci.cursor()

	for _, part in pairs(parts) do
		part.set(config, uci)
	end
end

local function pump(src, snk)
	while true do
		local chunk, src_err = src()
		local ret, snk_err = snk(chunk, src_err)

		if not (chunk and ret) then
			local err = src_err or snk_err
			if err then
				return nil, err
			else
				return true
			end
		end
	end
end

local parts = load_parts()

entry({"v1", "config"}, call(function(http, renderer)
	if http.request.env.REQUEST_METHOD == 'GET' then
		http:header('Content-Type', 'application/json; charset=utf-8')
		http:write(json.stringify(config_get(parts), true))
	elseif http.request.env.REQUEST_METHOD == 'POST' then
		local request_body = ""
		pump(http.input, function (data)
			if data then
				request_body = request_body .. data
			end
		end)

		-- Verify that we really have JSON input. UCL is able to parse other
		-- config formats as well. Those config formats allow includes and so on.
		-- This may be a security issue.

		local config = json.parse(request_body)
		if not config then
			http:status(400, 'Bad Request')
			http:header('Content-Type', 'application/json; charset=utf-8')
			http:write('{ "status": 400, "error": "Bad JSON in Body" }\n')
			http:close()
			return
		end

		-- Verify schema

		local parser = ucl.parser()
		local res, err = parser:parse_string(request_body)

		if not res then
			http:status(500, 'Internal Server Error.')
			http:header('Content-Type', 'application/json; charset=utf-8')
			http:write('{ "status": 500, "error": "Internal UCL Parsing Failed. This should not happen at all." }\n')
			http:close()
			return
		end

		res, err = parser:validate(schema_get(parts))
		if not res then
			http:status(400, 'Bad Request')
			http:header('Content-Type', 'application/json; charset=utf-8')
			http:write('{ "status": 400, "error": "Schema mismatch" }\n')
			http:close()
			return
		end

		-- Apply config
		config_set(parts, config)

		-- Write result

		http:write(json.stringify(res, true))
	elseif http.request.env.REQUEST_METHOD == 'OPTIONS' then
		local result = json.stringify({
			schema = schema_get(parts),
			allowed_methods = {'GET', 'POST', 'OPTIONS'}
		}, true)

		-- Content-Length is needed, as the transfer encoding is not chunked for OPTIONS.
		http:header('Content-Length', tostring(#result))
		http:header('Content-Type', 'application/json; charset=utf-8')
		http:write(result)
	else
		http:status(501, 'Not Implemented')
		http:header('Content-Length', '0')
		http:write('Not Implemented\n')
	end

	http:close()
end))
