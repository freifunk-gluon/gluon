Integration tests
=================

Gluon ships a rig that boots real firmware images as QEMU guests, wires
them into a mesh and drives them over SSH.

A test declares the mesh it wants, calls ``start()``, states what the
mesh should do, and calls ``finish()``:

.. code-block:: python

  #!/usr/bin/env python3
  """Two directly connected nodes see each other and can ping."""
  from pynet import start, finish
  from meshlib import pair, wait_neighbours, wait_connected, ping

  a, b = pair()

  start()

  wait_neighbours(a, 1)
  wait_connected(a, b)
  ping(a, b)

  finish()

Nothing in that names a routing protocol, interface or site config, so
the same test runs against every image the rig can boot.

Where tests live
----------------

A test belongs to the package it exercises, in a ``tests/`` directory
marked with a ``.gluon_tests`` file::

  package/gluon-core/tests/.gluon_tests
  package/gluon-core/tests/connect_two.py
  package/gluon-respondd/tests/test_respondd.py

Both Gluon's own ``package/`` tree and every checked-out feed under
``packages/`` are scanned, so a package feed pulled in through
``GLUON_SITE_FEEDS`` can ship tests the same way. The marker is what
distinguishes them from the unrelated ``tests/`` directories some
upstream packages ship.

A test runs when its own package is installed on the image. If it needs
more than that, it says so in a header:

.. code-block:: python

  # requires: gluon-mesh-batman-adv

An entry may name alternatives, ``new-name|old-name``, which keeps a
test satisfiable across a package rename. Naming the owning package
there replaces the implicit requirement on it.

The runner reads the installed package list from ``<image>.packages``
beside the image, booting one node to produce it when that file is
missing or older than the image. The image decides which tests apply.

Running them
------------

.. code-block:: sh

  cd tests
  pip install -r requirements.txt
  sudo ./run.py --image ../output/images/factory/gluon-*-x86-64.img.gz
  sudo ./run.py connect_two firewall_packets   # named tests only

``--image`` takes a ``.img`` or a ``.img.gz``; a gzipped image is
unpacked beside the archive and reused until the archive changes.
``--all`` skips the probe and runs everything, and ``-j`` sets how many
tests run at once (two by default).

Root is needed for the tests that attach clients, which use network
namespaces and taps; ``tcpdump`` and ``scapy`` are needed for the
firewall packet test. Each test gets ``tests/run/<test>/``, holding its
output in ``test.log`` and the node consoles under ``logs/``. A failing
test's output is printed as well.

Images are built per site config, which is what selects the routing
protocol; ``contrib/ci/minimal-site`` builds a batman-adv one.

Writing a test
--------------

Two modules make up the API. :mod:`meshlib` states things in terms of
the mesh and detects the routing protocol on the running nodes, so a
test written against it works on any site config. :mod:`pynet` is the
layer underneath, for running a specific command on a specific node.

meshlib
^^^^^^^

.. automodule:: meshlib
  :members:

pynet
^^^^^

.. currentmodule:: pynet

.. autoclass:: Node
  :members: add_mesh_link, uci_set, set_domain, execute, execute_in_background,
            succeed, wait_until_succeeds

.. autofunction:: connect

.. autofunction:: start

.. autofunction:: finish
