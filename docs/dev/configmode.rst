Config Mode
===========

As of 2014.4 `gluon-config-mode` consists of several modules.

gluon-config-mode-core
    This modules provides the core functionality for the config mode.
    All modules must depend on it.

gluon-config-mode-hostname
    Provides a hostname field.

gluon-config-mode-autoupdater
    Informs whether the autoupdater is enabled.

gluon-config-mode-mesh-vpn
    Allows toggling of mesh-vpn-fastd and setting a bandwidth limit.

gluon-config-mode-geo-location
    Enables the user to set the geographical location of the node.

gluon-config-mode-contact-info
    Adds a field where the user can provide contact information.

In order to get a config mode close to the one found in 2014.3.x you may add
these modules to your `site.mk`:
gluon-config-mode-hostname,
gluon-config-mode-autoupdater,
gluon-config-mode-mesh-vpn,
gluon-config-mode-geo-location,
gluon-config-mode-contact-info

Writing Config Mode Modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Config mode modules are located at `/lib/gluon/config-mode/wizard` and
`/lib/gluon/config-mode/reboot`. Modules are named like `0000-name.lua` and
are executed in lexical order. If you take the standard set of modules, the
order is, for wizard modules:

  - 0050-autoupdater-info
  - 0100-hostname
  - 0300-mesh-vpn
  - 0400-geo-location
  - 0500-contact-info

While for reboot modules it is:

  - 0100-mesh-vpn
  - 0900-msg-reboot

Wizards
-------

Wizard modules return a UCI section. A simple module capable of changing the
hostname might look like this::

  local cbi = require "luci.cbi"
  local uci = luci.model.uci.cursor()

  local M = {}

  function M.section(form)
    local s = form:section(cbi.SimpleSection, nil, nil)
    local o = s:option(cbi.Value, "_hostname", "Hostname")
    o.value = uci:get_first("system", "system", "hostname")
    o.rmempty = false
    o.datatype = "hostname"
  end

  function M.handle(data)
    uci:set("system", uci:get_first("system", "system"), "hostname", data._hostname)
    uci:save("system")
    uci:commit("system")
  end

  return M

Reboot page
-----------

Reboot modules return a function that will be called when the page is to be
rendered or nil (i.e. the module is skipped)::

  if no_hello_world_today then
    return nil
  else
    return function ()
      luci.template.render_string("Hello World!")
    end
  end

