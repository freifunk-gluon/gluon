gluon-hoodselector
==================

This package provides an automatism of selecting the right domain network in an
intelligent way. The job of the hoodselector is to automatically detect in which
domain the node is located by its geolocation settings. Therefore the domains
needs to have geostationary fixed quadrants defined as polygons or rectangles.
Based on this information the hoodselector will select a domain from a list of
known domains and adjust the domain related settings e.g. VPN, wireless ...
This package makes able to build scaled decentralised mesh-networks in a dynamical
and easy extendable way.

Background informations
-----------------------

The main problem of the Nordwest Freifunk community was the quickly rising
number of nodes in the network. This indirectly affected the stability of the
network because the noise inside the network, e.g. management traffic from
the batman-adv protocol, was rising, too. Inside the community there were some
ideas like building separate firmwares for each region. This kind of solution
would have problems with splitting regions again and problems with scattered
nodes, which belong to an other region. Therefore we decided to develop a
dynamic and decentralised management of regions called domains.
The Hoodselector's task is to choose the "right" domains in an intelligent way
and to hold the network together and accessible.

A domain is defined by geostationary fixed shapes by using longitude & latitude
in combination with the domain configuration system. Below you can see a visual
example of regional domain:

.. image:: hoodmap.jpeg

Hoodselector logic
------------------

The following is an abstract state diagramm which gives an overview
of the process:

.. image:: gluon-hoodselector.svg

The sequence of this diagramm is given the priority of running modes.
Each mode will be explained seperatedly below.

geolocation mode
^^^^^^^^^^^^^^^^

This mode will be entered only if a node have set a geo location.
Nodes which have a position will set their domain based on
it. If a node has a position which is outside of all defined shapes,
it will continue with the next mode. If no position is set,
the node will continue with the next mode too.

default domain mode
^^^^^^^^^^^^^^^^^^^

This mode will be entered if no other modes before fits.
It will simply set the default domain.

Domain shapes
-------------

There are two types of domainss: one without any defined shapes
which has to be unique and others which contain shapes.

* **default domain**

default domain: The default domain doesn’t have shapes and is the inverted form of
all other domains with geo coordinates. It will be entered if no node matches to a
real domain. A suggested approach is to define the "old" network as default domain
and gradually migrate parts from there to shape defined domains ("real domain").

* **real domains**

A real domain contains shapes, which are described by three dimensional arrays and
represents the geographical size of the domain. There are two possible
definitions of these shapes. The first one is using rectangulars so that only
two coordinates per box are needed to reconstruct it (see below for an example).
The second one is using polygons which can have multible edges.
Each domain can have multiple defined shapes.

.. image:: rectangle-example.svg

site.conf
---------

The designer of the shapes should always ensure that no overlapping polygons
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

Here is an example of a triangle defined shape:
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

This package is incompatible with the :doc:`gluon-config-mode-domain-select`.
