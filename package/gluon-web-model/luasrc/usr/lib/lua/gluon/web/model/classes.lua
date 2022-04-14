-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2017-2018 Matthias Schiffer <mschiffer@universe-factory.net>
-- Licensed to the public under the Apache License 2.0.

local util = require "gluon.web.util"

local datatypes  = require "gluon.web.model.datatypes"
local class      = util.class
local instanceof = util.instanceof


local M = {}

M.FORM_NODATA  =  0
M.FORM_VALID   =  1
M.FORM_INVALID = -1


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


local Node = class()
M.Node = Node

function Node:__init__(name, title, description)
	self.children = {}
	self.deps = {}
	self.title = title or ""
	self.description = description or ""
	self.name = name
	self.index = nil
	self.parent = nil
	self.state = M.FORM_NODATA
	self.package = 'gluon-web-model'
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

function Node:reset_node()
	self.state = M.FORM_NODATA
	for _, child in ipairs(self.children) do
		child:reset_node()
	end
end

function Node:parse(http)
	self.state = M.FORM_VALID
	for _, child in ipairs(self.children) do
		child:parse(http)
	end
end

function Node:propagate_state()
	if self.state == M.FORM_NODATA then
		return
	end

	for _, child in ipairs(self.children) do
		child:propagate_state()
		if child.state == M.FORM_INVALID then
			self.state = M.FORM_INVALID
		end
	end
end

function Node:render(renderer, scope)
	if self.template then
		local env = setmetatable({
			self = self,
			id = self:id(),
			scope = scope,
		}, {__index = scope})
		renderer.render(self.template, env, self.package)
	end
end

function Node:render_children(renderer, scope)
	for _, node in ipairs(self.children) do
		node:render(renderer, scope)
	end
end

function Node:depends(field, value)
	local deps
	if instanceof(field, Node) then
		deps = { [field] = value }
	else
		deps = field
	end

	table.insert(self.deps, deps)
end

function Node:deplist(deplist)
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

function Node:resolve_depends()
	local updated = self:resolve_node_depends()

	for _, node in ipairs(self.children) do
		updated = updated or node:resolve_depends()
	end

	return updated
end

function Node:resolve_node_depends()
	if #self.deps == 0 then
		return false
	end

	for _, d in ipairs(self.deps) do
		local valid = true
		for k, v in pairs(d) do
			if k.state ~= M.FORM_VALID or k.data ~= v then
				valid = false
				break
			end
		end
		if valid then return false end
	end

	self:reset_node()
	return true
end

-- will be overridden: write(value)
function Node:write()
end

function Node:handle()
	if self.state == M.FORM_VALID then
		for _, node in ipairs(self.children) do
			node:handle()
		end
		self:write(self.data)
	end
end


local Template = class(Node)
M.Template = Template

function Template:__init__(template)
	Node.__init__(self)
	self.template = template
end

local AbstractValue = class(Node)
M.AbstractValue = AbstractValue

function AbstractValue:__init__(...)
	Node.__init__(self, ...)

	self.default   = nil
	self.size      = nil
	self.optional  = false

	self.template  = "model/valuewrapper"

	self.error = false
end

function AbstractValue:defaultvalue()
	return self.default
end

function AbstractValue:formvalue(http)
	return http:formvalue(self:id())
end

function AbstractValue:cfgvalue()
	if self.state == M.FORM_NODATA then
		return self:defaultvalue()
	else
		return self.data
	end
end

function AbstractValue:reset_node()
	self.data = nil
	self.error = false
	self.state = M.FORM_NODATA

end

function AbstractValue:parse(http)
	self.data = self:formvalue(http)

	if not self:validate() then
		self.error = true
		self.state = M.FORM_INVALID
		return
	end

	self.state = M.FORM_VALID
end

function AbstractValue:resolve_node_depends()
	if self.state == M.FORM_NODATA then
		return false
	end

	return Node.resolve_node_depends(self)
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


local Value = class(AbstractValue)
M.Value = Value

function Value:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/value"
end


local Flag = class(AbstractValue)
M.Flag = Flag

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


local ListValue = class(AbstractValue)
M.ListValue = ListValue

function ListValue:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/lvalue"

	self.size = 1
	self.widget = "select"

	self.keys = {}
	self.entry_list = {}
end

function ListValue:value(key, val, ...)
	key = tostring(key)

	if self.keys[key] then
		return
	end
	self.keys[key] = true

	val = val or key
	table.insert(self.entry_list, {
		key = key,
		value = tostring(val),
		deps = {...},
	})
end

function ListValue:entries()
	local ret = {unpack(self.entry_list)}

	if self:cfgvalue() == nil or self.optional then
		table.insert(ret, 1, {
			key = '',
			value = '',
			deps = {},
		})
	end

	return ret
end

function ListValue:validate()
	if self.keys[self.data] then
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


local MultiListValue = class(AbstractValue)
M.MultiListValue = MultiListValue

function MultiListValue:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/mlvalue"

	self.size = 1

	self.keys = {}
	self.entry_list = {}
end

function MultiListValue:value(key, val, ...)
	key = tostring(key)

	if self.keys[key] then
		return
	end
	self.keys[key] = true

	val = val or key
	table.insert(self.entry_list, {
		key = key,
		value = tostring(val),
		deps = {...},
	})
end

function MultiListValue:entries()
	local ret = {unpack(self.entry_list)}

	return ret
end

function MultiListValue:validate()
	for _, val in ipairs(self.data) do
		if not self.keys[val] then
			return false
		end
	end

	return true
end

function MultiListValue:defaultvalue()
	local value = self.default

	if type(value) == "table" then
		return value
	else
		return { value }
	end
end

function MultiListValue:formvalue(http)
	return http:formvaluetable(self:id())
end


local DynamicList = class(AbstractValue)
M.DynamicList = DynamicList

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


local TextValue = class(AbstractValue)
M.TextValue = TextValue

function TextValue:__init__(...)
	AbstractValue.__init__(self, ...)
	self.subtemplate  = "model/tvalue"
end


local Element = class(Node)
M.Element = Element

function Element:__init__(template, kv, ...)
	Node.__init__(self, ...)

	self.default   = nil
	self.size      = nil
	self.optional  = false

	self.template  = template

	for key, value in pairs(kv) do
		self[key] = value
	end

	self.error = false
end

local Section = class(Node)
M.Section = Section

function Section:__init__(title, description, name)
	Node.__init__(self, name, title, description)
	self.template = "model/section"
end

function Section:option(t, ...)
	assert(instanceof(t, AbstractValue), "class must be a descendant of AbstractValue")

	local obj  = t(...)
	self:append(obj)
	return obj
end

function Section:element(...)
	local obj  = Element(...)
	self:append(obj)
	return obj
end

local Form = class(Node)
M.Form = Form

function Form:__init__(title, description, name)
	Node.__init__(self, name, title, description)
	self.template = "model/form"
end

function Form:submitstate(http)
	return http:getenv("REQUEST_METHOD") == "POST" and http:formvalue(self:id()) ~= nil
end

function Form:parse(http)
	if not self:submitstate(http) then
		self.state = M.FORM_NODATA
		return
	end

	Node.parse(self, http)

	while self:resolve_depends() do end

	self:propagate_state()
end

function Form:section(t, ...)
	assert(instanceof(t, Section), "class must be a descendent of Section")

	local obj  = t(...)
	self:append(obj)
	return obj
end


return M
