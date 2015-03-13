# List of hardware profiles

## NETGEAR

ifeq ($(BROKEN),1)
# WNDR3700 v4, WNDR4300 v1
$(eval $(call GluonProfile,WNDR4300))
$(eval $(call GluonProfileFactorySuffix,WNDR4300,-ubi-factory,.img))
$(eval $(call GluonProfileSysupgradeSuffix,WNDR4300,-squashfs-sysupgrade,.tar))
$(eval $(call GluonModel,WNDR4300,wndr3700v4,netgear-wndr3700v4)) # BROKEN: untested
$(eval $(call GluonModel,WNDR4300,wndr4300,netgear-wndr4300)) # BROKEN: untested
endif
