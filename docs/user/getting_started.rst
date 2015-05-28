Getting Started
===============

Selecting the right version
---------------------------

Gluon's releases are managed using `Git tags`_. If you're a community getting
started with Gluon we recommend to use the latest stable release of Gluon.

Take a look at the `list of gluon releases`_ and notice the latest release,
e.g. *v2014.3*.

Please keep in mind that a matching site configuration for your community
is required. Due to new features being added (or sometimes being removed)
the format of the site configuration changes slightly between releases.

Recent releases (starting with *v2014.3.1*) will come with an example
configuration located in *docs/site-example/*.

.. _Git tags: http://git-scm.com/book/en/Git-Basics-Tagging
.. _list of gluon releases: https://github.com/freifunk-gluon/gluon/releases

Dependencies
------------
To build Gluon, several packages need to be installed on the system. On a
freshly installed Debian Wheezy system the following packages are required:

* `git` (to get Gluon and other dependencies)
* `subversion`
* `build-essential`
* `gawk`
* `unzip`
* `libncurses-dev` (actually `libncurses5-dev`)
* `libz-dev` (actually `zlib1g-dev`)


Building the images
-------------------

To build Gluon, first check out the repository. Replace *RELEASE* with the
version you'd like to checkout, e.g. *v2015.1*.

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

Copy *site.conf*, *site.mk* and *i18n* from *docs/site-example*:

::

    cp ../docs/site-example/site.conf .
    cp ../docs/site-example/site.mk .
    cp -r ../docs/site-example/i18n .

Edit these files to match your community, then go back to the top-level Gluon
directory and build Gluon:

::

    cd ..
    make update                        # Get other repositories used by Gluon
    make GLUON_TARGET=ar71xx-generic   # Build Gluon

When calling make, the OpenWrt build environment is prepared/updated.
In case of errors read the messages carefully and try to fix the stated issues (e.g. install tools not available yet).

``ar71xx-generic`` is the most common target and will generated images for most of the supported hardware.
To see a complete list of supported targets, call ``make`` without setting ``GLUON_TARGET``.

The built images can be found in the directory `images`. Of these, the factory
images are to be used when flashing from the original firmware a device came with,
and sysupgrade is to upgrade from other versions of Gluon or any other OpenWRT-based
system.

You should reserve about 10GB of disk space for each `GLUON_TARGET`.

There are two levels of `make clean`:

::

    make clean GLUON_TARGET=ar71xx-generic

will ensure all packages are rebuilt for a single target; this is what you normally want to do after an update.

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


So all in all, to update and rebuild a Gluon build tree, the following commands should be used (repeat the
``make clean`` and ``make`` for all targets you want to build):

::

    git pull
    (cd site && git pull)
    make update
    make clean GLUON_TARGET=ar71xx-generic
    make GLUON_TARGET=ar71xx-generic
