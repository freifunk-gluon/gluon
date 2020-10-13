Autoupdater
===========

Gluon contains an automatic update system which can be configured in the site configuration.

Building Images
---------------

By default, the autoupdater is disabled (as it is usually not helpful to have unexpected updates
during development), but it can be enabled by setting the variable ``GLUON_AUTOUPDATER_ENABLED`` to ``1`` when building.
It is also possible to override the default branch during build using the variable ``GLUON_AUTOUPDATER_BRANCH``.

If a default branch is set neither in *site.conf* nor via ``GLUON_AUTOUPDATER_BRANCH``, the default branch is
implementation-defined. Currently, the branch with the first name in alphabetical order is chosen.

A manifest file for the updater can be generated with `make manifest`. A signing script (using
``ecdsautils``) can be found in the `contrib` directory. When creating the manifest, the
``PRIORITY`` value may be defined by setting ``GLUON_PRIORITY`` on the command line or in ``site.mk``.

``GLUON_PRIORITY`` defines the maximum number of days that may pass between releasing an update and installation
of the images. The update probability will start at 0 after the release time declared in the manifest file
by the variable DATE and then slowly rise up to 1 when ``GLUON_PRIORITY`` days have passed. The autoupdater checks
for updates hourly (at a random minute of the hour), but usually only updates during its run between
4am and 5am, except when the whole ``GLUON_PRIORITY`` days and another 24 hours have passed.

``GLUON_PRIORITY`` may be an integer or a decimal fraction.

If ``GLUON_RELEASE`` is passed to ``make`` explicitly or it is generated dynamically
in ``site.mk``, care must be taken to pass the same ``GLUON_RELEASE`` to ``make manifest``,
as otherwise the generated manifest will be incomplete.


Automated nightly builds
------------------------

A fully automated nightly build could use the following commands:

.. code-block:: sh

    git pull
    # git -C site pull
    make update
    make clean GLUON_TARGET=ar71xx-generic
    NUM_CORES_PLUS_ONE=$(expr $(nproc) + 1)
    make -j$NUM_CORES_PLUS_ONE GLUON_TARGET=ar71xx-generic GLUON_RELEASE=$GLUON_RELEASE \
        GLUON_AUTOUPDATER_BRANCH=experimental GLUON_AUTOUPDATER_ENABLED=1
    make manifest GLUON_RELEASE=$GLUON_RELEASE GLUON_AUTOUPDATER_BRANCH=experimental
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
