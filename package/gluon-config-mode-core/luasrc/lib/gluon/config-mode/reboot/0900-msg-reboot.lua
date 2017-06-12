local site = require 'gluon.site_config'
local sysconfig = require 'gluon.sysconfig'
local pretty_hostname = require 'pretty_hostname'

local uci = require("simple-uci").cursor()

local hostname = pretty_hostname.get(uci)
local contact = uci:get_first('gluon-node-info', 'owner', 'contact')

local msg = _translate('gluon-config-mode:reboot')
if not msg then return end

renderer.render_string(msg, {
	hostname = hostname,
	site = site,
	sysconfig = sysconfig,
	contact = contact,
})
