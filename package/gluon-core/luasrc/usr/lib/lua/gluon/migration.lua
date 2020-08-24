local unistd = require 'posix.unistd'


local M = {}

function M.get_migration_flag_path(migration_name)
	return '/lib/gluon/core/migration/flags' .. migration_name
end

function M.is_migration_done(migration_name)
	return unistd.access(M.get_migration_flag_path(migration_name))
end

function M.flag_migration_done(migration_name)
	os.execute(M.get_migration_flag_path(migration_name))
end

function M.reinit_led_config(uci)
	-- Remove LED configuration
	uci:foreach('system', 'rssid', function(config)
		uci:delete('system', config['.name'])
	end)
	uci:foreach('system', 'led', function(config)
		uci:delete('system', config['.name'])
	end)
	uci:save('led')

	-- Create LED configuration
	os.execute('/lib/gluon/core/migration/create_led_config.sh')
end

function M.reinit_board_json()
	os.execute('rm /etc/board.json')
	os.execute('board_detect')
end

return M
