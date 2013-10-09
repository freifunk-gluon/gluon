# List of hardware profiles

USB_PACKAGES := block-mount kmod-fs-ext4 kmod-fs-vfat kmod-usb-storage kmod-usb-storage-extras blkid swap-utils \
	kmod-nls-cp1250 kmod-nls-cp1251 kmod-nls-cp437 kmod-nls-cp775 kmod-nls-cp850 kmod-nls-cp852 kmod-nls-cp866 \
	kmod-nls-iso8859-1 kmod-nls-iso8859-13 kmod-nls-iso8859-15 kmod-nls-iso8859-2 kmod-nls-koi8r kmod-nls-utf8


## TP-Link

# TL-WR740N v1, v3, v4
$(eval $(call GluonProfile,TLWR740))

# TL-WR741N/ND v1, v2, v4
$(eval $(call GluonProfile,TLWR741))

# TL-WR841N/ND v1.5, v3, v5, v7, v8
$(eval $(call GluonProfile,TLWR841))

# TL-WR842N/ND v1
$(eval $(call GluonProfile,TLWR842,$(USB_PACKAGES)))

# TL-WR941N/ND v2, v3, v4
$(eval $(call GluonProfile,TLWR941))

# TL-WR1043N/ND v1
$(eval $(call GluonProfile,TLWR1043,$(USB_PACKAGES)))

# TL-WDR3600/4300 v1
$(eval $(call GluonProfile,TLWDR4300,$(USB_PACKAGES)))

# TL-MR3020 v1
$(eval $(call GluonProfile,TLMR3020,$(USB_PACKAGES)))

# TL-MR3040 v1
$(eval $(call GluonProfile,TLMR3040,$(USB_PACKAGES)))

# TL-MR3220 v1
$(eval $(call GluonProfile,TLMR3220,$(USB_PACKAGES)))

# TL-MR3420 v1
$(eval $(call GluonProfile,TLMR3420,$(USB_PACKAGES)))


## Ubiquiti (everything)
$(eval $(call GluonProfile,UBNT,$(USB_PACKAGES)))
