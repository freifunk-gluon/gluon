codes = true
std = "min"
self = false

read_globals = {
	"getfenv",
	"setfenv",
	"unpack",
}

include_files = {
	"**/*.lua",
	"package/**/luasrc/**/*",
	"targets/*",
	"package/features",
}

exclude_files = {
	"**/*.mk",
}

files["package/**/check_site.lua"] = {
	read_globals = {
		"alternatives",
		"extend",
		"in_domain",
		"in_site",
		"value",
		"need",
		"need_alphanumeric_key",
		"need_array",
		"need_array_elements_exclusive",
		"need_array_of",
		"need_boolean",
		"need_chanlist",
		"need_domain_name",
		"need_number",
		"need_number_range",
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

files["package/**/luasrc/lib/gluon/config-mode/*"] = {
	globals = {
		"MultiListValue",
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
		"Element",
	},
}

files["package/**/luasrc/lib/gluon/**/controller/*"] = {
	read_globals = {
		"_",
		"alias",
		"call",
		"entry",
		"model",
		"node",
		"template",
	},
}

files["package/**/luasrc/lib/gluon/nftables/*"] = {
	read_globals = {
		"path",
		"include",
		"rule",

		"bridge_rule",
		"bridge_chain",
		"bridge_table",
		"bridge_include_rule",
		"bridge_include_table",
	},
	max_line_length = false,
}

files["targets/*"] = {
	read_globals = {
		"class",
		"config",
		"defaults",
		"device",
		"env",
		"exec",
		"exec_capture",
		"exec_capture_raw",
		"exec_raw",
		"factory_image",
		"include",
		"istrue",
		"no_opkg",
		"packages",
		"sysupgrade_image",
		"try_config",
	},
}

files["package/features"] = {
	read_globals = {
		"_",
		"feature",
		"when",
	},
}
