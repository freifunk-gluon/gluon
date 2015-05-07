local platform_info = require 'platform_info'
local util = require 'luci.util'

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

   if not util.contains(boards, get_board_name()) then
      return false
   end

   return true
end


