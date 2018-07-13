-- Copyright 2018 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local tparser = require 'gluon.web.template.parser'
local unistd = require 'posix.unistd'


return function(config)
	local i18ndir = config.base_path .. "/i18n"


	local function i18n_file(lang, pkg)
		return string.format('%s/%s.%s.lmo', i18ndir, pkg, lang)
	end

	local function no_translation(key)
		return nil
	end

	local function load_catalog(lang, pkg)
		if pkg then
			local file = i18n_file(lang, pkg)
			local cat = unistd.access(file) and tparser.load_catalog(file)

			if cat then return cat end
		end

		return no_translation
	end


	local i18n = {}

	function i18n.supported(lang)
		return lang == 'en' or unistd.access(i18n_file(lang, 'gluon-web'))
	end

	function i18n.load(lang, pkg)
		local _translate = load_catalog(lang, pkg)

		local function translate(key)
			return _translate(key) or key
		end

		local function translatef(key, ...)
			return translate(key):format(...)
		end

		return {
			_translate = _translate,
			translate = translate,
			translatef = translatef,
		}
	end

	return i18n
end
