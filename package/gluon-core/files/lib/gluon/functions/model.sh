. /lib/functions.sh

# This must be generalized as soon as we support other OpenWRT archs
. /lib/ar71xx.sh


ar71xx_board_detect

local board_name="$AR71XX_BOARD_NAME"
local model="$AR71XX_MODEL"

get_arch() {
	echo 'ar71xx'
}

get_board_name() {
	echo "$board_name"
}

get_model() {
	echo "$model"
}
