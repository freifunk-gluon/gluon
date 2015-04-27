local announce = require 'gluon.announce'
local deflate = require 'deflate'
local json = require 'luci.json'


local function collect(type)
  return announce.collect_dir('/lib/gluon/announce/' .. type .. '.d')
end


module('gluon.announced', package.seeall)

function handle_request(query)
  if query:match('^nodeinfo$') then
    return json.encode(collect('nodeinfo'))
  end

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
      return deflate.compress(json.encode(data))
    end
  end
end
