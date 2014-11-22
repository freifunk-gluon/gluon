Getting Started
===============

Selecting the right version
---------------------------

Gluon's releases are managed using `Git tags`_. If you're a community getting
started with Gluon we recommend to use the latest stable release if Gluon.

Take a look at the `list of gluon releases`_ and notice the latest release,
e.g. *v2014.3*.

Please keep in mind that a matching site configuration for your community
is required. Due to new features being added (or sometimes being removed)
the format of the site configuration changes slightly between releases.

Recent releases (starting with *v2014.3.1*) will come with an example
configuration located in *docs/site-example/*.

.. _Git tags: http://git-scm.com/book/en/Git-Basics-Tagging
.. _list of gluon releases: https://github.com/freifunk-gluon/gluon/releases

Building the image
------------------

.. note:: Make sure you have configured your `Git identity`_.
          If you neglect this, you'll get strange error messages.

.. _Git identity: http://git-scm.com/book/en/Getting-Started-First-Time-Git-Setup#Your-Identity

To build Gluon, first check out the repository. Replace *RELEASE* with the
version you'd like to checkout, e.g. *v2014.3*.

::

    git clone https://github.com/freifunk-gluon/gluon.git gluon -b RELEASE

This command will create a directory named *gluon/*.
It might also tell a scary message about being in a *detached state*.
**Don't panic!** Everything's fine.
Now, enter the freshly created directory:

::

    cd gluon

It's time to add (or create) your site configuration.
So let's create the directory *site/*:

::

    mkdir site
    cd site

Copy *site.conf* and *site.mk* from *docs/site-example*:

::

    cp ../docs/site-example/site.conf .
    cp ../docs/site-example/site.mk .

.. note:: On **v2014.3**, take both files from
          https://github.com/freifunk-gluon/gluon/tree/2014.3.x/docs/site-example

Edit both files to match your community, then go back to the top-level Gluon
directory and build Gluon:

::

    cd ..
    make update  # Get other repositories used by Gluon
    make         # Build Gluon

When calling make, the OpenWRT build environment is prepared/updated.
In case of errors read the messages carefully and try to fix the stated issues (e.g. install tools not available yet).
To rebuild the images only, just use:

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
