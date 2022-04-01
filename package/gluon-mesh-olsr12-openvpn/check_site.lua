if need_boolean({'mesh', 'olsrd', 'olsr12', 'enable'}, false) then
  need_number({'mesh', 'olsrd', 'olsr12', 'port'}, false)
  need_string({'mesh', 'olsrd', 'olsr12', 'ca'})
  need_string({'mesh', 'olsrd', 'olsr12', 'server'})
end
