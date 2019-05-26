function check_lat_lon_range(pos,range,label)
	need({'hoodselector', 'shapes'}, function(err)
		if (type(pos) ~= "number") then
			return false
		end
		if pos > range or pos < -range then
			return false
		end
		return true
	end, true, label.." must match a range +/-"..range)
end

if this_domain() ~= need_string(in_site({'default_domain'})) then
	for _,shape in pairs(need_table(in_domain({'hoodselector', 'shapes'}))) do
		need({'hoodselector', 'shapes'}, function(err)
			if #shape < 2 then
				return false
			end
			for k,v in ipairs(shape) do
				check_lat_lon_range(v.lat,90.0,"lat")
				check_lat_lon_range(v.lon,180.0,"lon")
			end
			return true
		end, true, "needs to have at least 2 coordinates for rectangular shapes.")
	end
end
