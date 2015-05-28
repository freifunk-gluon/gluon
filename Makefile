all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG

empty:=
space:= $(empty) $(empty)

GLUONMAKE_EARLY = $(SUBMAKE) -C $(GLUON_ORIGOPENWRTDIR) -f $(GLUONDIR)/Makefile GLUON_TOOLS=0
GLUONMAKE = $(SUBMAKE) -C $(GLUON_OPENWRTDIR) -f $(GLUONDIR)/Makefile

ifneq ($(OPENWRT_BUILD),1)

GLUONDIR:=${CURDIR}

include $(GLUONDIR)/include/gluon.mk

TOPDIR:=$(GLUON_ORIGOPENWRTDIR)
export TOPDIR


update: FORCE
	$(GLUONDIR)/scripts/update.sh
	$(GLUONDIR)/scripts/patch.sh

patch: FORCE
	$(GLUONDIR)/scripts/patch.sh

unpatch: FORCE
	$(GLUONDIR)/scripts/unpatch.sh

update-patches: FORCE
	$(GLUONDIR)/scripts/update.sh
	$(GLUONDIR)/scripts/update-patches.sh
	$(GLUONDIR)/scripts/patch.sh

-include $(TOPDIR)/include/host.mk

_SINGLE=export MAKEFLAGS=$(space);

override OPENWRT_BUILD=1
override GLUON_TOOLS=1
GREP_OPTIONS=
export OPENWRT_BUILD GLUON_TOOLS GREP_OPTIONS

-include $(TOPDIR)/include/debug.mk
-include $(TOPDIR)/include/depends.mk
include $(GLUONDIR)/include/toplevel.mk


include $(GLUONDIR)/targets/targets.mk


CheckTarget := [ -n '$(GLUON_TARGET)' -a -n '$(GLUON_TARGET_$(GLUON_TARGET)_BOARD)' -a -n '$(GLUON_TARGET_$(GLUON_TARGET)_SUBTARGET)' ] \
	|| (echo -e 'Please set GLUON_TARGET to a valid target. Gluon supports the following targets:$(subst $(space),\n * ,$(GLUON_TARGETS))'; false)


CheckExternal := test -d $(GLUON_ORIGOPENWRTDIR) || (echo 'You don'"'"'t seem to have obtained the external repositories needed by Gluon; please call `make update` first!'; false)


prepare-target: FORCE
	@$(CheckExternal)
	@$(CheckTarget)
	+@$(GLUONMAKE_EARLY) prepare-target


all: prepare-target
	+@$(GLUONMAKE) prepare
	+@$(GLUONMAKE) images

prepare: prepare-target
	+@$(GLUONMAKE) $@

clean download images: FORCE
	@$(CheckExternal)
	@$(CheckTarget)
	+@$(GLUONMAKE_EARLY) maybe-prepare-target
	+@$(GLUONMAKE) $@

toolchain/% package/% target/% image/%: FORCE
	@$(CheckExternal)
	@$(CheckTarget)
	+@$(GLUONMAKE_EARLY) maybe-prepare-target
	+@$(GLUONMAKE) $@

manifest: FORCE
	@[ -n '$(GLUON_BRANCH)' ] || (echo 'Please set GLUON_BRANCH to create a manifest.'; false)
	@echo '$(GLUON_PRIORITY)' | grep -qE '^([0-9]*\.)?[0-9]+$$' || (echo 'Please specify a numeric value for GLUON_PRIORITY to create a manifest.'; false)
	@$(CheckExternal)

	( \
		echo 'BRANCH=$(GLUON_BRANCH)' && \
		echo 'DATE=$(shell $(GLUON_ORIGOPENWRTDIR)/staging_dir/host/bin/lua $(GLUONDIR)/scripts/rfc3339date.lua)' && \
		echo 'PRIORITY=$(GLUON_PRIORITY)' && \
		echo \
	) > $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp

	+($(foreach GLUON_TARGET,$(GLUON_TARGETS), \
		( [ ! -e $(BOARD_BUILDDIR)/prepared ] || ( $(GLUONMAKE) manifest GLUON_TARGET='$(GLUON_TARGET)' V=s$(OPENWRT_VERBOSE) ) ) && \
	) :)

	mkdir -p $(GLUON_IMAGEDIR)/sysupgrade
	mv $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp $(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_BRANCH).manifest

dirclean : FORCE
	for dir in build_dir dl staging_dir tmp; do \
		rm -rf $(GLUON_ORIGOPENWRTDIR)/$$dir; \
	done
	rm -rf $(GLUON_BUILDDIR) $(GLUON_IMAGEDIR)

else

TOPDIR=${CURDIR}
export TOPDIR

include rules.mk

include $(GLUONDIR)/include/gluon.mk

