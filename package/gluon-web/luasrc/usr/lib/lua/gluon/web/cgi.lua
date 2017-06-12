-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

module("gluon.web.cgi", package.seeall)
local nixio = require("nixio")
require("gluon.web.http")
require("gluon.web.dispatcher")

-- Limited source to avoid endless blocking
local function limitsource(handle, limit)
	limit = limit or 0
	local BLOCKSIZE = 2048

	return function()
		if limit < 1 then
			handle:close()
			return nil
		else
			local read = (limit > BLOCKSIZE) and BLOCKSIZE or limit
			limit = limit - read

			local chunk = handle:read(read)
			if not chunk then handle:close() end
			return chunk
		end
	end
end

function run()
	local http = gluon.web.http.Http(
		nixio.getenv(),
		limitsource(io.stdin, tonumber(nixio.getenv("CONTENT_LENGTH"))),
		io.stdout
	)

	gluon.web.dispatcher.httpdispatch(http)
end
