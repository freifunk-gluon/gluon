To build Gluon, after checking out the repository change to the source root directory
to  perform the following commands:

    git clone git://github.com/freifunk-gluon/site-ffhl.git site # Get the Freifunk Lübeck site repository - or use your own!
    make update                                                  # Get other repositories used by Gluon
    make                                                         # Build Gluon

When calling make, the OpenWRT build environment is prepared/updated. To rebuild
the images only, just use:

    make images

The built images can be found in the directory `images`.

For the build reserve 6GB of disk space. The build requires packages
for `subversion`, ncurses headers (`libncurses-dev`) and zlib headers
(`libz-dev`).`


There are two levels of `make clean`:

    make clean

will ensure all packages are rebuilt; this is what you normally want to do after an update.

    make dirclean

will clean the entire tree, so the toolchain will be rebuilt as well, which is
not necessary in most cases, and will take a while. (`make cleanall` is a deprecated
alias for `make clean`)

So all in all, to update and rebuild a Gluon build tree, the following commands should be used:

    git pull
    (cd site && git pull)
    make update
    make clean
    make


# The autoupdater

Gluon contains an automatic update system which can be configured in the site configuration.

By default, the autoupdater is disabled (as it is usually not helpful to have unexpected updates
during development), but it can be enabled by setting the variable GLUON_BRANCH when building
to override the default branch set in the set in the site configuration.

A manifest file for the updater can be generated with `make manifest`. A signing script (using
ecdsautils) can by found in the `contrib` directory.

A fully automated nightly build could use the following commands:

    git pull
    (cd site && git pull)
    make update
    make clean
    make -j5 GLUON_BRANCH=experimental
    make manifest GLUON_BRANCH=experimental
    contrib/sign.sh $SECRETKEY images/sysupgrade/experimental.manifest
    cp -r images /where/to/put/this/experimental
    mv /where/to/put/this/experimental/experimental.manifest /where/to/put/this/experimental/manifest


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
