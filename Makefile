all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG


GLUON_SITEDIR ?= $(CURDIR)/site
GLUON_TMPDIR ?= $(CURDIR)/tmp

GLUON_OUTPUTDIR ?= $(CURDIR)/output
GLUON_IMAGEDIR ?= $(GLUON_OUTPUTDIR)/images
GLUON_MODULEDIR ?= $(GLUON_OUTPUTDIR)/modules

export GLUON_TMPDIR GLUON_IMAGEDIR GLUON_MODULEDIR


GLUON_VERSION := $(shell git describe --always --dirty=+ 2>/dev/null || echo unknown)
GLUON_SITE_VERSION := $(shell ( cd $(GLUON_SITEDIR) && git --git-dir=.git describe --always --dirty=+ ) 2>/dev/null || echo unknown)


$(GLUON_SITEDIR)/site.mk:
	$(error No site configuration was found. Please check out a site configuration to $(GLUON_SITEDIR))

-include $(GLUON_SITEDIR)/site.mk

ifeq ($(GLUON_RELEASE),)
$(error GLUON_RELEASE not set. GLUON_RELEASE can be set in site.mk or on the command line.)
endif

GLUON_LANGS ?= en

export GLUON_RELEASE GLUON_ATH10K_MESH GLUON_REGION


update: FORCE
	@scripts/update.sh
	@scripts/patch.sh
	@scripts/feeds.sh

update-patches: FORCE
	@scripts/update.sh
	@scripts/update-patches.sh
	@scripts/patch.sh

update-feeds: FORCE
	@scripts/feeds.sh


GLUON_TARGETS :=

define GluonTarget
gluon_target := $(1)$$(if $(2),-$(2))
GLUON_TARGETS += $$(gluon_target)
GLUON_TARGET_$$(gluon_target)_BOARD := $(1)
GLUON_TARGET_$$(gluon_target)_SUBTARGET := $(if $(3),$(3),$(2))
endef

include targets/targets.mk


LEDEMAKE = $(MAKE) -C lede

BOARD := $(GLUON_TARGET_$(GLUON_TARGET)_BOARD)
SUBTARGET := $(GLUON_TARGET_$(GLUON_TARGET)_SUBTARGET)
LEDE_TARGET := $(BOARD)$(if $(SUBTARGET),-$(SUBTARGET))

export LEDE_TARGET


CheckTarget := [ -n '$(GLUON_TARGET)' -a -n '$(LEDE_TARGET)' ] \
	|| (echo 'Please set GLUON_TARGET to a valid target. Gluon supports the following targets:'; $(foreach target,$(GLUON_TARGETS),echo ' * $(target)';) false)

CheckExternal := test -d lede || (echo 'You don'"'"'t seem to have obtained the external repositories needed by Gluon; please call `make update` first!'; false)


GLUON_DEFAULT_PACKAGES := -odhcpd -ppp -ppp-mod-pppoe -uboot-envtools -wpad-mini gluon-core ip6tables hostapd-mini

GLUON_PACKAGES :=
define merge_packages
  $(foreach pkg,$(1),
    GLUON_PACKAGES := $$(strip $$(filter-out -$$(patsubst -%,%,$(pkg)) $$(patsubst -%,%,$(pkg)),$$(GLUON_PACKAGES)) $(pkg))
  )
endef
$(eval $(call merge_packages,$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES)))

GLUON_PACKAGES_YES := $(filter-out -%,$(GLUON_PACKAGES))
GLUON_PACKAGES_NO := $(patsubst -%,%,$(filter -%,$(GLUON_PACKAGES)))


prepare-target: FORCE
	@$(CheckExternal)
	@$(CheckTarget)
	@( \
		echo 'CONFIG_TARGET_$(BOARD)=y' \
		$(if $(SUBTARGET),&& echo 'CONFIG_TARGET_$(BOARD)_$(SUBTARGET)=y') \
		$(foreach pkg,$(GLUON_PACKAGES_NO),&& echo '# CONFIG_PACKAGE_$(pkg) is not set') \
		&& scripts/target_config.sh generic \
		&& scripts/target_config.sh '$(GLUON_TARGET)' \
		$(foreach pkg,$(GLUON_PACKAGES_YES),&& echo 'CONFIG_PACKAGE_$(pkg)=y') \
		$(foreach lang,$(GLUON_LANGS),&& echo 'CONFIG_LUCI_LANG_$(lang)=y') \
		&& echo 'CONFIG_GLUON_VERSION="$(GLUON_VERSION)"' \
		&& echo 'CONFIG_GLUON_SITE_VERSION="$(GLUON_SITE_VERSION)"' \
		&& echo 'CONFIG_GLUON_RELEASE="$(GLUON_RELEASE)"' \
		&& echo 'CONFIG_GLUON_SITEDIR="$(GLUON_SITEDIR)"' \
		&& echo 'CONFIG_GLUON_BRANCH="$(GLUON_BRANCH)"' \
	) > lede/.config
	+@$(LEDEMAKE) defconfig

	# FIXME: check config
	# FIXME: opkg config

all: prepare-target
	+@$(LEDEMAKE) tools/install
	+@$(LEDEMAKE) package/lua/host/install
	# FIXME: early site check

	+@$(LEDEMAKE)
	@scripts/copy_output.sh '$(GLUON_TARGET)'

clean download: prepare-target
	+@$(LEDEMAKE) $@

dirclean: FORCE
	+@$(LEDEMAKE) defconfig
	+@$(LEDEMAKE) dirclean
	rm -rf $(GLUON_TMPDIR) $(GLUON_OUTPUTDIR)

#manifest: FORCE
#	@[ -n '$(GLUON_BRANCH)' ] || (echo 'Please set GLUON_BRANCH to create a manifest.'; false)
#	@echo '$(GLUON_PRIORITY)' | grep -qE '^([0-9]*\.)?[0-9]+$$' || (echo 'Please specify a numeric value for GLUON_PRIORITY to create a manifest.'; false)
#	@$(CheckExternal)
#
#	( \
#		echo 'BRANCH=$(GLUON_BRANCH)' && \
#		echo 'DATE=$(shell $(GLUON_ORIGOPENWRTDIR)/staging_dir/host/bin/lua scripts/rfc3339date.lua)' && \
#		echo 'PRIORITY=$(GLUON_PRIORITY)' && \
#		echo \
#	) > $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp
#
#	+($(foreach GLUON_TARGET,$(GLUON_TARGETS), \
#		( [ ! -e $(BOARD_BUILDDIR)/prepared ] || ( $(GLUONMAKE) manifest GLUON_TARGET='$(GLUON_TARGET)' V=s$(OPENWRT_VERBOSE) ) ) && \
#	) :)
#
#	mkdir -p $(GLUON_IMAGEDIR)/sysupgrade
#	mv $(GLUON_BUILDDIR)/$(GLUON_BRANCH).manifest.tmp $(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_BRANCH).manifest

FORCE: ;

.PHONY: FORCE
.NOTPARALLEL:
