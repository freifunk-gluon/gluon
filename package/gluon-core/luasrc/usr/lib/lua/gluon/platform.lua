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
		'cpe510-520-v1',
		'ubnt-nano-m',
		'ubnt-nano-m-xw',
	}) then
		return true

	elseif M.match('ar71xx', 'generic', {'unifiac-lite'}) and
		M.get_model() == 'Ubiquiti UniFi-AC-MESH' then
		return true

	elseif M.match('ar71xx', 'generic', {'unifiac-pro'}) and
		M.get_model() == 'Ubiquiti UniFi-AC-MESH-PRO' then
		return true
	end

	return false
end

return M
