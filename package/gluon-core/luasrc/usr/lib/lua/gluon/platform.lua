local platform_info = require 'platform_info'
local util = require 'gluon.util'
local wireless = require 'gluon.wireless'
local unistd = require 'posix.unistd'


local M = setmetatable({}, {
	__index = platform_info,
})

function M.match(target, subtarget, boards)
	if target and M.get_target() ~= target then
		return false
	end

	if subtarget and M.get_subtarget() ~= subtarget then
		return false
	end

	if boards and not util.contains(boards, M.get_board_name()) then
		return false
	end

	return true
end

function M.is_outdoor_device()
	if M.match('ar71xx', 'generic', {
		'bullet-m',
		'cpe210',
		'cpe510',
		'wbs210',
		'wbs510',
		'lbe-m5',
		'loco-m-xw',
		'nanostation-m',
		'nanostation-m-xw',
		'rocket-m',
		'rocket-m-ti',
		'rocket-m-xw',
		'unifi-outdoor',
		'unifi-outdoor-plus',
	}) then
		return true

	elseif M.match('ar71xx', 'generic', {'unifiac-lite'}) and
		M.get_model() == 'Ubiquiti UniFi-AC-MESH' then
		return true

	elseif M.match('ar71xx', 'generic', {'unifiac-pro'}) and
		M.get_model() == 'Ubiquiti UniFi-AC-MESH-PRO' then
		return true

	elseif M.match('ath79', 'generic', {
		'devolo,dvl1750x',
		'plasmacloud,pa300',
		'plasmacloud,pa300e',
		'tplink,cpe220-v3',
		'tplink,eap225-outdoor-v1',
	}) then
		return true

	elseif M.match('ipq40xx', 'generic', {
		'engenius,ens620ext',
		'plasmacloud,pa1200',
	}) then
		return true
	end

	return false
end

function M.device_supports_wpa3()
	-- rt2x00 crashes when enabling WPA3 personal / OWE VAP
	if M.match('ramips', 'rt305x') then
		return false
	end

	return unistd.access('/lib/gluon/features/wpa3')
end

function M.device_supports_mfp(uci)
	local supports_mfp = true

	if not M.device_supports_wpa3() then
		return false
	end

	uci:foreach('wireless', 'wifi-device', function(radio)
		local phy = wireless.find_phy(radio)
		local phypath = '/sys/kernel/debug/ieee80211/' .. phy .. '/'

		if not util.file_contains_line(phypath .. 'hwflags', 'MFP_CAPABLE') then
			supports_mfp = false
			return false
		end
	end)

	return supports_mfp
end

function M.device_uses_11a(uci)
	local ret = false

	uci:foreach('wireless', 'wifi-device', function(radio)
		if radio.hwmode == '11a' or radio.hwmode == '11na' then
			ret = true
			return false
		end
	end)

	return ret
end

return M