include $(INCLUDE_DIR)/host.mk
include $(INCLUDE_DIR)/depends.mk
include $(INCLUDE_DIR)/subdir.mk

include package/Makefile
include tools/Makefile
include toolchain/Makefile
include target/Makefile


PROFILES :=
PROFILE_PACKAGES :=

define Profile
  $(eval $(call Profile/Default))
  $(eval $(call Profile/$(1)))
endef

define GluonProfile
PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$(2) $(GLUON_$(1)_SITE_PACKAGES))
GLUON_$(1)_DEFAULT_PACKAGES := $(2)
GLUON_$(1)_FACTORY_SUFFIX := -squashfs-factory
GLUON_$(1)_SYSUPGRADE_SUFFIX := -squashfs-sysupgrade
GLUON_$(1)_FACTORY_EXT := .bin
GLUON_$(1)_SYSUPGRADE_EXT := .bin
GLUON_$(1)_MODELS :=
endef

define GluonProfileFactorySuffix
GLUON_$(1)_FACTORY_SUFFIX := $(2)
GLUON_$(1)_FACTORY_EXT := $(3)
endef

define GluonProfileSysupgradeSuffix
GLUON_$(1)_SYSUPGRADE_SUFFIX := $(2)
GLUON_$(1)_SYSUPGRADE_EXT := $(3)
endef

define GluonModel
GLUON_$(1)_MODELS += $(3)
GLUON_$(1)_MODEL_$(3) := $(2)
endef


include $(GLUONDIR)/targets/targets.mk
include $(GLUONDIR)/targets/$(GLUON_TARGET)/profiles.mk

BOARD := $(GLUON_TARGET_$(GLUON_TARGET)_BOARD)
override SUBTARGET := $(GLUON_TARGET_$(GLUON_TARGET)_SUBTARGET)

target_prepared_stamp := $(BOARD_BUILDDIR)/target-prepared
gluon_prepared_stamp := $(BOARD_BUILDDIR)/prepared


include $(INCLUDE_DIR)/target.mk


prereq: FORCE
	+$(NO_TRACE_MAKE) prereq

gluon-tools: FORCE
	+$(GLUONMAKE_EARLY) tools/sed/install
	+$(GLUONMAKE_EARLY) package/lua/host/install

prepare-tmpinfo: FORCE
	@+$(MAKE) -r -s tmp/.prereq-build OPENWRT_BUILD= QUIET=0
	mkdir -p tmp/info
	$(_SINGLE)$(NO_TRACE_MAKE) -j1 -r -s -f include/scan.mk SCAN_TARGET="packageinfo" SCAN_DIR="package" SCAN_NAME="package" SCAN_DEPS="$(TOPDIR)/include/package*.mk $(TOPDIR)/overlay/*/*.mk" SCAN_EXTRA=""
	$(_SINGLE)$(NO_TRACE_MAKE) -j1 -r -s -f include/scan.mk SCAN_TARGET="targetinfo" SCAN_DIR="target/linux" SCAN_NAME="target" SCAN_DEPS="profiles/*.mk $(TOPDIR)/include/kernel*.mk $(TOPDIR)/include/target.mk" SCAN_DEPTH=2 SCAN_EXTRA="" SCAN_MAKEOPTS="TARGET_BUILD=1"
	for type in package target; do \
		f=tmp/.$${type}info; t=tmp/.config-$${type}.in; \
		[ "$$t" -nt "$$f" ] || ./scripts/metadata.pl $${type}_config "$$f" > "$$t" || { rm -f "$$t"; echo "Failed to build $$t"; false; break; }; \
	done
	[ tmp/.config-feeds.in -nt tmp/.packagefeeds ] || ./scripts/feeds feed_config > tmp/.config-feeds.in
	./scripts/metadata.pl package_mk tmp/.packageinfo > tmp/.packagedeps || { rm -f tmp/.packagedeps; false; }
	./scripts/metadata.pl package_feeds tmp/.packageinfo > tmp/.packagefeeds || { rm -f tmp/.packagefeeds; false; }
	touch $(TOPDIR)/tmp/.build

feeds: FORCE
	rm -rf $(TOPDIR)/package/feeds
	mkdir $(TOPDIR)/package/feeds
	[ ! -f $(GLUON_SITEDIR)/modules ] || . $(GLUON_SITEDIR)/modules && for feed in $$GLUON_SITE_FEEDS; do ln -s ../../../packages/$$feed $(TOPDIR)/package/feeds/$$feed; done
	ln -s ../../../package $(TOPDIR)/package/feeds/gluon
	. $(GLUONDIR)/modules && for feed in $$GLUON_FEEDS; do ln -s ../../../packages/$$feed $(TOPDIR)/package/feeds/module_$$feed; done
	+$(GLUONMAKE_EARLY) prepare-tmpinfo

