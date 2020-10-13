local M = {}

local function to_keys(t)
	local ret = {}
	for _, v in ipairs(t) do
		ret[v] = true
	end
	return ret
end

local function collect_keys(t)
	local ret = {}
	for v in pairs(t) do
		table.insert(ret, v)
	end
	return ret
end

function M.get_packages(files, features)
	local enabled_features = to_keys(features)
	local handled_features = {}
	local packages = {}

	local funcs = {}

	local function add_pkgs(pkgs)
		for _, pkg in ipairs(pkgs or {}) do
			packages[pkg] = true
		end
	end

	function funcs._(feature)
		return enabled_features[feature] ~= nil
	end

	function funcs.feature(feature, pkgs)
		assert(
			type(feature) == 'string',
			'Incorrect use of feature(): pass a feature name without _ as first argument')

		if enabled_features[feature] then
			handled_features[feature] = true
			add_pkgs(pkgs)
		end

	end

	function funcs.when(cond, pkgs)
		assert(
			type(cond) == 'boolean',
			'Incorrect use of when(): pass a locical expression of _-prefixed strings as first argument')

		if cond then
			add_pkgs(pkgs)
		end
	end

	-- Evaluate the feature definition files
	for _, file in ipairs(files) do
		local f, err = loadfile(file)
		if not f then
			error('Failed to parse feature definition: ' .. err)
		end
		setfenv(f, funcs)
		f()
	end

	-- Handle default packages
	for _, feature in ipairs(features) do
		if not handled_features[feature] then
			packages['gluon-' .. feature] = true
		end
	end

	return collect_keys(packages)
end

return M
