#!/usr/bin/lua

local json = require "luci.json"
local ltn12 = require "luci.ltn12"
local util = require "luci.util"

require "luci.model.uci"
local uci = luci.model.uci.cursor()

local alfred_data_type = tonumber(os.getenv("ALFRED_DATA_TYPE")) or 158
local net_if = os.getenv("NET_IF") or "br-client"

function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function chomp(s)
  return (s:gsub("^(.-)\n?$", "%1"))
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

output = {}

output["hostname"] = uci:get_first("system", "system", "hostname")

if uci:get_first("gluon-node-info", "location", "share_location", false) then
  output["location"] =
    { latitude = tonumber(uci:get_first("gluon-node-info", "location", "latitude"))
    , longitude = tonumber(uci:get_first("gluon-node-info", "location", "longitude"))
    }
end

local contact = uci:get_first("gluon-node-info", "owner", "contact", "")
if contact ~= "" then
  output["owner"] = { contact = contact }
end

output["software"] =
  { firmware = { base = "gluon-" .. chomp(readAll("/lib/gluon/gluon-version"))
               , release = chomp(readAll("/lib/gluon/release"))
               }
  }

local autoupdater = uci:get_all("autoupdater", "settings")
if autoupdater then
  output["software"]["autoupdater"] =
    { branch = autoupdater["branch"]
    , enabled = uci:get_bool("autoupdater", "settings", "enabled")
    }
end

local fastd = uci:get_all("fastd", "mesh_vpn")
if fastd then
  output["software"]["fastd"] =
    { enabled = uci:get_bool("fastd", "mesh_vpn", "enabled")
    , version = chomp(util.exec("fastd -v | cut -d' ' -f2"))
    }
end

output["hardware"] =
  { model = chomp(util.exec(". /lib/gluon/functions/model.sh; get_model")) }


local addresses = {}
local tmp = util.exec("ip -o -6 addr show dev \"" .. net_if .. "\" | "
                   .. "grep -oE 'inet6 [0-9a-fA-F:]+' | cut -d' ' -f2")

for address in tmp:gmatch("[^\n]+") do
  table.insert(addresses, address)
end

output["network"] =
  { mac = chomp(util.exec(". /lib/gluon/functions/sysconfig.sh; sysconfig primary_mac"))
  , addresses = addresses
  }

local gateway =
  chomp(util.exec("batctl -m bat0 gateways | awk '/^=>/ { print $2 }'"))

if gateway ~= "" then
  output["network"]["gateway"] = gateway
end

local traffic = {}
local ethtool = util.exec("ethtool -S bat0")
for k, v in ethtool:gmatch("([%a_]+): ([0-9]+)") do
  traffic[k] = v
end

for _,class in ipairs({"rx", "tx", "forward", "mgmt_rx", "mgmt_tx"}) do
  traffic[class] =
    { bytes = traffic[class .. "_bytes"]
    , packets = traffic[class]
    }

  if class == "tx" then
    traffic[class]["dropped"] = traffic[class .. "_dropped"]
  end
end

output["statistics"] =
  { uptime = chomp(util.exec("cut -d' ' -f1 /proc/uptime"))
  , loadavg = chomp(util.exec("cut -d' ' -f1 /proc/loadavg"))
  , traffic = traffic
  }

encoder = json.Encoder(output)
alfred = io.popen("alfred -s " .. tostring(alfred_data_type), "w")
ltn12.pump.all(encoder:source(), ltn12.sink.file(alfred))

 
