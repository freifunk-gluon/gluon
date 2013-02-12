To build Gluon, use the following commands after checking out the repository:

    git submodule update --init						# Get other repositories used by Gluon
    git clone git://github.com/freifunk-gluon/site-ffhl.git site	# Get the Freifunk Lübeck site repository - or use your own!
    make								# Build Gluon

When building Gluon for the first time, the OpenWRT build environment is prepared. To update the OpenWRT
environment, e. g. to compile added or changed packages, just use:

    make prepare

The built images can be found in the directory /images.
