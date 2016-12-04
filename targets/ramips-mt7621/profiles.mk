# List of hardware profiles

$(eval $(call GluonProfile,Default))
$(eval $(call GluonModel,Default,dir-860l-b1,d-link-dir-860l-b1))

ifneq ($(BROKEN),)
$(eval $(call GluonProfile,ZBT-WG3526)) # BROKEN: hangs during reboot (http://lists.infradead.org/pipermail/linux-mtd/2016-November/070368.html)
$(eval $(call GluonProfileFactorySuffix,ZBT-WG3526))
$(eval $(call GluonModel,ZBT-WG3526,zbt-wg3526,zbt-wg3526))
endif
