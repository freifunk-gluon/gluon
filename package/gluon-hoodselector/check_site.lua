function need_nil(path)
  need(path, function(val)
    if val == nil then
      return true
    end
    return false
  end, true, "default hood should not contain shapes")
  return nil
end

--Need to check if not default hood and does the default not contain shapes
if this_domain() ~= need_string(in_site({'default_domain'})) then
  local no_shapes = true
  for _,shape in ipairs(need_table(in_domain({'hoodselector', 'shapes'}))) do
    no_shapes = false
    if #shape >= 2 then
      for _, pos in ipairs(shape) do
        if pos.lat == nil or not ( pos.lat < 90.0 and pos.lat > -90.0 ) then
          need(in_domain({'hoodselector', 'shapes'}), function(err) return false end, true, "lat must match a range +/-90.0")
        end
        if pos.lon == nil or not ( pos.lon < 180.0 and pos.lon > -180.0 ) then
          need(in_domain({'hoodselector', 'shapes'}), function(err) return false end, true, "lon must match a range +/-180.0")
        end
      end
    end
    if #shape < 2 then
      need(in_domain({'hoodselector', 'shapes'}), function(err) return false end, true, "needs to have at least 2 coordinates for rectangular shapes.")
    end
  end
  if no_shapes then
    need(in_domain({'hoodselector', 'shapes'}), function(err) return false end, true, "no shapes are defined in hoods")
  end
else -- ente by default hood
  need_nil(in_domain({'hoodselector', 'shapes'}))
end
