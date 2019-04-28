local iwinfo = require 'iwinfo'
local site = require 'gluon.site'
local uci = require("simple-uci").cursor()
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

local function has_5ghz_radio()
	local result = false
	uci:foreach('wireless', 'wifi-device', function(config)
		local radio = config['.name']
		local hwmode = uci:get('wireless', radio, 'hwmode')

		result = result or (hwmode == '11a' or hwmode == '11na')
	end)

	return result
end

local f = Form(translate("WLAN"))

f:section(Section, nil, translate(
	"You can enable or disable your node's client and mesh network "
	.. "SSIDs here. Please don't disable the mesh network without "
	.. "a good reason, so other nodes can mesh with yours.<br /><br />"
	.. "It is also possible to configure the WLAN adapters transmission power "
	.. "here. Please note that the transmission power values include the antenna gain "
	.. "where available, but there are many devices for which the gain is unavailable or inaccurate."
))


uci:foreach('wireless', 'wifi-device', function(config)
	local radio = config['.name']

	local title
	if config.hwmode == '11g' or config.hwmode == '11ng' then
		title = translate("2.4GHz WLAN")
	elseif config.hwmode == '11a' or config.hwmode == '11na' then
		title = translate("5GHz WLAN")
	else
		return
	end

	local p = f:section(Section, title)

	local function vif_option(t, msg)
		if not uci:get('wireless', t .. '_' .. radio) then
			return
		end

		local o = p:option(Flag, radio .. '_' .. t .. '_enabled', msg)
		o.default = not uci:get_bool('wireless', t .. '_' .. radio, 'disabled')

		function o:write(data)
			uci:set('wireless', t .. '_' .. radio, 'disabled', not data)
		end
	end

	vif_option('client', translate('Enable client network (access point)'))
	vif_option('mesh', translate("Enable mesh network (802.11s)"))
	vif_option('ibss', translate("Enable mesh network (IBSS)"))

	local phy = util.find_phy(config)
	if not phy then
		return
	end

	local txpowers = txpower_list(phy)
	if #txpowers <= 1 then
		return
	end

	local tp = p:option(ListValue, radio .. '_txpower', translate("Transmission power"))
	tp.default = uci:get('wireless', radio, 'txpower') or 'default'

	tp:value('default', translate("(default)"))

	table.sort(txpowers, function(a, b) return a.driver_dbm > b.driver_dbm end)

	for _, entry in ipairs(txpowers) do
		tp:value(entry.driver_dbm, string.format("%i dBm (%i mW)", entry.display_dbm, entry.display_mw))
	end

	function tp:write(data)
		if data == 'default' then
			data = nil
		end
		uci:set('wireless', radio, 'txpower', data)
	end
end)


if has_5ghz_radio() then
	local r = f:section(Section, translate("Outdoor Installation"), translate(
		"Configuring the node for outdoor use tunes the 5 GHz radio to a frequency "
		.. "and transmission power that conforms with the local regulatory requirements. "
		.. "It also enables dynamic frequency selection (DFS; radar detection). At the "
		.. "same time, mesh functionality is disabled as it requires neighbouring nodes "
		.. "to stay on the same channel permanently."
	))

	local outdoor = r:option(Flag, 'outdoor', translate("Node will be installed outdoors"))
	outdoor.default = uci:get_bool('gluon', 'wireless', 'outdoor')

	function outdoor:write(data)
		uci:set('gluon', 'wireless', 'outdoor', data)
	end

	uci:foreach('wireless', 'wifi-device', function(config)
		local radio = config['.name']
		local hwmode = uci:get('wireless', radio, 'hwmode')

		if hwmode ~= '11a' and hwmode ~= '11na' then
			return
		end

		local phy = util.find_phy(uci:get_all('wireless', radio))

		local ht = r:option(ListValue, 'outdoor_htmode', translate('HT Mode') .. ' (' .. radio .. ')')
		ht:depends(outdoor, true)
		ht.default = uci.get('gluon', 'wireless', 'outdoor_' .. radio .. '_htmode') or 'default'

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
			uci:set('gluon', 'wireless', 'outdoor_' .. radio .. '_htmode', data)
		end
	end)
end


function f:write()
	uci:commit('gluon')
	os.execute('/lib/gluon/upgrade/200-wireless') 
	uci:commit('wireless')
end

return f
