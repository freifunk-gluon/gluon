local site = require 'gluon.site'


local M = {}

function M.next_node_macaddr()
	return site.next_node.mac('16:41:95:40:f7:dc')
end

return M
