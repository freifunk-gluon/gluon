Autoupdater
===========

Gluon contains an automatic update system which can be configured in the site configuration.

Building Images
---------------

By default, the autoupdater is disabled (as it is usually not helpful to have unexpected updates
during development), but it can be enabled by setting the variable GLUON_BRANCH when building
to override the default branch set in the set in the site configuration.

A manifest file for the updater can be generated with `make manifest`. A signing script (using
ecdsautils) can by found in the `contrib` directory. When creating the manifest, ``GLUON_PRIORITY`` can
be set on the command line, or it can be taken from the ``site.mk``.

The priority defines the maximum number of days that may pass between releasing an update and installation
of the images. The update probability with start at 0 after the release time mentioned in the manifest
and then slowly rise to 1 after the number of days given by the priority has passed.

The priority may be an integer or a decimal fraction.

A fully automated nightly build could use the following commands:

::

    git pull
    (cd site && git pull)
    make update
    make clean
    make -j5 GLUON_TARGET=ar71xx-generic GLUON_BRANCH=experimental
    make manifest GLUON_BRANCH=experimental
    contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest

    rm -rf /where/to/put/this/experimental
    cp -r images /where/to/put/this/experimental


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

The server should be available via IPv6.

Command Line
------------

These commands can be used on a node.

::

   # Update with some probability
   autoupdater

::

   # Force update check, even when the updater is disabled
   autoupdater -f


