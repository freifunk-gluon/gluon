To build Gluon, after checking out the repository change to the source root directory
to  perform the following commands:

    git clone git://github.com/ffrl/sites-ffrl.git sites         # Get the Freifunk Rheinland sites repository - or use your own!
	ln -s sites/site-rheinufer site                              # Link the site you want to compile images for
    make update                                                  # Get other repositories used by Gluon
    make                                                         # Build Gluon

When calling make, the OpenWRT build environment is prepared/updated. To rebuild
the images only, just use:

    make images

The built images can be found in the directory `images`.

For the build reserve 6GB of disk space. The building requires packages
for `subversion`, ncurses headers (`libncurses-dev`) and zlib headers
(`libz-dev`).`


There are three levels of `make clean`:

    make clean

will only clean the Gluon-specific files;

    make cleanall

will also call `make clean` on the OpenWRT tree, and

    make dirclean

will do all this, and call `make dirclean` on the OpenWRT tree.


# Development

**Gluon IRC channel: `#gluon` in hackint**

To update the repositories used by Gluon, just adjust the commit IDs in `modules` and
rerun

	make update

`make update` also applies the patches that can be found in the directories found in
`patches`; the resulting branch will be called `patched`, while the commit specified in `modules`
can be refered to by the branch `base`.

	make unpatch

sets the repositories to the `base` branch,

	make patch

re-applies the patches by resetting the `patched` branch to `base` and calling `git am`
for the patch files. Calling `make` or a similar command after calling `make unpatch`
is generally not a good idea.

After new patches have been commited on top of the patched branch (or existing commits
since the base commit have been edited or removed), the patch directories can be regenerated
using

	make update-patches

If applying a patch fails because you have changed the base commit, the repository will be reset to the old `patched` branch
and you can try rebasing it onto the new `base` branch yourself and after that call `make update-patches` to fix the problem.

Always call `make update-patches` after making changes to a module repository as `make update` will overwrite your
commits, making `git reflog` the only way to recover them!
