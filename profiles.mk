# List of hardware profiles

USB_PACKAGES := block-mount kmod-fs-ext4 kmod-fs-vfat kmod-usb-storage kmod-usb-storage-extras blkid swap-utils \
	kmod-nls-cp1250 kmod-nls-cp1251 kmod-nls-cp437 kmod-nls-cp775 kmod-nls-cp850 kmod-nls-cp852 kmod-nls-cp866 \
	kmod-nls-iso8859-1 kmod-nls-iso8859-13 kmod-nls-iso8859-15 kmod-nls-iso8859-2 kmod-nls-koi8r kmod-nls-utf8


$(eval $(call GluonProfile,TLWR741))
$(eval $(call GluonProfile,TLWR841))
$(eval $(call GluonProfile,TLWR842,$(USB_PACKAGES)))
$(eval $(call GluonProfile,TLWR1043,$(USB_PACKAGES)))
$(eval $(call GluonProfile,TLWDR4300,$(USB_PACKAGES)))
