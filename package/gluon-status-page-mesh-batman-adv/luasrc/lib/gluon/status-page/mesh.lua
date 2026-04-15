local site = require 'gluon.site'

-- List of mesh-specific attributes per routing algorithm, each a tuple of
-- 1) the internal identifier (JSON key)
-- 2) human-readable key (not translatable yet)
-- 3) value suffix (optional)
-- 4) formatter name (optional) -- key into status-page.js formats{}
local algo_attrs = {
	['BATMAN_IV'] = {
		{'tq', 'TQ', ' %'},
	},
	['BATMAN_V'] = {
		{'tp', 'Throughput', 'bit/s', 'bitrate'},
	},
}
local attrs = algo_attrs[site.mesh.batman_adv.routing_algo()] or {}

return {
	provider = '/cgi-bin/dyn/neighbours-batadv',
	attrs = attrs,
}
