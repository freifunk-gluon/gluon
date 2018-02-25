-- Copyright 2010 Jo-Philipp Wich <jow@openwrt.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local tonumber = tonumber


module "gluon.web.model.datatypes"


function bool(val)
	if val == "1" or val == "yes" or val == "on" or val == "true" then
		return true
	elseif val == "0" or val == "no" or val == "off" or val == "false" then
		return true
	elseif val == "" or val == nil then
		return true
	end

	return false
end

local function dec(val)
	if val:match('^%-?%d*%.?%d+$') then
		return tonumber(val)
	end
end

local function int(val)
	if val:match('^%-?%d+$') then
		return tonumber(val)
	end
end

function uinteger(val)
	local n = int(val)
	return (n ~= nil and n >= 0)
end

function integer(val)
	return (int(val) ~= nil)
end

function ufloat(val)
	local n = dec(val)
	return (n ~= nil and n >= 0)
end

function float(val)
	return (dec(val) ~= nil)
end

function ipaddr(val)
	return ip4addr(val) or ip6addr(val)
end

function ip4addr(val)
	local g = '(%d%d?%d?)'
	local v1, v2, v3, v4 = val:match('^'..((g..'%.'):rep(3))..g..'$')
	local n1, n2, n3, n4 = tonumber(v1), tonumber(v2), tonumber(v3), tonumber(v4)

	if not (n1 and n2 and n3 and n4) then return false end

	return (
		(n1 >= 0) and (n1 <= 255) and
		(n2 >= 0) and (n2 <= 255) and
		(n3 >= 0) and (n3 <= 255) and
		(n4 >= 0) and (n4 <= 255)
	)
end

function ip6addr(val)
	local g1 = '%x%x?%x?%x?'

	if not val:match('::') then
		return val:match('^'..((g1..':'):rep(7))..g1..'$') ~= nil
	end

	if
		val:match(':::') or val:match('::.+::') or
		val:match('^:[^:]') or val:match('[^:]:$')
	then
		return false
	end

	local g0 = '%x?%x?%x?%x?'
	for i = 2, 7 do
		if val:match('^'..((g0..':'):rep(i))..g0..'$') then
			return true
		end
	end

	if val:match('^'..((g1..':'):rep(7))..':$') then
		return true
	end
	if val:match('^:'..((':'..g1):rep(7))..'$') then
		return true
	end

	return false
end

function wpakey(val)
	if #val == 64 then
		return (val:match("^%x+$") ~= nil)
	else
		return (#val >= 8) and (#val <= 63)
	end
end

function range(val, vmin, vmax)
	return min(val, vmin) and max(val, vmax)
end

function min(val, min)
	val = dec(val)
	min = tonumber(min)

	if val ~= nil and min ~= nil then
		return (val >= min)
	end

	return false
end

function max(val, max)
	val = dec(val)
	max = tonumber(max)

	if val ~= nil and max ~= nil then
		return (val <= max)
	end

	return false
end

function irange(val, vmin, vmax)
	return integer(val) and range(val, vmin, vmax)
end

function imin(val, vmin)
	return integer(val) and min(val, vmin)
end

function imax(val, vmax)
	return integer(val) and max(val, vmax)
end

function minlength(val, min)
	min = tonumber(min)

	if min ~= nil then
		return (#val >= min)
	end

	return false
end

function maxlength(val, max)
	max = tonumber(max)

	if max ~= nil then
		return (#val <= max)
	end

	return false
end
