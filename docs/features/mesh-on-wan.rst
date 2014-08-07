Mesh on WAN
===========

It's possible to enable the mesh on the WAN port like this::

  uci set network.mesh_wan.auto=1
  uci commit

It may also be disabled again by running::

  uci set network.mesh_wan.auto=0
  uci commit

site.conf
---------

The optional option ``mesh_on_wan`` may be set to ``true`` (``false`` is the
default) to enable meshing on the WAN port without further configuration.
