return function(form, uci)
	if uci:get_bool("autoupdater", "settings", "enabled") then
		local s = form:section(
			Section, nil,
			translate('This node will automatically update its firmware when a new version is available.')
		)
	end
end
