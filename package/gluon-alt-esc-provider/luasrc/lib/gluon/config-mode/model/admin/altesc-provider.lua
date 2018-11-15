local uci = require("simple-uci").cursor()
local util = require 'gluon.util'
local site = require 'gluon.site'

local function get_provider(uci)
  local provider
  uci:foreach('gluon-alt-esc-provider', 'provider',
              function(s)
                 provider = s
                 return false
              end
  )
  return provider
end

local mac = uci:get('network', 'client', 'macaddr')
local disabled = uci:get_first('gluon-alt-esc-provider', 'provider', "disabled")

local f = Form(translate("Alternative Exit Service Collaborator - Provider"))
local s = f:section(Section, nil, translate(
		'<p>Here you can share your Internet connection from the WAN port directly '
		.. '(bypassing the community gateways), so this same or other nodes can '
		.. 'get Internet access via this node via the Alt-ESC-Client, for instance.</p>'
		.. '<p><strong>- Be aware of the legal obligations your jurisdiction might '
		.. 'require you to follow. -</strong></p>'
		.. '<p><strong>USE AT YOUR OWN RISK!</strong></p>'
))

local enabled = s:option(Flag, "enabled", translate("Enable"), translate("Note: When enabling this you will probably want to enable the Mesh-VPN in the wizard, too."))
enabled.default = disabled and disabled == "0"

local brave = s:option(Flag, "brave", translate("I am brave and I know what I am doing."))
brave:depends(enabled, true)
brave.default = disabled and disabled == "0"

local id = s:option(Value, "id", translate("Your Exit ID is:"), translate("(unchangeable, your nodes MAC address)"))
id:depends(brave, true)
id.default = mac

function f:write(self, state, data)
  local disabled
  local provider = get_provider(uci)['.name']

  if not(enabled.data and brave.data) then
    disabled = "1"

    uci:delete('firewall', 'client2wan')
    uci:delete('firewall', 'wan2client')
    uci:delete('firewall', 'wan_nat6')
    uci:delete('network', 'wan6client_lookup')
  else
    disabled = "0"

    uci:section('firewall', 'forwarding', 'client2wan',
                {
                  src = 'mesh',
                  dest = 'wan',
                }
    )
    uci:section('firewall', 'forwarding', 'wan2client',
                {
                  src = 'wan',
                  dest = 'mesh',
                }
    )
    uci:section('firewall', 'include', 'wan_nat6',
                {
                  family = 'ipv6',
                  type = 'restore',
                  path = '/lib/gluon/alt-esc-provider/iptables.rules',
                }
    )
    uci:section('network', 'rule6', 'wan6client_lookup',
                {
                  lookup = '1',
                }
    )
    uci:set('network', 'wan6client_lookup', 'in', 'client')
  end

  uci:set('gluon-alt-esc-provider', provider, 'disabled', disabled)
  uci:commit('gluon-alt-esc-provider')
  uci:commit('firewall')
  uci:commit('network')
end

return f
