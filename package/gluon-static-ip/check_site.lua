if need_string({'node_prefix4'}, false) then -- optional
  need_number({'node_prefix4_range'}, true)
  need_boolean({'node_prefix4_temporary'}, false)
end

need_string({'node_prefix6'}, true) -- always required
need_number({'node_prefix6_range'}, false)
need_boolean({'node_prefix6_temporary'}, false)
