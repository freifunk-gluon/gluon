local util = require("gluon.util")

local M = {}

-- returns a prefix generated from the domain-seed
-- for l3roamd -P <node-client-prefix>
function M.node_client_prefix6()
	local key = "gluon-l3roamd.node_client_prefix6"
	local prefix_seed = util.domain_seed_bytes(key, 7)
	return ("fd" .. prefix_seed):gsub(("(%x%x%x%x)"):rep(4), "%1:%2:%3:%4" .. "::/64")
end

return M
