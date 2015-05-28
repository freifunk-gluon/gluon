module("luci.controller.admin.noderole", package.seeall)

function index()
	entry({"admin", "noderole"}, cbi("admin/noderole"), "Verwendungszweck", 20)
end
