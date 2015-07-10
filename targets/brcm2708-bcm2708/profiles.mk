$(eval $(call GluonProfile,RaspberryPi,brcm2708-gpu-fw kmod-usb-hid kmod-sound-core kmod-sound-arm-bcm2835))
$(eval $(call GluonProfileFactorySuffix,RaspberryPi,-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,RaspberryPi))
$(eval $(call GluonModel,RaspberryPi,sdcard,raspberry-pi))
