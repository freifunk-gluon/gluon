local util = require 'gluon.util'

local json = require 'luci.jsonc'
local ltn12 = require 'luci.ltn12'
local lutil = require 'luci.util'

local assert = assert
local io = io
local ipairs = ipairs


local mesh_interfaces = '/lib/gluon/core/mesh_interfaces.json'
local interface_lock = '/var/lock/gluon_core_mesh_interfaces'


local function _interfaces()
  local file = io.open(mesh_interfaces)
  if not file then
    return {}
  end

  local decoder = json.new()
  ltn12.pump.all(ltn12.source.file(file), decoder:sink())

  file:close()

  return assert(decoder:get())
end

local function _update(ifs)
  for _, v in pairs(ifs) do
    v[{}] = true
  end
  ifs[{}] = true

  file = assert(io.open(mesh_interfaces, 'w'))
  file:write(json.stringify(ifs))
  file:close()
end

local function _register_interface(name, info)
  local ifs = _interfaces()
  if not ifs[name] then
    ifs[name] = info or {}
    _update(ifs)
  end
end

local function _unregister_interface(name)
  local ifs = _interfaces()
  if ifs[name] then
    ifs[name] = nil
    _update(ifs)
  end
end


module 'gluon.mesh'

function interfaces()
  return util.locked(interface_lock, _interfaces)
end

-- info may hold additional information about a mesh interface, the following values are defined:
--
-- transitive (boolean): defines if the interface provides transitive connectivity (default: false)
-- fixed_mtu (boolean): defines if the interface's MTU may not be changed (default: false)
--
-- Note: if the interface is already registered, the info is not updated
function register_interface(name, info)
  util.locked(interface_lock, _register_interface, name, info)
end

function unregister_interface(name)
  util.locked(interface_lock, _unregister_interface, name)
end
