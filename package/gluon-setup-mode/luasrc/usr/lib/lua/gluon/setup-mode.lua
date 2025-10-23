local platform = require 'gluon.platform'


local M = {}

function M.get_status_led()
	if platform.match('ath79', 'generic', {
		'comfast,cf-ew71-v2',
	}) then
		return "blue:wlan"
	end
	if platform.match('ath79', 'nand', {
		'glinet,gl-xe300',
	}) then
		return "green:wlan"
	end
end

return M
