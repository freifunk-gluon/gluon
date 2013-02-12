GLUONDIR:=${CURDIR}

LN_S:=ln -sf

all: images

include $(GLUONDIR)/builder/gluon.mk

BOARD:=ar71xx
PROFILES:=TLWR741

null :=
space := ${null} ${null}
${space} := ${space}

prepared_stamp:=$(GLUON_BUILDDIR)/prepared

prepare:
	mkdir -p $(GLUON_IMAGEDIR) $(GLUON_BUILDDIR)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/opkg-$(BOARD).conf

	$(LN_S) $(GLUON_BUILDERDIR)/feeds.conf $(GLUON_OPENWRTDIR)/feeds.conf
	$(GLUON_OPENWRTDIR)/scripts/feeds uninstall -a
	$(GLUON_OPENWRTDIR)/scripts/feeds update -a
	$(GLUON_OPENWRTDIR)/scripts/feeds install -a

	echo -e "CONFIG_TARGET_$(BOARD)=y\nCONFIG_TARGET_ROOTFS_JFFS2=n\n$(subst ${ },\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(GLUON_PACKAGES)))" > $(GLUON_OPENWRTDIR)/.config
	$(MAKE) -C $(GLUON_OPENWRTDIR) defconfig prepare
	$(MAKE) -C $(GLUON_BUILDERDIR) kernel
	$(MAKE) -C $(GLUON_OPENWRTDIR) package/compile

	touch $(prepared_stamp)

$(prepared_stamp):
	$(MAKE) prepare

image-%: $(prepared_stamp)
	$(MAKE) -C $(GLUON_BUILDERDIR) image \
		PACKAGE_DIR=$(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages \
		PROFILE=$(subst image-,,$@)

images: $(patsubst %,image-%,$(PROFILES))

clean:
	rm -rf $(GLUON_BUILDDIR) $(prepared_stamp)

cleanall: clean
	$(MAKE) -C $(GLUON_OPENWRTDIR) clean

.PHONY: all images prepare clean cleanall
