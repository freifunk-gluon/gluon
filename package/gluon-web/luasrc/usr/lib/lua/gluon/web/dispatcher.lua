-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008-2015 Jo-Philipp Wich <jow@openwrt.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local fs = require "nixio.fs"
local tpl = require "gluon.web.template"
local util = require "gluon.web.util"
local proto = require "gluon.web.http.protocol"

module("gluon.web.dispatcher", package.seeall)


function build_url(http, path)
	return (http:getenv("SCRIPT_NAME") or "") .. "/" .. table.concat(path, "/")
end

function redirect(http, ...)
	http:redirect(build_url(http, {...}))
end

function node_visible(node)
	return (
		node.title and
		node.target and
		(not node.hidden)
	)
end

function node_children(node)
	if not node then return {} end

	local ret = {}
	for k, v in pairs(node.nodes) do
		if node_visible(v) then
			table.insert(ret, k)
		end
	end

	table.sort(ret,
		function(a, b)
			return (node.nodes[a].order or 100)
			     < (node.nodes[b].order or 100)
		end
	)
	return ret
end


function httpdispatch(http)
	local request = {}
	local pathinfo = proto.urldecode(http:getenv("PATH_INFO") or "", true)
	for node in pathinfo:gmatch("[^/]+") do
		table.insert(request, node)
	end

	ok, err = pcall(dispatch, http, request)
	if not ok then
		http:status(500, "Internal Server Error")
		http:prepare_content("text/plain")
		http:write(err)
	end
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
		local lang = match:match('^%s*([^%s;-_]+)')
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

	for _, lang in ipairs(langs) do
		if renderer.setlanguage(lang) then
			return
		end
	end
end


function dispatch(http, request)
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
			val = util.serialize_json(val)
		end

		return string.format(' %s="%s"', key, util.pcdata(tostring(val)))
	end

	local renderer = tpl.renderer(setmetatable({
		http        = http,
		request     = request,
		node        = function(path) return _node({path}) end,
		write       = function(...) return http:write(...) end,
		pcdata      = util.pcdata,
		urlencode   = proto.urlencode,
		media       = '/static/gluon',
		theme       = 'gluon',
		resource    = '/static/resources',
		attr        = attr,
		url         = function(path) return build_url(http, path) end,
	}, { __index = _G }))

	local subdisp = setmetatable({
		node = function(...)
			return _node({...})
		end,

		entry = function(path, target, title, order)
			local c = _node(path, true)

			c.target = target
			c.title  = title
			c.order  = order

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

		template = function(view)
			return function()
				renderer.render("layout", {content = view})
			end
		end,

		model = function(name)
			return function()
				local hidenav = false

				local model = require "gluon.web.model"
				local maps = model.load(name, renderer)

				for _, map in ipairs(maps) do
					map:parse(http)
				end
				for _, map in ipairs(maps) do
					map:handle()
					hidenav = hidenav or map.hidenav
				end

				renderer.render("layout", {
					content = "model/wrapper",
					maps = maps,
					hidenav = hidenav,
				})
			end
		end,

		_ = function(text)
			return text
		end,
	}, { __index = _G })

	local function createtree()
		local base = util.libpath() .. "/controller/"

		local function load_ctl(path)
			local ctl = assert(loadfile(path))

			local env = setmetatable({}, { __index = subdisp })
			setfenv(ctl, env)

			ctl()
		end

		for path in (fs.glob(base .. "*.lua") or function() end) do
			load_ctl(path)
		end
		for path in (fs.glob(base .. "*/*.lua") or function() end) do
			load_ctl(path)
		end
	end

	set_language(renderer, http:getenv("HTTP_ACCEPT_LANGUAGE") or "")

	createtree()


	local node = _node(request)

	if not node or not node.target then
		http:status(404, "Not Found")
		renderer.render("layout", { content = "error404", message =
			"No page is registered at '/" .. table.concat(request, "/") .. "'.\n" ..
		        "If this URL belongs to an extension, make sure it is properly installed.\n"
		})
		return
	end

	http:parse_input(node.filehandler)

	local ok, err = pcall(node.target)
	if not ok then
		http:status(500, "Internal Server Error")
		renderer.render("layout", { content = "error500", message =
			"Failed to execute dispatcher target for entry '/" .. table.concat(request, "/") .. "'.\n" ..
			"The called action terminated with an exception:\n" .. tostring(err or "(unknown)")
		})
	end
end
