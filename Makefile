all:

LC_ALL:=C
LANG:=C
export LC_ALL LANG


GLUON_SITEDIR ?= $(CURDIR)/site
GLUON_TMPDIR ?= $(CURDIR)/tmp

GLUON_OUTPUTDIR ?= $(CURDIR)/output
GLUON_IMAGEDIR ?= $(GLUON_OUTPUTDIR)/images
GLUON_PACKAGEDIR ?= $(GLUON_OUTPUTDIR)/packages

export GLUON_TMPDIR GLUON_IMAGEDIR GLUON_PACKAGEDIR DEVICES


$(GLUON_SITEDIR)/site.mk:
	$(error No site configuration was found. Please check out a site configuration to $(GLUON_SITEDIR))

include $(GLUON_SITEDIR)/site.mk


GLUON_RELEASE ?= $(error GLUON_RELEASE not set. GLUON_RELEASE can be set in site.mk or on the command line)


export GLUON_RELEASE GLUON_ATH10K_MESH GLUON_REGION GLUON_DEBUG

show-release:
	@echo '$(GLUON_RELEASE)'


update: FORCE
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/update.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/patch.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/feeds.sh

update-patches: FORCE
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/update.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/update-patches.sh
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/patch.sh

update-feeds: FORCE
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/feeds.sh


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


CheckTarget := [ '$(LEDE_TARGET)' ] \
	|| (echo 'Please set GLUON_TARGET to a valid target. Gluon supports the following targets:'; $(foreach target,$(GLUON_TARGETS),echo ' * $(target)';) false)

CheckExternal := test -d lede || (echo 'You don'"'"'t seem to have obtained the external repositories needed by Gluon; please call `make update` first!'; false)


list-targets: FORCE
	@$(foreach target,$(GLUON_TARGETS),echo '$(target)';)


GLUON_DEFAULT_PACKAGES := -odhcpd -ppp -ppp-mod-pppoe -wpad-mini gluon-core ip6tables hostapd-mini

GLUON_PACKAGES :=
define merge_packages
  $(foreach pkg,$(1),
    GLUON_PACKAGES := $$(strip $$(filter-out -$$(patsubst -%,%,$(pkg)) $$(patsubst -%,%,$(pkg)),$$(GLUON_PACKAGES)) $(pkg))
  )
endef
$(eval $(call merge_packages,$(GLUON_DEFAULT_PACKAGES) $(GLUON_SITE_PACKAGES)))

GLUON_PACKAGES_YES := $(filter-out -%,$(GLUON_PACKAGES))
GLUON_PACKAGES_NO := $(patsubst -%,%,$(filter -%,$(GLUON_PACKAGES)))


config: FORCE
	@$(CheckExternal)
	@$(CheckTarget)

	@( \
		echo 'CONFIG_TARGET_$(BOARD)=y' \
		$(if $(SUBTARGET),&& echo 'CONFIG_TARGET_$(BOARD)_$(SUBTARGET)=y') \
		$(foreach pkg,$(GLUON_PACKAGES_NO),&& echo '# CONFIG_PACKAGE_$(pkg) is not set') \
		&& scripts/target_config.sh generic \
		&& GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/target_config.sh '$(GLUON_TARGET)' \
		$(foreach pkg,$(GLUON_PACKAGES_YES),&& echo 'CONFIG_PACKAGE_$(pkg)=y') \
		$(foreach lang,$(GLUON_LANGS),&& echo 'CONFIG_GLUON_WEB_LANG_$(lang)=y') \
		&& echo 'CONFIG_GLUON_RELEASE="$(GLUON_RELEASE)"' \
		&& echo 'CONFIG_GLUON_SITEDIR="$(GLUON_SITEDIR)"' \
		&& echo 'CONFIG_GLUON_BRANCH="$(GLUON_BRANCH)"' \
	) > lede/.config
	+@$(LEDEMAKE) defconfig

	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/target_config_check.sh '$(GLUON_TARGET)' '$(GLUON_PACKAGES_YES)'


LUA := lede/staging_dir/hostpkg/bin/lua

$(LUA):
	@$(CheckExternal)

	+@[ -e lede/.config ] || $(LEDEMAKE) defconfig
	+@$(LEDEMAKE) tools/install
	+@$(LEDEMAKE) package/lua/host/install

prepare-target: config $(LUA) ;

all: prepare-target
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' $(LUA) scripts/site_config.lua \
                || (echo 'Your site configuration did not pass validation.'; false)

	@scripts/clean_output.sh
	+@$(LEDEMAKE)
	@GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/copy_output.sh '$(GLUON_TARGET)'

clean download: config
	+@$(LEDEMAKE) $@

dirclean: FORCE
	+@[ -e lede/.config ] || $(LEDEMAKE) defconfig
	+@$(LEDEMAKE) dirclean
	@rm -rf $(GLUON_TMPDIR) $(GLUON_OUTPUTDIR)

manifest: $(LUA) FORCE
	@[ '$(GLUON_BRANCH)' ] || (echo 'Please set GLUON_BRANCH to create a manifest.'; false)
	@echo '$(GLUON_PRIORITY)' | grep -qE '^([0-9]*\.)?[0-9]+$$' || (echo 'Please specify a numeric value for GLUON_PRIORITY to create a manifest.'; false)
	@$(CheckExternal)

	@( \
		echo 'BRANCH=$(GLUON_BRANCH)' && \
		echo "DATE=$$($(LUA) scripts/rfc3339date.lua)" && \
		echo 'PRIORITY=$(GLUON_PRIORITY)' && \
		echo && \
		$(foreach GLUON_TARGET,$(GLUON_TARGETS), \
			GLUON_SITEDIR='$(GLUON_SITEDIR)' scripts/generate_manifest.sh '$(GLUON_TARGET)' && \
		) : \
	) > 'tmp/$(GLUON_BRANCH).manifest.tmp'

	@mkdir -p '$(GLUON_IMAGEDIR)/sysupgrade'
	@mv 'tmp/$(GLUON_BRANCH).manifest.tmp' '$(GLUON_IMAGEDIR)/sysupgrade/$(GLUON_BRANCH).manifest'

FORCE: ;

.PHONY: FORCE
.NOTPARALLEL:
