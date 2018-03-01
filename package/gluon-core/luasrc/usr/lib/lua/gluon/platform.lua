local platform_info = require 'platform_info'
local util = require 'gluon.util'

local setmetatable = setmetatable


module 'gluon.platform'

setmetatable(_M,
	     {
		__index = platform_info,
	     }
)

function match(target, subtarget, boards)
   if get_target() ~= target then
      return false
   end

   if get_subtarget() ~= subtarget then
      return false
   end

   if boards and not util.contains(boards, get_board_name()) then
      return false
   end

   return true
end

function is_outdoor_device()
   if match('ar71xx', 'generic', {
      'cpe510-520-v1',
      'ubnt-nano-m',
      'ubnt-nano-m-xw',
      }) then
      return true

   elseif match('ar71xx', 'generic', {'unifiac-lite'}) and
	   get_model() == 'Ubiquiti UniFi-AC-MESH' then
      return true

   elseif match('ar71xx', 'generic', {'unifiac-pro'}) and
	   get_model() == 'Ubiquiti UniFi-AC-MESH-PRO' then
      return true
   end

   return false
end
