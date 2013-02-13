# Makefile for OpenWrt
#
# Copyright (C) 2007-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

GLUONDIR:=${CURDIR}/..

include ${CURDIR}/gluon.mk

TOPDIR:=$(GLUON_OPENWRTDIR)
LC_ALL:=C
LANG:=C
export TOPDIR LC_ALL LANG
export OPENWRT_VERBOSE=s
all: image

include $(TOPDIR)/include/host.mk

ifneq ($(OPENWRT_BUILD),1)
  override OPENWRT_BUILD=1
  export OPENWRT_BUILD
endif

include rules.mk
include $(INCLUDE_DIR)/debug.mk
include $(INCLUDE_DIR)/depends.mk

include $(INCLUDE_DIR)/version.mk

REVISION:=$(shell $(GLUON_BUILDERDIR)/openwrt_rev.sh $(GLUONDIR))
export REVISION

include $(INCLUDE_DIR)/package-ipkg.mk

# override variables from rules.mk
OPKG:= \
  IPKG_TMP="$(TOPDIR)/tmp/ipkgtmp" \
  IPKG_INSTROOT="$(TARGET_DIR)" \
  IPKG_CONF_DIR="$(TOPDIR)/tmp" \
  IPKG_OFFLINE_ROOT="$(TARGET_DIR)" \
  $(STAGING_DIR_HOST)/bin/opkg \
	-f $(GLUONDIR)/build/opkg-$(BOARD).conf \
	--force-depends \
	--force-overwrite \
	--force-postinstall \
	--cache $(TOPDIR)/dl \
	--offline-root $(TARGET_DIR) \
	--add-dest root:/ \
	--add-arch all:100 \
	--add-arch $(ARCH_PACKAGES):200

define Profile
  $(eval $(call Profile/Default))
  $(eval $(call Profile/$(1)))
  ifeq ($(USER_PROFILE),)
    USER_PROFILE:=$(1)
  endif
  $(1)_NAME:=$(NAME)
  $(1)_PACKAGES:=$(PACKAGES)
endef

include $(INCLUDE_DIR)/target.mk

BUILD_PACKAGES:=$(sort $(DEFAULT_PACKAGES) $(USER_PACKAGES) $($(USER_PROFILE)_PACKAGES) kernel)
# "-pkgname" in the package list means remove "pkgname" from the package list
BUILD_PACKAGES:=$(filter-out $(filter -%,$(BUILD_PACKAGES)) $(patsubst -%,%,$(filter -%,$(BUILD_PACKAGES))),$(BUILD_PACKAGES))
PACKAGES:=

include $(INCLUDE_DIR)/kernel-build.mk

prepare: FORCE
	$(Kernel/CompileImage)
	$(MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image -f $(GLUON_BUILDERDIR)/Makefile.image prepare
	$(MAKE) package_index

_call_image:
	echo 'Building images for $(BOARD)$(if $($(USER_PROFILE)_NAME), - $($(USER_PROFILE)_NAME))'
	echo 'Packages: $(BUILD_PACKAGES)'
	echo
	rm -rf $(TARGET_DIR)
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(TARGET_DIR)/tmp
	$(OPKG) update
	$(MAKE) package_install
ifneq ($(USER_FILES),)
	$(MAKE) copy_files
endif
	$(MAKE) package_postinst
	$(MAKE) build_image

package_index: FORCE
	@echo
	@echo Building package index...
	(cd $(PACKAGE_DIR); $(SCRIPT_DIR)/ipkg-make-index.sh . > Packages && \
		gzip -9c Packages > Packages.gz \
	) >/dev/null 2>/dev/null

package_install: FORCE
	@echo
	@echo Installing packages...
	$(OPKG) install $(PACKAGE_DIR)/libc_*.ipk
	$(OPKG) install $(PACKAGE_DIR)/kernel_*.ipk
	$(OPKG) install $(BUILD_PACKAGES)
	rm -f $(TARGET_DIR)/usr/lib/opkg/lists/*

copy_files: FORCE
	@echo
	@echo Copying extra files
	@( cd $(USER_FILES); find -type f ) | \
		( cd $(TARGET_DIR); while :; do \
			read FILE; \
			[ -z "$$FILE" ] && break; \
			[ -L "$$FILE" ] || continue; \
			echo "Removing symlink $(TARGET_DIR)/$$FILE"; \
			rm -f "$$FILE"; \
		done; )
	$(CP) $(USER_FILES)/* $(TARGET_DIR)/

package_postinst: FORCE
	@echo
	@echo Cleaning up
	@rm -f $(TARGET_DIR)/tmp/opkg.lock
	@echo
	@echo Activating init scripts
	@( \
		cd $(TARGET_DIR); \
		for script in ./etc/init.d/*; do \
			grep '#!/bin/sh /etc/rc.common' $$script >/dev/null || continue; \
			IPKG_INSTROOT=$(TARGET_DIR) $(which bash) ./etc/rc.common $$script enable; \
		done || true; \
	)
	$(if $(CONFIG_CLEAN_IPKG),rm -rf $(TARGET_DIR)/usr/lib/opkg)

include $(INCLUDE_DIR)/image.mk

build_image: FORCE
	@echo
	@echo Building images...
	$(call Image/mkfs/prepare)
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 IMG_PREFIX="gluon-$(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))" \
		$(if $(USER_PROFILE),PROFILE="$(USER_PROFILE)")

image:
	(unset PROFILE FILES PACKAGES MAKEFLAGS; \
	$(MAKE) _call_image \
		$(if $(PROFILE),USER_PROFILE="$(PROFILE)") \
		$(if $(FILES),USER_FILES="$(FILES)") \
		$(if $(PACKAGES),USER_PACKAGES="$(PACKAGES)") \
		BIN_DIR="$(GLUON_IMAGEDIR)" \
		$(if $(PACKAGE_DIR),PACKAGE_DIR="$(PACKAGE_DIR)"))

.SILENT: kernel image

