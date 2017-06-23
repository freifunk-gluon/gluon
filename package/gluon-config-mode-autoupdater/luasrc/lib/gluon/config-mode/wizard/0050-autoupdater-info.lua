return function(form, uci)
	local enabled = uci:get_bool("autoupdater", "settings", "enabled")
	if enabled then
		form:section(
			Section, nil,
			translate('This node will automatically update its firmware when a new version is available.')
		)
	else
		form:section(
			Section, nil,
			translate('Automatic updates are disabled. They can be enabled in <em>Advanced settings</em>.')
		)
	end
end
