module("luci.controller.admin.noderole", package.seeall)

function index()
	entry({"admin", "noderole"}, cbi("admin/noderole"), "Node role", 20)
end
