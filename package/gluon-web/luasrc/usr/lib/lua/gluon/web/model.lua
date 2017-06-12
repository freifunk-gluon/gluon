-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

module("gluon.web.model", package.seeall)

local util = require("gluon.web.util")

local fs         = require("nixio.fs")
local datatypes  = require("gluon.web.model.datatypes")
local dispatcher = require("gluon.web.dispatcher")
local class      = util.class
local instanceof = util.instanceof

FORM_NODATA  =  0
FORM_VALID   =  1
FORM_INVALID = -1

-- Loads a model from given file, creating an environment and returns it
function load(name, renderer)
	local modeldir = util.libpath() .. "/model/"

	if not fs.access(modeldir..name..".lua") then
		error("Model '" .. name .. "' not found!")
	end

	local func = assert(loadfile(modeldir..name..".lua"))

	local env = {
		translate=renderer.translate,
		translatef=renderer.translatef,
	}

	setfenv(func, setmetatable(env, {__index =
		function(tbl, key)
			return _M[key] or _G[key]
		end
	}))

	local models = { func() }

	for k, model in ipairs(models) do
		if not instanceof(model, Node) then
			error("model definition returned an invalid model object")
		end
		model.index = k
	end

	return models
end


local function parse_datatype(code)
	local match, arg, arg2

	match, arg, arg2 = code:match('^([^%(]+)%(([^,]+),([^%)]+)%)$')
	if match then
		return datatypes[match], {arg, arg2}
	end

	match, arg = code:match('^([^%(]+)%(([^%)]+)%)$')
	if match then
		return datatypes[match], {arg}
	end

	return datatypes[code], {}
end

local function verify_datatype(dt, value)
	if dt then
		local c, args = parse_datatype(dt)
		assert(c, "Invalid datatype")
		return c(value, unpack(args))
	end
	return true
end


Node = class()

function Node:__init__(title, description, name)
	self.children = {}
	self.title = title or ""
	self.description = description or ""
	self.name = name
	self.index = nil
	self.parent = nil
end

function Node:append(obj)
	table.insert(self.children, obj)
	obj.index = #self.children
	obj.parent = self
end

function Node:id_suffix()
	return self.name or (self.index and tostring(self.index)) or '_'
end

function Node:id()
	local prefix = self.parent and self.parent:id() or "id"

	return prefix.."."..self:id_suffix()
end

function Node:parse(http)
	for _, child in ipairs(self.children) do
		child:parse(http)
	end
end

function Node:render(renderer, scope)
	if self.template then
		local env = setmetatable({
			self  = self,
			id  = self:id(),
			scope = scope,
		}, {__index = scope})
		renderer.render(self.template, env)
	end
end

function Node:render_children(renderer, scope)
	for _, node in ipairs(self.children) do
		node:render(renderer, scope)
	end
end

function Node:resolve_depends()
	local updated = false
	for _, node in ipairs(self.children) do
		update = updated or node:resolve_depends()
	end
	return updated
end

function Node:handle()
	for _, node in ipairs(self.children) do
		node:handle()
	end
end


Template = class(Node)

function Template:__init__(template)
	Node.__init__(self)
	self.template = template
end


Form = class(Node)

function Form:__init__(...)
	Node.__init__(self, ...)
	self.template = "model/form"
end

function Form:submitstate(http)
	return http:getenv("REQUEST_METHOD") == "POST" and http:formvalue(self:id()) ~= nil
end

function Form:parse(http)
	if not self:submitstate(http) then
		self.state = FORM_NODATA
		return
	end

	Node.parse(self, http)

	while self:resolve_depends() do end

	for _, s in ipairs(self.children) do
		for _, v in ipairs(s.children) do
			if v.state == FORM_INVALID then
				self.state = FORM_INVALID
				return
			end
		end
	end

	self.state = FORM_VALID
end

function Form:handle()
	if self.state == FORM_VALID then
		Node.handle(self)
		self:write()
	end
end

function Form:write()
end

function Form:section(t, ...)
	assert(instanceof(t, Section), "class must be a descendent of Section")

	local obj  = t(...)
	self:append(obj)
	return obj
end


Section = class(Node)

function Section:__init__(...)
	Node.__init__(self, ...)
	self.fields = {}
	self.template = "model/section"
end

