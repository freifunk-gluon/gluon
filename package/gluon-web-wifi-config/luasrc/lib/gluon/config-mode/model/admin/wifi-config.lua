local iwinfo = require 'iwinfo'
local uci = require("simple-uci").cursor()
local site = require 'gluon.site'
local wireless = require 'gluon.wireless'
local util = require 'gluon.util'

local function txpower_list(phy)
	local list = iwinfo.nl80211.txpwrlist(phy) or { }
	local off  = tonumber(iwinfo.nl80211.txpower_offset(phy)) or 0
	local new  = { }
	local prev = -1
	for _, val in ipairs(list) do
		local dbm = val.dbm + off
		local mw  = math.floor(10 ^ (dbm / 10))
		if mw ~= prev then
			prev = mw
			table.insert(new, {
				display_dbm = dbm,
				display_mw  = mw,
				driver_dbm  = val.dbm,
			})
		end
	end
	return new
end

local f = Form(translate("WLAN"))

f:section(Section, nil, translate(
	"You can enable or disable your node's client and mesh network "
	.. "SSIDs here. Please don't disable the mesh network without "
	.. "a good reason, so other nodes can mesh with yours.<br><br>"
	.. "It is also possible to configure the WLAN adapters transmission power "
	.. "here. Please note that the transmission power values include the antenna gain "
	.. "where available, but there are many devices for which the gain is unavailable or inaccurate."
))


local mesh_vifs_5ghz = {}

local function add_or_remove_role(roles, role, enabled)
	if enabled then
		util.add_to_set(roles, role)
	else
		util.remove_from_set(roles, role)
	end
end

local function vif_option(section, role_name, band, band_config, msg)
	local o = section:option(Flag, band .. '_' .. role_name .. '_enabled', msg)
	o.default = util.contains(band_config.role or {}, role_name)

	function o:write(data)
		-- Without the additional read before write in o:write, this would race
		local roles = uci:get_list('gluon', band, 'role')
		add_or_remove_role(roles, role_name, data)
		uci:set_list('gluon', band, 'role', roles)
	end

	return o
end

uci:foreach('gluon', 'wireless_band', function(band_config)
	local band = band_config['.name']

	local is_5ghz = false
	local title

	if band == 'band_2g' then
		title = translate("2.4GHz WLAN")
	elseif band == 'band_5g' then
		is_5ghz = true
		title = translate("5GHz WLAN")
	else
		return
	end

	local p = f:section(Section, title)

	vif_option(p, 'client', band, band_config, translate('Enable client network (access point)'))

	local mesh_vif = vif_option(p, 'mesh', band, band_config, translate("Enable mesh network (802.11s)"))
	if is_5ghz then
		table.insert(mesh_vifs_5ghz, mesh_vif)
	end
end)

local radio_sec = f:section(Section, translate("Per radio settings"))
wireless.foreach_radio(uci, function(radio)
	local radio_name = radio['.name']
	local phy = wireless.find_phy(radio)
	if not phy then
		return
	end

	local txpowers = txpower_list(phy)
	if #txpowers <= 1 then
		return
	end

	local str_txpower = translate("Transmission power").. ' (' .. radio_name .. ')'
	local tp = radio_sec:option(ListValue, 'txpower_' .. radio_name, str_txpower)
	tp.default = uci:get('gluon', radio_name, 'txpower') or 'default'

	tp:value('default', translate("(default)"))

	table.sort(txpowers, function(a, b) return a.driver_dbm > b.driver_dbm end)

	for _, entry in ipairs(txpowers) do
		tp:value(entry.driver_dbm, string.format("%i dBm (%i mW)", entry.display_dbm, entry.display_mw))
	end

	function tp:write(data)
		if data == 'default' then
			data = nil
		end
		uci:set('gluon', radio_name, 'txpower', data)
	end

	-- htmode
	local str_htmode = translate('HT Mode') .. ' (' .. radio_name .. ')'
	local ht = radio_sec:option(ListValue, 'htmode_' .. radio_name, str_htmode)
	ht.default = uci:get('gluon', radio_name, 'htmode') or 'default'
	ht:value('default', translate("(default)"))

	for mode, available in pairs(iwinfo.nl80211.htmodelist(phy)) do
		if available then
			ht:value(mode, mode)
		end
	end

	function ht:write(data)
		if data == 'default' then
			data = nil
		end
		uci:set('gluon', radio_name, 'htmode', data)
	end
end)


if wireless.device_uses_band(uci, '5g') and not wireless.preserve_channels(uci) then
	local r = f:section(Section, translate("Outdoor Installation"), translate(
		"Configuring the node for outdoor use tunes the 5 GHz radio to a frequency "
		.. "and transmission power that conforms with the local regulatory requirements. "
		.. "It also enables dynamic frequency selection (DFS; radar detection). At the "
		.. "same time, mesh functionality is disabled as it requires neighbouring nodes "
		.. "to stay on the same channel permanently."
	))

	local outdoor = r:option(Flag, 'outdoor', translate("Node will be installed outdoors"))
	outdoor.default = uci:get_bool('gluon', 'wireless', 'outdoor')

	for _, mesh_vif in ipairs(mesh_vifs_5ghz) do
		mesh_vif:depends(outdoor, false)
		if outdoor.default then
			mesh_vif.default = not site.wifi5.mesh.disabled(false)
		end
	end

	function outdoor:write(data)
		uci:set('gluon', 'wireless', 'outdoor', data)
	end
end


function f:write()
	uci:commit('gluon')
	os.execute('exec gluon-reconfigure >/dev/null')
end

return f
