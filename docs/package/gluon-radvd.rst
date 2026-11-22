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
providing such arguments in order to announce default routes for Layer 3 meshes,
while only announcing prefixes for Layer 2 meshes.

site.conf
---------

radvd.preferred_lifetime : optional
    - the span of time during which the address can be freely used as a source
      and destination for traffic. Should be less or equal valid-lifetime.
    - defaults to ``14400`` seconds => 4h
radvd.valid_lifetime : optional
    - the total time the prefix remains available before becoming unusable
    - defaults to ``86400`` seconds => one day

radvd.default_lifetime : optional
    - the router lifetime in seconds. A value greater than ``0`` makes the node
      announce itself as a default router; ``0`` means it is not a default router.
      Allowed range is ``0`` to ``65535`` (RFC 4861, updated by RFC 8319); a
      non-zero value must be at least ``max_interval``.
    - if unset, the packages providing the arguments decide: ``0`` for Layer 2
      meshes, ``900`` for Layer 3 meshes
radvd.min_interval, radvd.max_interval : optional
    - minimum and maximum time in seconds between unsolicited router
      advertisements. Both must be given together. ``max_interval`` must be in
      the range ``4`` to ``1800``, ``min_interval`` in the range ``3`` to ``1350``
      and at most ``0.75 * max_interval`` (as enforced by ``uradvd``).
    - defaults to ``200`` and ``600`` seconds

To be treated as a default router reliably, choose a router lifetime that spans
several advertisements, for example ``default_lifetime = 180`` together with
``min_interval = 20`` and ``max_interval = 50``.

Example::

  radvd = {
    preferred_lifetime = 120,
    valid_lifetime = 180,
    default_lifetime = 180,
    min_interval = 20,
    max_interval = 50,
  },
