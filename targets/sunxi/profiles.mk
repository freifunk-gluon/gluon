$(eval $(call GluonProfile,Bananapi,uboot-sunxi-Bananapi kmod-rtc-sunxi))
$(eval $(call GluonProfileFactorySuffix,Bananapi,-sdcard-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,Bananapi))
$(eval $(call GluonModel,Bananapi,Bananapi,lemaker-banana-pi))
