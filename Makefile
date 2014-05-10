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


GLUON_TARGET ?= ar71xx-generic
export GLUON_TARGET


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
override GLUON_TOOLS=1
GREP_OPTIONS=
export OPENWRT_BUILD GLUON_TOOLS GREP_OPTIONS

-include $(TOPDIR)/include/debug.mk
-include $(TOPDIR)/include/depends.mk
include $(GLUONDIR)/include/toplevel.mk

define GluonProfile
image/$(1): FORCE
	+@$$(GLUONMAKE) $$@
endef

define GluonModel
endef

include $(GLUONDIR)/targets/targets.mk

CheckExternal := test -d $(GLUON_OPENWRTDIR) || (echo 'You don'"'"'t seem to have obtained the external repositories needed by Gluon; please call `make update` first!'; false)

gluon-tools: FORCE
	+@$(SUBMAKE) -C $(TOPDIR) prepare-tmpinfo OPENWRT_BUILD=0
	+@$(GLUONMAKE) gluon-tools GLUON_TOOLS=0

all: gluon-tools
	+@$(GLUONMAKE) prepare
	+@$(GLUONMAKE) images

download prepare images: gluon-tools
	+@$(GLUONMAKE) $@

tools/% toolchain/% package/% target/%: gluon-tools
	+@$(GLUONMAKE) $@

manifest: gluon-tools
	[ -n "$(GLUON_BRANCH)" ] || (echo 'Please set GLUON_BRANCH to create a manifest.'; false)
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


PROFILES :=
PROFILE_PACKAGES :=

define Profile
  $(eval $(call Profile/Default))
  $(eval $(call Profile/$(1)))
  $(1)_PACKAGES := $(PACKAGES)
endef

define GluonProfile
PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$($(1)_PACKAGES) $(2) $(GLUON_$(1)_SITE_PACKAGES))
GLUON_$(1)_DEFAULT_PACKAGES := $(2)
GLUON_$(1)_MODELS :=
endef

define GluonModel
GLUON_$(1)_MODELS += $(2)
GLUON_$(1)_MODEL_$(2) := $(3)
endef


include $(GLUONDIR)/targets/targets.mk

BOARD := $(GLUON_TARGET_$(GLUON_TARGET)_BOARD)
override SUBTARGET := $(GLUON_TARGET_$(GLUON_TARGET)_SUBTARGET)

gluon_prepared_stamp := $(BOARD_BUILDDIR)/prepared


include $(INCLUDE_DIR)/target.mk


gluon-tools: $(STAGING_DIR_HOST)/bin/stat


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
	( \
		[ ! -f $(GLUON_SITEDIR)/modules ] || . $(GLUON_SITEDIR)/modules && for feed in $$GLUON_SITE_FEEDS; do echo src-link $$feed ../../packages/$$feed; done; \
		. $(GLUONDIR)/modules && for feed in $$GLUON_FEEDS; do echo src-link $$feed ../../packages/$$feed; done; \
	) > feeds.conf
	+$(GLUONMAKE) refresh_feeds V=s$(OPENWRT_VERBOSE)

config: FORCE
	( \
		cat $(GLUONDIR)/include/config $(GLUONDIR)/targets/$(GLUON_TARGET)/config; \
		echo '$(patsubst %,CONFIG_PACKAGE_%=m,$(sort $(filter-out -%,$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES) $(PROFILE_PACKAGES))))' \
			| sed -e 's/ /\n/g'; \
	) > $(BOARD_BUILDDIR)/config
	+$(NO_TRACE_MAKE) scripts/config/conf
	scripts/config/conf -D $(BOARD_BUILDDIR)/config -w $(BOARD_BUILDDIR)/config Config.in

	ln -sf $(BOARD_BUILDDIR)/config .config

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

CheckSite := (perl $(GLUON_SITEDIR)/site.conf 2>&1) > /dev/null || (echo 'Your site configuration did not pass validation; please verify yourself with `perl site.conf` and fix the problems.';false)

