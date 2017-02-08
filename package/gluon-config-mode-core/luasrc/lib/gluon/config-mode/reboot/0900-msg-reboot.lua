local site = require 'gluon.site_config'
local sysconfig = require 'gluon.sysconfig'
local pretty_hostname = require 'pretty_hostname'

local uci = require("simple-uci").cursor()

local hostname = pretty_hostname.get(uci)
local contact = uci:get_first('gluon-node-info', 'owner', 'contact')

local msg = translate('gluon-config-mode:reboot')

renderer.render_string(msg, {
	hostname = hostname,
	site = site,
	sysconfig = sysconfig,
	contact = contact,
})
