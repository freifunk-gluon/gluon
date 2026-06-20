-- SPDX-License-Identifier: Apache-2.0
--
-- Static preview generator for Gluon's config (setup) mode wizard.
--
-- This runs the *real* gluon-web model classes and the *real*
-- `config-mode/wizard/*` section files (from every package in the tree, so
-- plugins show up automatically) against stubbed router backends, then walks
-- the resulting form tree and emits static HTML that mirrors the gluon-web
-- view templates. The output is paired with the real gluon.css and
-- gluon-web-model.js, so dependency show/hide, validation and dynlists behave
-- exactly as on a device -- no Lua runtime needed to view it.
--
-- Usage (from the repository root):
--     lua contrib/config-mode-preview/generate.lua > out/index.html
--
-- All the values a real router would read from uci/site are gathered in the
-- MOCK table below -- tweak those to exercise different states (outdoor device,
-- mesh-vpn on/off, configured vs. fresh, ...).

-- Make the in-tree Lua libraries requirable (run from the repository root).
package.path = table.concat({
	"package/gluon-web-model/luasrc/usr/lib/lua/?.lua",
	"package/gluon-web/luasrc/usr/lib/lua/?.lua",
	package.path,
}, ";")

----------------------------------------------------------------------
-- Mock data: this is the "router state" the preview renders.
----------------------------------------------------------------------

