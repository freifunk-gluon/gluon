ifneq ($(__gluon_inc),1)
__gluon_inc=1

GLUON_SITEDIR ?= $(GLUONDIR)/site
GLUON_BUILDDIR ?= $(GLUONDIR)/build

GLUON_ORIGOPENWRTDIR := $(GLUONDIR)/openwrt
GLUON_SITE_CONFIG := $(GLUON_SITEDIR)/site.conf

GLUON_OUTPUTDIR ?= $(GLUONDIR)/output
GLUON_IMAGEDIR ?= $(GLUON_OUTPUTDIR)/images
GLUON_MODULEDIR ?= $(GLUON_OUTPUTDIR)/modules

GLUON_OPKG_KEY ?= $(GLUON_BUILDDIR)/gluon-opkg-key

export GLUONDIR GLUON_SITEDIR GLUON_BUILDDIR GLUON_SITE_CONFIG GLUON_OUTPUTDIR GLUON_IMAGEDIR GLUON_MODULEDIR


BOARD_BUILDDIR = $(GLUON_BUILDDIR)/$(GLUON_TARGET)
BOARD_KDIR = $(BOARD_BUILDDIR)/kernel

export BOARD_BUILDDIR


LINUX_RELEASE := 2
export LINUX_RELEASE


GLUON_OPENWRTDIR = $(BOARD_BUILDDIR)/openwrt


$(GLUON_SITEDIR)/site.mk:
	$(error There was no site configuration found. Please check out a site configuration to $(GLUON_SITEDIR))

-include $(GLUON_SITEDIR)/site.mk


GLUON_VERSION := $(shell cd $(GLUONDIR) && git describe --always 2>/dev/null || echo unknown)
export GLUON_VERSION

GLUON_LANGS ?= en
export GLUON_LANGS


ifeq ($(OPENWRT_BUILD),1)
ifeq ($(GLUON_TOOLS),1)

GLUON_OPENWRT_FEEDS := base packages luci routing telephony management
export GLUON_OPENWRT_FEEDS

GLUON_SITE_CODE := $(shell $(GLUONDIR)/scripts/site.sh site_code)
export GLUON_SITE_CODE

ifeq ($(GLUON_RELEASE),)
$(error GLUON_RELEASE not set. GLUON_RELEASE can be set in site.mk or on the command line.)
endif
export GLUON_RELEASE

endif
endif


define merge-lists
$(1) :=
$(foreach var,$(2),$(1) := $$(filter-out -% $$(patsubst -%,%,$$(filter -%,$$($(var)))),$$($(1)) $$($(var)))
)
endef

GLUON_TARGETS :=

define GluonTarget
gluon_target := $(1)$$(if $(2),-$(2))
GLUON_TARGETS += $$(gluon_target)
GLUON_TARGET_$$(gluon_target)_BOARD := $(1)
GLUON_TARGET_$$(gluon_target)_SUBTARGET := $(2)
endef

GLUON_DEFAULT_PACKAGES := gluon-core kmod-ipv6 firewall ip6tables -uboot-envtools -wpad-mini hostapd-mini

override DEFAULT_PACKAGES.router :=

endif #__gluon_inc
