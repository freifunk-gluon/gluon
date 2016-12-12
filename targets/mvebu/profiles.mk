# List of hardware profiles

# Linksys WRT1200AC
$(eval $(call GluonProfile,Caiman,kmod-usb2 kmod-usb3 kmod-usb-storage kmod-i2c-core \
	kmod-i2c-mv64xxx kmod-ata-core kmod-ata-mvebu-ahci kmod-rtc-armada38x \
	kmod-thermal-armada kmod-gpio-button-hotplug kmod-hwmon-tmp421 kmod-leds-pca963x \
	kmod-ledtrig-usbdev kmod-mwlwifi swconfig uboot-envtools))
$(eval $(call GluonProfileFactorySuffix,Caiman,-squashfs-factory,.img))
$(eval $(call GluonProfileSysupgradeSuffix,Caiman,-squashfs-sysupgrade,.tar))
$(eval $(call GluonModel,Caiman,armada-385-linksys-caiman,linksys-wrt1200ac))
