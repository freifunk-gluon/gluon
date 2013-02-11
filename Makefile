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
	$(LN_S) $(GLUON_BUILDERDIR)/feeds.conf $(GLUON_OPENWRTDIR)/feeds.conf
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/opkg-$(BOARD).conf

	echo 'CONFIG_TARGET_$(BOARD)=y' > $(GLUON_OPENWRTDIR)/.config
	echo -e "$(subst ${ },\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(GLUON_PACKAGES)))" >> $(GLUON_OPENWRTDIR)/.config
	$(MAKE) -C $(GLUON_OPENWRTDIR) defconfig package/symlinks prepare package/compile

image-%: prepare
	$(MAKE) -C $(GLUON_BUILDERDIR) image \
		BIN_DIR=$(GLUON_IMAGEDIR) \
		PACKAGE_DIR=$(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages \
		PROFILE=$(subst image-,,$@)

images: $(patsubst %,image-%,$(PROFILES))

.PHONY: all images prepare
