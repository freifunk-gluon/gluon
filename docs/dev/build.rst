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
    Git repository URL, branch and and
    commit ID of the feeds to use. The branch name may be omitted; the default
    branch will be used in this case.

GLUON_BASE_FEEDS
    Additional feed definitions to be added to *feeds.conf*
    verbatim. By default, this contains a reference to the Gluon base packages;
    when using the Gluon build system to build a non-Gluon system, the variable
    can be set to the empty string.
