Builds
======

For the build reserve 6GB of disk space. The building requires packages
for ``subversion``, ncurses headers (``libncurses-dev``) and zlib headers
(``libz-dev``).

Building Gluon
--------------

To build Gluon, after checking out the repository change to the source root directory to perform the following commands:

::

    git clone git://github.com/freifunk-gluon/site-ffhl.git site # Get the Freifunk Lübeck site repository - or use your own!
    make update                                                  # Get other repositories used by Gluon
    make                                                         # Build Gluon

When calling ``make``, the OpenWRT build environment is prepared and updated. To rebuild
the images only, just use:

::

    make images

The built images can be found in the directory ``images``.

Cleaning up
-----------

There are three levels of ``make clean``:

::

    make clean

will only clean the Gluon-specific files;

::

    make cleanall

will also call ``make clean`` on the OpenWRT tree, and

::

    make dirclean

will do all this, and call ``make dirclean`` on the OpenWRT tree.

Environment variables
---------------------

Gluon's build process can be controlled by various environment variables.

GLUON_SITEDIR
  Path to the site configuration. Defaults to ``site/``.

GLUON_IMAGEDIR
  Path where images will be stored. Defaults to ``images/``.

GLUON_BUILDDIR
  Working directory during build. Defaults to ``build/``.
