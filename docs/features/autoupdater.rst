Autoupdater
===========

Gluon contains an automatic update system which can be configured in the site configuration.

Building Images
---------------

By default, the autoupdater is disabled (as it is usually not helpful to have unexpected updates
during development), but it can be enabled by setting the variable GLUON_BRANCH when building
to override the default branch set in the set in the site configuration.

A manifest file for the updater can be generated with `make manifest`. A signing script (using
``ecdsautils``) can by found in the `contrib` directory. When creating the manifest, the 
``PRIORITY`` value may be defined by setting ``GLUON_PRIORITY`` on the command line or in ``site.mk``.

``GLUON_PRIORITY`` defines the maximum number of days that may pass between releasing an update and installation
of the images. The update probability will start at 0 after the release time declared in the manifest file
by the variable DATE and then slowly rise up to 1 when ``GLUON_PRIORITY`` days have passed. The autoupdater checks
for updates hourly (at a random minute of the hour), but usually only updates during its run between
4am and 5am, except when the whole ``GLUON_PRIORITY`` days and another 24 hours have passed.

``GLUON_PRIORITY`` may be an integer or a decimal fraction.

Automated nightly builds
------------------------

A fully automated nightly build could use the following commands:

::

    git pull
    (cd site && git pull)
    make update
    make clean
    NUM_CORES_PLUS_ONE=$(expr $(nproc) + 1)
    make -j$NUM_CORES_PLUS_ONE GLUON_TARGET=ar71xx-generic GLUON_BRANCH=experimental
    make manifest GLUON_BRANCH=experimental
    contrib/sign.sh $SECRETKEY output/images/sysupgrade/experimental.manifest

    rm -rf /where/to/put/this/experimental
    cp -r output/images /where/to/put/this/experimental


Infrastructure
--------------

We suggest to have following directory tree accessible via http:

::

    firmware/
            stable/
                    sysupgrade/
                    factory/
            snapshot/
                    sysupgrade/
                    factory/
            experimental/
                    sysupgrade/
                    factory/

The server must be available via IPv6.

Command Line
------------

These commands can be used on a node:

::

   # Update with some probability
   autoupdater

::

   # Force update check, even when the updater is disabled
   autoupdater -f

::

   # If fallback is true the updater will perform an update only if the timespan 
   # PRIORITY days (as defined in the manifest) and another 24h have passed
   autoupdater --fallback
