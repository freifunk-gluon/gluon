-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local tparser = require "gluon.web.template.parser"


local M = {}

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
function M.class(base)
	return setmetatable({}, {
		__call  = _instantiate,
		__index = base
	})
end

function M.instanceof(object, class)
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

function M.pcdata(value)
	return value and tparser.pcdata(tostring(value))
end

return M
