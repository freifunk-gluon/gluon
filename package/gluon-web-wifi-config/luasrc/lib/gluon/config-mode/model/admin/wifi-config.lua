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

-- Returns the configurable channel widths supported by the radio in
-- ascending order, considering the HT modes that are applied
local function channel_width_list(phy)
	local widths = {}
	for mode, available in pairs(iwinfo.nl80211.htmodelist(phy) or {}) do
		local hwmode, width = mode:match('^(%a+)(%d+)$')
		width = tonumber(width)
		if available and util.contains({'HT', 'VHT', 'HE'}, hwmode)
				and util.contains(wireless.channel_widths, width) then
			util.add_to_set(widths, width)
		end
	end
	table.sort(widths)
	return widths
end

local f = Form(translate("WLAN"))

f:section(Section, nil, translate(
	"You can enable or disable your node's client and mesh network "
	.. "SSIDs here. Please don't disable the mesh network without "
	.. "a good reason, so other nodes can mesh with yours.<br><br>"
	.. "It is also possible to configure the transmission power and the channel "
	.. "width of the WLAN adapters here. Please note that the transmission power values include the antenna gain "
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
	elseif band == 'band_6g' then
		title = translate("6GHz WLAN")
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

local p = f:section(Section, translate("Per radio settings"))
uci:foreach('wireless', 'wifi-device', function(config)
	local phy = wireless.find_phy(config)
	-- Per-radio settings are identified by the radio path
	if not phy or not config.path then
		return
	end

	local radio = config['.name']

	local txpowers = txpower_list(phy)
	if #txpowers > 1 then
		local tp = p:option(ListValue, radio .. '_txpower', translate("Transmission power") .. ' (' .. radio .. ')')
		tp.default = wireless.radio_option(uci, config, 'txpower') or 'default'

		tp:value('default', translate("(default)"))

		table.sort(txpowers, function(a, b) return a.driver_dbm > b.driver_dbm end)

		for _, entry in ipairs(txpowers) do
			tp:value(entry.driver_dbm, string.format("%i dBm (%i mW)", entry.display_dbm, entry.display_mw))
		end

		function tp:write(data)
			if data == 'default' then
				data = nil
			end
			wireless.set_radio_option(uci, config, 'txpower', data)
		end
	end

	-- The channel width is not applied when channels are preserved
	local channel_widths = channel_width_list(phy)
	if #channel_widths > 1 and not wireless.preserve_channels(uci) then
		local cw = p:option(ListValue, radio .. '_channel_width', translate("Channel width") .. ' (' .. radio .. ')')
		cw.default = wireless.radio_option(uci, config, 'channel_width') or 'default'

		cw:value('default', translate("(default)"))

		for _, width in ipairs(channel_widths) do
			cw:value(tostring(width), string.format("%i MHz", width))
		end

		function cw:write(data)
			if data == 'default' then
				data = nil
			end
			wireless.set_radio_option(uci, config, 'channel_width', data)
		end
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
	outdoor.default = wireless.is_outdoor(uci)

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
