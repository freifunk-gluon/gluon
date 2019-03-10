Package development
###################

Gluon packages are OpenWrt packages and follow the same rules described at https://openwrt.org/docs/guide-developer/packages.


Gluon package makefiles
=======================

As many packages share the same or a similar structure, Gluon provides a ``package/gluon.mk`` that
can be included for common definitions. This file replaces OpenWrt's ``$(INCLUDE_DIR)/package.mk``;
it is usually included as ``include ../gluon.mk`` from Gluon core packages, or as
``include $(TOPDIR)../package/gluon.mk`` from feeds.

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
making it necessary to list each package explicitly.

The main feature flag definition file is ``package/features``, but each package
feed can provide additional definitions in a file called ``features`` at the root
of the feed repository.

Each flag *$flag* without any explicit definition will simply include the package
with the name *gluon-$flag* by default. The feature definition file can modify
the package selection in two ways:

* The *nodefault* function suppresses default of including the *gluon-$flag*
  package
* The *packages* function adds a list of packages (or removes, when package
  names are prepended with minus signs) when a given logical expression
  is satisfied

Example::

    nodefault 'web-wizard'

    packages 'web-wizard' \
      'gluon-config-mode-hostname' \
      'gluon-config-mode-geo-location' \
      'gluon-config-mode-contact-info'

    packages 'web-wizard & (mesh-vpn-fastd | mesh-vpn-tunneldigger)' \
      'gluon-config-mode-mesh-vpn'

This will

* disable the inclusion of a (non-existent) package called *gluon-web-wizard*
* enable three config mode packages when the *web-wizard* feature is enabled
* enable *gluon-config-mode-mesh-vpn* when both *web-wizard* and one
  of *mesh-vpn-fastd* and *mesh-vpn-tunneldigger* are enabled

Supported syntax elements of logical expressions are:

* \& (and)
* \| (or)
* \! (not)
* parentheses
