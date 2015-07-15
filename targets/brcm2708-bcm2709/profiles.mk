$(eval $(call GluonProfile,RaspberryPi2))
$(eval $(call GluonProfileFactorySuffix,RaspberryPi2,-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,RaspberryPi2,-vfat-ext4,.img.gz))
$(eval $(call GluonModel,RaspberryPi2,sdcard,raspberry-pi-2))
