if need_table('mesh', nil, false) and  need_table('mesh.batman_adv', nil, false) then
	need_number('mesh.batman_adv.gw_sel_class', false)
	need_one_of('mesh.batman_adv.routing_algo', {'BATMAN_IV', 'BATMAN_V'}, false)
end
