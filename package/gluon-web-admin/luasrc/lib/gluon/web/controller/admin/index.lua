local root = node()
if not root.target then
	root.target = alias("admin")
end

entry({"admin"}, alias("admin", "info"), _("Advanced settings"), 10)

entry({"admin", "info"}, template("admin/info"), _("Information"), 1)
entry({"admin", "remote"}, model("admin/remote"), _("Remote access"), 10)
