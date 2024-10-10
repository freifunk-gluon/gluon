local os = require 'os'
local json = require 'jsonc'
local site = require 'gluon.site'
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

	-- commit all uci configs
	os.execute('uci commit')
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

local function json_response(http, obj)
	local result = json.stringify(obj, true)
	http:header('Content-Type', 'application/json; charset=utf-8')
	-- Content-Length is needed, as the transfer encoding is not chunked for
	-- http method OPTIONS.
	http:header('Content-Length', tostring(#result))
	http:write(result..'\n')
end

local function get_request_body_as_json(http)
	local request_body = ""
	pump(http.input, function (data)
		if data then
			request_body = request_body .. data
		end
	end)

	-- Verify that we really have JSON input. UCL is able to parse other
	-- config formats as well. Those config formats allow includes and so on.
	-- This may be a security issue.

	local data = json.parse(request_body)

	if not data then
		http:status(400, 'Bad Request')
		json_response(http, { status = 400, error = "Bad JSON in Body" })
		http:close()
		return
	end

	return data
end

local function verify_schema(schema, config)
	local parser = ucl.parser()
	local res, err = parser:parse_string(json.stringify(config))

	assert(res, "Internal UCL Parsing Failed. This should not happen at all.")

	res, err = parser:validate(schema)
	return res
end

entry({"v1", "config"}, call(function(http, renderer)
	local parts = load_parts()

	if http.request.env.REQUEST_METHOD == 'GET' then
		json_response(http, config_get(parts))
	elseif http.request.env.REQUEST_METHOD == 'POST' then
		local config = get_request_body_as_json(http)

		-- Verify schema
		if not verify_schema(schema_get(parts), config) then
			http:status(400, 'Bad Request')
			json_response(http, { status = 400, error = "Schema mismatch" })
			http:close()
			return
		end

		-- Apply config
		config_set(parts, config)

		-- Write result
		json_response(http, { status = 200, error = "Accepted" })
	elseif http.request.env.REQUEST_METHOD == 'OPTIONS' then
		json_response(http, {
			schema = schema_get(parts),
			allowed_methods = {'GET', 'POST', 'OPTIONS'}
		})
	else
		http:status(501, 'Not Implemented')
		http:header('Content-Length', '0')
		http:write('Not Implemented\n')
	end

	http:close()
end))
