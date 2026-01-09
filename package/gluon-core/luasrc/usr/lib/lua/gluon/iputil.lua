local bit = require 'bit32'


local M = {}

function M.IPv6(address)
	--[[
	(c) 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>
	(c) 2008 Steven Barth <steven@midlink.org>

	Licensed under the Apache License, Version 2.0 (the "License").
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
	]]--
	local data = {}

	local borderl = address:sub(1, 1) == ":" and 2 or 1
	local borderh, zeroh, chunk, block

	if #address > 45 then return nil end

	repeat
		borderh = address:find(":", borderl, true)
		if not borderh then break end

		block = tonumber(address:sub(borderl, borderh - 1), 16)
		if block and block <= 0xFFFF then
			data[#data+1] = block
		else
			if zeroh or borderh - borderl > 1 then return nil end
			zeroh = #data + 1
		end

		borderl = borderh + 1
	until #data == 7

	chunk = address:sub(borderl)
	if #chunk > 0 and #chunk <= 4 then
		block = tonumber(chunk, 16)
		if not block or block > 0xFFFF then return nil end

		data[#data+1] = block
	elseif #chunk > 4 then
		if #data == 7 or #chunk > 15 then return nil end
		borderl = 1
		for i=1, 4 do
			borderh = chunk:find(".", borderl, true)
			if not borderh and i < 4 then return nil end
			borderh = borderh and borderh - 1

			block = tonumber(chunk:sub(borderl, borderh))
			if not block or block > 255 then return nil end

			if i == 1 or i == 3 then
				data[#data+1] = block * 256
			else
				data[#data] = data[#data] + block
			end

			borderl = borderh and borderh + 2
		end
	end

	if zeroh then
		if #data == 8 then return nil end
		while #data < 8 do
			table.insert(data, zeroh, 0)
		end
	end

	if #data == 8 then
		return data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8]
	end
end

function M.mac_to_ip(prefix, mac, firstbyte, secondbyte)
	local m1, m2, m3, m6, m7, m8 = string.match(mac, '(%x%x):(%x%x):(%x%x):(%x%x):(%x%x):(%x%x)')
	local m4 = firstbyte or 0xff
	local m5 = secondbyte or 0xfe
	m1 = bit.bxor(tonumber(m1, 16), 0x02)

	local h1 = 0x100 * m1 + tonumber(m2, 16)
	local h2 = 0x100 * tonumber(m3, 16) + m4
	local h3 = 0x100 * m5 + tonumber(m6, 16)
	local h4 = 0x100 * tonumber(m7, 16) + tonumber(m8, 16)

	prefix = string.match(prefix, '(.*)/%d+')

	local p1, p2, p3, p4 = M.IPv6(prefix)

	return string.format("%x:%x:%x:%x:%x:%x:%x:%x/%d", p1, p2, p3, p4, h1, h2, h3, h4, 128)
end

return M
