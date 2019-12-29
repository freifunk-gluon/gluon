codes = true
std = "lua51"
self = false

include_files = {
	"*.lua",
	"/**/files/lib/gluon/ebtables/*",
	"/**/luasrc/**/*",
}

-- files["scripts/check_site.lua"] = {
--	allow_defined = true,
--	module = true,
-- }

files["/**/check_site.lua"] = {
	globals = {
		"alternatives",
		"extend",
		"in_domain",
		"in_site",
		"need",
		"need_alphanumeric_key",
		"need_array",
		"need_array_of",
		"need_boolean",
		"need_chanlist",
		"need_domain_name",
		"need_number",
		"need_one_of",
		"need_string",
		"need_string_array",
		"need_string_array_match",
		"need_string_match",
		"need_table",
		"need_value",
		"obsolete",
		"table_keys",
		"this_domain",
	},
}

files["/**/files/lib/gluon/ebtables/*"] = {
	globals = {
		"site",
	},
	new_read_globals = {
		"chain",
		"rule",
	},
	max_line_length = false,
}

files["/**/luasrc/lib/gluon/config-mode/*"] = {
	globals = {
		"DynamicList",
		"Flag",
		"Form",
		"i18n",
		"ListValue",
		"renderer.render",
		"renderer.render_string",
		"Section",
		"TextValue",
		"_translate",
		"translate",
		"translatef",
		"Value",
	},
}

files["/**/luasrc/lib/gluon/**/controller/*"] = {
	new_read_globals = {
		"_",
		"alias",
		"call",
		"entry",
		"model",
		"node",
		"template",
	},
}

files["/**/gluon-client-bridge/luasrc/usr/lib/lua/gluon/client_bridge.lua"] = {
	globals = {
		"next_node_macaddr",
	},
}

files["/**/gluon-config-mode-geo-location-osm/luasrc/usr/lib/lua/gluon/config-mode/geo-location-osm.lua"] = {
--	allow_defined = true,
--	module = true,
	globals = {
		"help",
		"MapValue",
		"options",
	},
}

files["/**/gluon-core/luasrc/usr/lib/lua/gluon/*"] = {
	globals = {
		"_M",
	},
}

files["/**/gluon-core/luasrc/usr/lib/lua/gluon/iputil.lua"] = {
--	allow_defined = true,
--	module = true,
	globals = {
		"IPv6",
		"mac_to_ip",
	},
}

files["/**/gluon-core/luasrc/usr/lib/lua/gluon/platform.lua"] = {
--	allow_defined = true,
--	module = true,
	globals = {
		"is_outdoor_device",
		"match",
	},
	new_read_globals = {
		-- globals provided by platform_info
		"get_board_name",
		"get_image_name",
		"get_model",
		"get_subtarget",
		"get_target",
	},
}

files["/**/gluon-core/luasrc/usr/lib/lua/gluon/users.lua"] = {
	globals = {
		"remove_group",
		"remove_user",
	},
}

files["/**/gluon-core/luasrc/usr/lib/lua/gluon/util.lua"] = {
--	allow_defined = true,
--	module = true,
	globals = {
		"add_to_set",
		"contains",
		"default_hostname",
		"domain_seed_bytes",
		"exec",
		"find_phy",
		"foreach_radio",
		"generate_mac",
		"get_mesh_devices",
		"get_uptime",
		"get_wlan_mac",
		"glob",
		"node_id",
		"readfile",
		"remove_from_set",
		"replace_prefix",
		"trim",
	},
}

files["/**/gluon-web/luasrc/usr/lib/lua/gluon/web/*"] = {
	globals = {
		"Http",
		"HTTP_MAX_CONTENT",
		"mimedecode_message_body",
		"parse_message_body",
		"urldecode",
		"urldecode_params",
		"urlencode",
	},
}

files["/**/gluon-web/luasrc/usr/lib/lua/gluon/web/util.lua"] = {
	globals = {
		"class",
		"instanceof",
		"pcdata",
	},
}

files["/**/gluon-web-admin/luasrc/lib/gluon/config-mode/controller/admin/upgrade.lua"] = {
	globals = {
		"file",
	},
}

files["/**/gluon-web-mesh-vpn-fastd/luasrc/lib/gluon/config-mode/model/admin/mesh_vpn_fastd.lua"] = {
	globals = {
		"gluon",
	},
}

files["/**/gluon-web-model/luasrc/usr/lib/lua/gluon/web/model/datatypes.lua"] = {
--	allow_defined = true,
--	module = true,
	globals = {
		"bool",
		"float",
		"imax",
		"imin",
		"integer",
		"ip4addr",
		"ip6addr",
		"ipaddr",
		"irange",
		"max",
		"maxlength",
		"min",
		"minlength",
		"range",
		"ufloat",
		"uinteger",
		"wpakey",
	},
}

files["/**/gluon-web-model/luasrc/usr/lib/lua/gluon/web/model/classes.lua"] = {
--	allow_defined = true,
	globals = {
		"AbstractValue",
		"DynamicList",
		"Flag",
		"Form",
		"FORM_INVALID",
		"FORM_NODATA",
		"FORM_VALID",
		"ListValue",
		"Node",
		"Section",
		"Template",
		"TextValue",
		"Value",
	},
}

files["/**/gluon-web-osm/luasrc/usr/lib/lua/gluon/*"] = {
	globals = {
		"MapValue",
	},
}
