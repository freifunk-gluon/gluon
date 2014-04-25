# List of hardware profiles

## TP-Link

# TL-WR740N v1, v3, v4
$(eval $(call GluonProfile,TLWR740))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v1-squashfs,tp-link-tl-wr740n-nd-v1))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v3-squashfs,tp-link-tl-wr740n-nd-v3))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v4-squashfs,tp-link-tl-wr740n-nd-v4))

# TL-WR741N/ND v1, v2, v4
$(eval $(call GluonProfile,TLWR741))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v1-squashfs,tp-link-tl-wr741n-nd-v1))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v2-squashfs,tp-link-tl-wr741n-nd-v2))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v4-squashfs,tp-link-tl-wr741n-nd-v4))

# TL-WR841N/ND v3, v5, v7, v8, v9
$(eval $(call GluonProfile,TLWR841))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v3-squashfs,tp-link-tl-wr841n-nd-v3))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v5-squashfs,tp-link-tl-wr841n-nd-v5))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v7-squashfs,tp-link-tl-wr841n-nd-v7))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v8-squashfs,tp-link-tl-wr841n-nd-v8))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v9-squashfs,tp-link-tl-wr841n-nd-v9))

# TL-WR842N/ND v1
$(eval $(call GluonProfile,TLWR842))
$(eval $(call GluonModel,TLWR842,tl-wr842n-v1-squashfs,tp-link-tl-wr842n-nd-v1))

# TL-WR941N/ND v2, v3, v4
$(eval $(call GluonProfile,TLWR941))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v2-squashfs,tp-link-tl-wr941n-nd-v2))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v3-squashfs,tp-link-tl-wr941n-nd-v3))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v4-squashfs,tp-link-tl-wr941n-nd-v4))

# TL-WR1043N/ND v1
$(eval $(call GluonProfile,TLWR1043))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v1-squashfs,tp-link-tl-wr1043n-nd-v1))

# TL-WDR3500/3600/4300 v1
$(eval $(call GluonProfile,TLWDR4300))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3500-v1-squashfs,tp-link-tl-wdr3500-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3600-v1-squashfs,tp-link-tl-wdr3600-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr4300-v1-squashfs,tp-link-tl-wdr4300-v1))

# TL-WA901N/ND v2
$(eval $(call GluonProfile,TLWA901))
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v2-squashfs,tp-link-tl-wa901n-nd-v2))

# TL-MR3020 v1
$(eval $(call GluonProfile,TLMR3020))
$(eval $(call GluonModel,TLMR3020,tl-mr3020-v1-squashfs,tp-link-tl-mr3020-v1))

# TL-MR3040 v1
$(eval $(call GluonProfile,TLMR3040))
$(eval $(call GluonModel,TLMR3040,tl-mr3040-v1-squashfs,tp-link-tl-mr3040-v1))

# TL-MR3220 v1
$(eval $(call GluonProfile,TLMR3220))
$(eval $(call GluonModel,TLMR3220,tl-mr3220-v1-squashfs,tp-link-tl-mr3220-v1))

# TL-MR3420 v1
$(eval $(call GluonProfile,TLMR3420))
$(eval $(call GluonModel,TLMR3420,tl-mr3420-v1-squashfs,tp-link-tl-mr3420-v1))

## Ubiquiti (everything)
$(eval $(call GluonProfile,UBNT))
$(eval $(call GluonModel,UBNT,ubnt-bullet-m-squashfs,ubiquiti-bullet-m))
$(eval $(call GluonModel,UBNT,ubnt-nano-m-squashfs,ubiquiti-nanostation-m))
$(eval $(call GluonModel,UBNT,ubnt-unifi-squashfs,ubiquiti-unifi))
$(eval $(call GluonModel,UBNT,ubnt-unifi-outdoor-squashfs,ubiquiti-unifiap-outdoor))

# D-Link DIR-825 rev. B1
$(eval $(call GluonProfile,DIR825B1))
$(eval $(call GluonModel,DIR825B1,dir-825-b1-squashfs,d-link-dir-825-rev-b1))
