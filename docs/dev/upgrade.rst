Upgrade scripts
===============

Basics
------

After each sysupgrade (including the initial installation), Gluon will execute all scripts
under ``/lib/gluon/upgrade``. These scripts' filenames usually begin with a 3-digit number
specifying the order of execution.

To get an overview of the ordering of all scripts of all packages, the helper script ``contrib/lsupgrade.sh``
in the Gluon repository can be used, which will print all upgrade scripts' filenames and directories. If executed
on a TTY, the filename will be highlighted in green, the repository in blue and the package in red.

Best practices
--------------

* Most upgrade scripts are written in Lua. This allows using lots of helper functions provided
  by LuCi and Gluon, e.g. to access the site configuration or edit UCI configuration files.

* Whenever possible, scripts shouldn't check if they are running for the first time, but just edit configuration
  files to achive a valid configuration (without overwriting configuration changes made by the user where desirable).
  This allows using the same code to create the initial configuration and upgrade configurations on upgrades.

* If it is unavoidable to run different code during the initial installation, the ``sysconfig.gluon_version`` variable
  can be checked. This variable is ``nil`` during the initial installation and contains the previously install Gluon
  version otherwise. The package ``gluon-legacy`` (which is responsible for upgrades from the old firmwares of
  Hamburg/Kiel/Lübeck) uses the special value ``legacy``; other packages should handle this value just as any other
  string.

Script ordering
---------------

These are some guidelines for the script numbers:

* ``0xx``: Basic ``sysconfig`` setup
* ``1xx``: Basic system setup (including basic network configuration)
* ``2xx``: Wireless setup
* ``3xx``: Advanced network and system setup
* ``4xx``: Extended network and system setup (e.g. mesh VPN and next-node)
* ``5xx``: Miscellaneous (everything not fitting into any other category)
* ``6xx`` .. ``8xx``: Currently unused
* ``9xx``: Upgrade finalization
