all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG

GLUONMAKE = $(SUBMAKE) -C $(GLUON_OPENWRTDIR) -f $(GLUONDIR)/Makefile

ifneq ($(OPENWRT_BUILD),1)

GLUONDIR:=${CURDIR}

include $(GLUONDIR)/builder/gluon.mk

TOPDIR:=$(GLUON_OPENWRTDIR)
export TOPDIR

include $(TOPDIR)/include/host.mk

empty:=
space:= $(empty) $(empty)
_SINGLE=export MAKEFLAGS=$(space);

override OPENWRT_BUILD=1
GREP_OPTIONS=
export OPENWRT_BUILD GREP_OPTIONS
include $(TOPDIR)/include/debug.mk
include $(TOPDIR)/include/depends.mk
include $(TOPDIR)/include/toplevel.mk

all: FORCE
	+@$(GLUONMAKE) prepare
	+@$(GLUONMAKE) images

prepare: FORCE
	+@$(GLUONMAKE) prepare

images: FORCE
	+@$(GLUONMAKE) images

clean: clean-gluon

clean-gluon:
	rm -rf $(GLUON_BUILDDIR)

else

include $(GLUONDIR)/builder/gluon.mk

include $(TOPDIR)/include/host.mk

include rules.mk
include $(INCLUDE_DIR)/depends.mk
include $(INCLUDE_DIR)/subdir.mk
include target/Makefile
include package/Makefile
include tools/Makefile
include toolchain/Makefile

null :=
space := ${null} ${null}
${space} := ${space}

BOARD := ar71xx
PROFILES :=
PROFILE_PACKAGES :=

gluon_prepared_stamp := $(GLUON_BUILDDIR)/$(BOARD)/prepared

define GluonProfile
image/$(1): $(gluon_prepared_stamp)
	$(MAKE) -C $(GLUON_BUILDERDIR) image \
		PROFILE="$(1)" \
		$(if $(2),PACKAGES="$(2)")

PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$(2))
endef

include $(GLUONDIR)/profiles.mk

$(BUILD_DIR)/.prepared: Makefile
	@mkdir -p $$(dirname $@)
	@touch $@

$(toolchain/stamp-install): $(tools/stamp-install)
$(target/stamp-compile): $(toolchain/stamp-install) $(tools/stamp-install) $(BUILD_DIR)/.prepared
$(package/stamp-cleanup): $(target/stamp-compile)
$(package/stamp-compile): $(target/stamp-compile) $(package/stamp-cleanup)
$(package/stamp-install): $(package/stamp-compile)
$(package/stamp-rootfs-prepare): $(package/stamp-install)
$(target/stamp-install): $(package/stamp-compile) $(package/stamp-install) $(package/stamp-rootfs-prepare)

feeds: FORCE
	ln -sf $(GLUON_BUILDERDIR)/feeds.conf feeds.conf

	scripts/feeds uninstall -a
	scripts/feeds update -a
	scripts/feeds install -a

	rm -f $(TMP_DIR)/info/.files-packageinfo-$(SCAN_COOKIE)
	$(SUBMAKE) prepare-tmpinfo OPENWRT_BUILD=0

config: FORCE
	echo -e 'CONFIG_TARGET_$(BOARD)=y\nCONFIG_TARGET_ROOTFS_JFFS2=n\n$(subst ${ },\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(GLUON_PACKAGES) $(PROFILE_PACKAGES)))' > .config
	$(SUBMAKE) defconfig OPENWRT_BUILD=0

toolchain: $(toolchain/stamp-install) $(tools/stamp-install)
target: $(target/stamp-compile)
packages: $(package/stamp-compile)

prepare: FORCE
	mkdir -p $(GLUON_IMAGEDIR) $(GLUON_BUILDDIR)/$(BOARD)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/$(BOARD)/opkg.conf

	$(GLUONMAKE) feeds
	$(GLUONMAKE) config
	$(GLUONMAKE) toolchain
	$(GLUONMAKE) target
	$(GLUONMAKE) packages
	$(SUBMAKE) -C $(GLUON_BUILDERDIR) prepare

	touch $(gluon_prepared_stamp)

$(gluon_prepared_stamp):
	$(MAKE) prepare

images: $(patsubst %,image/%,$(PROFILES))

.PHONY: all images prepare clean cleanall

endif
