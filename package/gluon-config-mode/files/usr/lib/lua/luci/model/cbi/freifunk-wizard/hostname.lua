local uci = luci.model.uci.cursor()

local nav = require "luci.tools.freifunk-wizard.nav"

local f = SimpleForm("hostname", "Name deines Freifunkknotens", "Als nächstes solltest du einem Freifunkknoten einen individuellen Namen geben. Dieser hilft dir und auch uns den Überblick zu behalten.")
f.template = "freifunk-wizard/wizardform"

hostname = f:field(Value, "hostname", "Hostname")
hostname.value = uci:get_first("system", "system", "hostname")
hostname.rmempty = false

function hostname.validate(self, value, section)
  return value
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = true
    uci:foreach("system", "system", function(s)
        stat = stat and uci:set("system", s[".name"], "hostname", data.hostname)
      end
    )

    stat = stat and uci:save("system")
    stat = stat and uci:commit("system")

    if stat then
      nav.maybe_redirect_to_successor()
            f.message = "Hostname geändert!"
    else
      f.errmessage = "Fehler!"
    end
  end

  return true
end

return f
