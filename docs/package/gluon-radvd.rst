gluon-radvd
===========

This package provides service files and configuration endpoints for the IPv6
router advertisement daemon.

Arguments
---------

This package provides skeleton service files for ``uradvd``.
It requires another package to provide the arguments ``uradvd`` is supposed to
be launched with.

:doc:`gluon-mesh-batman-adv` and ``gluon-mesh-layer3-common`` are two packages
providing such arguments.

This allows to have ``uradvd`` announce default routes for layer three meshes,
while only announcing prefixes for layer two meshes.

site.conf
---------

uradvd.preferred_lifetime : optional
    - the span of time during which the address can be freely used as a source
      and destination for traffic. Should be less or equal valid-lifetime.
    - defaults to ``14400`` seconds => 4h
uradvd.valid_lifetime : optional
    - the total time the prefix remains available before becoming unusable
    - defaults to ``86400`` seconds => one day

Example::

  uradvd = {
    preferred_lifetime = 150,
    valid_lifetime = 300,
  },
