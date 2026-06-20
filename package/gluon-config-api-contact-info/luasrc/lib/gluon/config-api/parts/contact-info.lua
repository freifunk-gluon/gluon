
local M = {}

function M.schema(site, platform)
	return {
		properties = {
			wizard = {
				properties = {
					contact = {
						type = 'string'
					}
				}
			}
		}
	}
end

function M.set(config, uci)
	local owner = uci:get_first("gluon-node-info", "owner")

	uci:set("gluon-node-info", owner, "contact", config.wizard.contact)
	uci:save("gluon-node-info")
end

function M.get(uci, config)
	local owner = uci:get_first("gluon-node-info", "owner")

	config.wizard = config.wizard or {}
	config.wizard.contact = uci:get("gluon-node-info", owner, "contact")
end

return M
