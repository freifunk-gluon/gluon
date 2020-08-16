local site_i18n = i18n 'gluon-site'

local uci = require("simple-uci").cursor()

local platform = require 'gluon.platform'
local site = require 'gluon.site'
local sysconfig = require 'gluon.sysconfig'
local vpn = require 'gluon.mesh-vpn'

local pretty_hostname = require 'pretty_hostname'

local hostname = pretty_hostname.get(uci)
local contact = uci:get_first("gluon-node-info", "owner", "contact")

local pubkey
local msg


if vpn.enabled() then
	local _, active_vpn = vpn.get_active_provider()

	if active_vpn ~= nil then
		pubkey = active_vpn.public_key()
	end

	if pubkey ~= nil then
		msg = site_i18n._translate('gluon-config-mode:pubkey')
	end
else
	msg = site_i18n._translate('gluon-config-mode:novpn')
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
