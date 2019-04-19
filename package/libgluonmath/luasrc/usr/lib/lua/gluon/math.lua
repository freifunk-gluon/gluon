local M = {}

-- Source with pseudocode: https://de.wikipedia.org/wiki/Punkt-in-Polygon-Test_nach_Jordan
-- see also https://en.wikipedia.org/wiki/Point_in_polygon
-- parameters: points A = (x_a,y_a), B = (x_b,y_b), C = (x_c,y_c)
-- return value: −1 if the ray from A to the right bisects the edge [BC] (the lower vortex of [BC]
-- is not seen as part of [BC]);
--                0 if A is on [BC];
--                +1 else
function M.cross_prod_test(x_a,y_a,x_b,y_b,x_c,y_c)
	if y_a == y_b and y_b == y_c then
		if (x_b <= x_a and x_a <= x_c) or (x_c <= x_a and x_a <= x_b) then
			return 0
		end
		return 1
	end
	if not ((y_a == y_b) and (x_a == x_b)) then
		if y_b > y_c then
			-- swap b and c
			local h = x_b
			x_b = x_c
			x_c = h
			h = y_b
			y_b = y_c
			y_c = h
		end
		if (y_a <= y_b) or (y_a > y_c) then
			return 1
		end
		local delta = (x_b-x_a) * (y_c-y_a) - (y_b-y_a) * (x_c-x_a)
		if delta > 0 then
			return 1
		end
		if delta < 0 then
			return -1
		end
	end
	return 0
end

-- Source with pseudocode: https://de.wikipedia.org/wiki/Punkt-in-Polygon-Test_nach_Jordan
-- see also: https://en.wikipedia.org/wiki/Point_in_polygon
-- let P be a 2D Polygon and Q a 2D Point
-- return value:  +1 if Q within P;
--                −1 if Q outside of P;
--                0 if Q on an edge of P
function M.point_in_polygon(poly, point)
	local t = -1
	for i=1,#poly-1 do
		t = t * M.cross_prod_test(point.lon,point.lat,poly[i].lon,poly[i].lat,poly[i+1].lon,poly[i+1].lat)
		if t == 0 then break end
	end
	return t
end

-- Convert Rectengular defined by two point into polygon
function M.two_point_rec_to_poly(rec)
	local poly = {};
	poly[1]["lon"] = rec[1].lon
	poly[1]["lat"] = rec[1].lat
	poly[2]["lon"] = rec[2].lon
	poly[2]["lat"] = rec[1].lat
	poly[3]["lon"] = rec[2].lon
	poly[3]["lat"] = rec[2].lat
	poly[4]["lon"] = rec[1].lon
	poly[4]["lat"] = rec[2].lat
	return poly
end

return M
