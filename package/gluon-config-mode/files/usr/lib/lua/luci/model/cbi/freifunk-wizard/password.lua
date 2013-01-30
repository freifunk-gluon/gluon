local nav = require "luci.tools.freifunk-wizard.nav"

f = SimpleForm("password", "Administrator-Passwort setzen", "<p>Damit nur du Zugriff auf deinen Freifunkknoten hast, solltest du jetzt ein Passwort vergeben. \
Da man mit Hilfe von diesem beliebige Einstellungen geändert werden können, sollte es möglichst sicher sein.</p>\
<p>Bitte beachte dazu folgende Hinweise:</p>\
<ul>\
  <li>Es sollte in keinem Wörterbuch vorkommen.</li>\
  <li>Es sollte mehr als acht Zeichen beinhalten.</li>\
  <li>Es sollte auch Zahlen &amp; Sonderzeichen enthalten.</li>\
</ul>")
f.template = "freifunk-wizard/wizardform"

pw1 = f:field(Value, "pw1", "Passwort")
pw1.password = true
pw1.rmempty = false

pw2 = f:field(Value, "pw2", "Wiederholung")
pw2.password = true
pw2.rmempty = false

function pw2.validate(self, value, section)
  return pw1:formvalue(section) == value and value
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local stat = luci.sys.user.setpasswd("root", data.pw1) == 0

    if stat then
            nav.maybe_redirect_to_successor()
            f.message = "Passwort geändert!"
    else
      f.errmessage = "Fehler!"
    end

    data.pw1 = nil
    data.pw2 = nil
  end

  return true
end

return f
