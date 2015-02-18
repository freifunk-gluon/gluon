# List of hardware profiles

## TP-Link

# CPE210/220/510/520
$(eval $(call GluonProfile,CPE510,rssileds))
$(eval $(call GluonModel,CPE510,cpe210-220-510-520-squashfs,tp-link-cpe210-v1.0))
$(eval $(call GluonModel,CPE510,cpe210-220-510-520-squashfs,tp-link-cpe220-v1.0))
$(eval $(call GluonModel,CPE510,cpe210-220-510-520-squashfs,tp-link-cpe510-v1.0))
$(eval $(call GluonModel,CPE510,cpe210-220-510-520-squashfs,tp-link-cpe520-v1.0))

# TL-WR703N v1
$(eval $(call GluonProfile,TLWR703))
$(eval $(call GluonModel,TLWR703,tl-wr703n-v1-squashfs,tp-link-tl-wr703n-v1))

# TL-WR710N v1
$(eval $(call GluonProfile,TLWR710))
$(eval $(call GluonModel,TLWR710,tl-wr710n-v1-squashfs,tp-link-tl-wr710n-v1))

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

# TL-WR801N/ND v2
$(eval $(call GluonProfile,TLWA801))
$(eval $(call GluonModel,TLWA801,tl-wa801nd-v2-squashfs,tp-link-tl-wa801n-nd-v2))

# TL-WR841N/ND v3, v5, v7, v8, v9
$(eval $(call GluonProfile,TLWR841))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v3-squashfs,tp-link-tl-wr841n-nd-v3))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v5-squashfs,tp-link-tl-wr841n-nd-v5))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v7-squashfs,tp-link-tl-wr841n-nd-v7))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v8-squashfs,tp-link-tl-wr841n-nd-v8))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v9-squashfs,tp-link-tl-wr841n-nd-v9))

# TL-WR842N/ND v1, v2
$(eval $(call GluonProfile,TLWR842))
$(eval $(call GluonModel,TLWR842,tl-wr842n-v1-squashfs,tp-link-tl-wr842n-nd-v1))
$(eval $(call GluonModel,TLWR842,tl-wr842n-v2-squashfs,tp-link-tl-wr842n-nd-v2))

# TL-WR941N/ND v2, v3, v4, v5, v6
$(eval $(call GluonProfile,TLWR941))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v2-squashfs,tp-link-tl-wr941n-nd-v2))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v3-squashfs,tp-link-tl-wr941n-nd-v3))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v4-squashfs,tp-link-tl-wr941n-nd-v4))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v5-squashfs,tp-link-tl-wr941n-nd-v5))
ifeq ($(BROKEN),1)
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v6-squashfs,tp-link-tl-wr941n-nd-v6)) # BROKEN: untested
endif

# TL-WR1043N/ND v1, v2
$(eval $(call GluonProfile,TLWR1043))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v1-squashfs,tp-link-tl-wr1043n-nd-v1))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v2-squashfs,tp-link-tl-wr1043n-nd-v2))

# TL-WDR3500/3600/4300 v1
$(eval $(call GluonProfile,TLWDR4300))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3500-v1-squashfs,tp-link-tl-wdr3500-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3600-v1-squashfs,tp-link-tl-wdr3600-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr4300-v1-squashfs,tp-link-tl-wdr4300-v1))

# TL-WA750RE v1
$(eval $(call GluonProfile,TLWA750))
$(eval $(call GluonModel,TLWA750,tl-wa750re-v1-squashfs,tp-link-tl-wa750re-v1))

ifeq ($(BROKEN),1)
# TL-WA830RE v2
$(eval $(call GluonProfile,TLWA830))
$(eval $(call GluonModel,TLWA830,tl-wa830re-v2-squashfs,tp-link-tl-wa830re-v2))
endif

# TL-WA850RE v1
$(eval $(call GluonProfile,TLWA850))
$(eval $(call GluonModel,TLWA850,tl-wa850re-v1-squashfs,tp-link-tl-wa850re-v1))

# TL-WA860RE v1
$(eval $(call GluonProfile,TLWA860))
$(eval $(call GluonModel,TLWA860,tl-wa860re-v1-squashfs,tp-link-tl-wa860re-v1))

# TL-WA901N/ND v2
$(eval $(call GluonProfile,TLWA901))
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v2-squashfs,tp-link-tl-wa901n-nd-v2))
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v3-squashfs,tp-link-tl-wa901n-nd-v3))

# TL-MR3020 v1
$(eval $(call GluonProfile,TLMR3020))
$(eval $(call GluonModel,TLMR3020,tl-mr3020-v1-squashfs,tp-link-tl-mr3020-v1))

# TL-MR3040 v1, v2
$(eval $(call GluonProfile,TLMR3040))
$(eval $(call GluonModel,TLMR3040,tl-mr3040-v1-squashfs,tp-link-tl-mr3040-v1))
$(eval $(call GluonModel,TLMR3040,tl-mr3040-v2-squashfs,tp-link-tl-mr3040-v2))

