-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local tparser = require "gluon.web.template.parser"
local util = require "gluon.web.util"
local fs = require "nixio.fs"

local tostring, setmetatable, setfenv, pcall, assert = tostring, setmetatable, setfenv, pcall, assert


module "gluon.web.template"

local viewdir = util.libpath() .. "/view/"
local i18ndir = util.libpath() .. "/i18n/"

function renderer(env)
	local ctx = {}


	local function render_template(name, template, scope)
		scope = scope or {}

		local locals = {
			renderer = ctx,
			translate = ctx.translate,
			translatef = ctx.translatef,
			_translate = ctx._translate,
			include = function(name)
				ctx.render(name, scope)
			end,
		}

		setfenv(template, setmetatable({}, {
			__index = function(tbl, key)
				return scope[key] or env[key] or locals[key]
			end
		}))

		-- Now finally render the thing
		local stat, err = pcall(template)
		assert(stat, "Failed to execute template '" .. name .. "'.\n" ..
			      "A runtime error occured: " .. tostring(err or "(nil)"))
	end

	--- Render a certain template.
	-- @param name		Template name
	-- @param scope		Scope to assign to template (optional)
	function ctx.render(name, scope)
		local sourcefile = viewdir .. name .. ".html"
		local template, _, err = tparser.parse(sourcefile)

		assert(template, "Failed to load template '" .. name .. "'.\n" ..
			"Error while parsing template '" .. sourcefile .. "':\n" ..
			(err or "Unknown syntax error"))

		render_template(name, template, scope)
	end

	--- Render a template from a string.
	-- @param template	Template string
	-- @param scope		Scope to assign to template (optional)
	function ctx.render_string(str, scope)
		local template, _, err = tparser.parse_string(str)

		assert(template, "Error while parsing template:\n" ..
			(err or "Unknown syntax error"))

		render_template('(local)', template, scope)
	end

	function ctx.setlanguage(lang)
		lang = lang:gsub("_", "-")
		if not lang then return false end

		if lang ~= 'en' and not fs.access(i18ndir .. "gluon-web." .. lang .. ".lmo") then
			return false
		end

		return tparser.load_catalog(lang, i18ndir)
	end

	-- Returns a translated string, or nil if none is found
	function ctx._translate(key)
		return (tparser.translate(key))
	end

	-- Returns a translated string, or the original string if none is found
	function ctx.translate(key)
		return tparser.translate(key) or key
	end

	function ctx.translatef(key, ...)
		local t = ctx.translate(key)
		return t:format(...)
	end

	return ctx
end
