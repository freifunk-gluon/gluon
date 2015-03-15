$(eval $(call GluonProfile,GENERIC,kmod-3c59x kmod-e100 kmod-e1000 kmod-natsemi kmod-ne2k-pci kmod-pcnet32 kmod-8139too kmod-r8169 kmod-sis900 kmod-tg3 kmod-via-rhine kmod-via-velocity))
$(eval $(call GluonProfileFactorySuffix,GENERIC,-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,GENERIC,-ext4,.img.gz))
$(eval $(call GluonModel,GENERIC,combined,x86-generic))

$(eval $(call GluonProfile,VDI,kmod-pcnet32 kmod-e1000))
$(eval $(call GluonProfileFactorySuffix,VDI,-ext4,.vdi))
$(eval $(call GluonProfileSysupgradeSuffix,VDI,-ext4,.img.gz))
$(eval $(call GluonModel,VDI,combined,x86-virtualbox))

$(eval $(call GluonProfile,VMDK,kmod-pcnet32))
$(eval $(call GluonProfileFactorySuffix,VMDK,-ext4,.vmdk))
$(eval $(call GluonProfileSysupgradeSuffix,VMDK,-ext4,.img.gz))
$(eval $(call GluonModel,VMDK,combined,x86-vmware))
