# List of hardware profiles

USB_PACKAGES := block-mount kmod-fs-ext4 kmod-fs-vfat kmod-usb-storage kmod-usb-storage-extras blkid swap-utils \
	kmod-nls-cp1250 kmod-nls-cp1251 kmod-nls-cp437 kmod-nls-cp775 kmod-nls-cp850 kmod-nls-cp852 kmod-nls-cp866 \
	kmod-nls-iso8859-1 kmod-nls-iso8859-13 kmod-nls-iso8859-15 kmod-nls-iso8859-2 kmod-nls-koi8r kmod-nls-utf8


## TP-Link

# TL-WR740N v1, v3, v4
$(eval $(call GluonProfile,TLWR740))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v1,tp-link-tl-wr740n-nd-v1))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v3,tp-link-tl-wr740n-nd-v3))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v4,tp-link-tl-wr740n-nd-v4))

# TL-WR741N/ND v1, v2, v4
$(eval $(call GluonProfile,TLWR741))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v1,tp-link-tl-wr741n-nd-v1))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v2,tp-link-tl-wr741n-nd-v2))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v4,tp-link-tl-wr741n-nd-v4))

# TL-WR841N/ND v3, v5, v7, v8
$(eval $(call GluonProfile,TLWR841))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v3,tp-link-tl-wr841n-nd-v3))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v5,tp-link-tl-wr841n-nd-v5))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v7,tp-link-tl-wr841n-nd-v7))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v8,tp-link-tl-wr841n-nd-v8))

# TL-WR842N/ND v1
$(eval $(call GluonProfile,TLWR842,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLWR842,tl-wr842n-v1,tp-link-tl-wr842n-nd-v1))

# TL-WR941N/ND v2, v3, v4
$(eval $(call GluonProfile,TLWR941))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v2,tp-link-tl-wr941n-nd-v2))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v3,tp-link-tl-wr941n-nd-v3))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v4,tp-link-tl-wr941n-nd-v4))

# TL-WR1043N/ND v1
$(eval $(call GluonProfile,TLWR1043,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v1,tp-link-tl-wr1043n-nd-v1))

# TL-WDR3600/4300 v1
$(eval $(call GluonProfile,TLWDR4300,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3600-v1,tp-link-tl-wdr3600-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr4300-v1,tp-link-tl-wdr4300-v1))

# TL-MR3020 v1
$(eval $(call GluonProfile,TLMR3020,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLMR3020,tl-mr3020-v1,tp-link-tl-mr3020))

# TL-MR3040 v1
$(eval $(call GluonProfile,TLMR3040,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLMR3040,tl-mr3040-v1,tp-link-tl-mr3040))

# TL-MR3220 v1
$(eval $(call GluonProfile,TLMR3220,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLMR3220,tl-mr3220-v1,tp-link-tl-mr3220))

# TL-MR3420 v1
$(eval $(call GluonProfile,TLMR3420,$(USB_PACKAGES)))
$(eval $(call GluonModel,TLMR3420,tl-mr3420-v1,tp-link-tl-mr3420))

## Ubiquiti (everything)
$(eval $(call GluonProfile,UBNT,$(USB_PACKAGES)))
$(eval $(call GluonModel,UBNT,ubnt-bullet-m,ubiquity-bullet-m))
$(eval $(call GluonModel,UBNT,ubnt-nano-m,ubiquity-nanostation-m))
