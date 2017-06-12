-- Copyright 2008 Freifunk Leipzig / Jo-Philipp Wich <jow@openwrt.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

-- This class contains several functions useful for http message- and content
-- decoding and to retrive form data from raw http messages.
module("gluon.web.http.protocol", package.seeall)


HTTP_MAX_CONTENT      = 1024*8		-- 8 kB maximum content size


local function pump(src, snk)
	while true do
		local chunk, src_err = src()
		local ret, snk_err = snk(chunk, src_err)

		if not (chunk and ret) then
			local err = src_err or snk_err
			if err then
				return nil, err
			else
				return true
			end
		end
	end
end

function urlencode(s)
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

-- the "+" sign to " " - and return the decoded string.
function urldecode(str, no_plus)

	local function chrdec(hex)
		return string.char(tonumber(hex, 16))
	end

	if type(str) == "string" then
		if not no_plus then
			str = str:gsub("+", " ")
		end

		str = str:gsub("%%(%x%x)", chrdec)
	end

	return str
end

local function initval(tbl, key)
	if not tbl[key] then
		tbl[key] = {}
	end

	table.insert(tbl[key], "")
end

local function appendval(tbl, key, chunk)
	local t = tbl[key]
	t[#t] = t[#t] .. chunk
end

-- from given url or string. Returns a table with urldecoded values.
-- Simple parameters are stored as string values associated with the parameter
-- name within the table. Parameters with multiple values are stored as array
-- containing the corresponding values.
function urldecode_params(url)
	local params = {}

	if url:find("?") then
		url = url:gsub("^.+%?([^?]+)", "%1")
	end

	for pair in url:gmatch("[^&;]+") do

		-- find key and value
		local key = urldecode(pair:match("^([^=]+)"))
		local val = urldecode(pair:match("^[^=]+=(.+)$"))

		-- store
		if key and key:len() > 0 then
			initval(params, key)
			if val then
				appendval(params, key, val)
			end
		end
	end

	return params
end

-- Content-Type. Stores all extracted data associated with its parameter name
-- in the params table withing the given message object. Multiple parameter
-- values are stored as tables, ordinary ones as strings.
-- If an optional file callback function is given then it is feeded with the
-- file contents chunk by chunk and only the extracted file name is stored
-- within the params table. The callback function will be called subsequently
-- with three arguments:
--  o Table containing decoded (name, file) and raw (headers) mime header data
--  o String value containing a chunk of the file data
--  o Boolean which indicates wheather the current chunk is the last one (eof)
function mimedecode_message_body(src, msg, filecb)

	if msg and msg.env.CONTENT_TYPE then
		msg.mime_boundary = msg.env.CONTENT_TYPE:match("^multipart/form%-data; boundary=(.+)$")
	end

	if not msg.mime_boundary then
		return nil, "Invalid Content-Type found"
	end


	local tlen   = 0
	local inhdr  = false
	local field  = nil
	local store  = nil
	local lchunk = nil

	local function parse_headers(chunk, field)
		local stat
		repeat
			chunk, stat = chunk:gsub(
				"^([A-Z][A-Za-z0-9%-_]+): +([^\r\n]+)\r\n",
				function(k,v)
					field.headers[k] = v
					return ""
				end
			)
		until stat == 0

		chunk, stat = chunk:gsub("^\r\n","")

		-- End of headers
		if stat > 0 then
			if field.headers["Content-Disposition"] then
				if field.headers["Content-Disposition"]:match("^form%-data; ") then
					field.name = field.headers["Content-Disposition"]:match('name="(.-)"')
					field.file = field.headers["Content-Disposition"]:match('filename="(.+)"$')
				end
			end

			if not field.headers["Content-Type"] then
				field.headers["Content-Type"] = "text/plain"
			end


			if field.name then
				initval(msg.params, field.name)
				if field.file then
					appendval(msg.params, field.name, field.file)
					store = filecb
				else
					store = function(hdr, buf, eof)
						appendval(msg.params, field.name, buf)
					end
				end
			else
				store = nil
			end

			return chunk, true
		end

		return chunk, false
	end

	local function snk(chunk)

		tlen = tlen + (chunk and #chunk or 0)

		if msg.env.CONTENT_LENGTH and tlen > tonumber(msg.env.CONTENT_LENGTH) + 2 then
			return nil, "Message body size exceeds Content-Length"
		end

		if chunk and not lchunk then
			lchunk = "\r\n" .. chunk

		elseif lchunk then
			local data = lchunk .. (chunk or "")
			local spos, epos, found

			repeat
				spos, epos = data:find("\r\n--" .. msg.mime_boundary .. "\r\n", 1, true)

				if not spos then
					spos, epos = data:find("\r\n--" .. msg.mime_boundary .. "--\r\n", 1, true)
				end


				if spos then
					local predata = data:sub(1, spos - 1)

					if inhdr then
						predata, eof = parse_headers(predata, field)

						if not eof then
							return nil, "Invalid MIME section header"
						elseif not field.name then
							return nil, "Invalid Content-Disposition header"
						end
					end

					if store then
						store(field, predata, true)
					end


					field = { headers = { } }
					found = true

					data, eof = parse_headers(data:sub(epos + 1, #data), field)
					inhdr = not eof
				end
			until not spos

			if found then
				-- We found at least some boundary. Save
				-- the unparsed remaining data for the
				-- next chunk.
				lchunk, data = data, nil
			else
				-- There was a complete chunk without a boundary. Parse it as headers or
				-- append it as data, depending on our current state.
				if inhdr then
					lchunk, eof = parse_headers(data, field)
					inhdr = not eof
				else
					-- We're inside data, so append the data. Note that we only append
					-- lchunk, not all of data, since there is a chance that chunk
					-- contains half a boundary. Assuming that each chunk is at least the
					-- boundary in size, this should prevent problems
					if store then
						store(field, lchunk, false)
					end
					lchunk, chunk = chunk, nil
				end
			end
		end

		return true
	end

	return pump(src, snk)
end

-- This function will examine the Content-Type within the given message object
-- to select the appropriate content decoder.
-- Currently only the multipart/form-data mime type is supported.
function parse_message_body(src, msg, filecb)
	if not (msg.env.REQUEST_METHOD == "POST" and msg.env.CONTENT_TYPE) then
		return
	end

	if msg.env.CONTENT_TYPE:match("^multipart/form%-data") then
		return mimedecode_message_body(src, msg, filecb)
	end
end
