local util = require 'luci.util'


module 'gluon.model'


-- This must be generalized as soon as we support other OpenWrt archs
local board_name, model = util.exec('. /lib/functions.sh; . /lib/ar71xx.sh; ar71xx_board_detect; echo "$AR71XX_BOARD_NAME"; echo "$AR71XX_MODEL"'):match('([^\n]+)\n([^\n]+)')


function get_arch()
	return 'ar71xx'
end

function get_board_name()
	return board_name
end

function get_model()
	return model
end
