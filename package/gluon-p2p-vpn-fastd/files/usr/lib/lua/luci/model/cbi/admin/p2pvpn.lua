local f, s, o
local uci = luci.model.uci.cursor()
local config = 'fastd'
local groupname = 'p2p_vpn'
local vpnname = 'mesh_vpn'

function splitRemoteEntry(p)
  local host, port, x

  p = p:gsub("["..'"'.."]", '')

  x = p:find(" ") or (#p + 1)
  host = p:sub(1, x-1)

  p = p:sub(x+1)
  x = p:find(" ") or (#p + 1)
  port = p:sub(x+1)

  return host, port
end

function splitPeerString(p)
  local host, port, key, x

  x = p:find(':') or (#p + 1)
  host = p:sub(1,x-1)

  p = p:sub(x+1)
  x = p:find('/') or (#p + 1)
  port = p:sub(1,x-1)
  key = p:sub(x+1)

  return host, port, key
end

function getPeerStrings()
  peers = {}

  uci:foreach('fastd', 'peer',
    function(s)
      if s['group'] == groupname then
        local host, port = splitRemoteEntry(table.concat(s['remote']))
        peers[#peers+1] = host .. ':' .. port .. '/' .. s['key']
      end
    end
  )

  return peers
end


f = SimpleForm(groupname, translate("Peer-to-peer Mesh VPN"))
f.template = "admin/expertmode"

s = f:section(SimpleSection, nil, translate(
                'Your node can additionally connect to other nodes in a Peer-to-peer fashion.'
))

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = uci:get_bool(config, groupname, "enabled") and o.enabled or o.disabled
o.rmempty = false

o = s:option(DynamicList, "hostname", translate("Remote"), translate("Format") ..": HOSTNAME:PORT/KEY")
o:write(nil, getPeerStrings())
o:depends("enabled", '1')


s = f:section(SimpleSection, nil, translate(
                'One of the participating nodes of a P2P connection has to be configured with a fixed fastd port.'
                ..'This port then has to be forwarded in the local home router which the node is using for Mesh VPN.'
))
o:depends("enabled", '1')

o = s:option(Flag, "fixedport", translate("Fixed VPN Port"))
o.default = (uci:get(config, vpnname, "bind")) and o.enabled or o.disabled
o.rmempty = false

p = uci:get(config, vpnname, "bind")
x = p:find(":") or (#p + 1)

o = s:option(Value, "localport", translate("Port"))
o:write('', p:sub(x+1))
o:depends("fixedport", '1')


function f.handle(self, state, data)
  if state == FORM_VALID then
    -- delete all existin p2p peers
    uci:foreach('fastd', 'peer',
      function(s)
        if s['group'] == groupname then
          uci:delete(config, s['.name'])
        end
      end
    )

    -- iterate over dynamic list if enabled
    if data.enabled == '1' and #data.hostname > 0 then
      for v,peer in pairs(data.hostname) do
        -- TODO: add sanity checks
        local host, port, key = splitPeerString(peer)

        -- hostname is cleaned to be valid as a section name
        uci:section(config, 'peer', groupname .. '_' .. host:gsub('%W',''),
                    {
                      net        = vpnname,
                      key        = key,
                      group      = groupname,
                      remote     = { '"'..host..'"'..' port '..port },
                      enabled    = 1,
                    }
        )
      end
    end

    if data.fixedport == '1' and #data.localport > 0 then
      -- TODO: add sanity checks
      uci:set(config, vpnname, 'bind', 'any:'..data.localport)
    else
      uci:delete(config, vpnname, 'bind')
    end

    uci:save("fastd")
    uci:commit("fastd")
  end
end

return f