function Section:option(t, option, title, description, ...)
	assert(instanceof(t, AbstractValue), "class must be a descendant of AbstractValue")

	local obj  = t(title, description, option, ...)
	self:append(obj)
	self.fields[option] = obj
	return obj
end


AbstractValue = class(Node)

function AbstractValue:__init__(option, ...)
	Node.__init__(self, option, ...)
	self.deps = {}

	self.default   = nil
	self.size      = nil
	self.optional  = false

	self.template  = "model/valuewrapper"

	self.state = FORM_NODATA
end

function AbstractValue:depends(field, value)
	local deps
	if instanceof(field, Node) then
		deps = { [field] = value }
	else
		deps = field
	end

	table.insert(self.deps, deps)
end

function AbstractValue:deplist(section, deplist)
	local deps = {}

	for _, d in ipairs(deplist or self.deps) do
		local a = {}
		for k, v in pairs(d) do
			a[k:id()] = v
		end
		table.insert(deps, a)
	end

	if next(deps) then
		return deps
	end
end

function AbstractValue:defaultvalue()
	return self.default
end

function AbstractValue:formvalue(http)
	return http:formvalue(self:id())
end

function AbstractValue:cfgvalue()
	if self.state == FORM_NODATA then
		return self:defaultvalue()
	else
		return self.data
	end
end

function AbstractValue:add_error(type, msg)
	self.error = msg or type

	if type == "invalid" then
		self.tag_invalid = true
	elseif type == "missing" then
		self.tag_missing = true
	end

	self.state = FORM_INVALID
end

function AbstractValue:reset()
	self.error = nil
	self.tag_invalid = nil
	self.tag_missing = nil
	self.data = nil
	self.state = FORM_NODATA

end

function AbstractValue:parse(http)
	self.data = self:formvalue(http)

	local ok, err = self:validate()
	if not ok then
		if type(self.data) ~= "string" or #self.data > 0 then
			self:add_error("invalid", err)
		else
			self:add_error("missing", err)
		end
		return
	end

	self.state = FORM_VALID
end

function AbstractValue:resolve_depends()
	if self.state == FORM_NODATA or #self.deps == 0 then
		return false
	end

	for _, d in ipairs(self.deps) do
		local valid = true
		for k, v in pairs(d) do
			if k.state ~= FORM_VALID or k.data ~= v then
				valid = false
				break
			end
		end
		if valid then return false end
	end

	self:reset()
	return true
end

function AbstractValue:validate()
	if self.data and verify_datatype(self.datatype, self.data) then
		return true
	end

	if type(self.data) == "string" and #self.data == 0 then
		self.data = nil
	end

	if self.data == nil then
		return self.optional
	end

	return false

end

function AbstractValue:handle()
	if self.state == FORM_VALID then
		self:write(self.data)
	end
end

function AbstractValue:write(value)
end


Value = class(AbstractValue)

function Value:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/value"
	self.keylist = {}
	self.vallist = {}
end


Flag = class(AbstractValue)

function Flag:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/fvalue"

	self.default = false
end

function Flag:formvalue(http)
	return http:formvalue(self:id()) ~= nil
end

function Flag:validate()
	return true
end


ListValue = class(AbstractValue)

function ListValue:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/lvalue"

	self.size = 1
	self.widget = "select"

	self.keylist = {}
	self.vallist = {}
	self.valdeps = {}
end

function ListValue:value(key, val, ...)
	if util.contains(self.keylist, key) then
		return
	end

	val = val or key
	table.insert(self.keylist, tostring(key))
	table.insert(self.vallist, tostring(val))
	table.insert(self.valdeps, {...})
end

function ListValue:validate()
	return util.contains(self.keylist, self.data)
end


DynamicList = class(AbstractValue)

function DynamicList:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/dynlist"
end

function DynamicList:defaultvalue()
	local value = self.default

	if type(value) == "table" then
		return value
	else
		return { value }
	end
end

function DynamicList:formvalue(http)
	return http:formvaluetable(self:id())
end

function DynamicList:validate()
	if self.data == nil then
		self.data = {}
	end

	if #self.data == 0 then
		return self.optional
	end

	for _, v in ipairs(self.data) do
		if not verify_datatype(self.datatype, v) then
			return false
		end
	end
	return true
end


TextValue = class(AbstractValue)

function TextValue:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/tvalue"
end