config: FORCE
	+$(NO_TRACE_MAKE) scripts/config/conf OPENWRT_BUILD= QUIET=0
	+$(GLUONMAKE) prepare-tmpinfo
	( \
		cat $(GLUONDIR)/include/config $(GLUONDIR)/targets/$(GLUON_TARGET)/config; \
		echo 'CONFIG_BUILD_SUFFIX="gluon-$(GLUON_TARGET)"'; \
		echo '$(patsubst %,CONFIG_PACKAGE_%=m,$(sort $(filter-out -%,$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES) $(PROFILE_PACKAGES))))' \
			| sed -e 's/ /\n/g'; \
		echo '$(patsubst %,CONFIG_GLUON_LANG_%=y,$(GLUON_LANGS))' \
			| sed -e 's/ /\n/g'; \
	) > $(BOARD_BUILDDIR)/config.tmp
	scripts/config/conf --defconfig=$(BOARD_BUILDDIR)/config.tmp Config.in
	mv .config $(BOARD_BUILDDIR)/config

	echo 'CONFIG_ALL_KMODS=y' >> $(BOARD_BUILDDIR)/config.tmp
	scripts/config/conf --defconfig=$(BOARD_BUILDDIR)/config.tmp Config.in
	mv .config $(BOARD_BUILDDIR)/config-allmods

	cp $(BOARD_BUILDDIR)/config .config

prepare-target: FORCE
	rm $(GLUON_OPENWRTDIR)/tmp || true
	mkdir -p $(GLUON_OPENWRTDIR)/tmp

	for dir in build_dir dl staging_dir; do \
		mkdir -p $(GLUON_ORIGOPENWRTDIR)/$$dir; \
	done
	for link in build_dir config Config.in dl include Makefile package rules.mk scripts staging_dir target toolchain tools; do \
		ln -sf $(GLUON_ORIGOPENWRTDIR)/$$link $(GLUON_OPENWRTDIR); \
	done

	+$(GLUONMAKE_EARLY) feeds
	+$(GLUONMAKE_EARLY) gluon-tools
	+$(GLUONMAKE) config
	touch $(target_prepared_stamp)

$(target_prepared_stamp):
	+$(GLUONMAKE_EARLY) prepare-target

maybe-prepare-target: $(target_prepared_stamp)

$(BUILD_DIR)/.prepared: Makefile
	@mkdir -p $$(dirname $@)
	@touch $@

$(toolchain/stamp-install): $(tools/stamp-install)
$(package/stamp-compile): $(package/stamp-cleanup)


clean: FORCE
	+$(SUBMAKE) clean
	rm -f $(gluon_prepared_stamp)


export SHA512SUM := $(GLUONDIR)/scripts/sha512sum.sh


download: FORCE
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
	@$(STAGING_DIR_HOST)/bin/lua $(GLUONDIR)/package/gluon-core/files/usr/lib/lua/gluon/site_config.lua \
		|| (echo 'Your site configuration did not pass validation.'; false)

	mkdir -p $(GLUON_IMAGEDIR) $(BOARD_BUILDDIR)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(BOARD_BUILDDIR)/opkg.conf

	+$(GLUONMAKE) toolchain
	+$(GLUONMAKE) kernel
	+$(GLUONMAKE) packages
	+$(GLUONMAKE) prepare-image

	echo "$(GLUON_RELEASE)" > $(gluon_prepared_stamp)

$(gluon_prepared_stamp):
	+$(GLUONMAKE) prepare


include $(INCLUDE_DIR)/package-ipkg.mk

# override variables from rules.mk
PACKAGE_DIR = $(GLUON_OPENWRTDIR)/bin/$(BOARD)/packages

PROFILE_BUILDDIR = $(BOARD_BUILDDIR)/profiles/$(PROFILE)
PROFILE_KDIR = $(PROFILE_BUILDDIR)/kernel
BIN_DIR = $(PROFILE_BUILDDIR)/images

TARGET_DIR = $(PROFILE_BUILDDIR)/root

PREPARED_RELEASE = $$(cat $(gluon_prepared_stamp))
IMAGE_PREFIX = gluon-$(GLUON_SITE_CODE)-$(PREPARED_RELEASE)

OPKG:= \
  IPKG_TMP="$(TMP_DIR)/ipkgtmp" \
  IPKG_INSTROOT="$(TARGET_DIR)" \
  IPKG_CONF_DIR="$(TMP_DIR)" \
  IPKG_OFFLINE_ROOT="$(TARGET_DIR)" \
  $(STAGING_DIR_HOST)/bin/opkg \
	-f $(BOARD_BUILDDIR)/opkg.conf \
	--cache $(TMP_DIR)/dl \
	--offline-root $(TARGET_DIR) \
	--force-postinstall \
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
$(eval $(call merge-lists,INSTALL_PACKAGES,DEFAULT_PACKAGES GLUON_DEFAULT_PACKAGES GLUON_SITE_PACKAGES GLUON_$(PROFILE)_DEFAULT_PACKAGES GLUON_$(PROFILE)_SITE_PACKAGES))

