To build Gluon, use the following commands after checking out the repository:

    git submodule update --init                                  # Get other repositories used by Gluon
    git clone git://github.com/freifunk-gluon/site-ffhl.git site # Get the Freifunk Lübeck site repository - or use your own!
    make                                                         # Build Gluon

When calling make, the OpenWRT build environment is prepared/updated. To rebuilt
the images only, just use:

    make images

The built images can be found in the directory /images.


There are three levels of 'make clean':

    make clean

will only clean the Gluon-specific files;

    make cleanall

will also call 'make clean' on the OpenWRT tree, and

    make dirclean

will do all this, and call 'make dirclean' on the OpenWRT tree.
