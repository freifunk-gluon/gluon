Node monitoring
===============

Gluon is capable of announcing information about each node to the mesh
and to neighbouring nodes. This allows nodes to learn each others hostname,
IP addresses, location, software versions and various other information.

Format of collected data
------------------------

Information to be announced is currently split into three categories:

  nodeinfo
    In this category (mostly) static information is collected. If
    something is unlikely to change without human intervention it should be
    put here.

  statistics
    This category holds fast changing data, like traffic counters, uptime,
    system load or the selected gateway.

  neighbours
    `neighbours` contains information about all neighbouring nodes of all
    interfaces. This data can be used to determine the network topology.

All categories will have a ``node_id`` key. It should be used to
relate data of different catagories.

Accessing Node Information
--------------------------

There are two packages responsible for distribution of the information. For
one, information is distributed across the mesh using alfred_. Information
between neighbouring nodes is exchanged using `gluon-respondd`.

.. _alfred: http://www.open-mesh.org/projects/alfred

alfred (mesh bound)
~~~~~~~~~~~~~~~~~~~

The package ``gluon-alfred`` is required for this to work.

Using alfred both categories are distributed within the mesh. In order to
retrieve the data you'll need both a local alfred daemon and alfred-json_
installed. Please note that at least one alfred daemon is required to run as
`master`.

.. _alfred-json: https://github.com/tcatm/alfred-json

The following datatypes are used:

* `nodeinfo`: 158
* `statistics`: 159
* `neighbours`: 160

All data is compressed using GZip (alfred-json can handle the decompression).

In order to retrieve statistics data you could run:

::

  # alfred-json -z -r 159
  {
    "f8:d1:11:7e:97:dc": {
      "processes": {
        "total": 55,
        "running": 2
      },
      "idletime": 30632.290000000001,
      "uptime": 33200.07,
      "memory": {
        "free": 1660,
        "cached": 8268,
        "total": 29212,
        "buffers": 2236
      },
      "node_id": "f8d1117e97dc",
      "loadavg": 0.01
    },
    "90:f6:52:3e:b9:50": {
      "processes": {
        "total": 58,
        "running": 2
      },
      "idletime": 28047.470000000001,
      "uptime": 33307.849999999999,
      "memory": {
        "free": 2364,
        "cached": 7168,
        "total": 29212,
        "buffers": 1952
      },
      "node_id": "90f6523eb950",
      "loadavg": 0.34000000000000002
    }
  }

You can find more information about alfred in its README_.

.. _README: http://www.open-mesh.org/projects/alfred/repository/revisions/master/entry/README

gluon-respondd
~~~~~~~~~~~~~~

`gluon-respondd` allows querying neighbouring nodes for their information.
It is a daemon listening on the multicast address ``ff02::2:1001`` on
UDP port 1001 on both the bare mesh interfaces and `br-client`. Unicast
requests are supported as well.

The supported requests are:

* ``nodeinfo``, ``statistics``, ``neighbours``: Returns the data of single category uncompressed.
* ``GET nodeinfo``, ...: Returns the data of one or multiple categories (separated by spaces)
  compressed using the `deflate` algorithm (without a gzip header). The data may
  be decompressed using zlib and many zlib bindings using -15 as the window size parameter.

gluon-neighbour-info
~~~~~~~~~~~~~~~~~~~~

The programm `gluon-neighbour-info` can be used to retrieve
information from other nodes.

::

  gluon-neighbour-info -i wlan0 \
  -p 1001 -d ff02:0:0:0:0:0:2:1001 \
  -r nodeinfo

An optional timeout may be specified, e.g. `-t 5` (default: 3 seconds). See
the usage information printed by ``gluon-neighbour-info -h`` for more information
about the supported arguments.

Adding a data provider
----------------------

To add a provider, you need to install a shared object into ``/lib/gluon/respondd``.
For more information, refer to the `respondd README <https://github.com/freifunk-gluon/packages/blob/master/net/respondd/README.md>`_
and have a look the existing providers.
