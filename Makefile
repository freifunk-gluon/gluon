all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG

empty:=
space:= $(empty) $(empty)

GLUONMAKE = $(SUBMAKE) -C $(GLUON_OPENWRTDIR) -f $(GLUONDIR)/Makefile

ifneq ($(OPENWRT_BUILD),1)

GLUONDIR:=${CURDIR}

include $(GLUONDIR)/include/gluon.mk

TOPDIR:=$(GLUON_OPENWRTDIR)
export TOPDIR

include $(TOPDIR)/include/host.mk

_SINGLE=export MAKEFLAGS=$(space);

override OPENWRT_BUILD=1
override REVISION:=$(shell $(GLUONDIR)/scripts/openwrt_rev.sh $(GLUONDIR))
GREP_OPTIONS=
export OPENWRT_BUILD GREP_OPTIONS REVISION

include $(TOPDIR)/include/debug.mk
include $(TOPDIR)/include/depends.mk
include $(GLUONDIR)/include/toplevel.mk

define GluonProfile
image/$(1): FORCE
	+@$$(GLUONMAKE) $$@
endef

include $(GLUONDIR)/include/profiles.mk

all: FORCE
	+@$(GLUONMAKE) prepare
	+@$(GLUONMAKE) images

download prepare images: FORCE
	+@$(GLUONMAKE) $@

dirclean: clean
	+@$(SUBMAKE) -C $(TOPDIR) -r dirclean

cleanall: clean
	+@$(SUBMAKE) -C $(TOPDIR) -r clean

clean:
	+@$(GLUONMAKE) clean

else

include $(GLUONDIR)/include/gluon.mk

include $(TOPDIR)/include/host.mk

include rules.mk
include $(INCLUDE_DIR)/depends.mk
include $(INCLUDE_DIR)/subdir.mk

include package/Makefile
include tools/Makefile
include toolchain/Makefile

BOARD := ar71xx
PROFILES :=
PROFILE_PACKAGES :=

gluon_prepared_stamp := $(GLUON_BUILDDIR)/$(BOARD)/prepared


define GluonProfile
image/$(1): $(gluon_prepared_stamp)
	$(GLUONMAKE) image PROFILE="$(1)" V=s$(OPENWRT_VERBOSE)

PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$(2) $(GLUON_$(1)_SITE_PACKAGES))
GLUON_$(1)_DEFAULT_PACKAGES := $(2)
endef

include $(GLUONDIR)/include/profiles.mk


$(BUILD_DIR)/.prepared: Makefile
	@mkdir -p $$(dirname $@)
	@touch $@

$(toolchain/stamp-install): $(tools/stamp-install)
$(package/stamp-compile): $(package/stamp-cleanup)

clean: FORCE
	rm -rf $(GLUON_BUILDDIR)

refresh_feeds: FORCE
	( \
		export SCAN_COOKIE=; \
		scripts/feeds uninstall -a; \
		scripts/feeds update -a; \
		scripts/feeds install -a; \
	)


export define FEEDS
src-link gluon ../../packages_gluon
src-link packages ../../packages_openwrt
src-link routing ../../packages_routing
src-svn luci http://svn.luci.subsignal.org/luci/tags/0.11.1/contrib/package
endef

feeds: FORCE
	rm -f feeds.conf
	echo "$$FEEDS" > feeds.conf
	$(GLUONMAKE) refresh_feeds V=s$(OPENWRT_VERBOSE)

config: FORCE
	echo -e 'CONFIG_TARGET_$(BOARD)=y\nCONFIG_TARGET_ROOTFS_JFFS2=n\n$(subst ${space},\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(sort $(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES) $(PROFILE_PACKAGES))))' > .config
	$(SUBMAKE) defconfig OPENWRT_BUILD=

.config:
	$(GLUONMAKE) config

download: .config FORCE
	$(SUBMAKE) tools/download
	$(SUBMAKE) toolchain/download
	$(SUBMAKE) package/download
	$(SUBMAKE) target/download

toolchain: $(toolchain/stamp-install) $(tools/stamp-install)

include $(INCLUDE_DIR)/kernel.mk

kernel: FORCE
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD) -f $(GLUONDIR)/include/Makefile.target $(LINUX_DIR)/.image TARGET_BUILD=1
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD) -f $(GLUONDIR)/include/Makefile.target $(LINUX_DIR)/.modules TARGET_BUILD=1

packages: $(package/stamp-compile)
	$(_SINGLE)$(SUBMAKE) -r package/index

