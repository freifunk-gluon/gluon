Build system
============

This page explains internals of the Gluon build system. It is currently very
incomplete; please contribute if you can!

Feed management
---------------

Rather that relying on the *feed.conf* mechanism of OpenWrt directly, Gluon
manages its feeds (*"modules"*) using a collection of scripts. This solution was
selected for multiple reasons:

- Feeds lists from Gluon base and the site repository are combined
- Patchsets are applied to downloaded feed repositories automatically

The following variables specifically affect the feed management:

GLUON_FEEDS
    List of base feeds; defined in file *modules* in Gluon base

GLUON_SITE_FEED
    List of site feeds; defined in file *modules* in site config

\*_REPO, \*_BRANCH, \*_COMMIT
    Git repository URL, branch and
    commit ID of the feeds to use. The branch name may be omitted; the default
    branch will be used in this case.

GLUON_BASE_FEEDS
    Additional feed definitions to be added to *feeds.conf*
    verbatim. By default, this contains a reference to the Gluon base packages;
    when using the Gluon build system to build a non-Gluon system, the variable
    can be set to the empty string.

Helper scripts
--------------

Several tasks of the build process have been separated from the Makefile into
external scripts, which are stored in the *scripts* directory. This was done to
ease maintenance of these scripts and the Makefile, by avoiding a lot of escaping.
These scripts are either bash or Lua scripts that run on the build system.

default_feeds.sh
    Defines the constant ``DEFAULT_FEEDS`` with the names of all feeds listed in
    *openwrt/feeds.conf.default*. This script is only used as an include by other
    scripts.

feeds.sh
    Creates the *openwrt/feeds.conf* file from ``FEEDS`` and ``DEFAULT_FEEDS``. The
    feeds from ``FEEDS`` are linked to the matching subfolder of *packages/* and not
    explicitly defined feeds of ``DEFAULT_FEEDS`` are setup as dummy (src-dummy).
    This *openwrt/feeds.conf* is used to reinstall all packages of all feeds with
    the *openwrt/scripts/feeds* tool.

modules.sh
    Defines the constants ``GLUON_MODULES`` and ``FEEDS`` by reading the *modules*
    files of the Gluon repository root and the site configuration. The returned
    variables look like:

    - ``FEEDS``: "*feedA feedB ...*"
    - ``GLUON_MODULES``: "*openwrt packages/feedA packages/feedB ...*"

    This script is only used as an include by other scripts.

patch.sh
    (Re-)applies the patches from the *patches* directory to all ``GLUON_MODULES``
    and checks out the files to the filesystem.
    This is done for each repo by:

    - creating a temporary clone of the repo to patch
      - only branch *base* is used
    - applying all patches via *git am* on top of this temporary *base* branch
      - this branch is named *patched*
    - copying the temporary clone to the *openwrt* (for OpenWrt Base) or
      *packages* (for feeds) folder
      - *git fetch* is used with the temporary clone as source
      - *git checkout* is called to update the filesystem
    - updating all git submodules

    This solution with a temporary clone ensures that the timestamps of checked
    out files are not changed by any intermediate patch steps, but only when
    updating the checkout with the final result. This avoids triggering unnecessary
    rebuilds.

update.sh
    Sets up a working clone of the ``GLUON_MODULES`` (external repos) from the external
    source and installs it into *packages/* directory. It simply tries to set the *base*
    branch of the cloned repo to the correct commit. If this fails it fetches the
    upstream branch and tries again to set the local *base* branch.

getversion.sh
    Used to determine the version numbers of the repositories of Gluon and the
    site configuration, to be included in the built firmware images as
    */lib/gluon/gluon-version* and */lib/gluon/site-version*.

    By default, this uses ``git describe`` to generate a version number based
    on the last annotated git tag. This can be overridden by putting a file called
    *.scmversion* into the root of the respective repositories.

    A command like ``rm -f .scmversion; echo "$(./scripts/getversion.sh .)" > .scmversion``
    can be used before applying local patches to ensure that the reported
    version numbers refer to an upstream commit ID rather than an arbitrary
    local one after ``git am``.
