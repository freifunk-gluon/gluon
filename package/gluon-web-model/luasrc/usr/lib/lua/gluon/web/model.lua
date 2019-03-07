-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017-2018 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

module('gluon.web.model', package.seeall)

local glob = require 'posix.glob'
local unistd = require 'posix.unistd'
local classes = require 'gluon.web.model.classes'

local util = require 'gluon.web.util'
local instanceof = util.instanceof

-- Loads a model from given file, creating an environment and returns it
local function load(filename, i18n, supra)
	supra = supra or {}
	local func = assert(loadfile(filename))

	setfenv(func, setmetatable({}, {__index =
		function(tbl, key)
			return supra[key] or classes[key] or i18n[key] or _G[key]
		end
	}))

	local models = { func() }

	for k, model in ipairs(models) do
		if not instanceof(model, classes.Node) then
			error("model definition returned an invalid model object")
		end
		model.index = k
	end

	return models
end

return function(config, http, renderer, name, pkg)
	local hidenav = false

	local modeldir = config.base_path .. '/model/'
	local filename = modeldir .. name .. '.lua'
	local infradir = modeldir .. name .. '/'
	local infrafnames = glob.glob(infradir .. '*.lua') or {}

	if not unistd.access(filename) then
		error("Model '" .. name .. "' not found!")
	end

	local i18n = setmetatable({
		i18n = renderer.i18n
	}, {
		__index = renderer.i18n(pkg)
	})

	local maps = load(filename, i18n)

	if #infrafnames > 0 and #maps ~= 1 then
		error("'" .. name .. "' has got inframaps. It must return a single supramap!")
	end

	for _, f in ipairs(infrafnames) do
		local m = load(f, i18n, { Supramap = maps[1] })
		if #m ~= 1 then
			error("Inframodule '" .. f:sub(#modeldir) .. "' must return the inherited supramap!")
		end
		hidenav = hidenav or maps[1].hidenav or m[1].hidenav
		maps[1] = m[1]
	end

	for _, map in ipairs(maps) do
		map:parse(http)
	end
	for _, map in ipairs(maps) do
		map:handle()
		hidenav = hidenav or map.hidenav
	end

	renderer.render_layout('model/wrapper', {
		maps = maps,
	}, nil, {
		hidenav = hidenav,
	})
end
