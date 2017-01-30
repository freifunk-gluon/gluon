Roles
=====

It is possible to define a set of roles you want to distinguish at backend side. One node can own one
role which it will announce via alfred inside the mesh. This will make it easier to differentiate
nodes when parsing alfred data. E.g to count only **normal** nodes and not the gateways
or servers (nodemap). A lot of things are possible.

For this the section ``roles`` in ``site.conf`` is needed::

  roles = {
    default = 'node',
    list = {
      'node',
      'test',
      'backbone',
      'service',
    },
  },

The strings to display in the LuCI interface are configured per language in the
``i18n/en.po``, ``i18n/de.po``, etc. files of the site repository using message IDs like
``gluon-luci-node-role:role:node`` and ``gluon-luci-node-role:role:backbone``.

The value of ``default`` is the role every node will initially own. This value should be part of ``list`` as well.
If you want node owners to change the defined roles via config-mode you can add the package
``gluon-luci-node-role`` to your ``site.mk``.

The role is saved in ``gluon-node-info.system.role``. To change the role using command line do::

  uci set gluon-node-info.system.role="$ROLE"
  uci commit

Please replace ``$ROLE`` by the role you want the node to own.
