local announce = require 'gluon.announce'
local deflate = require 'deflate'
local json = require 'luci.jsonc'
local util = require 'luci.util'
local nixio = require 'nixio'
local fs = require 'nixio.fs'

local memoize = {}

nixio.chdir('/lib/gluon/announce/')

for dir in fs.glob('*.d') do
  local name = dir:sub(1, -3)
  memoize[name] = {
    collect = announce.collect(dir),
    -- tonumber will return 0 for invalid inputs
    cache_time = tonumber(util.trim(fs.readfile(name .. '.cache') or ''))
  }
end

local function collect(type, timestamp)
  local c = memoize[type]
  if not c then
    return nil
  end

  if c.cache_timeout and timestamp < c.cache_timeout then
    return c.cache
  else
    local ret = c.collect()

    if c.cache_time then
      c.cache = ret
      c.cache_timeout = timestamp + c.cache_time
    end

    return ret
  end
end

module('gluon.announced', package.seeall)

function handle_request(query, timestamp)
  collectgarbage()

  local m = query:match('^GET ([a-z ]+)$')
  local ret
  if m then
    local data = {}

    for q in m:gmatch('([a-z]+)') do
      local ok, val = pcall(collect, q, timestamp)
      if ok then
        data[q] = val
      end
    end

    if next(data) then
      ret = deflate.compress(json.stringify(data))
    end
  elseif query:match('^[a-z]+$') then
    local ok, data = pcall(collect, query, timestamp)
    if ok then
      ret = json.stringify(data)
    end
  end

  collectgarbage()

  return ret
end
