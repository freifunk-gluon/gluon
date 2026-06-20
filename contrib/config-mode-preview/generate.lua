-- SPDX-License-Identifier: Apache-2.0
--
-- Static preview generator for Gluon's config (setup) mode.
--
-- Config mode is a tree of pages registered by `entry()` controllers: the
-- setup wizard plus the "Advanced settings" pages (network, WLAN, remote
-- access / SSH keys, automatic updates, node role, ...). This script runs the
-- *real* controllers and model files from every package in the tree against
-- stubbed router backends, builds the same navigation tree the dispatcher
-- builds, and emits one static HTML page per entry -- mirroring the gluon-web
-- view templates and paired with the real gluon.css and gluon-web-model.js.
--
-- Because it uses the same controller/model/section discovery the router does,
-- any package (including plugins) that registers config-mode pages shows up
-- automatically. Pages that genuinely need device state (e.g. live wifi
-- hardware) and fail to render degrade to a placeholder rather than breaking
-- the whole site.
--
-- Usage (from the repository root):
--     lua contrib/config-mode-preview/generate.lua OUTDIR
--
-- All values a real router would read from uci/site live in the MOCK tables
-- below; tweak them to exercise different states.

-- Make the in-tree Lua libraries requirable (run from the repository root).
package.path = table.concat({
	"package/gluon-web-model/luasrc/usr/lib/lua/?.lua",
	"package/gluon-web/luasrc/usr/lib/lua/?.lua",
	package.path,
}, ";")

local OUTDIR = (arg and arg[1]) or "out"

----------------------------------------------------------------------
-- Mock "router state".
----------------------------------------------------------------------

