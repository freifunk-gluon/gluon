local site = require 'gluon.site'

local attrs
if site.mesh.batman_adv.routing_algo() == 'BATMAN_V' then
	attrs = {
		{'tp', 'TP', 'bit/s'},
	}
else
	attrs = {
		{'tq', 'TQ', ' %'},
	}
end

return {
	provider = '/cgi-bin/dyn/neighbours-batadv',
	-- List of mesh-specific attributes, each a tuple of
	-- 1) the internal identifier (JSON key)
	-- 2) human-readable key (not translatable yet)
	-- 3) value suffix (optional)
	attrs = attrs,
}
