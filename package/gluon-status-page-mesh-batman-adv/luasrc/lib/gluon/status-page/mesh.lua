return {
	provider = '/cgi-bin/dyn/neighbours-batadv',
	-- List of mesh-specific attributes, each a tuple of
	-- 1) the internal identifier (JSON key)
	-- 2) human-readable key (not translatable yet)
	-- 3) value suffix (optional)
	attrs = {
		{'tq', 'TQ', ' %'},
	},
}
