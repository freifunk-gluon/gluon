#!/usr/bin/lua

module('gluon.announce', package.seeall)

fs = require 'luci.fs'
json = require 'luci.json'
uci = require('luci.model.uci').cursor()
util = require 'luci.util'

local function collect_entry(entry)
	if fs.isdirectory(entry) then
		return collect_dir(entry)
	else
		return setfenv(loadfile(entry), _M)()
	end
end

function collect_dir(dir)
	local ret = { [json.null] = true }

	for _, entry in ipairs(fs.dir(dir)) do
		if entry:sub(1, 1) ~= '.' then
			local ok, val = pcall(collect_entry, dir .. '/' .. entry)
			if ok then
				ret[entry] = val
			else
				io.stderr:write(val, '\n')
			end
		end
	end

	return ret
end

