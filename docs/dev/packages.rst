Package development
###################

Gluon packages are OpenWrt packages and follow the same rules described at https://openwrt.org/docs/guide-developer/packages.

Development workflow
====================

When you are developing packages, it often happens that you iteratively want to deploy
and verify the state your development. There are two ways to verify your changes:

1)
  One way is to rebuild the complete firmware, flash it, configure it and verify your
  development then. This usually takes at least a few minutes to get your changes
  working so you can test them. Especially if you iterate a lot, this becomes tedious.

2)
  Another way is to rebuild only the package you are currently working on and
  to deploy this package to your test system. Here not even a reboot is required.
  This makes iterating relatively fast. Your test system could be real hardware or
  even a qemu in most cases.

Gluon provides scripts to enhance workflow 2). Here is an example illustrating
the workflow using these scripts:

.. code-block:: shell

  # start a local qemu instance
  contrib/run_qemu.sh output/images/factory/[...]-x86-64.img

  # apply changes to the desired package
  vi package/gluon-nftables/files/etc/init.d/gluon-nftables

  # rebuild and push the package to the qemu instance
  contrib/push_pkg.sh package/gluon-nftables/

  # test your changes
  ...

  # do more changes
  ...

  # rebuild and push the package to the qemu instance
  contrib/push_pkg.sh package/gluon-nftables/

  # test your changes
  ...

  (and so on...)

  # see help of the script for more information
  contrib/push_pkg.sh -h
  ...

Features of ``push_pkg.sh``:

* Works with compiled and non-compiled packages.

  * This means it can be used in the development of C-code, Lua-Code and mostly any other code.

* Works with native OpenWrt and Gluon packages.
* Pushes to remote machines or local qemu instances.
* Pushes multiple packages in in one call if desired.
* Performs site.conf checks.

Implementation details of ``push_pkg.sh``:

* First, the script builds an opkg package using the OpenWrt build system.
* This package is pushed to a *target machine* using scp:

  * By default the *target machine* is a locally running x86 qemu started using ``run_qemu.sh``.
  * The *target machine* can also be remote machine. (See the cli switch ``-r``)
  * Remote machines are not limited to a specific architecture. All architectures supported by gluon can be used as remote machines.

* Finally opkg is used to install/update the packages in the target machine.

  * While doing this, it will not override ``/etc/config`` with package defaults by default. (See the cli switch ``-P``).
  * While doing this, opkg calls the ``check_site.lua`` from the package as post_install script to validate the ``site.conf``. This means that the ``site.conf`` of the target machine is used for this validation.

Note that:

* ``push_pkg.sh`` does neither build nor push dependencies of the packages automatically. If you want to update dependencies, you must explicitly specify them to be pushed.
* If you add new packages, you must run ``make update config GLUON_TARGET=...``.
* You can change the gluon target of the target machine via ``make config GLUON_TARGET=...``.
* If you want to update the ``site.conf`` of the target machine, use ``push_pkg.sh package/gluon-site/``.
* Sometimes when things break, you can heal them by compiling a package with its dependencies: ``cd openwrt; make package/gluon-nftables/clean; make package/gluon-nftables/compile; cd ..``.
* You can exit qemu by pressing ``CTRL + a`` and ``c`` afterwards.

Gluon package makefiles
=======================

As many packages share the same or a similar structure, Gluon provides a ``package/gluon.mk`` that
can be included for common definitions. This file replaces OpenWrt's ``$(INCLUDE_DIR)/package.mk``;
it is usually included as ``include ../gluon.mk`` from Gluon core packages, or as
``include $(TOPDIR)/../package/gluon.mk`` from feeds.

Provided macros
***************

* *GluonBuildI18N* (arguments: *<source directory>*)

  Converts the *.po* files for all enabled languages from the given source directory to
  the binary *.lmo* format and stores them in ``$(PKG_BUILD_DIR)/i18n``.

* *GluonInstallI18N*

  Install *.lmo* files from ``$(PKG_BUILD_DIR)/i18n`` to ``/lib/gluon/web/i18n`` in the
  package install directory.

