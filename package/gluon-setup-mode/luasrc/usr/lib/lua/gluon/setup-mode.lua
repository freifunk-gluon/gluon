local platform = require 'gluon.platform'


local M = {}

function M.get_status_led()
	if platform.match('ath79', 'nand', {
		'glinet,gl-xe300',
	}) then
		return "green:wlan"
	end
end

function M.supports_networked_activation()
	if platform.match('ramips', 'mt7621', {
		'zyxel,nwa55axe',
	}) then
		return true
	end
end

return M