local MOCK = {
	hostname = "Freifunk-Node-1234",
	release  = "Gluon 2024.1+preview",
	default_hostname = "freifunk-a1b2c3d4e5f6",
	pretty_hostname = nil,

	welcome = "Welcome to the config mode of your Freifunk node! Here you can " ..
		"adjust a few basic settings before connecting your node to the mesh.",

	-- mesh domains offered by domain-select (glob of /lib/gluon/domains/*.json)
	domains = {
		ffac = { domain_names = { ffac = "Aachen" },        hide_domain = false },
		ffms = { domain_names = { ffms = "Muenster" },      hide_domain = false },
		ffbs = { domain_names = { ffbs = "Braunschweig" },  hide_domain = false },
	},

	-- strings normally provided by the site i18n catalog
	site_i18n = {
		["gluon-config-mode:domain-select"] = "Please select the region your node is located in.",
		["gluon-config-mode:domain"] = "Region",
		["gluon-web-node-role:role:node"] = "Normal node",
		["gluon-web-node-role:role:gateway"] = "Gateway",
		["gluon-web-node-role:role:test"] = "Test node",
	},

	-- toggles that gate whole sections / pages
	outdoor_device = true,    -- show the outdoor wizard section
	cellular_device = false,  -- register the cellular admin page
	mesh_vpn_provider = "fastd",
}

-- site.* accessors. Leaves are either function-accessors `f(default)` or plain
-- functions; this mirrors how a real site.conf is consumed.
local function acc(value)
	return function(default)
		if value == nil then return default end
		return value
	end
end

MOCK.site = {
	default_domain = function() return "ffac" end,
	roles = { list = function() return { "node", "gateway", "test" } end },
	config_mode = {
		hostname = { optional = acc(true), prefill = acc(true) },
		geo_location = { show_altitude = acc(true) },
		remote_login = { show_password_form = acc(true), min_password_length = acc(12) },
	},
	mesh_vpn = { fastd = { methods = function() return { "salsa2012+umac" } end } },
	wifi24 = { mesh = { disabled = acc(false) } },
	wifi5  = { mesh = { disabled = acc(false) } },
	wifi6  = { mesh = { disabled = acc(false) } },
}

-- UCI dataset: each config is an ordered list of sections; a section carries
-- ".name"/".type" plus its options (lists are Lua tables).
local MOCK_UCI = {
	["gluon-setup-mode"] = {
		{ [".name"] = "setup_mode", [".type"] = "setup_mode", configured = "1" },
	},
	gluon = {
		{ [".name"] = "core", [".type"] = "core", domain = "ffac" },
		{ [".name"] = "mesh_vpn", [".type"] = "mesh_vpn", enabled = "1", limit_enabled = "0" },
		{ [".name"] = "wireless", [".type"] = "wireless", outdoor = "0", preserve_channels = "0",
			private_ssid = "MyHomeNet", private_key = "", private_encryption = "psk2", private_mfp = "0" },
		{ [".name"] = "d_wan", [".type"] = "interface", name = "/wan", role = { "uplink" } },
		{ [".name"] = "d_lan", [".type"] = "interface", name = "/lan", role = { "client" } },
		{ [".name"] = "band_2g", [".type"] = "wireless_band", role = { "client", "mesh" } },
		{ [".name"] = "band_5g", [".type"] = "wireless_band", role = { "client", "mesh" } },
	},
	["gluon-node-info"] = {
		{ [".name"] = "system", [".type"] = "system", role = "node" },
		{ [".name"] = "owner", [".type"] = "owner", contact = "freifunk@example.org" },
		{ [".name"] = "location", [".type"] = "location",
			latitude = "50.7766", longitude = "6.0834", share_location = "1" },
	},
	network = {
		{ [".name"] = "wan", [".type"] = "interface", proto = "dhcp" },
		{ [".name"] = "wan6", [".type"] = "interface", proto = "dhcpv6" },
	},
	["gluon-wan-dnsmasq"] = {
		{ [".name"] = "static", [".type"] = "static", server = { "8.8.8.8", "8.8.4.4" } },
	},
	system = {
		{ [".name"] = "system", [".type"] = "system", log_remote = "0", hostname = "Freifunk-Node-1234" },
	},
	autoupdater = {
		{ [".name"] = "settings", [".type"] = "autoupdater", enabled = "1", branch = "stable" },
		{ [".name"] = "stable", [".type"] = "branch", name = "stable" },
		{ [".name"] = "beta", [".type"] = "branch", name = "beta" },
	},
	fastd = {
		{ [".name"] = "mesh_vpn", [".type"] = "mesh_vpn", method = { "salsa2012+umac" } },
	},
	wireless = {
		{ [".name"] = "radio0", [".type"] = "wifi-device", band = "2g", path = "phy0" },
		{ [".name"] = "radio1", [".type"] = "wifi-device", band = "5g", path = "phy1" },
	},
}

----------------------------------------------------------------------
-- Source-tree discovery.
----------------------------------------------------------------------

local function popen_lines(cmd)
	local out, p = {}, assert(io.popen(cmd))
	for line in p:lines() do out[#out + 1] = line end
	p:close()
	return out
end

local function basename(path) return path:match("([^/]+)$") end

-- map "admin/network" -> source file, by scanning every package's model dir
local function discover(kind, ext)
	local map = {}
	local files = popen_lines(string.format(
		"find package -path '*/luasrc/lib/gluon/config-mode/%s/*.%s' 2>/dev/null", kind, ext))
	if kind == "view" then
		files = popen_lines(string.format(
			"find package -path '*/files/lib/gluon/config-mode/%s/*.%s' 2>/dev/null", kind, ext))
	end
	for _, f in ipairs(files) do
		local name = f:match("/" .. kind .. "/(.+)%." .. ext .. "$")
		if name then map[name] = f end
	end
	return map
end

local MODEL_FILES = discover("model", "lua")
local SECTION_FILES = (function()
	local files = popen_lines(
		"find package -path '*/luasrc/lib/gluon/config-mode/wizard/*.lua' 2>/dev/null")
	table.sort(files, function(a, b) return basename(a) < basename(b) end)
	return files
end)()
local CONTROLLER_FILES = (function()
	-- dispatcher loads base/*.lua then base/*/*.lua
	local files = popen_lines(
		"find package -path '*/luasrc/lib/gluon/config-mode/controller/*.lua' 2>/dev/null")
	table.sort(files, function(a, b)
		local da = select(2, a:gsub("/", "/")) -- depth proxy
		local db = select(2, b:gsub("/", "/"))
		if da ~= db then return da < db end
		return a < b
	end)
	return files
end)()

----------------------------------------------------------------------
-- Stub backend modules.
----------------------------------------------------------------------

-- gluon.web.util: real class/instanceof, pure-Lua pcdata (no C parser).
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
		for _, x in ipairs(t) do if x == v then return true end end
		return false
	end
	function M.add_to_set(t, v) if not M.contains(t, v) then t[#t + 1] = v end end
	function M.remove_from_set(t, v)
		for i, x in ipairs(t) do if x == v then table.remove(t, i); return end end
	end
	function M.default_hostname() return MOCK.default_hostname end
	function M.trim(s) return (tostring(s):gsub("^%s+", ""):gsub("%s+$", "")) end
	function M.readfile(path)
		local f = io.open(path); if not f then return nil end
		local d = f:read("*a"); f:close(); return d
	end
	function M.exec() return "" end
	function M.file_contains_line() return false end
	function M.get_role_interfaces() return {} end
	function M.get_role_interfaces_with_options() return {} end
	M.subprocess = { PIPE = 1, DEVNULL = 2, popen = function() return nil end }
	return M
end

-- simple-uci cursor over MOCK_UCI
package.preload["simple-uci"] = function()
	local function sections(config) return MOCK_UCI[config] or {} end
	local function find(config, name)
		for _, s in ipairs(sections(config)) do
			if s[".name"] == name then return s end
		end
	end

	local C = {}
	C.__index = C
	function C:get(config, section, option)
		local s = find(config, section)
		if not s then return nil end
		if option == nil then return s[".type"] end
		return s[option]
	end
	function C:get_all(config, section) return find(config, section) end
	function C:get_bool(config, section, option) return self:get(config, section, option) == "1" end
	function C:get_list(config, section, option)
		local v = self:get(config, section, option)
		if type(v) == "table" then return v end
		if v == nil then return {} end
		return { v }
	end
	function C:foreach(config, stype, fn)
		for _, s in ipairs(sections(config)) do
			if s[".type"] == stype then
				if fn(s) == false then return false end
			end
		end
		return true
	end
	function C:get_first(config, stype, option, default)
		local rv = default
		self:foreach(config, stype, function(s)
			local val = (option == nil) and s[".name"] or s[option]
			if type(default) == "number" then val = tonumber(val)
			elseif type(default) == "boolean" then val = (val == "1") end
			if val ~= nil then rv = val; return false end
		end)
		return rv
	end
	-- mutations are no-ops for the preview, but must not error
	function C:set() end
	function C:set_list() end
	function C:delete() end
	function C:delete_all() end
	function C:save() end
	function C:commit() end
	function C:add() return "cfgmock" end
	function C:section() return "cfgmock" end
	function C:tset() end

	return { cursor = function() return setmetatable({}, C) end }
end

package.preload["pretty_hostname"] = function()
	return {
		get = function() return MOCK.pretty_hostname or MOCK.hostname end,
		set = function() end,
	}
end

package.preload["gluon.site"] = function() return MOCK.site end

package.preload["gluon.mesh-vpn"] = function()
	return { get_active_provider = function()
		return MOCK.mesh_vpn_provider, MOCK.mesh_vpn_provider
	end }
end

package.preload["gluon.platform"] = function()
	return {
		is_outdoor_device = function() return MOCK.outdoor_device end,
		is_cellular_device = function() return MOCK.cellular_device end,
	}
end

package.preload["gluon.wireless"] = function()
	local uci_has = function(uci, band)
		local ret = false
		uci:foreach("wireless", "wifi-device", function(r)
			if not band or r.band == band then ret = true; return false end
		end)
		return ret
	end
	return {
		device_uses_wlan = function(uci) return uci_has(uci) end,
		device_uses_band = function(uci, band) return uci_has(uci, band) end,
		preserve_channels = function() return false end,
		device_supports_wpa3 = function() return true end,
		device_supports_mfp = function() return true end,
		find_phy = function(config) return config and config.path or "phy0" end,
		foreach_radio = function(uci, f)
			local bands = { ["2g"] = MOCK.site.wifi24, ["5g"] = MOCK.site.wifi5, ["6g"] = MOCK.site.wifi6 }
			local i = 0
			uci:foreach("wireless", "wifi-device", function(radio)
				f(radio, i, bands[radio.band]); i = i + 1
			end)
		end,
	}
end

package.preload["iwinfo"] = function()
	local nl = {
		txpwrlist = function() return {} end,
		txpower_offset = function() return 0 end,
		htmodelist = function() return {} end,
	}
	return { nl80211 = nl }
end

-- posix stubs (required at load by a few controllers/models)
local function posix_noop() return {} end
package.preload["posix.unistd"] = function()
	return setmetatable({ access = function() return false end }, { __index = function() return function() end end })
end
package.preload["posix.fcntl"] = function() return { open = function() return nil end, O_WRONLY = 1, O_RDWR = 2 } end
package.preload["posix.sys.wait"] = function() return { wait = function() return nil end } end
package.preload["posix.sys.stat"] = function() return { stat = function() return { st_size = 0 } end } end
package.preload["posix.glob"] = posix_noop

package.preload["jsonc"] = function()
	return {
		load = function(path) return MOCK.domains[basename(path):gsub("%.json$", "")] end,
		stringify = function(v) return require("__json").encode(v) end,
	}
end

package.preload["__json"] = function()
	local J = {}
	local function enc_string(s)
		return '"' .. s:gsub('[%z\1-\31\\"]', function(c)
			local m = { ['"'] = '\\"', ['\\'] = '\\\\', ['\n'] = '\\n', ['\r'] = '\\r', ['\t'] = '\\t' }
			return m[c] or string.format("\\u%04x", c:byte())
		end) .. '"'
	end
	function J.encode(v)
		local t = type(v)
		if v == nil then return "null"
		elseif t == "boolean" then return v and "true" or "false"
		elseif t == "number" then return tostring(v)
		elseif t == "string" then return enc_string(v)
		elseif t == "table" then
			local n, isarr = 0, true
			for k in pairs(v) do n = n + 1; if type(k) ~= "number" then isarr = false end end
			if n == 0 then return "{}" end
			local parts = {}
			if isarr then
				for i = 1, #v do parts[i] = J.encode(v[i]) end
				return "[" .. table.concat(parts, ",") .. "]"
			end
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
-- Model loading (real classes + identity i18n).
----------------------------------------------------------------------

local classes = require("gluon.web.model.classes")

local function make_i18n(catalog)
	catalog = catalog or {}
	return {
		translate = function(s) return catalog[s] or s end,
		translatef = function(s, ...) return (catalog[s] or tostring(s)):format(...) end,
		_translate = function(s) return catalog[s] end,
	}
end
local default_i18n = make_i18n()
local function i18n_factory(pkg)
	if pkg == "gluon-site" then return make_i18n(MOCK.site_i18n) end
	return make_i18n()
end

local function model_env()
	return setmetatable({}, {
		__index = function(_, key)
			if classes[key] ~= nil then return classes[key] end
			if key == "i18n" then return i18n_factory end
			if default_i18n[key] ~= nil then return default_i18n[key] end
			return _G[key]
		end,
	})
end

-- returns a list of forms (a model may return several)
local function load_model(filename)
	local func = assert(loadfile(filename))
	setfenv(func, model_env())
	local models = { func() }
	for k, m in ipairs(models) do m.index = k end
	return models
end

----------------------------------------------------------------------
-- Controller execution -> navigation tree.
----------------------------------------------------------------------

local root = { nodes = {} }

local function tree_node(path, create)
	local node = root
	for _, seg in ipairs(path) do
		if not node.nodes[seg] then
			if not create then return nil end
			node.nodes[seg] = { nodes = {} }
		end
		node = node.nodes[seg]
	end
	return node
end

local function run_controller(file)
	local chunk = assert(loadfile(file))
	local pkg
	local subdisp = setmetatable({
		package = function(name) pkg = name end,
		node = function(...) return tree_node({ ... }, true) end,
		entry = function(path, target, title, order)
			local c = tree_node(path, true)
			c.target, c.title, c.order, c.pkg = target, title, order, pkg
			return c
		end,
		alias = function(...) return { type = "alias", path = { ... } } end,
		call = function() return { type = "call" } end,
		template = function(view) return { type = "template", view = view, pkg = pkg } end,
		model = function(name) return { type = "model", name = name, pkg = pkg } end,
		_ = function(text) return text end,
	}, { __index = _G })
	setfenv(chunk, setmetatable({}, { __index = subdisp }))
	chunk()
end

for _, file in ipairs(CONTROLLER_FILES) do
	local ok, err = pcall(run_controller, file)
	if not ok then
		io.stderr:write(string.format("warning: controller %s failed: %s\n", file, err))
	end
end

----------------------------------------------------------------------
-- HTML emitter (mirrors the gluon-web view templates).
----------------------------------------------------------------------

local function esc(s)
	return (tostring(s)
		:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		:gsub('"', "&#34;"):gsub("'", "&#39;"))
end

local function attr(key, val)
	if not val then return "" end
	if type(val) == "table" then val = json.encode(val) end
	return string.format(' %s="%s"', key, esc(tostring(val)))
end

local function has_text(s) return s and #s > 0 end

local buf
local function w(s) buf[#buf + 1] = s end

-- widget subtemplates ------------------------------------------------

local function emit_value_input(o)
	w("<input data-update=\"change\"")
	w(attr("id", o:id()) .. attr("name", o:id()))
	w(attr("type", o.password and "password" or "text"))
	w(attr("value", o:cfgvalue()) .. attr("size", o.size))
	w(attr("placeholder", o.placeholder) .. attr("maxlength", o.maxlength))
	w(attr("data-type", o.datatype) .. attr("data-optional", o.datatype and o.optional))
	w(">")
end

local function emit_flag_input(o)
	w("<input data-update=\"click change\" type=\"checkbox\" value=\"1\"")
	w(attr("id", o:id()) .. attr("name", o:id()))
	w(attr("checked", o:cfgvalue() and "checked") .. ">")
	w(string.format("<label%s></label>", attr("for", o:id())))
end

local function emit_list_input(o)
	local id, entries = o:id(), o:entries()
	if o.widget == "radio" then
		local br = o.orientation == "horizontal" and "&#160;&#160;&#160;" or "<br>"
		w("<div>")
		for i, e in ipairs(entries) do
			w(string.format("<label%s%s>", attr("data-index", i), attr("data-depends", o:deplist(e.deps))))
			w("<input data-update=\"click change\" type=\"radio\"")
			w(attr("id", id .. "." .. e.key) .. attr("name", id) .. attr("value", e.key))
			w(attr("checked", (o:cfgvalue() == e.key) and "checked") .. ">")
			w(string.format("<label%s></label>", attr("for", id .. "." .. e.key)))
			w(esc(e.value) .. "</label>")
			if i ~= #entries then w(br) end
		end
		w("</div>")
	else
		w("<div class=\"select-wrapper\"><select data-update=\"change\"")
		w(attr("id", id) .. attr("name", id) .. attr("size", o.size))
		w(attr("data-type", "minlength(1)") .. attr("data-optional", o.optional) .. ">")
		for i, e in ipairs(entries) do
			w("<option" .. attr("id", id .. "." .. e.key) .. attr("value", e.key))
			w(attr("data-index", i) .. attr("data-depends", o:deplist(e.deps)))
			w(attr("selected", (o:cfgvalue() == e.key) and "selected") .. ">")
			w(esc(e.value) .. "</option>")
		end
		w("</select></div>")
	end
end

local function emit_multilist_input(o)
	local id, entries = o:id(), o:entries()
	local cfg = o:cfgvalue() or {}
	local function contains(v)
		for _, x in ipairs(cfg) do if x == v then return true end end
		return false
	end
	local br = o.orientation == "horizontal" and "&#160;&#160;&#160;" or "<br>"
	w("<div>")
	for i, e in ipairs(entries) do
		w(string.format("<label%s%s>", attr("data-index", i), attr("data-depends", o:deplist(e.deps))))
		w("<input data-update=\"change\" type=\"checkbox\"")
		w(attr("id", id .. "." .. e.key) .. attr("name", id) .. attr("value", e.key))
		w(attr("checked", contains(e.key) and "checked"))
		w(attr("data-exclusive-with", o.exclusions and o.exclusions[e.key]) .. ">")
		w(string.format("<label%s></label>", attr("for", id .. "." .. e.key)))
		w(string.format("<span class=\"gluon-multi-list-option-descr\">%s</span></label>", esc(e.value)))
		if i ~= #entries then w(br) end
	end
	w("</div>")
end

local function emit_dynlist_input(o)
	local id = o:id()
	w(string.format("<div%s>", attr("data-dynlist", {
		prefix = id, type = o.datatype, optional = o.datatype and o.optional,
		size = o.size, placeholder = o.placeholder,
	})))
	for i, val in ipairs(o:cfgvalue()) do
		w(string.format("<input value=\"%s\" data-update=\"change\" type=\"text\"%s%s%s%s><br>",
			esc(val), attr("id", id .. "." .. i), attr("name", id),
			attr("size", o.size), attr("placeholder", o.placeholder)))
	end
	w("</div>")
end

local function emit_text_input(o)
	w("<textarea")
	if not o.size then w(" style=\"width: 100%\"") else w(attr("cols", o.size)) end
	w(" data-update=\"change\"" .. attr("name", o:id()) .. attr("id", o:id()))
	w(attr("rows", o.rows) .. attr("wrap", o.wrap) .. ">")
	w(esc(o:cfgvalue() or "") .. "</textarea>")
end

local WIDGETS = {
	["model/value"] = emit_value_input,
	["model/fvalue"] = emit_flag_input,
	["model/lvalue"] = emit_list_input,
	["model/mlvalue"] = emit_multilist_input,
	["model/dynlist"] = emit_dynlist_input,
	["model/tvalue"] = emit_text_input,
}

-- model/valuewrapper
local function emit_option(o)
	local id = o:id()
	w(string.format("<div class=\"gluon-value%s\" id=\"value-%s\"%s%s>",
		o.error and " gluon-value-error" or "", id,
		attr("data-index", o.index), attr("data-depends", o:deplist())))
	local titled = has_text(o.title)
	if titled then
		w(string.format("<label class=\"gluon-value-title\"%s>%s</label><div class=\"gluon-value-field\">",
			attr("for", id), esc(o.title)))
	end
	local widget = WIDGETS[o.subtemplate]
	if widget then widget(o) else
		w(string.format("<em class=\"gluon-value-description\">[%s]</em>", esc(o.subtemplate or "?")))
	end
	if has_text(o.description) then
		w("<br><div class=\"gluon-value-description\">" .. o.description .. "</div>")
	end
	if titled then w("</div>") end
	w("</div>")
end

-- model/warning
local function emit_warning(o)
	if o.hide then return end
	w(string.format("<div class=\"gluon-warning\"%s%s%s>",
		attr("id", o:id()), attr("data-index", o.index), attr("data-depends", o:deplist(o.deps))))
	if o.content then w(o.content)
	else w("<b>" .. esc(o.title or "") .. "</b><br>" .. (o.description or "")) end
	w("</div>")
end

local function emit_child(child)
	if child.template == "model/valuewrapper" then emit_option(child)
	elseif child.template == "model/warning" then emit_warning(child)
	else
		-- option with a custom wrapper template (e.g. mesh-vpn-fastd)
		w(string.format("<div class=\"gluon-value\"><em>[custom widget: %s]</em></div>",
			esc(child.template or "?")))
	end
end

-- model/section
local function emit_section(s)
	w(string.format("<fieldset class=\"gluon-section\" id=\"%s\" data-index=\"%s\"%s>",
		s:id(), s.index, attr("data-depends", s:deplist())))
	if has_text(s.title) then w("<legend>" .. esc(s.title) .. "</legend>") end
	if has_text(s.description) then
		w("<div class=\"gluon-section-descr\">" .. s.description .. "</div>")
	end
	w(string.format("<div class=\"gluon-section-node\" id=\"section-%s\">", s:id()))
	for _, child in ipairs(s.children) do emit_child(child) end
	w("</div></fieldset>")
end

local function emit_custom_section(s)  -- e.g. wizard/welcome
	w(string.format("<fieldset class=\"gluon-section\" id=\"%s\" data-index=\"%s\">", s:id(), s.index))
	w("<p>" .. esc(MOCK.welcome) .. "</p></fieldset>")
end

-- model/form
local function emit_form(f)
	w("<form method=\"post\" enctype=\"multipart/form-data\" action=\"#\" data-update=\"reset\">")
	w(string.format("<input type=\"hidden\" name=\"%s\" value=\"1\">", f:id()))
	w(string.format("<div class=\"gluon-form\" id=\"form-%s\">", f:id()))
	if has_text(f.title) then w("<h2 name=\"content\">" .. esc(f.title) .. "</h2>") end
	if has_text(f.description) then w("<div class=\"gluon-form-descr\">" .. f.description .. "</div>") end
	for _, child in ipairs(f.children) do
		if child.template == "model/section" then emit_section(child) else emit_custom_section(child) end
	end
	w("</div>")
	if f.message then w("<div>" .. esc(f.message) .. "</div>") end
	if f.errmessage then w("<div class=\"error\">" .. esc(f.errmessage) .. "</div>") end
	w("<div class=\"gluon-page-actions\">")
	if f.submit ~= false then
		w(string.format("<input class=\"gluon-button gluon-button-submit\" type=\"submit\" value=\"%s\">",
			esc(f.submit or "Save")))
	end
	if f.reset ~= false then
		w(string.format("<input class=\"gluon-button gluon-button-reset\" type=\"reset\" value=\"%s\">",
			esc(f.reset or "Reset")))
	end
	w("</div></form>")
end

----------------------------------------------------------------------
-- Navigation + page assembly.
----------------------------------------------------------------------

local function node_visible(n) return n.title and n.target and not n.hidden end

local function node_children(n)
	local ret = {}
	for k, v in pairs(n.nodes) do if node_visible(v) then ret[#ret + 1] = k end end
	table.sort(ret, function(a, b)
		return (n.nodes[a].order or 100) < (n.nodes[b].order or 100)
	end)
	return ret
end

local function page_filename(path)
	if #path == 0 then return "index.html" end
	return table.concat(path, "-") .. ".html"
end

-- resolve alias chains to a concrete page path
local function resolve(path)
	local n = tree_node(path)
	local seen = 0
	while n and n.target and n.target.type == "alias" and seen < 8 do
		path = n.target.path
		n = tree_node(path)
		seen = seen + 1
	end
	return path
end

local function url(path) return page_filename(resolve(path)) end

local function append(xs, x)
	local r = { unpack(xs) }; r[#r + 1] = x; return r
end

-- tabmenu, mirroring layout.html's subtree()
local function emit_subtree(prefix, node, rest)
	if not node then return end
	local children = node_children(node)
	if #children == 0 then return end
	local name = rest[1]
	w(string.format("<div class=\"tabmenu%d\"><ul class=\"tabmenu l%d\">", #prefix, #prefix))
	for _, v in ipairs(children) do
		local child = node.nodes[v]
		local active = (v == name) and " active" or ""
		w(string.format("<li class=\"tabmenu-item-%s%s\"><a href=\"%s\">%s</a></li>",
			v, active, url(append(prefix, v)), esc(child.title)))
	end
	w("</ul><br style=\"clear:both\">")
	if name then emit_subtree(append(prefix, name), node.nodes[name], { unpack(rest, 2) }) end
	w("</div>")
end

local function render_page(path, title, content_html)
	buf = {}
	-- menubar
	w("<div id=\"menubar\"><div class=\"hostinfo\">")
	w(string.format("<a href=\"%s\">%s / %s</a>", url({}), esc(MOCK.hostname), esc(MOCK.release)))
	w("</div>")
	local categories = node_children(root)
	if #categories > 1 then
		w("<ul id=\"topmenu\">")
		for _, r in ipairs(categories) do
			local active = (path[1] == r) and " active" or ""
			w(string.format("<li><a class=\"topcat%s\" href=\"%s\">%s</a></li>",
				active, url({ r }), esc(root.nodes[r].title)))
		end
		w("</ul>")
	end
	w("</div>")
	-- main
	w("<div id=\"maincontainer\">")
	if path[1] and root.nodes[path[1]] then
		emit_subtree({ path[1] }, root.nodes[path[1]], { unpack(path, 2) })
	end
	w("<div id=\"maincontent\">")
	w("<noscript><div class=\"errorbox\"><strong>JavaScript required!</strong><br>" ..
		"You must enable JavaScript in your browser or the web interface will not work properly.</div></noscript>")
	w(content_html)
	w("</div></div>")
	local body = table.concat(buf)

	return string.format([[<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="stylesheet" type="text/css" media="screen" href="static/gluon.css">
		<title>%s</title>
	</head>
	<body>
%s
	<script src="static/gluon-web-model.js"></script>
	</body>
</html>
]], esc(MOCK.hostname .. (title and (" - " .. title) or "")), body)
end

local function placeholder(kind, detail)
	return string.format(
		"<div class=\"gluon-form\"><div class=\"gluon-section-descr\">" ..
		"This page is rendered by a <strong>%s</strong> on the device (%s) and is not part of the " ..
		"static preview. The navigation entry is shown for completeness.</div></div>", esc(kind), esc(detail))
end

local function render_target(node)
	local t = node.target
	if t.type == "model" then
		local file = MODEL_FILES[t.name]
		if not file then return placeholder("model", "missing source for " .. t.name) end
		local ok, forms = pcall(load_model, file)
		if not ok then
			return string.format(
				"<div class=\"gluon-form\"><div class=\"error500\"><strong>Could not render this page " ..
				"with mock data.</strong><br>It likely needs live device state.<br><br><code>%s</code></div></div>",
				esc(tostring(forms)))
		end
		buf = {}
		for _, f in ipairs(forms) do emit_form(f) end
		return table.concat(buf)
	elseif t.type == "template" then
		return placeholder("custom template", t.view)
	else
		return placeholder("controller action", "e.g. firmware upload/reboot")
	end
end

-- collect all page nodes (DFS)
local pages = {}
local function collect(node, path)
	for _, k in ipairs(node_children(node)) do
		local child = node.nodes[k]
		local cp = append(path, k)
		if child.target and child.target.type ~= "alias" then
			pages[#pages + 1] = { path = cp, node = child }
		end
		collect(child, cp)
	end
end
collect(root, {})

----------------------------------------------------------------------
-- Write output.
----------------------------------------------------------------------

os.execute("mkdir -p " .. OUTDIR .. "/static")

local written = {}
for _, page in ipairs(pages) do
	local content = render_target(page.node)
	local html = render_page(page.path, page.node.title, content)
	local fname = page_filename(page.path)
	local fh = assert(io.open(OUTDIR .. "/" .. fname, "w"))
	fh:write(html); fh:close()
	written[#written + 1] = fname
end

-- index.html -> redirect to the default (resolved root) page
local landing = url({})
local fh = assert(io.open(OUTDIR .. "/index.html", "w"))
fh:write(string.format([[<!DOCTYPE html>
<html lang="en"><head><meta charset="UTF-8">
<meta http-equiv="refresh" content="0; URL=%s"></head>
<body><a href="%s">Continue</a></body></html>
]], landing, landing))
fh:close()

io.stderr:write(string.format("Generated %d pages: %s\n", #written, table.concat(written, ", ")))
