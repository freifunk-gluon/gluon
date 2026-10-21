
local M = {}

function M.schema(site, platform)
	return {
		type = 'object',
		properties = {
			wizard = {
				type = 'object',
				additionalProperties = false
			}
		},
		additionalProperties = false,
		required = { 'wizard' }
	}
end

function M.set(config, uci)
end

function M.get(uci, config)
end

return M
