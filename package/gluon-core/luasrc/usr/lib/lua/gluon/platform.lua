local platform_info = require 'platform_info'
local util = require 'gluon.util'


local M = setmetatable({}, {
	__index = platform_info,
})

function M.match(target, subtarget, boards)
	if M.get_target() ~= target then
		return false
	end

	if M.get_subtarget() ~= subtarget then
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
		'cpe510',
		'lbe-m5',
		'loco-m-xw',
		'nanostation-m',
		'nanostation-m-xw',
		'rocket-m',
		'rocket-m-ti',
		'rocket-m-xw',
		'unifi-outdoor',
	}) then
		return true

	elseif M.match('ar71xx', 'generic', {'unifiac-lite'}) and
		M.get_model() == 'Ubiquiti UniFi-AC-MESH' then
		return true

	elseif M.match('ar71xx', 'generic', {'unifiac-pro'}) and
		M.get_model() == 'Ubiquiti UniFi-AC-MESH-PRO' then
		return true

	elseif M.match('ath79', 'generic', {'devolo,dvl1750x'}) then
		return true

	elseif M.match('ipq40xx', 'generic', {'engenius,ens620ext'}) then
		return true
	end

	return false
end

return M