package_install: FORCE
	$(OPKG) update
	$(OPKG) install $(PACKAGE_DIR)/libc_*.ipk
	$(OPKG) install $(PACKAGE_DIR)/kernel_*.ipk

	$(OPKG) install $(INSTALL_PACKAGES)
	+$(GLUONMAKE) enable_initscripts

	rm -f $(TARGET_DIR)/usr/lib/opkg/lists/* $(TARGET_DIR)/tmp/opkg.lock

ifeq ($(GLUON_OPKG_CONFIG),1)
include $(INCLUDE_DIR)/version.mk
endif

opkg_config: FORCE
	cp $(GLUON_OPENWRTDIR)/package/system/opkg/files/opkg.conf $(TARGET_DIR)/etc/opkg.conf
	for d in base luci packages routing telephony management oldpackages; do \
		echo "src/gz %n_$$d %U/$$d" >> $(TARGET_DIR)/etc/opkg.conf; \
	done
	$(VERSION_SED) $(TARGET_DIR)/etc/opkg.conf


image: FORCE
	rm -rf $(TARGET_DIR) $(BIN_DIR) $(PROFILE_KDIR)
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TARGET_DIR)/tmp $(GLUON_IMAGEDIR)/factory $(GLUON_IMAGEDIR)/sysupgrade
	cp -r $(BOARD_KDIR) $(PROFILE_KDIR)

	+$(GLUONMAKE) package_install
	+$(GLUONMAKE) opkg_config GLUON_OPKG_CONFIG=1

	$(call Image/mkfs/prepare)
	$(_SINGLE)$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 IMG_PREFIX=gluon \
		PROFILE="$(PROFILE)" KDIR="$(PROFILE_KDIR)" TARGET_DIR="$(TARGET_DIR)" BIN_DIR="$(BIN_DIR)" TMP_DIR="$(TMP_DIR)"

	$(foreach model,$(GLUON_$(PROFILE)_MODELS), \
		$(if $(GLUON_$(PROFILE)_SYSUPGRADE_EXT), \
			rm -f $(GLUON_IMAGEDIR)/sysupgrade/gluon-*-$(model)-sysupgrade$(GLUON_$(PROFILE)_SYSUPGRADE_EXT) && \
			cp $(BIN_DIR)/gluon-$(GLUON_$(PROFILE)_MODEL_$(model))$(GLUON_$(PROFILE)_SYSUPGRADE_SUFFIX)$(GLUON_$(PROFILE)_SYSUPGRADE_EXT) $(GLUON_IMAGEDIR)/sysupgrade/$(IMAGE_PREFIX)-$(model)-sysupgrade$(GLUON_$(PROFILE)_SYSUPGRADE_EXT) && \
		) \
		$(if $(GLUON_$(PROFILE)_FACTORY_EXT), \
			rm -f $(GLUON_IMAGEDIR)/factory/gluon-*-$(model)$(GLUON_$(PROFILE)_FACTORY_EXT) && \
			cp $(BIN_DIR)/gluon-$(GLUON_$(PROFILE)_MODEL_$(model))$(GLUON_$(PROFILE)_FACTORY_SUFFIX)$(GLUON_$(PROFILE)_FACTORY_EXT) $(GLUON_IMAGEDIR)/factory/$(IMAGE_PREFIX)-$(model)$(GLUON_$(PROFILE)_FACTORY_EXT) && \
		) \
	) :

image/%: $(gluon_prepared_stamp)
	+$(GLUONMAKE) image PROFILE="$(patsubst image/%,%,$@)" V=s$(OPENWRT_VERBOSE)

call_image/%: FORCE
	+$(GLUONMAKE) $(patsubst call_image/%,image/%,$@)

images: $(patsubst %,call_image/%,$(PROFILES)) ;

manifest: FORCE
	( \
		cd $(GLUON_IMAGEDIR)/sysupgrade; \
		$(foreach profile,$(PROFILES), \
			$(foreach model,$(GLUON_$(profile)_MODELS), \
				file="$(IMAGE_PREFIX)-$(model)-sysupgrade$(GLUON_$(profile)_SYSUPGRADE_EXT)"; \
				[ -e "$$file" ] && echo '$(model)' "$(PREPARED_RELEASE)" "$$($(SHA512SUM) "$$file")" "$$file"; \
			) \
		) : \
	) >> $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp


.PHONY: all images prepare clean gluon-tools manifest

endif
