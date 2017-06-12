Contribution Guidelines
=======================

Because Gluon is such a universal software package that is used by several
different communities with different expectations and requirements, it is both
essential and difficult to have contributions from the communities. While they
are sometimes necessary to adapt Gluon to the needs of the communities, they
also have to be adaptable enough to fit as many needs as possible. On the other
hands, very special needs are better addressed in [packages] in community
repositories, because the Gluon maintainers would not use or test them and
thus couldn't do their "job" of maintaining them.

To ease the work for the maintainers and to reduce the frustration of
contributors, please adhere to the following guidelines:

Discuss first, build later
--------------------------
If you have some non-trivial enhancement like a new package, some modification
of what is announced by a node, it is often best to first discuss the precise
solution first. The maintainers might have hints as to how a solution could be
implemented easiest, point out solutions how the same thing can already be done
using other parts or why the proposed change breaks other parts of the system.
They might even refuse the idea altogether - after all, they have to sleep well
after merging the changes, too.

The preferred way to discuss in the IRC channel ([#gluon] on irc.hackint.org)
or on the [mailing list], however, you can also open a new issue on Github to
discuss there. We maintain a [list of rejected features] and we'd like to
kindly ask you to review it first. In general, looking for duplicates may save
you some time.

Develop on top of master
------------------------
If you are not developing something specific to a release (like for example a
security fix to a feature that got completely rewritten since the release),
develop it on top of the master branch. New features and even feature changes
aren't usually backported to old releases, but will be included in the upcoming
release, which will be built from master.

Use descriptive commit messages
-------------------------------
If you modify a single package, start the first line of your commit message
with the package name followed by a colon. The first line should be enough to
identify the commit a week later and still know roughly what it did. If you
fix some bug, detail in the remaining commit message exactly how it could be
triggered and what you did to fix it. If in question, have a glance at the
existing commit messages to get the idea.


[packages]: http://gluon.readthedocs.org/en/latest/user/site.html#packages
[#gluon]: https://webirc.hackint.org/#gluon
[mailing list]: mailto:gluon@luebeck.freifunk.net
[list of rejected features]: https://github.com/freifunk-gluon/gluon/issues?q=label%3Arejected
