-- Writes all lines from the file input to the file output except those starting with prefix
-- Doesn't close the output file, but returns the file object
local function do_filter_prefix(input, output, prefix)
	local f = io.open(output, 'w+')
	local l = prefix:len()

	for line in io.lines(input) do
		if line:sub(1, l) ~= prefix then
			f:write(line, '\n')
		end
	end

	return f
end


local function escape_args(ret, arg0, ...)
	if not arg0 then
		return ret
	end

	return escape_args(ret .. "'" .. string.gsub(arg0, "'", "'\\''") .. "' ", ...)
end


local os = os
local string = string

module 'gluon.util'

function exec(...)
	return os.execute(escape_args('', ...))
end

-- Removes all lines starting with a prefix from a file, optionally adding a new one
function replace_prefix(file, prefix, add)
	local tmp = file .. '.tmp'
	local f = do_filter_prefix(file, tmp, prefix)
	if add then
		f:write(add)
	end
	f:close()
	os.rename(tmp, file)
end

function lock(file)
	exec('lock', file)
end

function unlock(file)
	exec('lock', '-u', file)
end
