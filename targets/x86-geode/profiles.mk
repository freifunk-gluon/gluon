X86_GENERIC_NETWORK_MODULES := kmod-3c59x kmod-e100 kmod-natsemi kmod-ne2k-pci kmod-pcnet32 kmod-8139too kmod-r8169 kmod-sis900 kmod-tg3 kmod-via-rhine kmod-via-velocity kmod-forcedeth


$(eval $(call GluonProfile,GEODE,$(X86_GENERIC_NETWORK_MODULES)))
$(eval $(call GluonProfileFactorySuffix,GEODE,-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,GEODE,-ext4,.img.gz))
$(eval $(call GluonModel,GEODE,combined,x86-geode))

