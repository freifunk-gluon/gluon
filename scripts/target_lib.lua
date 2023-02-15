-- Functions for use in targets/*
local F = {}

-- To be accessed by scripts using target_lib
local M = setmetatable({}, { __index = F })

local funcs = setmetatable({}, {
	__index = function(_, k)
		return F[k] or _G[k]
	end,
})

local env = setmetatable({}, {
	__index = function(_, k) return os.getenv(k) end
})
F.env = env

assert(env.GLUON_SITEDIR)
assert(env.GLUON_TARGETSDIR)
assert(env.GLUON_RELEASE)
assert(env.GLUON_DEPRECATED)


M.site_code = assert(
	dofile('scripts/site_config.lua')('site.conf').site_code, 'site_code missing in site.conf'
)
M.target_packages = {}
M.target_class_packages = {}
M.configs = {}
M.devices = {}
M.images = {}


local default_options = {
	factory = '-squashfs-factory',
	factory_ext = '.bin',
	sysupgrade = '-squashfs-sysupgrade',
	sysupgrade_ext = '.bin',
	extra_images = {},
	aliases = {},
	manifest_aliases = {},
	packages = {},
	class = 'standard',
	deprecated = false,
	broken = false,
}


local gluon_devices, unknown_devices = {}, {}
for dev in string.gmatch(env.GLUON_DEVICES or '', '%S+') do
	gluon_devices[dev] = true
	unknown_devices[dev] = true
end

function F.istrue(v)
	return (tonumber(v) or 0) > 0
end

local function want_device(dev, options)
	if options.broken and not F.istrue(env.BROKEN) then
		return false
	end
	if options.deprecated and env.GLUON_DEPRECATED == '0' then
		return false
	end

	if (env.GLUON_DEVICES or '') == '' then
		return true
	end

	unknown_devices[dev] = nil
	return gluon_devices[dev]
end

local full_deprecated = env.GLUON_DEPRECATED == 'full'


local function merge(a, b)
	local ret = {}
	for k, v in pairs(a) do
		ret[k] = v
	end
	for k, v in pairs(b or {}) do
		assert(ret[k] ~= nil, string.format("unknown option '%s'", k))
		ret[k] = v
	end
	return ret
end

-- Escapes a single argument to be used in a shell command
-- The argument is surrounded by single quotes, single quotes inside the
-- argument are replaced by '\''.
-- To allow using shell wildcards, zero bytes in the arguments are replaced
-- by unquoted asterisks.
function F.escape(s)
	s = string.gsub(s, "'", "'\\''")
	s = string.gsub(s, "%z", "'*'")
	return "'" .. s .. "'"
end

local function escape_command(command, raw)
	local ret = ''
	if not raw then
		ret = 'exec'
	end
	for _, arg in ipairs(command) do
		ret = ret .. ' ' .. F.escape(arg)
	end
	if raw then
		ret = ret .. ' ' .. raw
	end
	return ret
end

function F.exec_raw(command, may_fail)
	local ret = os.execute(command)
	assert((ret == 0) or may_fail)
	return ret
end

function F.exec(command, may_fail, raw)
	return F.exec_raw(escape_command(command, raw), may_fail)
end

function F.exec_capture_raw(command)
	local f = io.popen(command)
	assert(f)

	local data = f:read('*a')
	f:close()
	return data
end

function F.exec_capture(command, raw)
	return F.exec_capture_raw(escape_command(command, raw))
end


local image_mt = {
	__index = {
		dest_name = function(image, name, site, release)
			return env.GLUON_IMAGEDIR..'/'..image.subdir,
				'gluon-'..(site or M.site_code)..'-'..(release or env.GLUON_RELEASE)..'-'..name..image.out_suffix..image.extension
		end,
	},
}

local function add_image(image)
	local device = image.image
	M.images[device] = M.images[device] or {}
	table.insert(M.images[device], setmetatable(image, image_mt))
end


local function format_config(k, v)
	local format
	if type(v) == 'string' then
		format = '%s=%q'
	elseif v == true then
		format = '%s=y'
	elseif v == nil then
		format = '%s=m'
	elseif v == false then
		format = '# %s is not set'
	else
		format = '%s=%d'
	end
	return string.format(format, 'CONFIG_' .. k, v)
end

local config_mt = {
	__index = {
		format = function(config)
			return format_config(config.key, config.value)
		end,
	}
}

local function do_config(k, v, required)
	M.configs[k] = setmetatable({
		key = k,
		value = v,
		required = required,
	}, config_mt)
end

function F.try_config(k, v)
	do_config(k, v)
end

function F.config(k, v, message)
	if not message then
		message = string.format("unable to set '%s'", format_config(k, v))
	end
	do_config(k, v, message)
end


function F.packages(pkgs)
	for _, pkg in ipairs(pkgs) do
		table.insert(M.target_packages, pkg)
	end
end
M.packages = F.packages

function F.class_packages(target, pkgs)
	if not M.target_class_packages[target] then
		M.target_class_packages[target] = {}
	end

	for _, pkg in ipairs(pkgs) do
		table.insert(M.target_class_packages[target], pkg)
	end
end
M.class_packages = F.class_packages

local function as_table(v)
	if type(v) == 'table' then
		return v
	else
		return {v}
	end
end

function F.device(image, name, options)
	options = merge(default_options, options)

	if not want_device(image, options) then
		return
	end

	table.insert(M.devices, {
		image = image,
		name = name,
		options = options,
	})

	if options.sysupgrade then
		add_image {
			image = image,
			name = name,
			subdir = 'sysupgrade',
			in_suffix = options.sysupgrade,
			out_suffix = '-sysupgrade',
			extension = options.sysupgrade_ext,
			aliases = options.aliases,
			manifest_aliases = options.manifest_aliases,
		}
	end

	if options.deprecated and not full_deprecated then
		return
	end

	if options.factory then
		for _, ext in ipairs(as_table(options.factory_ext)) do
			add_image {
				image = image,
				name = name,
				subdir = 'factory',
				in_suffix = options.factory,
				out_suffix = '',
				extension = ext,
				aliases = options.aliases,
			}
		end
	end
	for _, extra_image in ipairs(options.extra_images) do
		add_image {
			image = image,
			name = name,
			subdir = 'other',
			in_suffix = extra_image[1],
			out_suffix = extra_image[2],
			extension = extra_image[3],
			aliases = options.aliases,
		}
	end
end

function F.defaults(options)
	default_options = merge(default_options, options)
end

local function load_and_assert(...)
	for _, path in ipairs(arg) do
		local fd = io.open(path, 'r')
		if fd ~= nil then
			fd:close()
			-- only assert if file exists. this allows trying multiple files.
			return assert(loadfile(path))
		end
	end

	assert(nil)
end

-- this function allows including target configurations from the first source
-- that a file is found
-- targets are loaded in the following order:
--  - current working directory
--  - site
--  - gluon
function F.include(name)
	local f = load_and_assert('./' .. name, env.GLUON_SITEDIR .. '/' .. name, env.GLUON_TARGETSDIR .. '/' .. name)
	setfenv(f, funcs)
	return f()
end

-- this function allows including target configurations from gluon
-- can be used to include original targets via site, for example
function F.include_gluon(name)
	local f = load_and_assert(env.GLUON_TARGETSDIR .. '/' .. name)
	setfenv(f, funcs)
	return f()
end

function M.check_devices()
	local device_list = {}
	for device in pairs(unknown_devices) do
		table.insert(device_list, device)
	end
	if #device_list ~= 0 then
		table.sort(device_list)
		io.stderr:write('Error: unknown devices given: ', table.concat(device_list, ' '), '\n')
		os.exit(1)
	end
end


return M
