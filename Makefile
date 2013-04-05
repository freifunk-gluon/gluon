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
include $(INCLUDE_DIR)/kernel.mk

include package/Makefile
include tools/Makefile
include toolchain/Makefile

BOARD := ar71xx
PROFILES :=
PROFILE_PACKAGES :=

gluon_prepared_stamp := $(GLUON_BUILDDIR)/$(BOARD)/prepared

define GluonProfile
image/$(1): $(gluon_prepared_stamp)
	$(NO_TRACE_MAKE) -C $(GLUON_BUILDERDIR) image PROFILE="$(1)"

PROFILES += $(1)
PROFILE_PACKAGES += $(filter-out -%,$(2) $(GLUON_$(1)_SITE_PACKAGES))
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

feeds: FORCE
	ln -sf $(GLUON_BUILDERDIR)/feeds.conf feeds.conf
	$(GLUONMAKE) refresh_feeds V=s$(OPENWRT_VERBOSE)

config: FORCE
	echo -e 'CONFIG_TARGET_$(BOARD)=y\nCONFIG_TARGET_ROOTFS_JFFS2=n\n$(subst ${space},\n,$(patsubst %,CONFIG_PACKAGE_%=m,$(sort $(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES) $(PROFILE_PACKAGES))))' > .config
	$(SUBMAKE) defconfig OPENWRT_BUILD=0

.config:
	$(GLUONMAKE) config

download: .config FORCE
	$(SUBMAKE) tools/download
	$(SUBMAKE) toolchain/download
	$(SUBMAKE) package/download
	$(SUBMAKE) target/download

toolchain: $(toolchain/stamp-install) $(tools/stamp-install)

kernel: FORCE
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD) -f $(GLUON_BUILDERDIR)/Makefile.target $(LINUX_DIR)/.image TARGET_BUILD=1
	$(NO_TRACE_MAKE) -C $(TOPDIR)/target/linux/$(BOARD) -f $(GLUON_BUILDERDIR)/Makefile.target $(LINUX_DIR)/.modules TARGET_BUILD=1

packages: $(package/stamp-compile)
	$(_SINGLE)$(SUBMAKE) -r package/index

prepare-image: FORCE
	rm -rf $(BOARD_KDIR)
	mkdir -p $(BOARD_KDIR)
	cp $(KERNEL_BUILD_DIR)/vmlinux $(KERNEL_BUILD_DIR)/vmlinux.elf $(BOARD_KDIR)/
	$(SUBMAKE) -C $(TOPDIR)/target/linux/$(BOARD)/image -f $(GLUON_BUILDERDIR)/Makefile.image prepare KDIR="$(BOARD_KDIR)"

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

call_image/%: FORCE
	$(GLUONMAKE) $(patsubst call_image/%,image/%,$@)

images: $(patsubst %,call_image/%,$(PROFILES)) ;

.PHONY: all images prepare clean cleanall

endif
