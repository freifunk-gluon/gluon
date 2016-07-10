module("luci.controller.admin.privatewifi", package.seeall)

function index()
	entry({"admin", "privatewifi"}, cbi("admin/privatewifi"), _("Private WLAN"), 10)
end
