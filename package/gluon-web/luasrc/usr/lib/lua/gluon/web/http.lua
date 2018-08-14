-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local string = string
local table = table
local nixio = require "nixio"
local protocol = require "gluon.web.http.protocol"
local util  = require "gluon.web.util"

local ipairs, pairs, tostring = ipairs, pairs, tostring

module "gluon.web.http"


Http = util.class()
function Http:__init__(env, input, output)
	self.input = input
	self.output = output

	self.request = {
		env = env,
		headers = {},
		params = protocol.urldecode_params(env.QUERY_STRING or ""),
	}
	self.headers = {}
end

local function push_headers(self)
	if self.eoh then return end

	for _, header in pairs(self.headers) do
		self.output:write(string.format("%s: %s\r\n", header[1], header[2]))
	end
	self.output:write("\r\n")

	self.eoh = true
end

function Http:parse_input(filehandler)
	protocol.parse_message_body(
		self.input,
		self.request,
		filehandler
	)
end

function Http:formvalue(name)
	return self:formvaluetable(name)[1]
end

function Http:formvaluetable(name)
	return self.request.params[name] or {}
end

function Http:getcookie(name)
	local c = string.gsub(";" .. (self:getenv("HTTP_COOKIE") or "") .. ";", "%s*;%s*", ";")
	local p = ";" .. name .. "=(.-);"
	local i, j, value = c:find(p)
	return value and urldecode(value)
end

function Http:getenv(name)
	return self.request.env[name]
end

function Http:close()
	if not self.output then return end

	push_headers(self)

	self.output:flush()
	self.output:close()
	self.output = nil
end

function Http:header(key, value)
	self.headers[key:lower()] = {key, value}
end

function Http:prepare_content(mime)
	if self.headers["content-type"] then return end

	if mime == "application/xhtml+xml" then
		local accept = self:getenv("HTTP_ACCEPT")
		if not accept or not accept:find("application/xhtml+xml", nil, true) then
			mime = "text/html; charset=UTF-8"
		end
		self:header("Vary", "Accept")
	end
	self:header("Content-Type", mime)
end

function Http:status(code, request)
	if not self.output or self.code then return end

	code = code or 200
	request = request or "OK"
	self.code = code
	self.output:write(string.format("Status: %i %s\r\n", code, request))
end

function Http:write(content)
	if not self.output then return end

	self:status()

	self:prepare_content("text/html; charset=utf-8")

	if not self.headers["cache-control"] then
		self:header("Cache-Control", "no-cache")
		self:header("Expires", "0")
	end

	push_headers(self)
	self.output:write(content)
end

function Http:redirect(url)
	self:status(302, "Found")
	self:header("Location", url)
	self:close()
end
