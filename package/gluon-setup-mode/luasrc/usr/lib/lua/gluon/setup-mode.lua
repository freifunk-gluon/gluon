local platform = require 'gluon.platform'
local json = require 'jsonc'


local M = {}

function M.get_status_led()
	if platform.match('ath79', 'nand', {
		'glinet,gl-xe300',
	}) then
		return "green:wlan"
	end
end

function M.rename_phys()
	-- Load board data from JSON file
	local board_data = json.load('/etc/board.json')
	local wlan_data = board_data.wlan or {}

	-- Iterate over all entries in wlan_data
	for phyname, data in pairs(wlan_data) do
		local path = data.path
		if path then
			-- Get the phyname using iwinfo
			-- lua iwinfo does return nil by path instead
			-- local other_phyname = iwinfo.nl80211.phyname('path=' .. path)

			local f = io.popen("iwinfo nl80211 phyname path=" .. path)
			local other_phyname = f:read("*a")
			f:close()

			-- Check if the retrieved phyname doesn't match the key
			if other_phyname ~= "" and other_phyname ~= phyname then
				-- Execute the command
				os.execute(string.format("iw %s set name %s", other_phyname, phyname))

				print(string.format("Renamed phy %s to %s", other_phyname, phyname))
			end
		end
	end
end

return M
