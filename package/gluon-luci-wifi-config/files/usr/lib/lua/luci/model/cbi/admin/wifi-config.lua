local f, s, o
local uci = luci.model.uci.cursor()

f = SimpleForm("wifi", translate("WLAN"))
f.template = "admin/expertmode"

s = f:section(SimpleSection, nil, translate(
                "You can enable or disable your node's client and mesh network "
                  .. "SSIDs here. Please don't disable the mesh network without "
                  .. "a good reason, so other nodes can mesh with yours."
))

local radios = {}

-- look for wifi interfaces and add them to the array
uci:foreach('wireless', 'wifi-device',
  function(s)
    table.insert(radios, s['.name'])
  end
)

-- add a client and mesh checkbox for each interface
for _, radio in ipairs(radios) do
  local hwmode = uci:get('wireless', radio, 'hwmode')
  local p

  if hwmode == '11g' or hwmode == '11ng' then
    p = f:section(SimpleSection, translate("2.4GHz WLAN"))
  elseif hwmode == '11a' or hwmode == '11na' then
    p = f:section(SimpleSection, translate("5GHz WLAN"))
  end

  if p then
    --box for the client network
    o = p:option(Flag, 'clientbox_' .. radio, translate("Enable client network"))
    o.default = uci:get_bool('wireless', 'client_' .. radio, "disabled") and o.disabled or o.enabled
    o.rmempty = false
    --box for the mesh network
    o = p:option(Flag, 'meshbox_' .. radio, translate("Enable mesh network"))
    o.default = uci:get_bool('wireless', 'mesh_' .. radio, "disabled") and o.disabled or o.enabled
    o.rmempty = false
  end

end

--when the save-button is pushed
function f.handle(self, state, data)
  if state == FORM_VALID then

    for _, radio in ipairs(radios) do

      local clientdisabled = 0
      local meshdisabled = 0
      -- get and invert the data from the boxes
      if data["clientbox_"..radio] == '0' then
        clientdisabled = 1
      end
      -- write the data to the config file
      uci:set('wireless', 'client_' .. radio, "disabled", clientdisabled)

      if data["meshbox_"..radio] == '0' then
        meshdisabled = 1
      end

      uci:set('wireless', 'mesh_' .. radio, "disabled", meshdisabled)

    end

    uci:save('wireless')
    uci:commit('wireless')
  end
end

return f
