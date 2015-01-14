Announcing Node Information
===========================

Gluon is capable of announcing information about each node to the mesh
and to neighbouring nodes. This allows nodes to learn each others hostname,
IP addresses, location, software versions and various other information.

Format of collected data
------------------------

Information to be announced is currently split into two categories:

  nodeinfo
    In this category (mostly) static information is collected. If
    something is unlikely to change without human intervention it should be
    put here.

  statistics
    This category holds fast changing data, like traffic counters, uptime,
    system load or the selected gateway.

Both categories will have a ``node_id`` key by default. It should be used to
match data from *statistics* to *nodeinfo*.

Accessing Node Information
--------------------------

There are two packages responsible for distribution of the information. For
one, information is distributed across the mesh using alfred_. Information
between neighbouring nodes is exchanged using `gluon-announced`.

.. _alfred: http://www.open-mesh.org/projects/alfred

alfred (mesh bound)
~~~~~~~~~~~~~~~~~~~

The package ``gluon-alfred`` is required for this to work.

Using alfred both categories are distributed within the mesh. In order to
retrieve the data you'll need both a local alfred daemon and alfred-json_
installed. Please note that at least one alfred daemon is required to run as
`master`.

.. _alfred-json: https://github.com/tcatm/alfred-json

`nodeinfo` is distributed as alfred datatype `158`, while `statistics` uses
`159`. Both are compressed using GZip (alfred-json can handle the decompression).

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

gluon-announced
~~~~~~~~~~~~~~~

`gluon-announced` allows querying neighbouring nodes for their `nodeinfo`.
It is a daemon listening on the multicast address ``ff02::2:1001`` on
UDP port 1001 on the bare mesh interfaces.

gluon-neighbour-info
~~~~~~~~~~~~~~~~~~~~

A programm called `gluon-neighbour-info` has been developed to retrieve
information from neighbours.

::

  gluon-neighbour-info -i wlan0 \
  -p 1001 -d ff02:0:0:0:0:0:2:1001 \
  -r nodeinfo

On optional timeout may be specified, e.g. `-t 5` (default: 3 seconds).

Adding a fact
-------------

To add a fact just add a file to either ``/lib/gluon/announce/nodeinfo.d/`` or
``/lib/gluon/announce/statistics.d/``.

The file must contain a lua script and its name will become the key for the
resulting JSON object. A simple script adding a ``hostname`` field might look
like this:

::

  return uci:get_first('system', 'system', 'hostname')

The directory structure will be converted to a JSON object, i.e. you may
create subdirectories. So, if the directories look like this

::

  .
  ├── hardware
  │   └── model
  ├── hostname
  ├── network
  │   └── mac
  ├── node_id
  └── software
      └── firmware

the resulting JSON would become:

::

  # /lib/gluon/announce/announce.lua nodeinfo
  {
     "hardware" : {
        "model" : "TP-Link TL-MR3420 v1"
     },
     "hostname" : "mr3420-test",
     "network" : {
        "mac" : "90:f6:52:82:06:02"
     },
     "node_id" : "90f652820602",
     "software" : {
        "firmware" : {
           "base" : "gluon-v2014.2-32-ge831099",
           "release" : "0.4.1+0-exp20140720"
        }
     }
  }
