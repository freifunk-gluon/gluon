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

Gluon's developers frequent the IRC chatroom `#gluon`_ on `hackint`_.
There is a `webchat`_ that allows for easy access from within your
web browser. You're welcome to join us!

.. _#gluon: ircs://irc.hackint.org/#gluon
.. _hackint: https://hackint.org/
.. _webchat: https://chat.hackint.org/?join=gluon

.. _working-with-repositories:

Working with repositories
-------------------------

To update the repositories used by Gluon, just adjust the commit IDs in `modules` and
rerun

::

  make update

`make update` also applies the patches that can be found in the directories found in
`patches`; the resulting branch will be called `patched`, while the commit specified in `modules`
can be referred to by the branch `base`.

After new patches have been committed on top of the `patched` branch (or existing commits
since the base commit have been edited or removed), the patch directories can be regenerated
using

::

  make update-patches

If applying a patch fails because you have changed the base commit, the repository will be reset to the old `patched` branch
and you can try rebasing it onto the new `base` branch yourself and after that call `make update-patches` to fix the problem.

Always call `make update-patches` after making changes to a module repository as `make update` will overwrite your
commits, making `git reflog` the only way to recover them!

::

  make refresh-patches

In order to refresh patches when updating feeds or the OpenWrt base, `make refresh-patches` applies and updates all of their patches without installing feed packages to the OpenWrt build system.

This command speeds up the maintenance of updating OpenWrt and feeds.

Development Guidelines
----------------------
Lua should be used instead of sh whenever sensible. The following criteria
should be considered:

- Is the script doing more than just executing external commands? if so, use Lua
- Is the script parsing/editing json-data? If so, use Lua for speed
- When using sh, use jsonfilter instead of json_* functions for speed

Code formatting may sound like a topic for the pedantic, however it helps if
the code in the project is formatted in the same way. The following basic rules
apply:

- use tabs instead of spaces
- trailing whitespace characters must be eliminated
- files need to end with a final newline
- newlines need to have Unix line endings (lf)

To that end we provide a ``.editorconfig`` configuration, which is supported by most
of the editors out there.

If you add Lua scripts to gluon, check formatting with ``luacheck``.
