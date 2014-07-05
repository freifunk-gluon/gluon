include $(INCLUDE_DIR)/package.mk

# Annoyingly, make's shell function replaces all newlines with spaces, so we have to do some escaping work. Yuck.
define GluonCheckSite
[ -z "$$GLUONDIR" ] || sed -e 's/-@/\n/g' -e 's/+@/@/g' <<'END__GLUON__CHECK__SITE' | "$$GLUONDIR"/scripts/check_site.sh
$(shell cat $(1) | sed -ne '1h; 1!H; $$ {g; s/@/+@/g; s/\n/-@/g; p}')
END__GLUON__CHECK__SITE
endef
