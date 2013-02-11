GLUONDIR:=${CURDIR}

LN_S:=ln -sf

all: images

include $(GLUONDIR)/builder/gluon.mk

BOARD:=ar71xx
PROFILES:=TLWR741

null :=
space := ${null} ${null}
${space} := ${space}

prepare:
	mkdir -p $(GLUON_IMAGEDIR) $(GLUON_BUILDDIR)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/opkg-$(BOARD).conf

	$(LN_S) $(GLUON_BUILDERDIR)/feeds.conf $(GLUON_OPENWRTDIR)/feeds.conf
	$(GLUON_OPENWRTDIR)/scripts/feeds uninstall -a
	$(GLUON_OPENWRTDIR)/scripts/feeds update -a
	$(GLUON_OPENWRTDIR)/scripts/feeds install -a

	echo 'CONFIG_TARGET_$(BOARD)=y' > $(GLUON_OPENWRTDIR)/.config
	echo -e "$(subst ${ },\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(GLUON_PACKAGES)))" >> $(GLUON_OPENWRTDIR)/.config
	$(MAKE) -C $(GLUON_OPENWRTDIR) defconfig prepare package/compile

image-%: prepare
	$(MAKE) -C $(GLUON_BUILDERDIR) image \
		PACKAGE_DIR=$(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages \
		PROFILE=$(subst image-,,$@)

images: $(patsubst %,image-%,$(PROFILES))

.PHONY: all images prepare
