local uci = require('simple-uci').cursor()
local pretty_hostname = require 'pretty_hostname'

local site = require 'gluon.site'
local sysconfig = require 'gluon.sysconfig'
local platform = require 'gluon.platform'
local util = require 'gluon.util'
local has_vpn, vpn = pcall(require, 'gluon.mesh-vpn')
local ethernet = require 'gluon.ethernet'

local pubkey
if has_vpn and vpn.enabled() then
	local _, active_vpn = vpn.get_active_provider()

	if active_vpn ~= nil then
		pubkey = active_vpn.public_key()
	end
end

local M = {}

function M.get_info()
	local updater_enabled = uci:get_bool('autoupdater', 'settings', 'enabled')
	return {
		hostname = pretty_hostname.get(uci),
		mac_address = sysconfig.primary_mac,
		hardware_model = platform.get_model(),
		gluon_version = util.trim(util.readfile('/lib/gluon/gluon-version')),
		site_version = util.trim(util.readfile('/lib/gluon/site-version')),
		firmware_release = util.trim(util.readfile('/lib/gluon/release')),
		site = site.site_name(),
		domain = uci:get('gluon', 'core', 'domain'),
		public_vpn_key = pubkey,
		switch_type = ethernet.get_switch_type(),
		updater_branch = updater_enabled and uci:get('autoupdater', 'settings', 'branch'),
	}
end

function M.get_info_pretty(i18n)
	local _
	if i18n then
		local pkg_i18n = i18n 'gluon-core'
		_ = function(s)
			return pkg_i18n.translate(s)
		end
	else
		_ = function(s)
			return s
		end
	end

	local data = M.get_info()

	return {
		{ _('Hostname'), data.hostname },
		{ _('MAC address'), data.mac_address },
		{ _('Hardware model'), data.hardware_model },
		{ _('Gluon version') .. " / " .. _('Site version'), data.gluon_version .. " / " .. data.site_version },
		{ _('Firmware release'), data.firmware_release },
		{ _('Site'), data.site },
		{ _('Domain'), data.domain or 'n/a' },
		{ _('Public VPN key'), data.public_vpn_key or 'n/a' },
		{ _('Switch type'), data.switch_type },
		{ _('Autoupdater branch'), data.updater_branch or _('disabled') },
	}
end

return M
