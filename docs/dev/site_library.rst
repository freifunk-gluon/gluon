gluon.site library
==================

The *gluon.site* library allows convenient access to the site configuration
from Lua scripts. Example:

.. code-block:: lua

  local site = require 'gluon.site'
  print(site.wifi24.ap.ssid())

The *site* object in this example does not directly represent the *site.conf* data structure;
instead, it is wrapped in a way that makes it more convenient to access deeply nested elements.
To access the underlying values, they must be unwrapped using the function call notation
(the ``()`` after ``site.wifi24.ap.ssid`` in the example).

The wrapper objects have two advantages over simple Lua tables:

* Accessing non-existing values is never an error: ``site.wifi24.ap.ssid()`` will simply
  return *nil* if ``site.wifi24`` or ``site.wifi24.ap`` do not exist
* Default values: A default value can be passed to the unwrapping function call:

  .. code-block:: lua

    print(site.wifi24.ap.ssid('Default'))

  will return *'Default'* instead of *nil* when the value is unset.

  Note that *nil* values and unset values are equivalent in Lua.

A simple way to access the whole site configuration as a simple table
is to unwrap the top-level site object:

.. code-block:: lua

  local site_table = site()
