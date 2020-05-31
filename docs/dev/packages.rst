Package development
###################

Gluon packages are OpenWrt packages and follow the same rules described at https://openwrt.org/docs/guide-developer/packages.


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

Feature definitions use Lua syntax. The function *feature* has two arguments:

* A logical expression composed of feature flag names (each prefixed with an underscore before the opening
  quotation mark), logical operators (*and*, *or*, *not*) and parantheses
* A table with settings that are applied when the logical expression is
  satisfied:

  * Setting *nodefault* to *true* suppresses the default of including the *gluon-$flag* package.
    This setting is only applicable when the logical expression is a single,
    non-negated flag name.
  * The *packages* field adds or removes packages to install. A package is
    removed when the package name is prefixed with a ``-`` (after the opening
    quotation mark).

Example::

    feature(_'web-wizard', {
      nodefault = true,
      packages = {
        'gluon-config-mode-hostname',
        'gluon-config-mode-geo-location',
        'gluon-config-mode-contact-info',
        'gluon-config-mode-outdoor',
      },
    })

    feature(_'web-wizard' and (_'mesh-vpn-fastd' or _'mesh-vpn-tunneldigger'), {
      packages = {
        'gluon-config-mode-mesh-vpn',
      },
    })

    feature(_'no-radvd', {
      nodefault = true,
      packages = {
        '-gluon-radvd',
      },
    })


This will

* disable the inclusion of the (non-existent) packages *gluon-web-wizard* and *gluon-no-radvd* when their
  corresponding feature flags appear in *GLUON_FEATURES*
* enable four additional config mode packages when the *web-wizard* feature is enabled
* enable *gluon-config-mode-mesh-vpn* when both *web-wizard* and one
  of *mesh-vpn-fastd* and *mesh-vpn-tunneldigger* are enabled
* disable the *gluon-radvd* package when *gluon-no-radvd* is enabled
