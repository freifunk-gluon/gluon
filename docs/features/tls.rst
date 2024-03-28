TLS support
===========

The generic TLS implementation which is currently used by OpenWRT can be installed or added as dependency through the package ``gluon-tls``.
This removes the need for community packages to depend on a specific TLS implementation (like mbedtls, OpenSSL or WolfSSL).

This package is an alias for the current TLS implementation used.
To allow for easy usage of communicating through HTTPS from the node, typical Certificate Authorities (CAs) are included through the package ``ca-bundle`` .

* Starting with OpenWRT 23.05, mbedtls is the default TLS layer - this is reflected in Gluon :ref:`v2023.2 <releases-v2023.2-minor-changes>`. HTTPS is used by default to communicate with OpenWRT opkg servers.
