Config Mode
===========

The `Config Mode` consists of several modules that provide a range of different
configuration options:

gluon-config-mode-core
    This modules provides the core functionality for the config mode.
    All modules must depend on it.

gluon-config-mode-hostname
    Provides a hostname field.

:doc:`gluon-config-mode-autoupdater <../../features/autoupdater>`
    Informs whether the autoupdater is enabled.

:doc:`gluon-config-mode-mesh-vpn <../../features/vpn>`
    Allows toggling of installed mesh-vpn technology and setting a bandwidth limit.

gluon-config-mode-geo-location
    Enables the user to set the geographical location of the node.

:doc:`../../package/gluon-config-mode-geo-location-osm`
    Lets the user click on a map to select the geographical location through a OSM map

gluon-config-mode-contact-info
    Adds a field where the user can provide contact information.

:doc:`../../package/gluon-web-cellular`
    Adds advanced options to enter WWAN config.

:doc:`../../package/gluon-web-network`
    Adds option to configure used role on interfaces

Most of the configuration options are described in :ref:`user-site-config_mode`

Writing Config Mode modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Config mode modules are located at ``/lib/gluon/config-mode/wizard`` and
``/lib/gluon/config-mode/reboot``. Modules are named like ``0000-name.lua`` and
are executed in lexical order. In the standard package set, the
order is, for wizard modules:

  - 0050-autoupdater-info
  - 0100-hostname
  - 0300-mesh-vpn
  - 0400-geo-location
  - 0500-contact-info

The reboot module order is:

  - 0100-mesh-vpn
  - 0900-msg-reboot

All modules are run in the gluon-web model context and have access to the same
variables as "full" gluon-web modules.

Wizards
-------

Wizard modules must return a function that is provided with the wizard form and an
UCI cursor. The function can create configuration sections in the form:

.. code-block:: lua

  return function(form, uci)
    local s = form:section(Section)
    local o = s:option(Value, "hostname", "Hostname")
    o.default = uci:get_first("system", "system", "hostname")
    o.datatype = "hostname"

    function o:write(data)
      uci:set("system", uci:get_first("system", "system"), "hostname", data)
    end

    return {'system'}
  end

The function may return a table of UCI packages to commit after the individual
fields' `write` methods have been executed. This is done to avoid committing the
packages repeatedly when multiple wizard modules modify the same package.

Reboot page
-----------

Reboot modules are simply executed when the reboot page is
rendered:

.. code-block:: lua

  renderer.render_string("Hello World!")
