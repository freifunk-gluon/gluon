$(eval $(call GluonProfile,RaspberryPi2,brcm2708-gpu-fw kmod-usb-hid kmod-sound-core kmod-sound-arm-bcm2835))
$(eval $(call GluonProfileFactorySuffix,RaspberryPi2,-vfat-ext4,.img.gz))
$(eval $(call GluonProfileSysupgradeSuffix,RaspberryPi2))
$(eval $(call GluonModel,RaspberryPi2,sdcard,raspberry-pi-2))
