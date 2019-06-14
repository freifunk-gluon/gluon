gluon-offline-ssid
==================

This package adds a script to change the SSID when there is no connection to any
gateway. This Offline-SSID can be generated from the node's hostname with the
first and last part of the node name or the MAC address allowing observers to
recognize which node does not have a connection to a gateway. This script is
called once every minute by ``micrond`` and check gateway-connectivity. It will
change the SSID to the Offline-SSID after the node lost gateway connectivity for
several consecutive checks. As soon as the gateway-connectivity is back it
toggles back to the original SSID.

You can enable/disable it in the config mode.

It checks if a gateway is reachable in an interval. Different algorithms can be
selected to determine whether a gateway is reachable:

-  ``tq_limit_enabled=true``: (not working with BATMAN\_V) define an upper and
   lower bound to toggle the SSID. As long as the TQ stays in-between those
   bounds the SSID will not be changed.
-  ``tq_limit_enabled=false``: there will be only checked, if the gateway is
   reachable with:

   ::

       batctl gwl -H

The SSID is always changed back to normal every minute as soon as the
gateway-connectivity is back, The parameter ``switch_timeframe`` defines how
long it will record the gateway-connectivity. **Only** if the gateway is not
reachable during at least half the checks within ``switch_timeframe`` minutes,
the SSID will be changed to "FF\_Offline\_$node\_hostname".

The parameter ``first`` defines a learning phase after reboot (in minutes)
during which the SSID may be changed to the Offline-SSID **every minute**.

site.conf
=========

Adapt and add this block to your ``site.conf``:

::

    offline_ssid = {
      disabled = false,
      switch_timeframe = 30,    -- only once every timeframe (in minutes) the SSID will change to the Offline-SSID 
                                -- set to 1440 to change once a day
                                -- set to 1 minute to change every time the router gets offline
      first = 5,                -- the first few minutes directly after reboot within which an Offline-SSID may be
                                -- activated every minute (must be <= switch_timeframe)
      prefix = 'Offline_',   -- use something short to leave space for the nodename (no '~' allowed!)
      suffix = 'nodename',      -- generate the SSID with either 'nodename', 'mac' or to use only the prefix: 'none'
      
      tq_limit_enabled = false, -- if false, the offline SSID will only be set if there is no gateway reacheable
                                -- upper and lower limit to turn the offline_ssid on and off
                                -- in-between these two values the SSID will never be changed to prevent it from
                                -- toggeling every minute.
      tq_limit_max = 45,        -- upper limit, above that the online SSID will be used
      tq_limit_min = 35         -- lower limit, below that the offline SSID will be used
    },

Commandline options
===================

You can configure the offline-ssid on the commandline with ``uci``, for example
disable it with:

::

    uci set gluon-offline-ssid.settings.disabled='1'

Or set the timeframe to every three minutes with

::

    uci set gluon-offline-ssid.settings.switch_timeframe='3'
    uci set gluon-offline-ssid.settings.first='3'
