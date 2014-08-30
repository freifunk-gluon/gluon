Getting Started
===============

To build Gluon, after checking out the repository change to the source root directory
to  perform the following commands:

::

    git clone git://github.com/freifunk-gluon/site-ffhl.git site # Get the Freifunk Lübeck site repository - or use your own!
    make update                                                  # Get other repositories used by Gluon
    make                                                         # Build Gluon

When calling make, the OpenWRT build environment is prepared/updated. To rebuild
the images only, just use:

::

    make images

The built images can be found in the directory `images`. Of these, the factory
images are to be used when flashing from the original firmware a device came with,
and sysupgrade is to upgrade from other versions of Gluon or any other OpenWRT-based
system.

For the build reserve 6GB of disk space. The build requires packages
for `subversion`, ncurses headers (`libncurses-dev`) and zlib headers
(`libz-dev`).


There are two levels of `make clean`:

::

    make clean

will ensure all packages are rebuilt; this is what you normally want to do after an update.

::

    make dirclean

will clean the entire tree, so the toolchain will be rebuilt as well, which is
not necessary in most cases, and will take a while.


Environment variables
---------------------

Gluon's build process can be controlled by various environment variables.

GLUON_SITEDIR
  Path to the site configuration. Defaults to ``site/``.

GLUON_IMAGEDIR
  Path where images will be stored. Defaults to ``images/``.

GLUON_BUILDDIR
  Working directory during build. Defaults to ``build/``.


So all in all, to update and rebuild a Gluon build tree, the following commands should be used:

::

    git pull
    (cd site && git pull)
    make update
    make clean
    make
