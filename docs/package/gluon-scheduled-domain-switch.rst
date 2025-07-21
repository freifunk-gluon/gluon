gluon-scheduled-domain-switch
=============================

This package allows to switch a routers domain at a given point
in time. This is needed for switching between incompatible transport
protocols (e.g. wired meshing with and without VXLAN).

Nodes will switch when the defined *switch-time* has passed. In case the node was
powered off while this was supposed to happen, it might not be able to acquire the
correct time. In this case, the node will switch after it has not seen any gateway
for a given period of time.

In older versions ping was used against an array of endpoints to determine mesh-connectivity.
Nowadays *gluon-state-check* is used for this and evaluates mesh-(VPN) connectivity and NTP states.

site.conf
---------
All those settings have to be defined exclusively in the domain, not the site.

domain_switch : optional (needed for domains to switch)
  target_domain :
    - target domain to switch to
  switch_after_offline_mins :
    - amount of time without reachable gateway to switch unconditionally
  switch_time :
    - UNIX epoch after which domain will be switched

Example::

  domain_switch = {
    target_domain = 'new_domain',
    switch_after_offline_mins = 120,
    switch_time = 1546344000, -- 01.01.2019 - 12:00 UTC
  },