prepare-image: FORCE
	rm -rf $(BOARD_KDIR)
	mkdir -p $(BOARD_KDIR)
	cp $(KERNEL_BUILD_DIR)/vmlinux $(KERNEL_BUILD_DIR)/vmlinux.elf $(BOARD_KDIR)/
	$(SUBMAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image -f $(GLUONDIR)/include/Makefile.image prepare KDIR="$(BOARD_KDIR)"

prepare: FORCE
	mkdir -p $(GLUON_IMAGEDIR) $(GLUON_BUILDDIR)/$(BOARD)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/$(BOARD)/opkg.conf

	$(GLUONMAKE) feeds
	$(GLUONMAKE) config
	$(GLUONMAKE) toolchain
	$(GLUONMAKE) kernel
	$(GLUONMAKE) packages
	$(GLUONMAKE) prepare-image

	touch $(gluon_prepared_stamp)

$(gluon_prepared_stamp):
	$(GLUONMAKE) prepare


include $(INCLUDE_DIR)/package-ipkg.mk

# override variables from rules.mk
PACKAGE_DIR = $(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages
BIN_DIR = $(GLUON_IMAGEDIR)/$(BOARD)/$(PROFILE)

PROFILE_BUILDDIR = $(BOARD_BUILDDIR)/$(PROFILE)
PROFILE_KDIR = $(PROFILE_BUILDDIR)/kernel

TMP_DIR = $(PROFILE_BUILDDIR)/tmp
TARGET_DIR = $(PROFILE_BUILDDIR)/root

OPKG:= \
  IPKG_TMP="$(TMP_DIR)/ipkgtmp" \
  IPKG_INSTROOT="$(TARGET_DIR)" \
  IPKG_CONF_DIR="$(TMP_DIR)" \
  IPKG_OFFLINE_ROOT="$(TARGET_DIR)" \
  $(STAGING_DIR_HOST)/bin/opkg \
	-f $(BOARD_BUILDDIR)/opkg.conf \
	--force-depends \
	--force-overwrite \
	--force-postinstall \
	--cache $(TMP_DIR)/dl \
	--offline-root $(TARGET_DIR) \
	--add-dest root:/ \
	--add-arch all:100 \
	--add-arch $(ARCH_PACKAGES):200

EnableInitscript = ! grep -q '\#!/bin/sh /etc/rc.common' $(1) || bash ./etc/rc.common $(1) enable
FileOrigin = $(firstword $(shell $(OPKG) search $(1)))


enable_initscripts: FORCE
	cd $(TARGET_DIR) && ( export IPKG_INSTROOT=$(TARGET_DIR); \
		$(foreach script,$(wildcard $(TARGET_DIR)/etc/init.d/*), \
			$(if $(filter $(ENABLE_INITSCRIPTS_FROM),$(call FileOrigin,$(script))),$(call EnableInitscript,$(script));) \
		) : \
	)


# Generate package lists
$(eval $(call merge-lists,BASE_PACKAGES,DEFAULT_PACKAGES $(PROFILE)_PACKAGES))
$(eval $(call merge-lists,GLUON_PACKAGES,GLUON_DEFAULT_PACKAGES GLUON_SITE_PACKAGES GLUON_$(PROFILE)_DEFAULT_PACKAGES GLUON_$(PROFILE)_SITE_PACKAGES))

package_install: FORCE
	$(OPKG) update
	$(OPKG) install $(PACKAGE_DIR)/libc_*.ipk
	$(OPKG) install $(PACKAGE_DIR)/kernel_*.ipk

	$(OPKG) install $(BASE_PACKAGES)
	$(GLUONMAKE) enable_initscripts ENABLE_INITSCRIPTS_FROM=%

	$(OPKG) install $(GLUON_PACKAGES)
	$(GLUONMAKE) enable_initscripts ENABLE_INITSCRIPTS_FROM="$(GLUON_PACKAGES)"

	rm -f $(TARGET_DIR)/usr/lib/opkg/lists/* $(TARGET_DIR)/tmp/opkg.lock

image: FORCE
	rm -rf $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(PROFILE_KDIR)
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(TARGET_DIR)/tmp
	cp -r $(BOARD_KDIR) $(PROFILE_KDIR)

	$(GLUONMAKE) package_install

	$(call Image/mkfs/prepare)
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 IMG_PREFIX="gluon-$(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))" \
		PROFILE="$(PROFILE)" KDIR="$(PROFILE_KDIR)" TARGET_DIR="$(TARGET_DIR)" BIN_DIR="$(BIN_DIR)" TMP_DIR="$(TMP_DIR)"


call_image/%: FORCE
	$(GLUONMAKE) $(patsubst call_image/%,image/%,$@)

images: $(patsubst %,call_image/%,$(PROFILES)) ;

.PHONY: all images prepare clean cleanall

endif
