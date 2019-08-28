-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008-2015 Jo-Philipp Wich <jow@openwrt.org>
-- Copyright 2017-2018 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local glob = require 'posix.glob'
local json = require "jsonc"
local tpl = require "gluon.web.template"
local util = require "gluon.web.util"
local proto = require "gluon.web.http.protocol"


local function build_url(http, path)
	return (http:getenv("SCRIPT_NAME") or "") .. "/" .. table.concat(path, "/")
end


local function set_language(renderer, accept)
	local langs = {}
	local weights = {}
	local star = 0

	local function add(lang, q)
		if not weights[lang] then
			table.insert(langs, lang)
			weights[lang] = q
		end
	end

	for match in accept:gmatch("[^,]+") do
		local lang = match:match('^%s*([^%s;_-]+)')
		local q = tonumber(match:match(';q=(%S+)%s*$') or 1)

		if lang == '*' then
			star = q
		elseif lang and q > 0 then
			add(lang, q)
		end
	end

	add('en', star)

	table.sort(langs, function(a, b)
		return (weights[a] or 0) > (weights[b] or 0)
	end)

	renderer.set_language(langs)
end

local function dispatch(config, http, request)
	local tree = {nodes={}}
	local nodes = {[''] = tree}

	local function _node(path, create)
		local name = table.concat(path, ".")
		local c = nodes[name]

		if not c and create then
			local last = table.remove(path)
			local parent = _node(path, true)

			c = {nodes={}}
			parent.nodes[last] = c
			nodes[name] = c
		end
		return c
	end

	-- Init template engine
	local function attr(key, val)
		if not val then
			return ''
		end

		if type(val) == "table" then
			val = json.stringify(val)
		end

		return string.format(' %s="%s"', key, util.pcdata(tostring(val)))
	end

	local renderer = tpl(config, setmetatable({
		http        = http,
		request     = request,
		node        = function(path) return _node({path}) end,
		write       = function(...) return http:write(...) end,
		pcdata      = util.pcdata,
		urlencode   = proto.urlencode,
		attr        = attr,
		json        = json.stringify,
		url         = function(path) return build_url(http, path) end,
	}, { __index = _G }))


	local function createtree()
		local base = config.base_path .. "/controller/"

		local function load_ctl(path)
			local ctl = assert(loadfile(path))

			local _pkg

			local subdisp = setmetatable({
				package = function(name)
					_pkg = name
				end,

				node = function(...)
					return _node({...})
				end,

				entry = function(entry_path, target, title, order)
					local c = _node(entry_path, true)

					c.target = target
					c.title  = title
					c.order  = order
					c.pkg    = _pkg

					return c
				end,

				alias = function(...)
					local req = {...}
					return function()
						http:redirect(build_url(http, req))
					end
				end,

				call = function(func, ...)
					local args = {...}
					return function()
						func(http, renderer, unpack(args))
					end
				end,

				template = function(view, scope)
					local pkg = _pkg
					return function()
						renderer.render_layout(view, scope, pkg)
					end
				end,

				model = function(name)
					local pkg = _pkg
					return function()
						require('gluon.web.model')(config, http, renderer, name, pkg)
					end
				end,

				_ = function(text)
					return text
				end,
			}, { __index = _G })

			local env = setmetatable({}, { __index = subdisp })
			setfenv(ctl, env)

			ctl()
		end

		for _, path in ipairs(glob.glob(base .. "*.lua", 0) or {}) do
			load_ctl(path)
		end
		for _, path in ipairs(glob.glob(base .. "*/*.lua", 0) or {}) do
			load_ctl(path)
		end
	end

	set_language(renderer, http:getenv("HTTP_ACCEPT_LANGUAGE") or "")

	createtree()


	local node = _node(request)

	if not node or not node.target then
		http:status(404, "Not Found")
		renderer.render_layout("error/404", {
			message =
				"No page is registered at '/" .. table.concat(request, "/") .. "'.\n" ..
			        "If this URL belongs to an extension, make sure it is properly installed.\n",
		}, 'gluon-web')
		return
	end

	http:parse_input(node.filehandler)

	local ok, err = pcall(node.target)
	if not ok then
		http:status(500, "Internal Server Error")
		renderer.render_layout("error/500", {
			message =
				"Failed to execute dispatcher target for entry '/" .. table.concat(request, "/") .. "'.\n" ..
				"The called action terminated with an exception:\n" .. tostring(err or "(unknown)"),
		}, 'gluon-web')
	end
end

return function(config, http)
	local request = {}
	local pathinfo = proto.urldecode(http:getenv("PATH_INFO") or "", true)
	for node in pathinfo:gmatch("[^/]+") do
		table.insert(request, node)
	end

	local ok, err = pcall(dispatch, config, http, request)
	if not ok then
		http:status(500, "Internal Server Error")
		http:prepare_content("text/plain")
		http:write(err)
	end
end
