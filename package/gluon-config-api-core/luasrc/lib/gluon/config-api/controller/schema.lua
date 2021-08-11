
local util = require 'gluon.util'

local M = {}

local function merge_types(Ta, Tb)
	-- T == nil means "any" type is allowed

	if not Ta then return Tb end
	if not Tb then return Ta end

	-- convert scalar types to arrays
	if type(Ta) ~= 'table' then Ta = { Ta } end
	if type(Tb) ~= 'table' then Tb = { Tb } end

	local Tnew = {}

	for _, t in pairs(Ta) do
		if util.contains(Tb, t) then
			table.insert(Tnew, t)
		end
	end

	assert(#Tnew > 0, 'ERROR: The schema does not match anything at all.')

	if #Tnew == 1 then
		return Tnew[1] -- convert to scalar
	else
		return Tnew
	end
end

local function keys(tab)
	local keys = {}
	if tab then
		for k, _ in pairs(tab) do
			table.insert(keys, k)
		end
	end
	return keys
end

local function merge_array(table1, table2)
	local values = {}
	if table1 then
		for _, v in pairs(table1) do
			table.insert(values, v)
		end
	end
	if table2 then
		for _, v in pairs(table2) do
			if not util.contains(values, v) then
				table.insert(values, v)
			end
		end
	end
	return values
end

local function deepcopy(o, seen)
	seen = seen or {}
	if o == nil then return nil end
	if seen[o] then return seen[o] end

	local no
	if type(o) == 'table' then
		no = {}
		seen[o] = no

		for k, v in next, o, nil do
			no[deepcopy(k, seen)] = deepcopy(v, seen)
		end
		setmetatable(no, deepcopy(getmetatable(o), seen))
	else -- number, string, boolean, etc
		no = o
	end
	return no
end

function M.merge_schemas(schema1, schema2)
	local merged = {}

	merged.type = merge_types(schema1.type, schema2.type)

	function add_property(pkey, pdef)
		merged.properties = merged.properties or {}
		merged.properties[pkey] = pdef
	end

	if not merged.type or merged.type == 'object' then
		-- generate merged.properties
		local properties1 = schema1.properties or {}
		local properties2 = schema2.properties or {}

		for _, pkey in pairs(merge_array(keys(properties1), keys(properties2))) do
			local pdef1 = properties1[pkey]
			local pdef2 = properties2[pkey]

			if pdef1 and pdef2 then
				add_property(pkey, M.merge_schemas(pdef1, pdef2))
			elseif pdef1 then
				add_property(pkey, deepcopy(pdef1))
			elseif pdef2 then
				add_property(pkey, deepcopy(pdef2))
			end
		end

		-- generate merged.additionalProperties
		if schema1.additionalProperties and schema2.additionalProperties then
			merged.additionalProperties = M.merge_schemas(
				schema1.additionalProperties, schema2.additionalProperties)
		else
			merged.additionalProperties = false
		end

		-- generate merged.required
		merged.required = merge_array(schema1.required, schema2.required)
		if #merged.required == 0 then
			merged.required = nil
		end
	end

	-- TODO: implement array

	-- generate merged.default
	merged.default = schema2.default or schema1.default

	return merged
end

return M
