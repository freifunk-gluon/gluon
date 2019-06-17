env = setmetatable({}, {
	__index = function(_, k) return os.getenv(k) end
})
envtrue = setmetatable({}, {
	__index = function(_, k) return (tonumber(os.getenv(k)) or 0) > 0 end
})

assert(env.GLUON_SITEDIR)
assert(env.GLUON_TARGETSDIR)
assert(env.GLUON_RELEASE)
assert(env.GLUON_DEPRECATED)


site_code = assert(assert(dofile('scripts/site_config.lua')('site.conf')).site_code)


target_packages = {}

local default_options = {
	profile = false,
	factory = '-squashfs-factory',
	factory_ext = '.bin',
	sysupgrade = '-squashfs-sysupgrade',
	sysupgrade_ext = '.bin',
	extra_images = {},
	aliases = {},
	manifest_aliases = {},
	packages = {},
	deprecated = false,
	broken = false,
}


local gluon_devices, unknown_devices = {}, {}
for dev in string.gmatch(env.GLUON_DEVICES or '', '%S+') do
	gluon_devices[dev] = true
	unknown_devices[dev] = true
end

local function want_device(dev, options)
	if options.broken and not envtrue.BROKEN then
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
function escape(s)
	s = string.gsub(s, "'", "'\\''")
	s = string.gsub(s, "%z", "'*'")
	return "'" .. s .. "'"
end

local function escape_command(command, raw)
	local ret = 'exec'
	for _, arg in ipairs(command) do
		ret = ret .. ' ' .. escape(arg)
	end
	if raw then
		ret = ret .. ' ' .. raw
	end
	return ret
end

function exec_raw(command, may_fail)
	local ret = os.execute(command)
	assert((ret == 0) or may_fail)
	return ret
end

function exec(command, may_fail, raw)
	return exec_raw(escape_command(command, raw), may_fail)
end

function exec_capture_raw(command)
	local f = io.popen(command)
	assert(f)

	local data = f:read('*a')
	f:close()
	return data
end

function exec_capture(command, raw)
	return exec_capture_raw(escape_command(command, raw))
end


local image_mt = {
	__index = {
		dest_name = function(image, name, site, release)
			return env.GLUON_IMAGEDIR .. '/' .. image.subdir,
				'gluon-' .. (site or site_code) .. '-'
				.. (release or env.GLUON_RELEASE) .. '-'
				.. name .. image.out_suffix .. image.extension
		end,
	},
}

local function add_image(image)
	table.insert(images, setmetatable(image, image_mt))
end


-- Variables to be consumed by scripts using common.inc.lua
devices = {}
images = {}
opkg = true


function config() end
function try_config() end

function packages(pkgs)
	for _, pkg in ipairs(pkgs) do
		table.insert(target_packages, pkg)
	end
end

function device(image, name, options)
	options = merge(default_options, options)

	if not want_device(image, options) then
		return
	end

	table.insert(devices, {
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
		add_image {
			image = image,
			name = name,
			subdir = 'factory',
			in_suffix = options.factory,
			out_suffix = '',
			extension = options.factory_ext,
			aliases = options.aliases,
			manifest_aliases = options.manifest_aliases,
		}
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
			manifest_aliases = options.manifest_aliases,
		}
	end
end

function factory_image(image, name, ext, options)
	options = merge(default_options, options)

	if not want_device(image, options) then
		return
	end

	if options.deprecated and not full_deprecated then
		return
	end

	add_image {
		image = image,
		name = name,
		subdir = 'factory',
		in_suffix = '',
		out_suffix = '',
		extension = ext,
		aliases = options.aliases,
		manifest_aliases = options.manifest_aliases,
	}
end

function sysupgrade_image(image, name, ext, options)
	options = merge(default_options, options)

	if not want_device(image, options) then
		return
	end

	add_image {
		image = image,
		name = name,
		subdir = 'sysupgrade',
		in_suffix = '',
		out_suffix = '-sysupgrade',
		extension = ext,
		aliases = options.aliases,
		manifest_aliases = options.manifest_aliases,
	}
end

function no_opkg()
	opkg = false
end

function defaults(options)
	default_options = merge(default_options, options)
end


function check_devices()
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
