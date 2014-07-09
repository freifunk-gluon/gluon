Development Basics
==================

Gluon's source is kept in `git repositories`_ at GitHub.

.. _git repositories: https://github.com/freifunk-gluon

Bug Tracker
-----------

The `main repo`_ does have issues enabled. 

.. _main repo: https://github.com/freifunk-gluon/gluon

IRC
---

Gluon's developers frequent `#gluon on hackint`_. You're welcome to join us!

.. _#gluon on hackint: irc://irc.hackint.org/#gluon


Working with repositories
-------------------------

To update the repositories used by Gluon, just adjust the commit IDs in `modules` and
rerun

::

	make update

`make update` also applies the patches that can be found in the directories found in
`patches`; the resulting branch will be called `patched`, while the commit specified in `modules`
can be refered to by the branch `base`.

::

	make unpatch

sets the repositories to the `base` branch,

::

	make patch

re-applies the patches by resetting the `patched` branch to `base` and calling `git am`
for the patch files. Calling `make` or a similar command after calling `make unpatch`
is generally not a good idea.

After new patches have been commited on top of the patched branch (or existing commits
since the base commit have been edited or removed), the patch directories can be regenerated
using

::

	make update-patches

If applying a patch fails because you have changed the base commit, the repository will be reset to the old `patched` branch
and you can try rebasing it onto the new `base` branch yourself and after that call `make update-patches` to fix the problem.

Always call `make update-patches` after making changes to a module repository as `make update` will overwrite your
commits, making `git reflog` the only way to recover them!