* *GluonSrcDiet* (arguments: *<source directory>*, *<destination directory>*)

  Copies a directory tree, processing all files in it using *LuaSrcDiet*. The directory
  tree should only contain Lua files.

* *GluonCheckSite* (arguments: *<source file>*)

  Intended to be used in a package postinst script. It will use the passed Lua
  snippet to verify package-specific site configuration.

* *BuildPackageGluon* (replaces *BuildPackage*)

  Extends the *Package/<name>* definition with common defaults, sets the package
  install script to the common *Gluon/Build/Install*, and automatically creates
  a postinst script using *GluonCheckSite* if a ``check_site.lua`` is found in the
  package directory.

Default build steps
*******************

These defaults greatly reduce the boilerplate in each package, but they can also
be confusing because of the many implicit behaviors depending on files in the
package directory. If any part of *Gluon/Build/Compile* or *Gluon/Build/Install*
does not work as intended for a package, the compile and install steps can
always be replaced or extended.

*Build/Compile* is set to *Gluon/Build/Compile* by default, which will

* run OpenWrt standard default commands (*Build/Compile/Default*) if a ``src/Makefile``
  or ``src/CMakeLists.txt`` is found
* run *GluonSrcDiet* on all files in the ``luasrc`` directory
* run *GluonBuildI18N* if a ``i18n`` directory is found

*Package/<name>* defaults to *Gluon/Build/Install* for packages defined using
*BuildPackageGluon*, which will

* copy all files from ``$(PKG_INSTALL_DIR)`` into the package if ``$(PKG_INSTALL)`` is 1
* copy all files from ``files`` into the package
* copy all Lua files built from ``luasrc`` into the package
* installs ``$(PKG_BUILD_DIR)/respondd.so`` to ``/usr/lib/respondd/$(PKG_NAME).so`` if ``src/respondd.c`` exists
* installs compiled i18n *.lmo* files

Feature flags
=============

Feature flags provide a convenient way to define package selections without
making it necessary to list each package explicitly. The list of features to
enable for a Gluon build is set by the *GLUON_FEATURES* variable in *site.mk*.

The main feature flag definition file is ``package/features``, but each package
feed can provide additional definitions in a file called ``features`` at the root
of the feed repository.

Each flag *$flag* will include the package the name *gluon-$flag* by default.
The feature definition file can modify the package selection by adding or removing
packages when certain combinations of flags are set.

Feature definitions use Lua syntax. Two basic functions are defined:

* *feature(name, pkgs)*: Defines a new feature. *feature()* expects a feature
  (flag) name and a list of packages to add or remove when the feature is
  enabled.

  * Defining a feature using *feature* replaces the default definition of
    just including *gluon-$flag*.
  * A package is removed when the package name is prefixed with a ``-`` (after
    the opening quotation mark).

* *when(expr, pkgs)*: Adds or removes packages when a given logical expression
  of feature flags is satisfied.

  * *expr* is a logical expression composed of feature flag names (each prefixed
    with an underscore before the opening quotation mark), logical operators
    (*and*, *or*, *not*) and parentheses.
  * Referencing a feature flag in *expr* has no effect on the default handling
    of the flag. When no *feature()* entry for a flag exists, it will still
    add *gluon-$flag* by default.
  * *pkgs* is handled as for *feature()*.

Example::

    feature('web-wizard', {
      'gluon-config-mode-hostname',
      'gluon-config-mode-geo-location',
      'gluon-config-mode-contact-info',
      'gluon-config-mode-outdoor',
    })

    when(_'web-wizard' and (_'mesh-vpn-fastd' or _'mesh-vpn-tunneldigger'), {
      'gluon-config-mode-mesh-vpn',
    })

    feature('no-radvd', {
      '-gluon-radvd',
    })


This will

* disable the inclusion of the (non-existent) packages *gluon-web-wizard* and *gluon-no-radvd* when their
  corresponding feature flags appear in *GLUON_FEATURES*
* enable four additional config mode packages when the *web-wizard* feature is enabled
* enable *gluon-config-mode-mesh-vpn* when both *web-wizard* and one
  of *mesh-vpn-fastd* and *mesh-vpn-tunneldigger* are enabled
* disable the *gluon-radvd* package when *gluon-no-radvd* is enabled
