-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017-2018 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local tparser = require 'gluon.web.template.parser'

local tostring, ipairs, setmetatable, setfenv = tostring, ipairs, setmetatable, setfenv
local pcall, assert = pcall, assert


return function(config, env)
	local i18n = require('gluon.web.i18n')(config)

	local viewdir = config.base_path .. '/view/'

	local ctx = {}

	local language = 'en'
	local catalogs = {}

	function ctx.set_language(langs)
		for _, lang in ipairs(langs) do
			if i18n.supported(lang) then
				language = lang
				catalogs = {}
				return
			end
		end
	end

	function ctx.i18n(pkg)
		local cat = catalogs[pkg] or i18n.load(language, pkg)
		if pkg then catalogs[pkg] = cat end
		return cat
	end

	local function render_template(name, template, scope, pkg)
		scope = scope or {}
		local t = ctx.i18n(pkg)

		local locals = {
			renderer = ctx,
			i18n = ctx.i18n,
			translate = t.translate,
			translatef = t.translatef,
			_translate = t._translate,
			include = function(include_name)
				ctx.render(include_name, scope, pkg)
			end,
		}

		setfenv(template, setmetatable({}, {
			__index = function(_, key)
				return scope[key] or locals[key] or env[key]
			end
		}))

		-- Now finally render the thing
		local stat, err = pcall(template)
		assert(stat, "Failed to execute template '" .. name .. "'.\n" ..
			"A runtime error occurred: " .. tostring(err or "(nil)"))
	end

	--- Render a certain template.
	-- @param name		Template name
	-- @param scope		Scope to assign to template (optional)
	-- @param pkg		i18n namespace package (optional)
	function ctx.render(name, scope, pkg)
		local sourcefile = viewdir .. name .. ".html"
		local template, _, err = tparser.parse(sourcefile)

		assert(template, "Failed to load template '" .. name .. "'.\n" ..
			"Error while parsing template '" .. sourcefile .. "':\n" ..
			(err or "Unknown syntax error"))

		render_template(name, template, scope, pkg)
	end

	--- Render a template from a string.
	-- @param template	Template string
	-- @param scope		Scope to assign to template (optional)
	-- @param pkg		i18n namespace package (optional)
	function ctx.render_string(str, scope, pkg)
		local template, _, err = tparser.parse_string(str)

		assert(template, "Error while parsing template:\n" ..
			(err or "Unknown syntax error"))

		render_template('(local)', template, scope, pkg)
	end

	--- Render a template, wrapped in the configured layout.
	-- @param name		Template name
	-- @param scope		Scope to assign to template (optional)
	-- @param pkg		i18n namespace package (optional)
	-- @param layout_scope  Additional variables to pass to the layout template
	function ctx.render_layout(name, scope, pkg, layout_scope)
		ctx.render(config.layout_template, setmetatable({
			content = name,
			scope = scope,
			pkg = pkg,
		}, {
			__index = layout_scope
		}), config.layout_package)
	end

	return ctx
end
