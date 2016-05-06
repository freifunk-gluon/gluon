# List of hardware profiles

## TP-Link

# CPE210/220/510/520
$(eval $(call GluonProfile,CPE510,rssileds))
$(eval $(call GluonModel,CPE510,cpe210-220-510-520,tp-link-cpe510-v1.0))

$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe210-v1.0))
$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe220-v1.0))
$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe520-v1.0))
$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe210-v1.1))
$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe220-v1.1))
$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe510-v1.1))
$(eval $(call GluonModelAlias,CPE510,tp-link-cpe510-v1.0,tp-link-cpe520-v1.1))

# TL-WA701N/ND v1, v2
$(eval $(call GluonProfile,TLWA701))
$(eval $(call GluonModel,TLWA701,tl-wa701n-v1,tp-link-tl-wa701n-nd-v1))
$(eval $(call GluonModel,TLWA701,tl-wa701nd-v2,tp-link-tl-wa701n-nd-v2))

# TL-WA7510 v1
$(eval $(call GluonProfile,TLWA7510))
$(eval $(call GluonModel,TLWA7510,tl-wa7510n,tp-link-tl-wa7510n-v1))

# TL-WR703N v1
$(eval $(call GluonProfile,TLWR703))
$(eval $(call GluonModel,TLWR703,tl-wr703n-v1,tp-link-tl-wr703n-v1))

# TL-WR710N v1, v2, v2.1
$(eval $(call GluonProfile,TLWR710))
$(eval $(call GluonModel,TLWR710,tl-wr710n-v1,tp-link-tl-wr710n-v1))
$(eval $(call GluonModel,TLWR710,tl-wr710n-v2,tp-link-tl-wr710n-v2))
$(eval $(call GluonModel,TLWR710,tl-wr710n-v2.1,tp-link-tl-wr710n-v2.1))

# TL-WR740N v1, v3, v4, v5
$(eval $(call GluonProfile,TLWR740))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v1,tp-link-tl-wr740n-nd-v1))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v3,tp-link-tl-wr740n-nd-v3))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v4,tp-link-tl-wr740n-nd-v4))
$(eval $(call GluonModel,TLWR740,tl-wr740n-v5,tp-link-tl-wr740n-nd-v5))

# TL-WR741N/ND v1, v2, v4, v5
$(eval $(call GluonProfile,TLWR741))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v1,tp-link-tl-wr741n-nd-v1))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v2,tp-link-tl-wr741n-nd-v2))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v4,tp-link-tl-wr741n-nd-v4))
$(eval $(call GluonModel,TLWR741,tl-wr741nd-v5,tp-link-tl-wr741n-nd-v5))

# TL-WR743N/ND v1, v1.1, v2
$(eval $(call GluonProfile,TLWR743))
$(eval $(call GluonModel,TLWR743,tl-wr743nd-v1,tp-link-tl-wr743n-nd-v1))
$(eval $(call GluonModel,TLWR743,tl-wr743nd-v2,tp-link-tl-wr743n-nd-v2))

# TL-WR801N/ND v1, v2
$(eval $(call GluonProfile,TLWA801))
$(eval $(call GluonModel,TLWA801,tl-wa801nd-v1,tp-link-tl-wa801n-nd-v1))
$(eval $(call GluonModel,TLWA801,tl-wa801nd-v2,tp-link-tl-wa801n-nd-v2))

# TL-WR841N/ND v3, v5, v7, v8, v9, v10, v11
$(eval $(call GluonProfile,TLWR841))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v3,tp-link-tl-wr841n-nd-v3))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v5,tp-link-tl-wr841n-nd-v5))
$(eval $(call GluonModel,TLWR841,tl-wr841nd-v7,tp-link-tl-wr841n-nd-v7))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v8,tp-link-tl-wr841n-nd-v8))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v9,tp-link-tl-wr841n-nd-v9))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v10,tp-link-tl-wr841n-nd-v10))
$(eval $(call GluonModel,TLWR841,tl-wr841n-v11,tp-link-tl-wr841n-nd-v11))

# TL-WR842N/ND v1, v2
$(eval $(call GluonProfile,TLWR842))
$(eval $(call GluonModel,TLWR842,tl-wr842n-v1,tp-link-tl-wr842n-nd-v1))
$(eval $(call GluonModel,TLWR842,tl-wr842n-v2,tp-link-tl-wr842n-nd-v2))

