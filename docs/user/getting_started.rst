Getting Started
===============

Selecting the right version
-------------

The versions of gluon are managed with tags and branches. Every tag is a stable release (like v2014.2 or v2014.3.1), every branch is a development branch, where 2014.3.x is a branch for 2014.3 bugfix releases and master is the unstable branch for the upcoming release. Branches should be used for development purposes, while tags can be used for productive releases. To check out a branch do:

::

    git clone https://github.com/freifunk-gluon/gluon.git gluon
    cd gluon
    git checkout v2014.3

Please keep in mind that you need the appropriate site configuration for that gluon version.

Building the image
-------------

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

So all in all, to update and rebuild a Gluon build tree, the following commands should be used:

::

    git pull
    (cd site && git pull)
    make update
    make clean
    make


