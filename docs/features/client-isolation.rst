Client Isolation Support
========================

Normally every client is a wireless network can communicate
with any other client in the network.
Client Isolation is a security feature which prevents
Client-to-Client communication.

There are two different modes to isolate traffic, which can be
selected by the ``mesh.isolate`` setting in the site or domain
configuration.

Full Client Isolation Mode
--------------------------

In the full isolation mode all traffic between wireless and
wired clients is prevented. The Clients are only able to access
the Gateway and the Internet.

This mode may not be very useful in a Freifunk context.

It can be activated by setting ``mesh.isolate`` to ``all`` in the
site or domain configuration.

::

  {
    mesh = {
      isolate = 'all'
    },

    -- more domain specific config follows below
  }

Wireless Client Isolation Mode
------------------------------

In the wireless isolation mode only wireless clients are isolated
from other wireless clients. Communication where a wired client is
involved is not prevented. So every client can access any wired
client and every wired client can access all of the clients, only
wireless clients can not access other wireless clients.

This mode may be more useful in a Freifunk context, but is still
not as ``frei`` as without any isolation.

It can be activated by setting ``mesh.isolate`` to ``wireless``
in the site or domain configuration.

::

  {
    mesh = {
      isolate = 'wireless'
    },

    -- more domain specific config follows below
  }
