module("luci.controller.freifunk.index", package.seeall)


function index()
  local uci_state = luci.model.uci.cursor_state()

  if uci_state:get_first("config_mode", "wizard", "running", "0") == "1" then
    local root = node()
    root.target = alias("wizard", "welcome")
    root.index = true
  end
end

