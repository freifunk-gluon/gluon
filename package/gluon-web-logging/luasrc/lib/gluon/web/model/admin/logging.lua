local uci = require('simple-uci').cursor()
local system = uci:get_first('system', 'system')

local f = Form(translate('Logging'), translate(
	"If you want to use a remote syslog server, you can set it up here. "
	.. "Please keep in mind that the data is not encrypted, which may cause "
	.. "individual-related data to be transmitted unencrypted over the internet."
))
local s = f:section(Section)

local enable = s:option(Flag, 'log_remote', translate('Enable'))
enable.default = uci:get_bool('system', system, 'log_remote')
function enable:write(data)
	uci:set('system', system, 'log_remote', data)
end

local ip = s:option(Value, 'log_ip', translate('IP'))
ip.default = uci:get('system', system, 'log_ip')
ip:depends(enable, true)
ip.optional = false
ip.placeholder = '0.0.0.0'
ip.datatype = 'ipaddr'
function ip:write(data)
	uci:set('system', system, 'log_ip', data)
end

local port = s:option(Value, 'log_port', translate('Port'))
port.default = uci:get('system', system, 'log_port')
port:depends(enable, true)
port.optional = true
port.placeholder = 514
port.datatype = 'irange(1, 65535)'
function port:write(data)
	if data ~= nil then
		uci:set('system', system, 'log_port', data)
	else
		uci:delete('system', system, 'log_port')
	end
end

function f:write()
	uci:commit('system')
end

return f
