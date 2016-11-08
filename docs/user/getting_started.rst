Getting Started
===============

Selecting the right version
---------------------------

Gluon's releases are managed using `Git tags`_. If you are just getting
started with Gluon we recommend to use the latest stable release of Gluon.

Take a look at the `list of gluon releases`_ and notice the latest release,
e.g. *v2016.2.1*. Always get Gluon using git and don't try to download it
as a Zip archive as the archive will be missing version information.

Please keep in mind that there is no "default Gluon" build; a site configuration
is required to adjust Gluon to your needs. Due to new features being added (or
sometimes being removed) the format of the site configuration changes slightly
between releases. Please refer to our release notes for instructions to update
an old site configuration to a newer release of Gluon.

An example configuration can be found in the Gluon repository at *docs/site-example/*.

.. _Git tags: http://git-scm.com/book/en/Git-Basics-Tagging
.. _list of gluon releases: https://github.com/freifunk-gluon/gluon/releases

Dependencies
------------
To build Gluon, several packages need to be installed on the system. On a
freshly installed Debian Wheezy system the following packages are required:

* `git` (to get Gluon and other dependencies)
* `subversion`
* `python` (Python 3 doesn't work)
* `build-essential`
* `gawk`
* `unzip`
* `libncurses-dev` (actually `libncurses5-dev`)
* `libz-dev` (actually `zlib1g-dev`)
* `libssl-dev`


Building the images
-------------------

To build Gluon, first check out the repository. Replace *RELEASE* with the
version you'd like to checkout, e.g. *v2016.2.1*.

::

    git clone https://github.com/freifunk-gluon/gluon.git gluon -b RELEASE

This command will create a directory named *gluon/*.
It might also tell a scary message about being in a *detached state*.
**Don't panic!** Everything's fine.
Now, enter the freshly created directory::

    cd gluon

It's time to add (or create) your site configuration. If you already
have a site repository, just clone it::

   git clone https://github.com/freifunk-duckburg/site-ffdb.git site

If you want to build a new site, create a new git repository *site/*::

    mkdir site
    cd site
    git init

Copy *site.conf*, *site.mk* and *i18n* from *docs/site-example*::

    cp ../docs/site-example/site.conf .
    cp ../docs/site-example/site.mk .
    cp -r ../docs/site-example/i18n .

Edit these files as you see fit and commit them into the site repository.
Extensive documentation about the site configuration can be found at:
:doc:`site`. The
site directory should always be a git repository by itself; committing site-specific files
to the Gluon main repository should be avoided, as it will make updates more complicated.

Next go back to the top-level Gluon directory and build Gluon::

    cd ..
    make update                        # Get other repositories used by Gluon
    make GLUON_TARGET=ar71xx-generic   # Build Gluon

When calling make, the OpenWrt build environment is prepared/updated.
In case of errors read the messages carefully and try to fix the stated issues (e.g. install tools not available yet).

``ar71xx-generic`` is the most common target and will generate images for most of the supported hardware.
To see a complete list of supported targets, call ``make`` without setting ``GLUON_TARGET``.

You should reserve about 10GB of disk space for each `GLUON_TARGET`.

The built images can be found in the directory `output/images`. Of these, the `factory`
images are to be used when flashing from the original firmware a device came with,
and `sysupgrade` is to upgrade from other versions of Gluon or any other OpenWrt-based
system.

**Note:** The images for some models are identical; to save disk space, symlinks are generated instead
of multiple copies of the same image. If your webserver's configuration prohibits following
symlinks, you can use the following command to resolve these links while copying the images::

    cp -rL output/images /var/www

Cleaning the build tree
.......................

There are two levels of `make clean`::

    make clean GLUON_TARGET=ar71xx-generic

will ensure all packages are rebuilt for a single target; this is what you normally want to do after an update.

::

    make dirclean

will clean the entire tree, so the toolchain will be rebuilt as well, which is
not necessary in most cases, and will take a while.

So in summary, to update and rebuild a Gluon build tree, the following commands should be used (repeat the
``make clean`` and ``make`` for all targets you want to build):

::

    git pull
    (cd site && git pull)
    make update
    make clean GLUON_TARGET=ar71xx-generic
    make GLUON_TARGET=ar71xx-generic


opkg repositories
-----------------

Gluon is mostly compatible with OpenWrt, so the normal OpenWrt package repositories
can be used for Gluon as well. It is advisable to setup a mirror or reverse proxy
reachable over IPv6 and add it to ``site.conf`` as http://downloads.openwrt.org/ does
not support IPv6.

This is not true for kernel modules; the Gluon kernel is incompatible with the
kernel of the default OpenWrt images. Therefore, Gluon will not only generate images,
but also an opkg repository containing all kernel modules provided by OpenWrt/Gluon
for the kernel of the generated images.

Signing keys
............

Gluon does not support HTTPS for downloading packages; fortunately, opkg deploys
public-key cryptography to ensure package integrity.

The Gluon images will contain two public keys: the official OpenWrt signing key
(to allow installing userspace packages) and a Gluon-specific key (which is used
to sign the generated module repository).

By default, Gluon will handle the generation and handling of the keys itself.
When making firmware releases based on Gluon, it might make sense to store
the keypair, so updating the module repository later is possible.

The location the keys are stored at and read from can be changed
(see :ref:`getting-started-make-variables`). To only generate the keypair
at the configured location without doing a full build, use ``make create-key``.

.. _getting-started-make-variables:

Make variables
--------------

Gluon's build process can be controlled by various variables. They can
usually be set on the command line or in ``site.mk``.

Common variables
................

GLUON_ATH10K_MESH
  While Gluon does support some hardware with ath10k-based 5GHz WLAN, these WLAN adapters don't work
  well for meshing at the moment, so building images for these models is disabled by default. In addition,
  ath10k can't support IBSS and 11s meshing in the same image due to WLAN firmware restrictions.

  Setting GLUON_ATH10K_MESH to ``11s`` or ``ibss`` will enable generation of images for ath10k devices
  and install the firmware for the corresponding WLAN mode.

GLUON_BRANCH
  Sets the default branch of the autoupdater. If unset, the autoupdater is disabled
  by default. For the ``make manifest`` command, GLUON_BRANCH defines the branch to
  generate a manifest for.

GLUON_LANGS
  Space-separated list of languages to include for the config mode/advanced settings. Defaults to ``en``.
  ``en`` should always be included, other supported languages are ``de`` and ``fr``.

GLUON_PRIORITY
  Defines the priority of an automatic update in ``make manifest``. See :doc:`../features/autoupdater` for
  a detailed description of this value.

GLUON_REGION
  Some devices (at the moment the TP-Link Archer C7) contain a region code that restricts
  firmware installations. Set GLUON_REGION to ``eu`` or ``us`` to make the resulting
  images installable from the respective stock firmwares.

GLUON_RELEASE
  Firmware release number: This string is displayed in the config mode, announced
  via respondd/alfred and used by the autoupdater to decide if a newer version
  is available.

GLUON_TARGET
  Target architecture to build.

Special variables
.................

GLUON_BUILDDIR
  Working directory during build. Defaults to ``build``.

GLUON_IMAGEDIR
  Path where images will be stored. Defaults to ``$(GLUON_OUTPUTDIR)/images``.

GLUON_MODULEDIR
  Path where the kernel module opkg repository will be stored. Defaults to ``$(GLUON_OUTPUTDIR)/modules``.

GLUON_OPKG_KEY
  Path key file used to sign the module opkg repository. Defaults to ``$(GLUON_BULDDIR)/gluon-opkg-key``.

  The private key will be stored as ``$(GLUON_OPKG_KEY)``, the public key as ``$(GLUON_OPKG_KEY).pub``.

GLUON_OUTPUTDIR
  Path where output files will be stored. Defaults to ``output``.

GLUON_SITEDIR
  Path to the site configuration. Defaults to ``site``.
