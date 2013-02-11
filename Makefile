TOPDIR:=${CURDIR}

LN_S:=ln -sf

IMAGEDIR:=$(TOPDIR)/images
OPENWRTDIR:=$(TOPDIR)/openwrt
BUILDERDIR:=$(TOPDIR)/builder

BOARD:=ar71xx

all :
	mkdir -p $(IMAGEDIR)
	$(LN_S) $(BUILDERDIR)/feeds.conf $(OPENWRTDIR)/feeds.conf
	$(LN_S) $(BUILDERDIR)/config-$(BOARD) $(OPENWRTDIR)/.config

	$(MAKE) -C $(OPENWRTDIR) package/symlinks prepare package/compile 
	$(MAKE) -C $(BUILDERDIR) image BIN_DIR=$(IMAGEDIR) PACKAGE_DIR=$(OPENWRTDIR)/bin/$(BOARD)/packages PROFILE=TLWR741
