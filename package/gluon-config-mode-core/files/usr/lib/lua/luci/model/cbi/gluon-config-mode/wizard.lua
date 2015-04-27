local wizard_dir = "/lib/gluon/config-mode/wizard/"
local i18n = luci.i18n
local uci = luci.model.uci.cursor()
local fs = require "luci.fs"
local f, s

local wizard = {}
local files = fs.dir(wizard_dir)

table.sort(files)

for _, entry in ipairs(files) do
  if entry:sub(1, 1) ~= '.' then
    table.insert(wizard, dofile(wizard_dir .. '/' .. entry))
  end
end

f = SimpleForm("wizard")
f.reset = false
f.template = "gluon-config-mode/cbi/wizard"

for _, s in ipairs(wizard) do
  s.section(f)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    for _, s in ipairs(wizard) do
      s.handle(data)
    end

    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode", "reboot"))
  end

  return true
end

return f
