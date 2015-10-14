local announce = require 'gluon.announce'
local deflate = require 'deflate'
local json = require 'luci.jsonc'
local nixio = require 'nixio'
local fs = require 'nixio.fs'

local memoize = {}

nixio.chdir('/lib/gluon/announce/')

for dir in fs.glob('*.d') do
  local name = dir:sub(1, -3)
  memoize[name] = announce.collect_dir(dir)
end

local function collect(type)
  return memoize[type] and memoize[type]()
end

module('gluon.announced', package.seeall)

function handle_request(query)
  collectgarbage()

  local m = query:match('^GET ([a-z ]+)$')
  local ret
  if m then
    local data = {}

    for q in m:gmatch('([a-z]+)') do
      local ok, val = pcall(collect, q)
      if ok then
        data[q] = val
      end
    end

    if next(data) then
      ret = deflate.compress(json.stringify(data))
    end
  elseif query:match('^[a-z]+$') then
    local ok, data = pcall(collect, query)
    if ok then
      ret = json.stringify(data)
    end
  end

  collectgarbage()

  return ret
end
