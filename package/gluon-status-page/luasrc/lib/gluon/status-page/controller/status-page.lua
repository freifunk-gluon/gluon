local json = require 'jsonc'
local site = require 'gluon.site'
local util = require 'gluon.util'

local function parse_ip(addr)
	if not addr then return end

	local ip4 = {addr:match('(%d+)%.(%d+)%.(%d+)%.(%d+)')}
	if ip4[1] then
		local ret = {}

		for i, part in ipairs(ip4) do
			ret[i] = tonumber(part)
		end
		return ret
	end

	if not addr:match('^[:%x]+$') then
		return
	end

	if addr:sub(0, 2) == '::' then
		addr = '0' .. addr
	end
	if addr:sub(-2) == '::' then
		addr = addr .. '0'
	end

	addr = addr .. ':'

	local groups, groups1 = {}, {}
	for part in addr:gmatch('([^:]*):') do
		if part == '' then
			groups1 = groups
			groups = {}
		else
			groups[#groups+1] = tonumber(part, 16)
		end
	end

	while #groups + #groups1 < 8 do
		groups1[#groups1+1] = 0
	end
	for _, group in ipairs(groups) do
		groups1[#groups1+1] = group
	end

	return groups1
end

local function match(a, b, n)
	if not a or not b then return false end

	for i = 1, n do
		if a[i] ~= b[i] then
			return false
		end
	end

	return true
end

entry({}, call(function(http, renderer)
	local nodeinfo = json.parse(util.exec('exec gluon-neighbour-info -d ::1 -p 1001 -t 3 -c 1 -r nodeinfo'))

	local node_ip = parse_ip(http:getenv('SERVER_ADDR'))
	if node_ip and (
			match(node_ip, parse_ip(site.next_node.ip4()), 8) or
			match(node_ip, parse_ip(site.next_node.ip6()), 8)
	) then
		-- The user has visited the status page via a next-node address
		-- Redirect the user to a unique address to avoid switching nodes
		local prefix = parse_ip(site.prefix6():match('^[^/]+'))
		for _, addr in ipairs(nodeinfo.network.addresses) do
			if match(prefix, parse_ip(addr), 4) then
				http:header('Cache-Control', 'no-cache, no-store, must-revalidate')
				http:redirect('http://[' .. addr .. ']' .. http:getenv('REQUEST_URI'))
				http:close()
				return
			end
		end
	end


	renderer.render('status-page', { nodeinfo = nodeinfo, site = site }, 'gluon-status-page')
end))