# TL-WR843N/ND v1
$(eval $(call GluonProfile,TLWR843))
$(eval $(call GluonModel,TLWR843,tl-wr843nd-v1,tp-link-tl-wr843n-nd-v1))

# TL-WR941N/ND v2, v3, v4, v5, v6; TL-WR940N/ND v1, v2, v3
$(eval $(call GluonProfile,TLWR941))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v2,tp-link-tl-wr941n-nd-v2))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v3,tp-link-tl-wr941n-nd-v3))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v4,tp-link-tl-wr941n-nd-v4))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v5,tp-link-tl-wr941n-nd-v5))
$(eval $(call GluonModel,TLWR941,tl-wr941nd-v6,tp-link-tl-wr941n-nd-v6))

$(eval $(call GluonModelAlias,TLWR941,tp-link-tl-wr941n-nd-v4,tp-link-tl-wr940n-nd-v1))
$(eval $(call GluonModelAlias,TLWR941,tp-link-tl-wr941n-nd-v5,tp-link-tl-wr940n-nd-v2))
$(eval $(call GluonModelAlias,TLWR941,tp-link-tl-wr941n-nd-v6,tp-link-tl-wr940n-nd-v3))

# TL-WR1043N/ND v1, v2, v3
$(eval $(call GluonProfile,TLWR1043))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v1,tp-link-tl-wr1043n-nd-v1))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v2,tp-link-tl-wr1043n-nd-v2))
$(eval $(call GluonModel,TLWR1043,tl-wr1043nd-v3,tp-link-tl-wr1043n-nd-v3))

# TL-WDR3500/3600/4300 v1
$(eval $(call GluonProfile,TLWDR4300))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3500-v1,tp-link-tl-wdr3500-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr3600-v1,tp-link-tl-wdr3600-v1))
$(eval $(call GluonModel,TLWDR4300,tl-wdr4300-v1,tp-link-tl-wdr4300-v1))

# TL-WA750RE v1
$(eval $(call GluonProfile,TLWA750))
$(eval $(call GluonModel,TLWA750,tl-wa750re-v1,tp-link-tl-wa750re-v1))

# TL-WA830RE v1, v2
$(eval $(call GluonProfile,TLWA830))
$(eval $(call GluonModel,TLWA830,tl-wa830re-v1,tp-link-tl-wa830re-v1))
$(eval $(call GluonModel,TLWA830,tl-wa830re-v2,tp-link-tl-wa830re-v2))

# TL-WA850RE v1
$(eval $(call GluonProfile,TLWA850))
$(eval $(call GluonModel,TLWA850,tl-wa850re-v1,tp-link-tl-wa850re-v1))

# TL-WA860RE v1
$(eval $(call GluonProfile,TLWA860))
$(eval $(call GluonModel,TLWA860,tl-wa860re-v1,tp-link-tl-wa860re-v1))

# TL-WA901N/ND v1, v2, v3, v4
$(eval $(call GluonProfile,TLWA901))
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v1,tp-link-tl-wa901n-nd-v1))
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v2,tp-link-tl-wa901n-nd-v2))
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v3,tp-link-tl-wa901n-nd-v3))
ifneq ($(BROKEN),)
$(eval $(call GluonModel,TLWA901,tl-wa901nd-v4,tp-link-tl-wa901n-nd-v4)) # BROKEN: untested
endif

# TL-MR13U v1
$(eval $(call GluonProfile,TLMR13U))
$(eval $(call GluonModel,TLMR13U,tl-mr13u-v1,tp-link-tl-mr13u-v1))

# TL-MR3020 v1
$(eval $(call GluonProfile,TLMR3020))
$(eval $(call GluonModel,TLMR3020,tl-mr3020-v1,tp-link-tl-mr3020-v1))

# TL-MR3040 v1, v2
$(eval $(call GluonProfile,TLMR3040))
$(eval $(call GluonModel,TLMR3040,tl-mr3040-v1,tp-link-tl-mr3040-v1))
$(eval $(call GluonModel,TLMR3040,tl-mr3040-v2,tp-link-tl-mr3040-v2))

# TL-MR3220 v1, v2
$(eval $(call GluonProfile,TLMR3220))
$(eval $(call GluonModel,TLMR3220,tl-mr3220-v1,tp-link-tl-mr3220-v1))
$(eval $(call GluonModel,TLMR3220,tl-mr3220-v2,tp-link-tl-mr3220-v2))

