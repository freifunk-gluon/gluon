#!/usr/bin/lua

function replace_patterns(value, subst)
  for k, v in pairs(subst) do
    value = value:gsub(k, v)
  end
  return value
end

dofile(os.getenv('GLUON_SITEDIR') ..'/extra/default.conf')
local template = os.getenv('GLUON_SITEDIR') ..'/extra/template.conf'
local site = os.getenv('GLUON_SITEDIR') ..'/site.conf'

local config = io.open(template):read('*a')
config = replace_patterns(config, subst)

io.open(site, 'w'):write(config)
