local f, s, o
local uci = luci.model.uci.cursor()

--set the heading, button and stuff 
f = SimpleForm("wifi", "WLAN-Config")
f.reset = false
f.template = "admin/expertmode"
f.submit = "Speichern"

-- text, which describes what the package does to the user
s = f:section(SimpleSection, nil, [[
In diesem Abschnitt hast du die Möglichkeit die SSIDs des Client- und des
Mesh-Netzes zu deaktivieren. Bitte lass die SSID des Mesh-Netzes aktiviert, 
damit sich auch andere Knoten über dich mit dem Freifunk verbinden können.
]])

local radios = {}

-- look for wifi interfaces and add them to the array
uci:foreach('wireless', 'wifi-device',
function(s)
  table.insert(radios, s['.name'])
end
)

--add a client and mesh checkbox  for each interface
for index, radio in ipairs(radios) do
  --get the hwmode to seperate 2.4GHz and 5Ghz radios
  local hwmode = uci:get('wireless', radio, 'hwmode')
  local p

  if hwmode == '11g' or hwmode == '11ng' then --if 2.4GHz

    p = f:section(SimpleSection, "2,4GHz-WLAN", nil)

  elseif hwmode == '11a' or hwmode == '11na' then --if 5GHz

    p = f:section(SimpleSection, "5GHz-WLAN", nil)

  end

  if p then
    --box for the clientnet
    o = p:option(Flag, 'clientbox' .. index, "Client-Netz aktivieren")
    o.default = (uci:get_bool('wireless', 'client_' .. radio, "disabled")) and o.disabled or o.enabled
    o.rmempty = false
    --box for the meshnet 
    o = p:option(Flag, 'meshbox' .. index, "Mesh-Netz aktivieren")
    o.default = (uci:get_bool('wireless', 'mesh_' .. radio, "disabled")) and o.disabled or o.enabled
    o.rmempty = false
  end

end

--if the save-button is pushed
function f.handle(self, state, data)
  if state == FORM_VALID then

    for index, radio in ipairs(radios) do

      local clientdisabled = 0
      local meshdisabled = 0
      -- get the data from the boxes and invert it
      if data["clientbox"..index] == '0' then
        clientdisabled = 1
      end
      -- write the data to the config file
      uci:set('wireless', 'client_' .. radio, "disabled", clientdisabled)

      if data["meshbox"..index] == '0' then
          meshdisabled = 1
      end

      uci:set('wireless', 'mesh_' .. radio, "disabled", meshdisabled)

    end

    uci:save('wireless')
    uci:commit('wireless')
  end
end

return f