# TL-MR3420 v1, v2
$(eval $(call GluonProfile,TLMR3420))
$(eval $(call GluonModel,TLMR3420,tl-mr3420-v1,tp-link-tl-mr3420-v1))
$(eval $(call GluonModel,TLMR3420,tl-mr3420-v2,tp-link-tl-mr3420-v2))

# TL-WR2543N/ND v1
$(eval $(call GluonProfile,TLWR2543))
$(eval $(call GluonModel,TLWR2543,tl-wr2543-v1,tp-link-tl-wr2543n-nd-v1))

ifneq ($(BROKEN),)
# Archer C5 v1, C7 v2
$(eval $(call GluonProfile,ARCHERC7,kmod-ath10k ath10k-firmware-qca988x-ct))
$(eval $(call GluonModel,ARCHERC7,archer-c5,tp-link-archer-c5-v1)) # BROKEN: ath10k
$(eval $(call GluonModel,ARCHERC7,archer-c7-v2,tp-link-archer-c7-v2)) # BROKEN: ath10k
endif

## Ubiquiti (everything)
$(eval $(call GluonProfile,UBNT))
$(eval $(call GluonModel,UBNT,ubnt-air-gateway,ubiquiti-airgateway))
$(eval $(call GluonModel,UBNT,ubnt-airrouter,ubiquiti-airrouter))

$(eval $(call GluonModel,UBNT,ubnt-bullet-m,ubiquiti-bullet-m))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-nanostation-loco-m2))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-nanostation-loco-m5))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-rocket-m2))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-rocket-m5))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-bullet-m2))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-bullet-m5))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-bullet-m,ubiquiti-picostation-m2))

$(eval $(call GluonModel,UBNT,ubnt-nano-m,ubiquiti-nanostation-m))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-nanostation-m,ubiquiti-nanostation-m2))
$(eval $(call GluonModelAlias,UBNT,ubiquiti-nanostation-m,ubiquiti-nanostation-m5))

$(eval $(call GluonModel,UBNT,ubnt-loco-m-xw,ubiquiti-loco-m-xw))
$(eval $(call GluonModel,UBNT,ubnt-nano-m-xw,ubiquiti-nanostation-m-xw))
$(eval $(call GluonModel,UBNT,ubnt-rocket-m-xw,ubiquiti-rocket-m-xw))
$(eval $(call GluonModel,UBNT,ubnt-uap-pro,ubiquiti-unifi-ap-pro))
$(eval $(call GluonModel,UBNT,ubnt-unifi,ubiquiti-unifi))
$(eval $(call GluonModel,UBNT,ubnt-unifi-outdoor,ubiquiti-unifiap-outdoor))
$(eval $(call GluonModel,UBNT,ubnt-unifi-outdoor-plus,ubiquiti-unifiap-outdoor+))

ifneq ($(BROKEN),)
$(eval $(call GluonModel,UBNT,ubnt-ls-sr71,ubiquiti-ls-sr71)) # BROKEN: Untested
endif


## D-Link

# D-Link DIR-505 rev. A1

$(eval $(call GluonProfile,DIR505A1))
$(eval $(call GluonModel,DIR505A1,dir-505-a1,d-link-dir-505-rev-a1))

# D-Link DIR-615 rev. C1
$(eval $(call GluonProfile,DIR615C1))
$(eval $(call GluonModel,DIR615C1,dir-615-c1,d-link-dir-615-rev-c1))

# D-Link DIR-825 rev. B1
$(eval $(call GluonProfile,DIR825B1))
$(eval $(call GluonModel,DIR825B1,dir-825-b1,d-link-dir-825-rev-b1))


## Linksys by Cisco

# WRT160NL
$(eval $(call GluonProfile,WRT160NL))
$(eval $(call GluonModel,WRT160NL,wrt160nl,linksys-wrt160nl))

## Buffalo

# WZR-HP-G450H
$(eval $(call GluonProfile,WZRHPG450H))
$(eval $(call GluonModel,WZRHPG450H,wzr-hp-g450h,buffalo-wzr-hp-g450h))

# WZR-HP-G300NH
$(eval $(call GluonProfile,WZRHPG300NH))
$(eval $(call GluonModel,WZRHPG300NH,wzr-hp-g300nh,buffalo-wzr-hp-g300nh))

# WZR-HP-AG300H (factory)
$(eval $(call GluonProfile,WZRHPAG300H))
$(eval $(call GluonProfileSysupgradeSuffix,WZRHPAG300H))
$(eval $(call GluonModel,WZRHPAG300H,wzr-hp-ag300h,buffalo-wzr-hp-ag300h))

