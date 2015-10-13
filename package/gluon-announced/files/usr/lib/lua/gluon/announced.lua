local announce = require 'gluon.announce'
local deflate = require 'deflate'
local json = require 'luci.jsonc'


local function collect(type)
  return announce.collect_dir('/lib/gluon/announce/' .. type .. '.d')
end


module('gluon.announced', package.seeall)

function handle_request(query)
  local m = query:match('^GET ([a-z ]+)$')
  if m then
    local data = {}

    for q in m:gmatch('([a-z]+)') do
      local ok, val = pcall(collect, q)
      if ok then
        data[q] = val
      end
    end

    if next(data) then
      return deflate.compress(json.stringify(data))
    end
  elseif query:match('^[a-z]+$') then
    local ok, data = pcall(collect, query)
    if ok then
      return json.stringify(data)
    end
  end
end
