Feature flags
=============

Feature flags provide a convenient way to define package selections without
making it necessary to list each package explicitly.

The main feature flag definition file is ``package/features``, but each package
feed can provide additional defintions in a file called ``features`` at the root
of the feed repository.

Each flag *$flag* without any explicit definition will simply include the package
with the name *gluon-$flag* by default. The feature definition file can modify
the package selection in two ways:

* The *nodefault* function suppresses default of including the *gluon-$flag*
  package
* The *packages* function adds a list of packages (or removes, when package
  names are prepended with minus signs) when a given logical expression
  is satisfied

Example::

    nodefault 'web-wizard'

    packages 'web-wizard' \
      'gluon-config-mode-hostname' \
      'gluon-config-mode-geo-location' \
      'gluon-config-mode-contact-info'

    packages 'web-wizard & (mesh-vpn-fastd | mesh-vpn-tunneldigger)' \
      'gluon-config-mode-mesh-vpn'

This will

* Disable the inclusion of a (non-existent) package called *gluon-web-wizard*
* Enable three config mode packages when the *web-wizard* feature is enabled
* Enable *gluon-config-mode-mesh-vpn* when both *web-wizard* and one
  of *mesh-vpn-fastd* and *mesh-vpn-tunneldigger* are enabled

Supported syntax elements of logical expressions are:

* \& (and)
* \| (or)
* \! (not)
* parentheses
