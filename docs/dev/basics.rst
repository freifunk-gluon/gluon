Development Basics
==================

Gluon's source is kept in `git repositories`_ at GitHub.

.. _git repositories: https://github.com/freifunk-gluon

Bug Tracker
-----------

The `main repo`_ does have issues enabled. 

.. _main repo: https://github.com/freifunk-gluon/gluon

IRC
---

Gluon's developers frequent `#gluon on hackint`_. You're welcome to join us!

.. _#gluon on hackint: irc://irc.hackint.org/#gluon


Working with repositories
-------------------------

To update the repositories used by Gluon, just adjust the commit IDs in `modules` and
rerun

::

  make update

`make update` also applies the patches that can be found in the directories found in
`patches`; the resulting branch will be called `patched`, while the commit specified in `modules`
can be refered to by the branch `base`.

After new patches have been commited on top of the `patched` branch (or existing commits
since the base commit have been edited or removed), the patch directories can be regenerated
using

::

  make update-patches

If applying a patch fails because you have changed the base commit, the repository will be reset to the old `patched` branch
and you can try rebasing it onto the new `base` branch yourself and after that call `make update-patches` to fix the problem.

Always call `make update-patches` after making changes to a module repository as `make update` will overwrite your
commits, making `git reflog` the only way to recover them!

Development Guidelines
----------------------

lua should be used instead of sh whenever sensible. The following criteria
should be considered:

- Is the script doing more than just executing external commands? if so, use lua
- Is the script parsing/editing json-data? If so, use lua for speed
- When using sh, use jsonfilter instead of json_* functions for speed

Code formatting may sound like a topic for the pedantic, however it helps if
the code in the project is formatted in the same way. The following rules
apply:

- use tabs instead of spaces (set your editor to show tabs as two spaces.) Only
  exceptions are Makefiles, that need spaces in some places (for example the
  Package definition)
- trailing whitespaces must be eliminated

Developing Packages
-------------------

If you want to develop your own external Gluon package, the best way would be 
to start with an existing package from the gluon repository and adapt it, for 
example use the package ``gluon-web-mesh-vpn-fastd`` as a base

- rename all occurrences of your example package
- adapt the upgrade script to your needs
- to create new config values that may be editable with ``uci`` create a file 
  in ``/ect/config/your_new_config`` with just one section

::

  config main 'settings'


- to fill this section with values from the ``site.conf`` edit the upgrade 
  script for your package and add the same section as the filename of the config
  file in your ``site.conf``:

::

  your_new_config {
    new_value = 'example'
  }

::

Upgrading Packages from 2016.2.x
--------------------------------

The site.conf and external packages to be rewritten in some parts and Gluon now
doesn't use LuCI for its Config Mode anymore, but our own fork
"gluon-web", which is significantly smaller (as lots of features we don't
need have been removed) for detailed changes see section `/web/`_.

- the function ``gluon_luci.escape()`` must be replaced with ``pcdata()`` and
  ``urlescape()`` with ``urlencode()``
- the dependencies in the ``Makefile`` must be adapted: replace
  ``DEPENDS:=gluon-luci-theme`` with ``DEPENDS:=gluon-web-theme``, ``luci-base``
  with ``gluon-web`` and ``gluon-luci-admin`` with ``gluon-web-admin`` ...
- ``i18n.translate()`` => ``translate()``
- ``luci.template.render_string()`` =>
  ``renderer.render_string()``
- i.e. ``s:option(cbi.Value, "_altitude" ...`` =>
  ``o = s:option(Value, "altitude" ...``
- ``o.rmempty`` => ``o.optional``
- adapt the paths: ``/lib/gluon/setup-mode/www`` =>
  ``/lib/gluon/web/www``
- includes: ``require 'luci.util'`` => ``require 'gluon.web.util'``, 'luci.i18n' and 'gluon.luci' => 'gluon.util'
- ``local uci = luci.model.uci.cursor()`` => ``local uci = require("simple-uci").cursor()``
- In ``site.mk`` all pakages with ``-luci-`` in its name must be replaced with
  ``-web-`` (exception: ``gluon-luci-portconfig`` =>
  ``gluon-web-network``
- the Makefile now has to reside in a subfolder within the repository, all
  files and folders needed for inclusion need to be in that same subfolder
- the ``site.conf`` needs to be adjusted too. Refer to `site.html#configuration`_
  for the new format:
    - The changes in short: the ``fastd_mesh_vpn`` section has been renamed to
      ``fastd`` and moved into a new section ``mesh_vpn``, with the exception of
      the options ``enabled``, ``mtu`` and ``bandwidth_limit``, which are set
      directly in the ``mesh_vpn`` section.
