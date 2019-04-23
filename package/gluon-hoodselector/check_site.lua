--Need to check if not default domain and does the default not contain shapes
if this_domain() ~= need_string(in_site({'default_domain'})) then
	for _,shape in ipairs(need_table(in_domain({'hoodselector', 'shapes'}))) do
		need({'hoodselector', 'shapes'}, function(err)
			if #shape >= 2 then
				for _, pos in ipairs(shape) do
					need({'hoodselector', 'shapes'}, function(err) return pos.lat == nil or not ( pos.lat < 90.0 and pos.lat > -90.0 ) end, false, "lat must match a range +/-90.0")
					need({'hoodselector', 'shapes'}, function(err) return pos.lon == nil or not ( pos.lon < 180.0 and pos.lon > -180.0 ) end, false, "lon must match a range +/-180.0")
				end
				return true
			end
			return false
		end, true, "needs to have at least 2 coordinates for rectangular shapes.")
	end
end
