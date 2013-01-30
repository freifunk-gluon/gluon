module("luci.controller.freifunk.wizard", package.seeall)

function index()
  local uci_state = luci.model.uci.cursor_state()
  if uci_state:get_first("config_mode", "wizard", "running", "0") == "1" then
    entry({"wizard", "welcome"}, template("freifunk-wizard/welcome"), "Willkommen", 10).dependent=false
    entry({"wizard", "password"}, form("freifunk-wizard/password"), "Passwort", 20).dependent=false
    entry({"wizard", "hostname"}, form("freifunk-wizard/hostname"), "Hostname", 30).dependent=false
    entry({"wizard", "meshvpn"}, form("freifunk-wizard/meshvpn"), "Mesh-VPN", 40).dependent=false
    entry({"wizard", "meshvpn", "pubkey"}, template("freifunk-wizard/meshvpn-key"), "Mesh-VPN Key", 1).dependent=false
    entry({"wizard", "completed"}, template("freifunk-wizard/completed"), "Fertig", 50).dependent=false
    entry({"wizard", "completed", "reboot"}, call("reboot"), "reboot", 1).dependent=false
  end
end

function reboot()
  local uci = luci.model.uci.cursor()

  uci:foreach("config_mode", "wizard",
              function(s)
                uci:set("config_mode", s[".name"], "configured", "1")
              end
             )

  uci:save("config_mode")
  uci:commit("config_mode")

  luci.sys.reboot()
end

