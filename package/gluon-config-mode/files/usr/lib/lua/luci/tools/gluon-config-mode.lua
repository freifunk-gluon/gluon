local luci = require "luci"
local io = require "io"

module "luci.tools.gluon-config-mode"

function setup_fastd_secret(name)
  local uci = luci.model.uci.cursor()
  local secret = uci:get("fastd", name, "secret")

  if not secret or not secret:match("%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x") then
    local f = io.popen("fastd --generate-key --machine-readable", "r")
    local secret = f:read("*a")
    f:close()

    uci:set("fastd", name, "secret", secret)
    uci:save("fastd")
    uci:commit("fastd")
  end
end

function get_fastd_pubkey(name)
  local f = io.popen("/etc/init.d/fastd show_key " .. name, "r")
  local key = f:read("*a")
  f:close()

  return key
end


