need_number({'radvd', 'preferred_lifetime'}, false)
need_number({'radvd', 'valid_lifetime'}, false)

local function is_int(v)
	return type(v) == 'number' and v == math.floor(v)
end

-- The interval limits mirror the validation of uradvd, the router lifetime
-- follows RFC 4861 section 6.2.1 as updated by RFC 8319
local default_lifetime = need_number_range({'radvd', 'default_lifetime'}, 0, 65535, false)
local min_interval = need_number_range({'radvd', 'min_interval'}, 3, 1350, false)
local max_interval = need_number_range({'radvd', 'max_interval'}, 4, 1800, false)

for _, key in ipairs({'default_lifetime', 'min_interval', 'max_interval'}) do
	need({'radvd', key}, is_int, false, 'be an integer')
end

-- Setting only one interval could violate uradvd's constraint against the
-- default of the other one, so both are required together
if (min_interval == nil) ~= (max_interval == nil) then
	need({'radvd', min_interval == nil and 'min_interval' or 'max_interval'},
		function() return false end, true,
		'be set as well, as radvd.min_interval and radvd.max_interval must be given together')
end

if min_interval and max_interval then
	need({'radvd', 'min_interval'}, function(v) return v <= 0.75 * max_interval end, true,
		'be at most 0.75 * radvd.max_interval')
end

-- uradvd defaults to a maximum interval of 600 seconds
if default_lifetime and default_lifetime ~= 0 then
	need({'radvd', 'default_lifetime'}, function(v) return v >= (max_interval or 600) end, true,
		'be 0 or at least radvd.max_interval (default 600)')
end