# TL-MR3220 v1
$(eval $(call GluonProfile,TLMR3220))
$(eval $(call GluonModel,TLMR3220,tl-mr3220-v1-squashfs,tp-link-tl-mr3220-v1))

# TL-MR3420 v1, v2
$(eval $(call GluonProfile,TLMR3420))
$(eval $(call GluonModel,TLMR3420,tl-mr3420-v1-squashfs,tp-link-tl-mr3420-v1))
$(eval $(call GluonModel,TLMR3420,tl-mr3420-v2-squashfs,tp-link-tl-mr3420-v2))

# TL-WR2543N/ND v1
$(eval $(call GluonProfile,TLWR2543))
$(eval $(call GluonModel,TLWR2543,tl-wr2543-v1-squashfs,tp-link-tl-wr2543n-nd-v1))

ifeq ($(BROKEN),1)
# Archer C5 v1, C7 v2
$(eval $(call GluonProfile,ARCHERC7,kmod-ath10k))
$(eval $(call GluonModel,ARCHERC7,archer-c5-squashfs,tp-link-archer-c5-v1)) # BROKEN: ath10k
$(eval $(call GluonModel,ARCHERC7,archer-c7-v2-squashfs,tp-link-archer-c7-v2)) # BROKEN: ath10k
endif

## Ubiquiti (everything)
$(eval $(call GluonProfile,UBNT))
$(eval $(call GluonModel,UBNT,ubnt-bullet-m-squashfs,ubiquiti-bullet-m))
$(eval $(call GluonModel,UBNT,ubnt-loco-m-xw-squashfs,ubiquiti-loco-m-xw))
$(eval $(call GluonModel,UBNT,ubnt-nano-m-squashfs,ubiquiti-nanostation-m))
$(eval $(call GluonModel,UBNT,ubnt-nano-m-xw-squashfs,ubiquiti-nanostation-m-xw))
$(eval $(call GluonModel,UBNT,ubnt-unifi-squashfs,ubiquiti-unifi))
$(eval $(call GluonModel,UBNT,ubnt-unifi-outdoor-squashfs,ubiquiti-unifiap-outdoor))
ifeq ($(BROKEN),1)
$(eval $(call GluonModel,UBNT,ubnt-ls-sr71-squashfs,ubiquiti-ls-sr71)) # BROKEN: Untested
$(eval $(call GluonModel,UBNT,ubnt-uap-pro-squashfs,ubiquiti-unifi-ap-pro)) # BROKEN: not properly tested; probably issues with WLAN adapter detection
$(eval $(call GluonModel,UBNT,ubnt-unifi-outdoor-plus-squashfs,ubiquiti-unifiap-outdoor+)) # BROKEN: WLAN doesn't work correctly (high packet loss)
endif


## D-Link

# D-Link DIR-615 rev. C1
$(eval $(call GluonProfile,DIR615C1))
$(eval $(call GluonModel,DIR615C1,dir-615-c1-squashfs,d-link-dir-615-rev-c1))

# D-Link DIR-825 rev. B1
$(eval $(call GluonProfile,DIR825B1))
$(eval $(call GluonModel,DIR825B1,dir-825-b1-squashfs,d-link-dir-825-rev-b1))


## Linksys by Cisco

# WRT160NL
$(eval $(call GluonProfile,WRT160NL))
$(eval $(call GluonModel,WRT160NL,wrt160nl-squashfs,linksys-wrt160nl))

## Buffalo

# WZR-HP-G450H
$(eval $(call GluonProfile,WZRHPG450H))
$(eval $(call GluonModel,WZRHPG450H,wzr-hp-g450h-squashfs,buffalo-wzr-hp-g450h))

# WZR-HP-AG300H/WZR-600DHP
$(eval $(call GluonProfile,WZRHPAG300H))
$(eval $(call GluonModel,WZRHPAG300H,wzr-hp-ag300h-squashfs,buffalo-wzr-hp-ag300h-wzr-600dhp))

## Netgear

# WNDR3700v2/3800
$(eval $(call GluonProfile,WNDR3700))
$(eval $(call GluonProfileFactorySuffix,WNDR3700,.img))
$(eval $(call GluonModel,WNDR3700,wndr3700-squashfs,netgear-wndr3700))
$(eval $(call GluonModel,WNDR3700,wndr3700v2-squashfs,netgear-wndr3700v2))
$(eval $(call GluonModel,WNDR3700,wndr3800-squashfs,netgear-wndr3800))
+
+## Allnet
+
+# ALL0315N
+$(eval $(call GluonProfile,ALL0315N,uboot-envtools rssileds))
+$(eval $(call GluonProfileFactorySuffix,ALL0315N,))
+$(eval $(call GluonModel,ALL0315N,all0315n-squashfs,allnet-all0315n))
