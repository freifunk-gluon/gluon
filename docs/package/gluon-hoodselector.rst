gluon-hoodselector
==================

This package provides an automatism of selecting the right hood network in an
intelligent way. This hood bases on geostationary fixed quadrants for
batman-adv mesh networks. The Hoodselector makes it possible to build scaled
decentralised mesh-networks.

Background informations
-----------------------

The main problem of the Nordwest Freifunk community was the fast increasing of
amount of nodes in the network. This affected indirectly the stability of the
network because also the noise inside the network e.g. management traffic from
the batman-adv protocoll was increasing. Inside the community there were some
ideas like to build seperated firmwares for each region. Kind of idea
will have problems in resplitting regions again or even problems of scattered
nodes, which belongs to an another region. Therefore we decide to develop an
dynamic and decentralized management of kind of region called hoods.
The Hoodselectors task is to choose belonged hoods in an inteligent way and
ensure to hold the network together and accessible.

A hood is defined by geostationary fixed shapes by using longitude & latitude
in combination with the domain configuration system. Below you can see a visual
example of regional hoods:

.. image:: hoodmap.jpeg

Hoodselector logic
------------------

In following there is an abstract state diagramm which should give an overview
of the process:

.. image:: gluon-hoodselector.svg

The sequence of this diagramm is given the priorty of running modes.
Each mode will be explained seperatedly below.

VPN-MODE
^^^^^^^^

This mode will be only entered if a router can see batman-adv Gateways over VPN.
Means only routers which have a vpn connection to supernodes will enter and set
the hood base on their position if they have one. If a node has a position
which is outside of all definded shapes, it will set the default hood. If no
position exists, the node will continue with the next mode. This mode will be
entered at first. The reason is because the Hoodselector takes
care of holding nodes arround supernodes e.g. to ensure that nodes can always
reach at least the autoupdate server.

Hood
----

A hood bases on the related domain configuration with some additional
configurations. There are two types of hoods: one without any defined shapes
which has to be unique and other which contains shapes.

* **default hood**

defaulthood: The default hood doesn’t have shapes and is the inverted form of
all other hoods with geo coordinates. It will be entered if no node match to a
real hood. In the Nordwest Freifunk situation we defined the old network as
default hood and continuously migrated parts from there to shape defined hoods
named "real hood"

* **real hood**

A real hood contains shapes, which are described by three dimensional array and
represents the geographical size of the real hood. There are 2 possible
definitions of those shapes. The first one are rectangulars definded which
means just two points per box are needed to reconstruct it.
(see below for an example). The second one are normal polygons which can have
multible edges. Each real hood can have multible defined shapes.

.. image:: rectangle-example.svg

site.conf
---------

The designer of the shapes should always ensure that no overleaping poligons
will be created!
Here is an example of a rectangular definition of a shape:
Example::

  hoodselector = {
    shapes = {
      {
        {
          lat = 53.128,
          lon = 8.187
        },
        {
          lat = 53.163,
          lon = 8.216
        },
      },
    },
  },

Here in an example of a Trigon polygon defined shape:
Example::

  hoodselector = {
    shapes = {
      {
        {
          lat = 53.128,
          lon = 8.187
        },
        {
          lat = 53.163,
          lon = 8.216
        },
        {
          lat = 53.196,
          lon = 8.194
        },
      },
    },
  },

This package is not compatible with the :doc:`gluon-config-mode-domain-select`.
