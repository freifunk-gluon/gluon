site_packages() {
	MAKEFLAGS= make print PROFILE="$1" --no-print-directory -s -f - <<'END_MAKE'
include $(GLUON_SITEDIR)/site.mk

print:
	echo '$(GLUON_$(PROFILE)_SITE_PACKAGES)'
END_MAKE
}


. scripts/common.inc.sh


no_opkg() {
	config '# CONFIG_SIGNED_PACKAGES is not set'
	config 'CONFIG_CLEAN_IPKG=y'
	packages '-opkg'
}
