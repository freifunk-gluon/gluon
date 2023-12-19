local M = {}

local function file_exists(file)
	local f = io.open(file)
	if not f then
		return false
	end
	f:close()
	return true
end

local function get_customization_file_name(env)
	return env.GLUON_SITEDIR .. '/image-customization.lua'
end

local function evaluate_device(env, dev)
	local selections = {
		features = {},
		packages = {},
	}
	local funcs = {}
	local device_overrides = {}

	local function add_elements(element_type, element_list)
		-- We depend on the fact both feature and package
		-- are already initialized as empty tables
		for _, element in ipairs(element_list) do
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
			'Incorrect use of broken(): has to be a boolean value')
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
			'Incorrect use of device(): pass a list of device names as argument')

		for _, device_name in ipairs(device_names) do
			if device_name == dev.image then
				return true
			end
		end

		return false
	end

	function funcs.target(target, subtarget)
		assert(
			type(target) == 'string',
			'Incorrect use of target(): pass a target name as first argument')

		if target ~= env.BOARD then
			return false
		end

		if subtarget and subtarget ~= env.SUBTARGET then
			return false
		end

		return true
	end

	function funcs.device_class(class)
		return dev.options.class == class
	end

	-- Evaluate the feature definition files
	local f, err = loadfile(get_customization_file_name(env))
	if not f then
		error('Failed to parse feature definition: ' .. err)
	end
	setfenv(f, funcs)
	f()

	return {
		selections = selections,
		device_overrides = device_overrides,
	}
end

function M.get_selections(env, dev)
	local return_object = {
		features = {},
		packages = {},
	}

	if not file_exists(get_customization_file_name(env)) then
		return return_object
	end

	local eval_result = evaluate_device(env, dev)
	return eval_result.selections
end

function M.device_overrides(env, dev)
	if not file_exists(get_customization_file_name(env)) then
		return {}
	end

	local eval_result = evaluate_device(env, dev)
	return eval_result.device_overrides
end

return M
