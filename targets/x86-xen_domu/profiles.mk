$(eval $(call GluonProfile,GENERIC))
$(eval $(call GluonProfileFactorySuffix,GENERIC,-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,GENERIC,-ext4,.img.gz))
$(eval $(call GluonModel,GENERIC,combined,x86-xen))
