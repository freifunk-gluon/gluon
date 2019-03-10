gluon-config-mode-domain-select
===============================
This package provides a drop-down list for the config mode to select the domain
the node will be placed in. If the selection has changed the upgrade scripts in
``/lib/gluon/upgrade/`` are triggered to update the nodes configuration.

Hiding domains could be useful for default or testing domains, which should not
be accidentally selected by a node operator.

domains/\*.conf
---------------

hide_domain \: optional (defaults to false)
    - ``false`` shows this domain in drop-down list
    - ``true`` hides this domain

Example::

  hide_domain = true
