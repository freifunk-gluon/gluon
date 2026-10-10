OLSRD
===========

Gluon supports olsrd (OLSR version 1), which runs one daemon per address
family:

- ``olsrd`` for IPv4, started when the site sets ``prefix4``
- ``olsrd6`` for IPv6, started when the site sets ``prefix6``

There is nothing to enable, the prefixes of the site (or domain) decide
which daemons run.

Configuration
-------------

The LAN will automatically be determined by the specified prefix and prefix6

Both daemons are configured by Gluon, the site configuration can add to (and
override) that configuration per address family.

.. code-block:: lua

    {
      mesh = {
        olsrd = {
          v4 = {
            -- Additional olsrd configuration for IPv4
            -- config = {
            --   DebugLevel = 0,
            --   AllowNoInt = 'yes',
            -- },
          },
          v6 = {
            -- Additional olsrd configuration for IPv6
            -- config = {
            -- },
          },
        },
      },
    }
