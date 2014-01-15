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


update: FORCE
	$(GLUONDIR)/scripts/update.sh $(GLUONDIR)
	$(GLUONDIR)/scripts/patch.sh $(GLUONDIR)

patch: FORCE
	$(GLUONDIR)/scripts/patch.sh $(GLUONDIR)

unpatch: FORCE
	$(GLUONDIR)/scripts/unpatch.sh $(GLUONDIR)

update-patches: FORCE
	$(GLUONDIR)/scripts/update.sh $(GLUONDIR)
	$(GLUONDIR)/scripts/update-patches.sh $(GLUONDIR)
	$(GLUONDIR)/scripts/patch.sh $(GLUONDIR)

-include $(TOPDIR)/include/host.mk

_SINGLE=export MAKEFLAGS=$(space);

override OPENWRT_BUILD=1
GREP_OPTIONS=
export OPENWRT_BUILD GREP_OPTIONS

-include $(TOPDIR)/include/debug.mk
-include $(TOPDIR)/include/depends.mk
include $(GLUONDIR)/include/toplevel.mk

define GluonProfile
image/$(1): FORCE
	+@$$(GLUONMAKE) $$@
endef

include $(GLUONDIR)/include/profiles.mk

CheckExternal := test -d $(GLUON_OPENWRTDIR) || (echo 'You don'"'"'t seem to have optained the external repositories needed by Gluon; please call `make update` first!'; false)

all: FORCE
	@$(CheckExternal)
	+@$(GLUONMAKE) prepare
	+@$(GLUONMAKE) images

download prepare images: FORCE
	@$(CheckExternal)
	+@$(GLUONMAKE) $@

dirclean: clean
	@$(CheckExternal)
	+@$(SUBMAKE) -C $(TOPDIR) -r dirclean

cleanall: clean
	@$(CheckExternal)
	+@$(SUBMAKE) -C $(TOPDIR) -r clean

clean:
	@$(CheckExternal)
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
override SUBTARGET := generic

PROFILES :=
PROFILE_PACKAGES :=

gluon_prepared_stamp := $(GLUON_BUILDDIR)/$(BOARD)/prepared


define Profile
  $(eval $(call Profile/Default))
  $(eval $(call Profile/$(1)))
  $(1)_PACKAGES := $(PACKAGES)
endef

define GluonProfile
image/$(1): $(gluon_prepared_stamp)
	+$(GLUONMAKE) image PROFILE="$(1)" V=s$(OPENWRT_VERBOSE)

CheckSite := (perl $(GLUON_SITEDIR)/site.conf 2>&1) > /dev/null || (echo 'Your site configuration did not pass validation; please verify yourself with `perl site.conf` and fix the problems.';false)

PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$($(1)_PACKAGES) $(2) $(GLUON_$(1)_SITE_PACKAGES))
GLUON_$(1)_DEFAULT_PACKAGES := $(2)
endef

include $(INCLUDE_DIR)/target.mk
include $(GLUONDIR)/include/profiles.mk


$(BUILD_DIR)/.prepared: Makefile
	@mkdir -p $$(dirname $@)
	@touch $@

$(toolchain/stamp-install): $(tools/stamp-install)
$(package/stamp-compile): $(package/stamp-cleanup)

clean: FORCE
	rm -rf $(GLUON_BUILDDIR)

refresh_feeds: FORCE
	export MAKEFLAGS=V=s$(OPENWRT_VERBOSE); \
	export SCAN_COOKIE=; \
	scripts/feeds uninstall -a; \
	scripts/feeds update -a; \
	scripts/feeds install -a


export GLUON_GENERATE := $(GLUONDIR)/scripts/generate.sh
export GLUON_CONFIGURE := $(GLUONDIR)/scripts/configure.pl


feeds: FORCE
	. $(GLUONDIR)/modules && for feed in $$GLUON_FEEDS; do echo src-link $$feed ../../packages/$$feed; done > feeds.conf
	+$(GLUONMAKE) refresh_feeds V=s$(OPENWRT_VERBOSE)

