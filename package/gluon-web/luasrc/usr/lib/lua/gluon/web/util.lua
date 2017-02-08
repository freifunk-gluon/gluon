-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local io = require "io"
local table = require "table"
local tparser = require "gluon.web.template.parser"
local json = require "luci.jsonc"
local nixio = require "nixio"
local fs = require "nixio.fs"

local getmetatable, setmetatable = getmetatable, setmetatable
local tostring, pairs = tostring, pairs

module "gluon.web.util"

--
-- Class helper routines
--

-- Instantiates a class
local function _instantiate(class, ...)
	local inst = setmetatable({}, {__index = class})

	if inst.__init__ then
		inst:__init__(...)
	end

	return inst
end

-- The class object can be instantiated by calling itself.
-- Any class functions or shared parameters can be attached to this object.
-- Attaching a table to the class object makes this table shared between
-- all instances of this class. For object parameters use the __init__ function.
-- Classes can inherit member functions and values from a base class.
-- Class can be instantiated by calling them. All parameters will be passed
-- to the __init__ function of this class - if such a function exists.
-- The __init__ function must be used to set any object parameters that are not shared
-- with other objects of this class. Any return values will be ignored.
function class(base)
	return setmetatable({}, {
		__call  = _instantiate,
		__index = base
	})
end

function instanceof(object, class)
	while object do
		if object == class then
			return true
		end
		local mt = getmetatable(object)
		object = mt and mt.__index
	end
	return false
end


--
-- String and data manipulation routines
--

function pcdata(value)
	return value and tparser.pcdata(tostring(value))
end


function contains(table, value)
	for k, v in pairs(table) do
		if value == v then
			return k
		end
	end
	return false
end


--
-- System utility functions
--

function exec(command)
	local pp   = io.popen(command)
	local data = pp:read("*a")
	pp:close()

	return data
end

function uniqueid(bytes)
	local rand = fs.readfile("/dev/urandom", bytes)
	return nixio.bin.hexlify(rand)
end

serialize_json = json.stringify

function libpath()
	return '/lib/gluon/web'
end
