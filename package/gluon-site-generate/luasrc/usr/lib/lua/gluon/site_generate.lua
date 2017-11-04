#!/usr/bin/lua

local tool = {}
local uci = require('luci.model.uci').cursor()
local json =  require 'luci.json'
local sites_json = '/lib/gluon/site-select/sites.json'

module('gluon.site_generate', package.seeall)

function get_config(file)
  local f = io.open(file)
  if f then
    local config = json.decode(f:read('*a'))
    f:close()
    return config
  end
  return nil
end

function get_list()
  local list = {}
  local sites = get_config(sites_json)
  for index, site in pairs(sites) do
    list[site.site_code]=index
  end
  return list
end

local site_list=get_list()

function validate_site(site_code)
  return site_list[site_code]
end

function force_site_code(site_code)
  if site_code then
    uci:set('currentsite', 'current', 'name', site_code)
    uci:save('currentsite')
    uci:commit('currentsite')
    return true
  end
  return false
end

function set_site_code(site_code)
  if site_code and validate_site(site_code) then
    uci:set('currentsite', 'current', 'name', site_code)
    uci:save('currentsite')
    uci:commit('currentsite')
    return true
  end
  return false
end

function replace_patterns(value, subst)
  for k, v in pairs(subst) do
    value = value:gsub(k, v)
  end
  return value
end