prepare: FORCE
	@$(CheckSite)

	mkdir -p $(GLUON_IMAGEDIR) $(BOARD_BUILDDIR)
	echo 'src packages file:../openwrt/bin/$(BOARD)/packages' > $(BOARD_BUILDDIR)/opkg.conf

	+$(GLUONMAKE) feeds
	+$(GLUONMAKE) config
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

PROFILE_BUILDDIR = $(BOARD_BUILDDIR)/$(PROFILE)
PROFILE_KDIR = $(PROFILE_BUILDDIR)/kernel
BIN_DIR = $(PROFILE_BUILDDIR)/images

TMP_DIR = $(PROFILE_BUILDDIR)/tmp
TARGET_DIR = $(PROFILE_BUILDDIR)/root

IMAGE_PREFIX = gluon-$(GLUON_SITE_CODE)-$$(cat $(gluon_prepared_stamp))

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
	mkdir -p $(TARGET_DIR) $(BIN_DIR) $(TMP_DIR) $(TARGET_DIR)/tmp $(GLUON_IMAGEDIR)/factory $(GLUON_IMAGEDIR)/sysupgrade
	cp -r $(BOARD_KDIR) $(PROFILE_KDIR)

	+$(GLUONMAKE) package_install

	$(call Image/mkfs/prepare)
	$(_SINGLE)$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image install TARGET_BUILD=1 IB=1 IMG_PREFIX=gluon \
		PROFILE="$(PROFILE)" KDIR="$(PROFILE_KDIR)" TARGET_DIR="$(TARGET_DIR)" BIN_DIR="$(BIN_DIR)" TMP_DIR="$(TMP_DIR)"

	$(foreach model,$(GLUON_$(PROFILE)_MODELS), \
		rm -f $(GLUON_IMAGEDIR)/factory/gluon-*-$(GLUON_$(PROFILE)_MODEL_$(model)).bin && \
		rm -f $(GLUON_IMAGEDIR)/sysupgrade/gluon-*-$(GLUON_$(PROFILE)_MODEL_$(model))-sysupgrade.bin && \
		\
		cp $(BIN_DIR)/gluon-$(model)-factory.bin $(GLUON_IMAGEDIR)/factory/$(IMAGE_PREFIX)-$(GLUON_$(PROFILE)_MODEL_$(model)).bin && \
		cp $(BIN_DIR)/gluon-$(model)-sysupgrade.bin $(GLUON_IMAGEDIR)/sysupgrade/$(IMAGE_PREFIX)-$(GLUON_$(PROFILE)_MODEL_$(model))-sysupgrade.bin && \
	) :

image/%: $(gluon_prepared_stamp)
	+$(GLUONMAKE) image PROFILE="$(patsubst image/%,%,$@)" V=s$(OPENWRT_VERBOSE)

call_image/%: FORCE
	+$(GLUONMAKE) $(patsubst call_image/%,image/%,$@)

images: $(patsubst %,call_image/%,$(PROFILES)) ;

manifest: FORCE
	mkdir -p $(GLUON_IMAGEDIR)/sysupgrade
	(cd $(GLUON_IMAGEDIR)/sysupgrade && echo 'BRANCH=$(GLUON_BRANCH)' && echo && ($(foreach profile,$(PROFILES), \
		$(foreach model,$(GLUON_$(profile)_MODELS), \
			for file in gluon-*-'$(GLUON_$(profile)_MODEL_$(model))-sysupgrade.bin'; do \
				[ -e "$$file" ] && echo \
					'$(GLUON_$(profile)_MODEL_$(model))' \
					"$$(echo "$$file" | sed -n -r -e 's/^gluon-$(call regex-escape,$(GLUON_SITE_CODE))-(.*)-$(call regex-escape,$(GLUON_$(profile)_MODEL_$(model)))-sysupgrade\.bin$$/\1/p')" \
					"$$(sha512sum "$$file" | awk '{print $$1}')" \
					"$$file" && break; \
			done; \
		) \
	) :)) > $(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_BRANCH).manifest


.PHONY: all images prepare clean cleanall gluon-tools

endif