# WZR-600DHP (factory)
$(eval $(call GluonProfile,WZR600DHP))
$(eval $(call GluonProfileSysupgradeSuffix,WZR600DHP))
$(eval $(call GluonModel,WZR600DHP,wzr-600dhp,buffalo-wzr-600dhp))

# WZR-HP-AG300H/WZR-600DHP (sysupgrade)
$(eval $(call GluonProfile,WZRHPAG300H_WZR600DHP,,WZRHPAG300H))
$(eval $(call GluonProfileFactorySuffix,WZRHPAG300H_WZR600DHP))
$(eval $(call GluonModel,WZRHPAG300H_WZR600DHP,wzr-hp-ag300h,buffalo-wzr-hp-ag300h-wzr-600dhp))

# WHR-HP-G300N
#$(eval $(call GluonProfile,WHRHPG300N))
#$(eval $(call GluonModel,WHRHPG300N,whr-hp-g300n,buffalo-whr-hp-g300n))

## Netgear

# WNDR3700 (v1, v2) / WNDR3800 / WNDRMAC (v1, v2)
$(eval $(call GluonProfile,WNDR3700))
$(eval $(call GluonProfileFactorySuffix,WNDR3700,-squashfs-factory,.img))
$(eval $(call GluonModel,WNDR3700,wndr3700,netgear-wndr3700))
$(eval $(call GluonModel,WNDR3700,wndr3700v2,netgear-wndr3700v2))
$(eval $(call GluonModel,WNDR3700,wndr3800,netgear-wndr3800))
ifneq ($(BROKEN),)
$(eval $(call GluonModel,WNDR3700,wndrmac,netgear-wndrmac)) # BROKEN: untested
endif
$(eval $(call GluonModel,WNDR3700,wndrmacv2,netgear-wndrmacv2))

## Allnet

# ALL0315N
$(eval $(call GluonProfile,ALL0315N,uboot-envtools rssileds))
$(eval $(call GluonProfileFactorySuffix,ALL0315N))
$(eval $(call GluonModel,ALL0315N,all0315n,allnet-all0315n))

## GL-iNet

# GL-iNet 1.0
$(eval $(call GluonProfile,GLINET))
$(eval $(call GluonModel,GLINET,gl-inet-6408A-v1,gl-inet-6408a-v1))
$(eval $(call GluonModel,GLINET,gl-inet-6416A-v1,gl-inet-6416a-v1))

## Western Digital

# WD MyNet N600
$(eval $(call GluonProfile,MYNETN600))
$(eval $(call GluonModel,MYNETN600,mynet-n600,wd-my-net-n600))

# WD MyNet N750
$(eval $(call GluonProfile,MYNETN750))
$(eval $(call GluonModel,MYNETN750,mynet-n750,wd-my-net-n750))

## Onion

# Omega
$(eval $(call GluonProfile,OMEGA))
$(eval $(call GluonModel,OMEGA,onion-omega,onion-omega))

## ALFA

# Hornet-UB
$(eval $(call GluonProfile,HORNETUB))
$(eval $(call GluonModel,HORNETUB,hornet-ub,alfa-hornet-ub))
$(eval $(call GluonModelAlias,HORNETUB,alfa-hornet-ub,alfa-ap121))
$(eval $(call GluonModelAlias,HORNETUB,alfa-hornet-ub,alfa-ap121u))

## Meraki

# Meraki MR12/MR62
$(eval $(call GluonProfile,MR12,rssileds))
$(eval $(call GluonProfileFactorySuffix,MR12))
$(eval $(call GluonModel,MR12,mr12,meraki-mr12))
$(eval $(call GluonModelAlias,MR12,meraki-mr12,meraki-mr62))

# Meraki MR16/MR66
$(eval $(call GluonProfile,MR16,rssileds))
$(eval $(call GluonProfileFactorySuffix,MR16))
$(eval $(call GluonModel,MR16,mr16,meraki-mr16))
$(eval $(call GluonModelAlias,MR16,meraki-mr16,meraki-mr66))

## 8devices

# Carambola 2
$(eval $(call GluonProfile,CARAMBOLA2))
$(eval $(call GluonModel,CARAMBOLA2,carambola2,8devices-carambola2-board))
$(eval $(call GluonProfileFactorySuffix,CARAMBOLA2))
