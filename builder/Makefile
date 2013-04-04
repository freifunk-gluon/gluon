# Greatly modified OpenWRT Image Builder Makefile
#
# Copyright (C) 2007-2010 OpenWrt.org
# Copyright (C) 2013 Project Gluon
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

all: image

include ${CURDIR}/../include/gluon.mk

include $(TOPDIR)/include/host.mk
include $(TOPDIR)/rules.mk

PACKAGE_DIR := $(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages
BIN_DIR := $(GLUON_IMAGEDIR)/$(BOARD)/$(PROFILE)

PROFILE_BUILDDIR := $(BOARD_BUILDDIR)/$(PROFILE)
PROFILE_KDIR := $(PROFILE_BUILDDIR)/kernel

TMP_DIR := $(PROFILE_BUILDDIR)/tmp
TARGET_DIR := $(PROFILE_BUILDDIR)/root

include $(INCLUDE_DIR)/debug.mk
include $(INCLUDE_DIR)/depends.mk

include $(INCLUDE_DIR)/version.mk

REVISION:=$(shell $(GLUONDIR)/scripts/openwrt_rev.sh $(GLUONDIR))
export REVISION

include $(INCLUDE_DIR)/package-ipkg.mk

# override variables from rules.mk
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

define Profile
  $(eval $(call Profile/Default))
  $(eval $(call Profile/$(1)))
  ifeq ($(PROFILE),)
    PROFILE:=$(1)
  endif
  $(1)_NAME:=$(NAME)
  $(1)_PACKAGES:=$(PACKAGES)
endef

include $(INCLUDE_DIR)/target.mk

define GluonProfile
  GLUON_$(1)_DEFAULT_PACKAGES := $(2)
endef

include $(GLUONDIR)/include/profiles.mk

# Generate package list s
$(eval $(call merge-lists,BASE_PACKAGES,DEFAULT_PACKAGES $(PROFILE)_PACKAGES))
$(eval $(call merge-lists,GLUON_PACKAGES,GLUON_DEFAULT_PACKAGES GLUON_SITE_PACKAGES GLUON_$(PROFILE)_DEFAULT_PACKAGES GLUON_$(PROFILE)_SITE_PACKAGES))

include $(INCLUDE_DIR)/image.mk

define EnableInitscript
	( \
		grep '#!/bin/sh /etc/rc.common' $(1) >/dev/null && \
		IPKG_INSTROOT=$(TARGET_DIR) $(which bash) ./etc/rc.common $(1) enable || \
		true \
	)
endef

define FileOrigin
	$(firstword $(shell $(OPKG) search $(1)))
endef

enable_initscripts: FORCE
	cd $(TARGET_DIR) && ( \
		$(foreach script,$(wildcard $(TARGET_DIR)/etc/init.d/*), \
			$(if $(filter $(ENABLE_INITSCRIPTS_FROM),$(call FileOrigin,$(script))),$(call EnableInitscript,$(script));) \
		) : \
	)

package_install: FORCE
	$(OPKG) update
	$(OPKG) install $(PACKAGE_DIR)/libc_*.ipk
	$(OPKG) install $(PACKAGE_DIR)/kernel_*.ipk

	$(OPKG) install $(BASE_PACKAGES)
	$(NO_TRACE_MAKE) enable_initscripts ENABLE_INITSCRIPTS_FROM=%

	$(OPKG) install $(GLUON_PACKAGES)
	$(NO_TRACE_MAKE) enable_initscripts ENABLE_INITSCRIPTS_FROM="$(GLUON_PACKAGES)"

	rm -f $(TARGET_DIR)/usr/lib/opkg/lists/* $(TARGET_DIR)/tmp/opkg.lock

image: FORCE
	rm -rf $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(PROFILE_KDIR)
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(TARGET_DIR)/tmp
	cp -r $(BOARD_KDIR) $(PROFILE_KDIR)

	$(NO_TRACE_MAKE) package_install

	$(call Image/mkfs/prepare)
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 IMG_PREFIX="gluon-$(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))" \
		PROFILE="$(PROFILE)" KDIR="$(PROFILE_KDIR)" TARGET_DIR="$(TARGET_DIR)" BIN_DIR="$(BIN_DIR)" TMP_DIR="$(TMP_DIR)"
