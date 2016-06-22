#Banana Pi/M1
$(eval $(call GluonProfile,Bananapi,uboot-sunxi-Bananapi kmod-rtc-sunxi))
$(eval $(call GluonProfileFactorySuffix,Bananapi,-sdcard-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,Bananapi))
$(eval $(call GluonModel,Bananapi,Bananapi,lemaker-banana-pi))

#BananaPi R1 / Lamobo R1
$(eval $(call GluonProfile,Lamobo_R1,uboot-sunxi-Lamobo_R1 kmod-ata-sunxi kmod-rtl8192cu kmod-rtc-sunxi swconfig))
$(eval $(call GluonProfileFactorySuffix,Lamobo_R1,-sdcard-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,Lamobo_R1))
$(eval $(call GluonModel,Lamobo_R1,Lamobo_R1,lemaker-lamobo-r1))

# Banana Pro
$(eval $(call GluonProfile,Bananapro,uboot-sunxi-Bananapro kmod-rtc-sunxi kmod-brcmfmac))
$(eval $(call GluonProfileFactorySuffix,Bananapro,-sdcard-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,Bananapro))
$(eval $(call GluonModel,Bananapro,Bananapro,lemaker-banana-pro))