config: FORCE
	echo \
		'CONFIG_TARGET_$(BOARD)=y' \
		'CONFIG_TARGET_ROOTFS_JFFS2=n' \
		'CONFIG_ATH_USER_REGD=y' \
		'$(patsubst %,CONFIG_PACKAGE_%=m,$(sort $(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES) $(PROFILE_PACKAGES)))' \
		| sed -e 's/ /\n/g' > .config
	$(_SINGLE)$(SUBMAKE) defconfig OPENWRT_BUILD=

.config:
	+$(GLUONMAKE) config

download: .config FORCE
	+$(SUBMAKE) tools/download
	+$(SUBMAKE) toolchain/download
	+$(SUBMAKE) package/download
	+$(SUBMAKE) target/download

toolchain: $(toolchain/stamp-install) $(tools/stamp-install)

include $(INCLUDE_DIR)/kernel.mk

kernel: FORCE
	+$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD) -f $(GLUONDIR)/include/Makefile.target $(LINUX_DIR)/.image TARGET_BUILD=1
	+$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD) -f $(GLUONDIR)/include/Makefile.target $(LINUX_DIR)/.modules TARGET_BUILD=1

packages: $(package/stamp-compile)
	$(_SINGLE)$(SUBMAKE) -r package/index

prepare-image: FORCE
	rm -rf $(BOARD_KDIR)
	mkdir -p $(BOARD_KDIR)
	cp $(KERNEL_BUILD_DIR)/vmlinux $(KERNEL_BUILD_DIR)/vmlinux.elf $(BOARD_KDIR)/
	+$(SUBMAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image -f $(GLUONDIR)/include/Makefile.image prepare KDIR="$(BOARD_KDIR)"

prepare: FORCE
	@$(CheckSite)

	mkdir -p $(GLUON_IMAGEDIR) $(GLUON_BUILDDIR)/$(BOARD)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(GLUON_BUILDDIR)/$(BOARD)/opkg.conf

	+$(GLUONMAKE) feeds
	+$(GLUONMAKE) config
	+$(GLUONMAKE) toolchain
	+$(GLUONMAKE) kernel
	+$(GLUONMAKE) packages
	+$(GLUONMAKE) prepare-image

	touch $(gluon_prepared_stamp)

$(gluon_prepared_stamp):
	+$(GLUONMAKE) prepare


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


enable_initscripts: FORCE
	cd $(TARGET_DIR) && ( export IPKG_INSTROOT=$(TARGET_DIR); \
		$(foreach script,$(wildcard $(TARGET_DIR)/etc/init.d/*), \
			$(call EnableInitscript,$(script)); \
		) : \
	)


# Generate package list
$(eval $(call merge-lists,INSTALL_PACKAGES,DEFAULT_PACKAGES $(PROFILE)_PACKAGES GLUON_DEFAULT_PACKAGES GLUON_SITE_PACKAGES GLUON_$(PROFILE)_DEFAULT_PACKAGES GLUON_$(PROFILE)_SITE_PACKAGES))

package_install: FORCE
	$(OPKG) update
	$(OPKG) install $(PACKAGE_DIR)/libc_*.ipk
	$(OPKG) install $(PACKAGE_DIR)/kernel_*.ipk

	$(OPKG) install $(INSTALL_PACKAGES)
	+$(GLUONMAKE) enable_initscripts

	rm -f $(TARGET_DIR)/usr/lib/opkg/lists/* $(TARGET_DIR)/tmp/opkg.lock

image: FORCE
	rm -rf $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(PROFILE_KDIR)
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(TARGET_DIR)/tmp
	cp -r $(BOARD_KDIR) $(PROFILE_KDIR)

	+$(GLUONMAKE) package_install

	$(call Image/mkfs/prepare)
	$(_SINGLE)$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 IMG_PREFIX="gluon-$(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))" \
		PROFILE="$(PROFILE)" KDIR="$(PROFILE_KDIR)" TARGET_DIR="$(TARGET_DIR)" BIN_DIR="$(BIN_DIR)" TMP_DIR="$(TMP_DIR)"


call_image/%: FORCE
	+$(GLUONMAKE) $(patsubst call_image/%,image/%,$@)

images: $(patsubst %,call_image/%,$(PROFILES)) ;

.PHONY: all images prepare clean cleanall

endif
