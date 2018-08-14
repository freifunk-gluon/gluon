local site_i18n = i18n 'gluon-site'

local uci = require("simple-uci").cursor()
local fs = require "nixio.fs"

local platform = require 'gluon.platform'
local site = require 'gluon.site'
local sysconfig = require 'gluon.sysconfig'
local util = require "gluon.util"

local pretty_hostname = require 'pretty_hostname'


local has_fastd = fs.access('/lib/gluon/mesh-vpn/fastd')
local has_tunneldigger = fs.access('/lib/gluon/mesh-vpn/tunneldigger')


local hostname = pretty_hostname.get(uci)
local contact = uci:get_first("gluon-node-info", "owner", "contact")

local pubkey
local msg


if has_tunneldigger then
	local tunneldigger_enabled = uci:get_bool("tunneldigger", "mesh_vpn", "enabled")
	if not tunneldigger_enabled then
		msg = site_i18n._translate('gluon-config-mode:novpn')
	end
elseif has_fastd then
	local fastd_enabled = uci:get_bool("fastd", "mesh_vpn", "enabled")
	if fastd_enabled then
		pubkey = util.trim(util.exec("/etc/init.d/fastd show_key mesh_vpn"))
		msg = site_i18n._translate('gluon-config-mode:pubkey')
	else
		msg = site_i18n._translate('gluon-config-mode:novpn')
	end
end

if not msg then return end

renderer.render_string(msg, {
	pubkey = pubkey,
	hostname = hostname,
	site = site,
	platform = platform,
	sysconfig = sysconfig,
	contact = contact,
})
