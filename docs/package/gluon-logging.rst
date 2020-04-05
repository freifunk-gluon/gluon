gluon-logging
=============

The *gluon-logging* package allows to configure a remote syslog server that
will receive the systems log output that is also visible when calling ``logread``
from a terminal.

It supports both IPv4 and IPv6 endpoints over UDP and TCP.

Note: The syslog mechanism is incapable of providing a complete log as network
access is required to send out log messages and ``logd`` does not buffer and resend
older log messages even though they might be available in ``logread``.

This package conflicts with ``gluon-web-logging`` as it will overwrite the
user-given syslog server on every upgrade.

site.conf
---------

syslog.ip : required
    - Destination address of the remote syslog server

syslog.port : optional
    - Destination port of the remote syslog server
    - Defaults to 514

syslog.proto : optional
    - Protocol to transport syslog frames in, can be either ``tcp`` or ``udp``
    - Defaults to UDP

Example::

  syslog = {
    ip = "2001:db8::1",
    port = 514,
    proto = "udp",
  },
