return function(form, uci)
	local pkg_i18n = i18n 'gluon-config-mode-autoupdater'

	local enabled = uci:get_bool("autoupdater", "settings", "enabled")
	if enabled then
		form:section(
			Section, nil,
			pkg_i18n.translate('This node will automatically update its firmware when a new version is available.')
		)
	else
		form:section(
			Section, nil,
			pkg_i18n.translate('Automatic updates are disabled. They can be enabled in <em>Advanced settings</em>.')
		)
	end
end
