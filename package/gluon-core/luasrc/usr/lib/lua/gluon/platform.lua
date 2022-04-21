local platform_info = require 'platform_info'
local util = require 'gluon.util'


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
	if M.match('ath79', 'generic', {
		'devolo,dvl1750x',
		'plasmacloud,pa300',
		'plasmacloud,pa300e',
		'tplink,cpe210-v1',
		'tplink,cpe210-v2',
		'tplink,cpe220-v3',
		'tplink,cpe510-v1',
		'tplink,cpe510-v2',
		'tplink,cpe510-v3',
		'tplink,eap225-outdoor-v1',
		'tplink,wbs210-v1',
		'tplink,wbs210-v2',
		'ubnt,nanostation-loco-m',
		'ubnt,nanostation-m-xw',
		'ubnt,unifiac-mesh',
	}) then
		return true

	elseif M.match('ipq40xx', 'generic', {
		'aruba,ap-365',
		'engenius,ens620ext',
		'plasmacloud,pa1200',
	}) then
		return true
	end

	return false
end

return M
