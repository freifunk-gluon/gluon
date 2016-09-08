-- Config mode utility functions

local string = string

module 'gluon.luci'

function escape(s)
	return (string.gsub(s, '[<>&"]', {
		['<'] = '&lt;',
		['>'] = '&gt;',
		['&'] = '&amp;',
		['"'] = '&quot;',
	}))
end

function urlescape(s)
	return (string.gsub(s, '[^a-zA-Z0-9%-_%.~]',
		function(c)
			local ret = ''

			for i = 1, string.len(c) do
				ret = ret .. string.format('%%%02X', string.byte(c, i, i))
			end

			return ret
		end
	))
end