local MOCK = {
	-- shown in the pink top bar
	hostname = "Freifunk-Node-1234",
	release  = "Gluon 2024.1+preview",

	-- the default node name offered when nothing is configured yet
	default_hostname = "freifunk-a1b2c3d4e5f6",

	-- site.config_mode.* accessors (function-style on a real site)
	site = {
		default_domain = "ffac",
		config_mode = {
			hostname = { optional = true, prefill = true },
			geo_location = { show_altitude = true },
		},
	},

	-- whether this (mock) device is an outdoor device using 5 GHz; controls
	-- whether the gluon-config-mode-outdoor plugin section is shown
	outdoor_device = true,

	-- mesh-vpn: an active provider must exist for the section to appear
	mesh_vpn_provider = "fastd",

	-- uci values, keyed "config.section.option"; get_first uses the type name
	uci = {
		["gluon.core.domain"]               = "ffac",
		["gluon.mesh_vpn.enabled"]          = "1",
		["gluon.mesh_vpn.limit_enabled"]    = "0",
		["gluon.mesh_vpn.limit_ingress"]    = nil,
		["gluon.mesh_vpn.limit_egress"]     = nil,
		["gluon.wireless.outdoor"]          = "0",
		["autoupdater.settings.enabled"]    = "1",
		-- gluon-node-info uses anonymous (type-first) sections
		["gluon-node-info.@owner[0].contact"]          = "freifunk@example.org",
		["gluon-node-info.@location[0].latitude"]      = "50.7766",
		["gluon-node-info.@location[0].longitude"]     = "6.0834",
		["gluon-node-info.@location[0].altitude"]      = nil,
		["gluon-node-info.@location[0].share_location"] = "1",
		-- "1" renders a configured node (domain preselected, names prefilled);
		-- set to nil to preview a fresh, not-yet-configured node instead.
		["gluon-setup-mode.@setup_mode[0].configured"] = "1",
	},

	-- pretty hostname currently stored (nil -> falls back to default_hostname)
	pretty_hostname = nil,

	-- available mesh domains (glob of /lib/gluon/domains/*.json)
	domains = {
		ffac = { domain_names = { ffac = "Aachen" },        hide_domain = false },
		ffms = { domain_names = { ffms = "Muenster" },      hide_domain = false },
		ffbs = { domain_names = { ffbs = "Braunschweig" },  hide_domain = false },
	},

	-- the welcome message normally pulled from the site i18n catalog
	welcome = "Welcome to the config mode of your Freifunk node! Here you can " ..
		"adjust a few basic settings before connecting your node to the mesh.",

	-- site-specific i18n strings (normally provided by the site's catalog);
	-- only the keys a site is expected to define need entries here.
	site_i18n = {
		["gluon-config-mode:domain-select"] = "Please select the region your node is located in.",
		["gluon-config-mode:domain"] = "Region",
	},
}

----------------------------------------------------------------------
-- Locate the source tree and discover wizard section files.
----------------------------------------------------------------------

local function popen_lines(cmd)
	local out = {}
	local p = assert(io.popen(cmd))
	for line in p:lines() do
		out[#out + 1] = line
	end
	p:close()
	return out
end

local function basename(path)
	return path:match("([^/]+)$")
end

-- The wizard model itself
local WIZARD_MODEL = "package/gluon-config-mode-core/luasrc/lib/gluon/config-mode/model/gluon-config-mode/wizard.lua"

-- All wizard section snippets, from every package; the router installs them all
-- into one directory and globs them, so ordering is by file *base* name.
local function discover_sections()
	local files = popen_lines(
		"find package -path '*/luasrc/lib/gluon/config-mode/wizard/*.lua' 2>/dev/null")
	table.sort(files, function(a, b) return basename(a) < basename(b) end)
	return files
end

----------------------------------------------------------------------
-- Stub backend modules (registered before the real model is required).
----------------------------------------------------------------------

local SECTION_FILES = discover_sections()

-- gluon.web.util: real class/instanceof, but a pure-Lua pcdata so we don't pull
-- in the compiled template parser.
package.preload["gluon.web.util"] = function()
	local M = {}
	local function _instantiate(class, ...)
		local inst = setmetatable({}, { __index = class })
		if inst.__init__ then inst:__init__(...) end
		return inst
	end
	function M.class(base)
		return setmetatable({}, { __call = _instantiate, __index = base })
	end
	function M.instanceof(object, class)
		while object do
			if object == class then return true end
			local mt = getmetatable(object)
			object = mt and mt.__index
		end
		return false
	end
	function M.pcdata(value)
		return value and (tostring(value)
			:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
			:gsub('"', "&#34;"):gsub("'", "&#39;"))
	end
	return M
end

package.preload["gluon.util"] = function()
	local M = {}
	function M.glob(pattern)
		if pattern:match("config%-mode/wizard") then
			return SECTION_FILES
		elseif pattern:match("/domains/") then
			local list = {}
			for code in pairs(MOCK.domains) do
				list[#list + 1] = "/lib/gluon/domains/" .. code .. ".json"
			end
			table.sort(list)
			return list
		end
		return {}
	end
	function M.contains(t, v)
		if not t then return false end
		for _, x in ipairs(t) do
			if x == v then return true end
		end
		return false
	end
	function M.add_to_set(t, v)
		if not M.contains(t, v) then t[#t + 1] = v end
	end
	function M.default_hostname()
		return MOCK.default_hostname
	end
	function M.readfile(path)
		local f = io.open(path)
		if not f then return nil end
		local d = f:read("*a"); f:close()
		return d
	end
	return M
end

-- simple-uci cursor backed by MOCK.uci
package.preload["simple-uci"] = function()
	local cursor = {}
	cursor.__index = cursor

	local function key(config, section, option)
		if option == nil then
			return config .. "." .. section
		end
		return config .. "." .. section .. "." .. option
	end

	function cursor:get(config, section, option)
		return MOCK.uci[key(config, section, option)]
	end
	function cursor:get_first(config, typename, option, default)
		-- anonymous sections are mocked as "@type[0]"
		if option == nil then
			return "@" .. typename .. "[0]"
		end
		local v = MOCK.uci[key(config, "@" .. typename .. "[0]", option)]
		if v == nil then return default end
		return v
	end
	function cursor:get_bool(config, section, option)
		local v = self:get(config, section, option)
		return v == "1" or v == "true" or v == "yes" or v == "on"
	end
	-- writes are no-ops in the preview
	function cursor:set() end
	function cursor:save() end
	function cursor:delete() end
	function cursor:foreach() end

	return {
		cursor = function() return setmetatable({}, cursor) end,
	}
end

package.preload["pretty_hostname"] = function()
	return {
		get = function() return MOCK.pretty_hostname or MOCK.hostname end,
		set = function() end,
	}
end

-- gluon.site: function-style accessors returning the mock value or the default
package.preload["gluon.site"] = function()
	local function accessor(value)
		return function(default)
			if value == nil then return default end
			return value
		end
	end
	local cm = MOCK.site.config_mode
	return {
		default_domain = function() return MOCK.site.default_domain end,
		config_mode = {
			hostname = {
				optional = accessor(cm.hostname.optional),
				prefill  = accessor(cm.hostname.prefill),
			},
			geo_location = {
				show_altitude = accessor(cm.geo_location.show_altitude),
			},
		},
	}
end

package.preload["gluon.mesh-vpn"] = function()
	return {
		get_active_provider = function()
			return MOCK.mesh_vpn_provider, MOCK.mesh_vpn_provider
		end,
	}
end

package.preload["gluon.platform"] = function()
	return {
		is_outdoor_device = function() return MOCK.outdoor_device end,
	}
end

package.preload["gluon.wireless"] = function()
	return {
		device_uses_band = function() return true end,
		preserve_channels = function() return false end,
		-- foreach helper used elsewhere; harmless default
	}
end

package.preload["jsonc"] = function()
	local function load_file(path)
		local code = basename(path):gsub("%.json$", "")
		return MOCK.domains[code]
	end
	return {
		load = load_file,
		stringify = function(v) return require("__json").encode(v) end,
	}
end

----------------------------------------------------------------------
-- Minimal JSON encoder (matches what dispatcher's attr() needs).
----------------------------------------------------------------------

package.preload["__json"] = function()
	local J = {}
	local function enc_string(s)
		return '"' .. s:gsub('[%z\1-\31\\"]', function(c)
			local m = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n',
				['\r'] = '\\r', ['\t'] = '\\t' }
			return m[c] or string.format("\\u%04x", c:byte())
		end) .. '"'
	end
	function J.encode(v)
		local t = type(v)
		if v == nil then
			return "null"
		elseif t == "boolean" then
			return v and "true" or "false"
		elseif t == "number" then
			return tostring(v)
		elseif t == "string" then
			return enc_string(v)
		elseif t == "table" then
			local n, isarr = 0, true
			for k in pairs(v) do
				n = n + 1
				if type(k) ~= "number" then isarr = false end
			end
			if n == 0 then return "{}" end
			local parts = {}
			if isarr then
				for i = 1, #v do parts[i] = J.encode(v[i]) end
				return "[" .. table.concat(parts, ",") .. "]"
			end
			-- stable key order for reproducible output
			local keys = {}
			for k in pairs(v) do keys[#keys + 1] = k end
			table.sort(keys)
			for _, k in ipairs(keys) do
				parts[#parts + 1] = enc_string(tostring(k)) .. ":" .. J.encode(v[k])
			end
			return "{" .. table.concat(parts, ",") .. "}"
		end
		error("cannot encode " .. t)
	end
	return J
end

local json = require("__json")

----------------------------------------------------------------------
-- Load the real model classes and build the wizard form tree.
----------------------------------------------------------------------

local classes = require("gluon.web.model.classes")

-- identity i18n: translate returns the source string, _translate returns nil so
-- sections fall back to their hard-coded English text. The 'gluon-site'
-- namespace additionally honours MOCK.site_i18n, matching how a site provides
-- its own catalog.
local function make_i18n(catalog)
	catalog = catalog or {}
	local function _translate(s) return catalog[s] end
	return {
		translate = function(s) return catalog[s] or s end,
		translatef = function(s, ...) return (catalog[s] or tostring(s)):format(...) end,
		_translate = _translate,
	}
end
local default_i18n = make_i18n()
local function i18n_factory(pkg)
	if pkg == "gluon-site" then return make_i18n(MOCK.site_i18n) end
	return make_i18n()
end

local function load_model(filename)
	local func = assert(loadfile(filename))
	setfenv(func, setmetatable({}, {
		__index = function(_, key)
			if classes[key] ~= nil then return classes[key] end
			if key == "i18n" then return i18n_factory end
			if default_i18n[key] ~= nil then return default_i18n[key] end
			return _G[key]
		end,
	}))
	return func()
end

local form = load_model(WIZARD_MODEL)
-- The dispatcher assigns model.index (1 for the single wizard form); mirror that
-- so generated element ids match a real device (id.1.* rather than id._.*).
form.index = 1

----------------------------------------------------------------------
-- HTML emitter -- mirrors the gluon-web view templates.
----------------------------------------------------------------------

local buf = {}
local function w(s) buf[#buf + 1] = s end

local function esc(s)
	return (tostring(s)
		:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		:gsub('"', "&#34;"):gsub("'", "&#39;"))
end

-- dispatcher.lua attr(): omit when falsy, JSON-encode tables, escape value.
local function attr(key, val)
	if not val then return "" end
	if type(val) == "table" then val = json.encode(val) end
	return string.format(' %s="%s"', key, esc(tostring(val)))
end

local function has_text(s)
	return s and #s > 0
end

-- model/value
local function emit_value_input(o)
	w("<input data-update=\"change\"")
	w(attr("id", o:id()))
	w(attr("name", o:id()))
	w(attr("type", o.password and "password" or "text"))
	w(attr("value", o:cfgvalue()))
	w(attr("size", o.size))
	w(attr("placeholder", o.placeholder))
	w(attr("maxlength", o.maxlength))
	w(attr("data-type", o.datatype))
	w(attr("data-optional", o.datatype and o.optional))
	w(">")
end

-- model/fvalue
local function emit_flag_input(o)
	w("<input data-update=\"click change\" type=\"checkbox\" value=\"1\"")
	w(attr("id", o:id()))
	w(attr("name", o:id()))
	w(attr("checked", o:cfgvalue() and "checked"))
	w(">")
	w(string.format("<label%s></label>", attr("for", o:id())))
end

-- model/lvalue (select / radio)
local function emit_list_input(o)
	local id = o:id()
	local entries = o:entries()
	if o.widget == "radio" then
		local br = o.orientation == "horizontal" and "&#160;&#160;&#160;" or "<br>"
		w("<div>")
		for i, entry in ipairs(entries) do
			w(string.format("<label%s%s>",
				attr("data-index", i), attr("data-depends", o:deplist(entry.deps))))
			w("<input data-update=\"click change\" type=\"radio\"")
			w(attr("id", id .. "." .. entry.key))
			w(attr("name", id))
			w(attr("value", entry.key))
			w(attr("checked", (o:cfgvalue() == entry.key) and "checked"))
			w(">")
			w(string.format("<label%s></label>", attr("for", id .. "." .. entry.key)))
			w(esc(entry.value))
			w("</label>")
			if i ~= #entries then w(br) end
		end
		w("</div>")
	else
		w("<div class=\"select-wrapper\">")
		w("<select data-update=\"change\"")
		w(attr("id", id))
		w(attr("name", id))
		w(attr("size", o.size))
		w(attr("data-type", "minlength(1)"))
		w(attr("data-optional", o.optional))
		w(">")
		for i, entry in ipairs(entries) do
			w("<option")
			w(attr("id", id .. "." .. entry.key))
			w(attr("value", entry.key))
			w(attr("data-index", i))
			w(attr("data-depends", o:deplist(entry.deps)))
			w(attr("selected", (o:cfgvalue() == entry.key) and "selected"))
			w(">")
			w(esc(entry.value))
			w("</option>")
		end
		w("</select></div>")
	end
end

-- model/mlvalue
local function emit_multilist_input(o)
	local id = o:id()
	local entries = o:entries()
	local br = o.orientation == "horizontal" and "&#160;&#160;&#160;" or "<br>"
	w("<div>")
	for i, entry in ipairs(entries) do
		w(string.format("<label%s%s>",
			attr("data-index", i), attr("data-depends", o:deplist(entry.deps))))
		w("<input data-update=\"change\" type=\"checkbox\"")
		w(attr("id", id .. "." .. entry.key))
		w(attr("name", id))
		w(attr("value", entry.key))
		w(attr("data-exclusive-with", o.exclusions and o.exclusions[entry.key]))
		w(">")
		w(string.format("<label%s></label>", attr("for", id .. "." .. entry.key)))
		w(string.format("<span class=\"gluon-multi-list-option-descr\">%s</span>", esc(entry.value)))
		w("</label>")
		if i ~= #entries then w(br) end
	end
	w("</div>")
end

-- model/dynlist
local function emit_dynlist_input(o)
	local id = o:id()
	w(string.format("<div%s>", attr("data-dynlist", {
		prefix = id,
		type = o.datatype,
		optional = o.datatype and o.optional,
		size = o.size,
		placeholder = o.placeholder,
	})))
	for i, val in ipairs(o:cfgvalue()) do
		w(string.format("<input value=\"%s\" data-update=\"change\" type=\"text\"%s%s%s%s><br>",
			esc(val), attr("id", id .. "." .. i), attr("name", id),
			attr("size", o.size), attr("placeholder", o.placeholder)))
	end
	w("</div>")
end

-- model/tvalue
local function emit_text_input(o)
	w("<textarea")
	if not o.size then w(" style=\"width: 100%\"") else w(attr("cols", o.size)) end
	w(" data-update=\"change\"")
	w(attr("name", o:id()))
	w(attr("id", o:id()))
	w(attr("rows", o.rows))
	w(attr("wrap", o.wrap))
	w(">")
	w(esc(o:cfgvalue() or ""))
	w("</textarea>")
end

local WIDGETS = {
	["model/value"]   = emit_value_input,
	["model/fvalue"]  = emit_flag_input,
	["model/lvalue"]  = emit_list_input,
	["model/mlvalue"] = emit_multilist_input,
	["model/dynlist"] = emit_dynlist_input,
	["model/tvalue"]  = emit_text_input,
}

-- model/valuewrapper
local function emit_option(o)
	local id = o:id()
	w(string.format("<div class=\"gluon-value%s\" id=\"value-%s\"%s%s>",
		o.error and " gluon-value-error" or "", id,
		attr("data-index", o.index), attr("data-depends", o:deplist())))
	local titled = has_text(o.title)
	if titled then
		w(string.format("<label class=\"gluon-value-title\"%s>%s</label>",
			attr("for", id), esc(o.title)))
		w("<div class=\"gluon-value-field\">")
	end
	local widget = WIDGETS[o.subtemplate]
	if widget then widget(o) end
	if has_text(o.description) then
		w("<br><div class=\"gluon-value-description\">" .. o.description .. "</div>")
	end
	if titled then w("</div>") end
	w("</div>")
end

-- model/section
local function emit_section(s)
	w(string.format("<fieldset class=\"gluon-section\" id=\"%s\" data-index=\"%s\"%s>",
		s:id(), s.index, attr("data-depends", s:deplist())))
	if has_text(s.title) then
		w("<legend>" .. esc(s.title) .. "</legend>")
	end
	if has_text(s.description) then
		w("<div class=\"gluon-section-descr\">" .. s.description .. "</div>")
	end
	w(string.format("<div class=\"gluon-section-node\" id=\"section-%s\">", s:id()))
	for _, child in ipairs(s.children) do
		emit_option(child)
	end
	w("</div></fieldset>")
end

-- the custom wizard/welcome template
local function emit_welcome(s)
	w(string.format("<fieldset class=\"gluon-section\" id=\"%s\" data-index=\"%s\">",
		s:id(), s.index))
	w("<p>" .. esc(MOCK.welcome) .. "</p>")
	w("</fieldset>")
end

-- model/form
local function emit_form(f)
	w("<form method=\"post\" enctype=\"multipart/form-data\" action=\"#\" data-update=\"reset\">")
	w(string.format("<input type=\"hidden\" name=\"%s\" value=\"1\">", f:id()))
	w(string.format("<div class=\"gluon-form\" id=\"form-%s\">", f:id()))
	if has_text(f.title) then
		w("<h2 name=\"content\">" .. esc(f.title) .. "</h2>")
	end
	if has_text(f.description) then
		w("<div class=\"gluon-form-descr\">" .. f.description .. "</div>")
	end
	for _, child in ipairs(f.children) do
		if child.template == "model/section" then
			emit_section(child)
		else
			emit_welcome(child)
		end
	end
	w("</div>")
	w("<div class=\"gluon-page-actions\">")
	if f.submit ~= false then
		w(string.format("<input class=\"gluon-button gluon-button-submit\" type=\"submit\" value=\"%s\">",
			esc(f.submit or "Save")))
	end
	if f.reset ~= false then
		w(string.format("<input class=\"gluon-button gluon-button-reset\" type=\"reset\" value=\"%s\">",
			esc(f.reset or "Reset")))
	end
	w("</div>")
	w("</form>")
end

----------------------------------------------------------------------
-- Page shell (mirrors gluon-config-mode-theme layout.html) and output.
----------------------------------------------------------------------

emit_form(form)
local form_html = table.concat(buf)

local page = ([[<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" type="text/css" media="screen" href="static/gluon.css">
		<title>__HOSTNAME__ - Wizard</title>
	</head>
	<body>
	<div id="menubar">
		<div class="hostinfo">
			<a href="#">__HOSTNAME__ / __RELEASE__</a>
		</div>
	</div>
	<div id="maincontainer">
		<div id="maincontent">
			<noscript>
				<div class="errorbox">
					<strong>JavaScript required!</strong><br>
					You must enable JavaScript in your browser or the web interface will not work properly.
				</div>
			</noscript>
			__FORM__
		</div>
	</div>
	<script src="static/gluon-web-model.js"></script>
	</body>
</html>
]])
	:gsub("__HOSTNAME__", (esc(MOCK.hostname):gsub("%%", "%%%%")))
	:gsub("__RELEASE__", (esc(MOCK.release):gsub("%%", "%%%%")))
	:gsub("__FORM__", (form_html:gsub("%%", "%%%%")))

io.write(page)
