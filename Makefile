GLUONDIR:=${CURDIR}

LN_S:=ln -sf

all:
	$(MAKE) prepare
	$(MAKE) images

include $(GLUONDIR)/builder/gluon.mk

BOARD := ar71xx
PROFILES :=
PROFILE_PACKAGES :=

null :=
space := ${null} ${null}
${space} := ${space}

prepared_stamp := $(GLUON_BUILDDIR)/prepared

define GluonProfile
image/$(1): $(prepared_stamp)
	$(MAKE) -C $(GLUON_BUILDERDIR) image \
		PROFILE="$(1)" \
		PACKAGE_DIR="$(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages" \
		$(if $(2),PACKAGES="$(2)")

PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$(2))
endef

include profiles.mk

prepare:
	mkdir -p $(GLUON_IMAGEDIR) $(GLUON_BUILDDIR)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/opkg-$(BOARD).conf

	$(LN_S) $(GLUON_BUILDERDIR)/feeds.conf $(GLUON_OPENWRTDIR)/feeds.conf
	$(GLUON_OPENWRTDIR)/scripts/feeds uninstall -a
	$(GLUON_OPENWRTDIR)/scripts/feeds update -a
	$(GLUON_OPENWRTDIR)/scripts/feeds install -a

	echo -e "CONFIG_TARGET_$(BOARD)=y\nCONFIG_TARGET_ROOTFS_JFFS2=n\n$(subst ${ },\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(GLUON_PACKAGES) $(PROFILE_PACKAGES)))" > $(GLUON_OPENWRTDIR)/.config
	$(MAKE) -C $(GLUON_OPENWRTDIR) defconfig prepare
	$(MAKE) -C $(GLUON_BUILDERDIR) kernel
	$(MAKE) -C $(GLUON_OPENWRTDIR) package/compile

	touch $(prepared_stamp)

$(prepared_stamp):
	$(MAKE) prepare

images:
	for profile in $(PROFILES); do $(MAKE) image/$$profile; done

clean:
	rm -rf $(GLUON_BUILDDIR)

cleanall: clean
	$(MAKE) -C $(GLUON_OPENWRTDIR) clean

.PHONY: all images prepare clean cleanall
