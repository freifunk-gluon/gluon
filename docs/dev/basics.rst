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
webbrowser. You're welcome to join us!

.. _#gluon: ircs://irc.hackint.org/#gluon
.. _hackint: https://hackint.org/
.. _webchat: https://webirc.hackint.org/#irc://irc.hackint.org/#gluon


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

Development Guidelines
----------------------
lua should be used instead of sh whenever sensible. The following criteria
should be considered:

- Is the script doing more than just executing external commands? if so, use lua
- Is the script parsing/editing json-data? If so, use lua for speed
- When using sh, use jsonfilter instead of json_* functions for speed

Code formatting may sound like a topic for the pedantic, however it helps if
the code in the project is formatted in the same way. The following rules
apply:

- use tabs instead of spaces
- trailing whitespaces must be eliminated
