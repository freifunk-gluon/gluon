local M = {
	customization_file = nil,
}

local function evaluate_device(env, dev)
	local selections = {
		features = {},
		packages = {},
	}
	local funcs = {}
	local device_overrides = {}

	local function add_elements(element_type, element_list)
		local error_msg = string.format(
			'incorrect use of %s(): list of %s expected as argument',
			element_type, element_type)
		assert(type(element_list) == 'table', error_msg)

		-- We depend on the fact both feature and package
		-- are already initialized as empty tables
		for _, element in ipairs(element_list) do
			assert(type(element) == 'string', error_msg)
			table.insert(selections[element_type], element)
		end
	end

	local function add_override(ovr_key, ovr_value)
		device_overrides[ovr_key] = ovr_value
	end

	function funcs.features(features)
		add_elements('features', features)
	end

	function funcs.packages(packages)
		add_elements('packages', packages)
	end

	function funcs.broken(broken)
		assert(
			type(broken) == 'boolean',
			'incorrect use of broken(): boolean argument expected')
		add_override('broken', broken)
	end

	function funcs.disable()
		add_override('disabled', true)
	end

	function funcs.disable_factory()
		add_override('disable_factory', true)
	end

	function funcs.device(device_names)
		assert(
			type(device_names) == 'table',
			'incorrect use of device(): list of device names expected as argument')

		for _, device_name in ipairs(device_names) do
			assert(
				type(device_name) == 'string',
				'incorrect use of device(): list of device names expected as argument')

			if device_name == dev.image then
				return true
			end
		end

		return false
	end

	function funcs.target(target, subtarget)
		assert(
			type(target) == 'string',
			'incorrect use of target(): target name expected as first argument')

		if target ~= env.BOARD then
			return false
		end

		if subtarget then
			assert(
				type(subtarget) == 'string',
				'incorrect use of target(): subtarget name expected as first argument')

			if subtarget ~= env.SUBTARGET then
				return false
			end
		end

		return true
	end

	function funcs.device_class(class)
		assert(
			type(class) == 'string',
			'incorrect use of device_class(): class name expected as first argument')

		return dev.options.class == class
	end

	function funcs.include(path)
		assert(
			type(path) == 'string',
			'incorrect use of include(): path expected as first argument')

		if string.sub(path, 1, 1) ~= '/' then
			assert(
				string.find(path, '/') == nil,
				'incorrect use of include(): including files from subdirectories is unsupported')
			path = env.GLUON_SITEDIR .. '/' .. path
		end
		local f = assert(loadfile(path))
		setfenv(f, funcs)
		return f()
	end

	-- Evaluate the feature definition files
	setfenv(M.customization_file, funcs)
	M.customization_file()

	return {
		selections = selections,
		device_overrides = device_overrides,
	}
end

function M.get_selections(dev)
	local eval_result = evaluate_device(M.env, dev)
	return eval_result.selections
end

function M.device_overrides(dev)
	local eval_result = evaluate_device(M.env, dev)
	return eval_result.device_overrides
end

function M.init(env)
	local filename = env.GLUON_SITEDIR .. '/image-customization.lua'

	M.env = env
	M.customization_file = assert(loadfile(filename))
end

return M
