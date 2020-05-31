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

function M.get_packages(file, features)
	local feature_table = to_keys(features)

	local funcs = {}

	function funcs._(feature)
		if feature_table[feature] then
			return feature
		end
	end

	local nodefault = {}
	local packages = {}
	function funcs.feature(match, options)
		if not match then
			return
		end

		if options.nodefault then
			nodefault[match] = true
		end
		for _, package in ipairs(options.packages or {}) do
			packages[package] = true
		end
	end

	-- Evaluate the feature definition file
	local f = loadfile(file)
	setfenv(f, funcs)
	f()

	-- Handle default packages
	for _, feature in ipairs(features) do
		if not nodefault[feature] then
			packages['gluon-' .. feature] = true
		end
	end

	return collect_keys(packages)
end

return M
