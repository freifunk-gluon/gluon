local site = require 'gluon.site_config'


module 'gluon.client_bridge'

function next_node_macaddr()
	return (site.next_node or {}).mac or '16:41:95:40:f7:dc'
end
