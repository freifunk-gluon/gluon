$(eval $(call GluonProfile,RaspberryPi))
$(eval $(call GluonProfileFactorySuffix,RaspberryPi,-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,RaspberryPi,-vfat-ext4,.img.gz))
$(eval $(call GluonModel,RaspberryPi,sdcard,raspberry-pi))
