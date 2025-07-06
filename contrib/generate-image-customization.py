#!/usr/bin/env python3

import requests
from pathlib import Path

toh = requests.get("https://openwrt.org/toh.json").json()


def get_devices_from_gluon():
    devices = []
    for path in Path("../targets").glob("*"):
        file = path.read_text()
        for line in file.splitlines():
            if line.startswith("device('"):
                devices.append(line.split("('")[1].split("',")[0])
    return devices


# the name of some devices in the openwrt deviceid does not match
# the gluon identifier from the device name
map_openwrt_to_gluon = {
    "aerohive-ap121": "aerohive-hiveap-121",
    "arcadyanastoria-vgv7510kw22o2box6431": "arcadyan-vgv7510kw22",
    "asus-rt-ac57u": "asus-rt-ac57u-v1",
    "avm-fritz-box-7360sl": "avm-fritz-box-7360-sl",
    "avm-fritz-box-7362sl": "avm-fritz-box-7362-sl",
    "avm-fritz-box-wlan-3370": [
        "avm-fritz-box-3370-rev-2-micron-nand",
        "avm-fritz-box-3370-rev-2-hynix-nand",
    ],
    "buffalo-wzr-hp-ag300h-v1": "buffalo-wzr-hp-ag300h",
    "buffalo-wzr-hp-g300nh-v1": "buffalo-wzr-hp-g300nh-rtl8366s",
    "cudy-wr1000-v1": "cudy-wr1000",
    "cudy-x6": "cudy-x6-v1",
    "d-link-aquila-pro-ai-m30": "d-link-aquila-pro-ai-m30-a1",
    "d-link-dir-825": "d-link-dir825b1",
    "devolo-dlan-pro-1200-wifi-ac": "devolo-dlan-pro-1200+-wifi-ac",
    "extreme-networks-ws-ap3935i": "extreme-networks-ap3935",
    "friendlyarm-nanopi-r2s": "friendlyelec-nanopi-r2s",
    "friendlyarm-nanopi-r4s": "friendlyelec-nanopi-r4s",
    "gl.inet-6416a": "gl.inet-6416",
    "gl.inet-gl-ar300m": "gl.inet-gl-ar300m-nor",
    "gl.inet-gl-ar750s": "gl.inet-gl-ar750s-nor",
    "gl.inet-gl-mt2500-gl-mt2500a": "gl.inet-gl-mt2500",
    "gl.inet-gl-mt300a": "gl-mt300a",
    "gl.inet-gl-mt300n-v1": "gl-mt300n",
    "gl.inet-gl-mt300n-v2": "gl-mt300n-v2",
    "gl.inet-gl-mt750": "gl-mt750",
    "gl.inet-gl-mv1000-brume": "gl.inet-gl-mv1000",
    "google-wifi": "google-wifi-gale",
    "hpe-msm460": "hewlett-packard-msm460",
    "lamobo-bananapi-r1": "lamobo-r1",
    "lemaker-bananapi": "lemaker-banana-pi",
    "librerouter-librerouter-v1": "librerouter-v1",
    "linksys-e4200-v2": "linksys-e4200-v2-viper",
    "linksys-e8450": "linksys-e8450-ubi",
    "linksys-ea4500-v1": "linksys-ea4500-viper",
    "linksys-ea6350-v3": "linksys-ea6350v3",
    "meraki-mr33": "meraki-mr33-access-point",
    "mikrotik-rb951ui-2nd": "mikrotik-routerboard-951ui-2nd-hap",
    "mikrotik-rbd52g-5hacd2hnd-tc-hap-ac2": "mikrotik-hap-ac2",
    "mikrotik-rbwapr-2nd-wap-r": "mikrotik-routerboard-wapr-2nd",
    "netgear-ex6100-v2": "netgear-ex6100v2",
    "netgear-ex6150-v2": "netgear-ex6150v2",
    "netgear-r7800": "netgear-nighthawk-x4s-r7800",
    "netgear-wndr3700-v1": "netgear-wndr3700",
    "netgear-wndr3800-ch": "netgear-wndr3800ch",
    "netgear-wndr3800ch": "netgear-wndr3800",
    "netgear-wndr4300-v1": "netgear-wndr4300",
    "netgear-wnr2200-16mb-ru": "netgear-wnr2200-16m",
    "netgear-wnr2200-8mb-eu": "netgear-wnr2200-8m",
    "nexx-wt3020h": "nexx-wt3020-8m",
    "openmesh-om2p": "openmesh-om2p-v1",
    "openmesh-om5p-ac": "openmesh-om5p-ac-v1",
    "openwrt-one-1": "openwrt-one",
    "qemu-arm": ["armsr-armv7", "armsr-armv8"],
    "qemu-i386": ["x86-legacy", "x86-geode", "x86-generic"],
    "qemu-x86-64": "x86-64",
    "raspberry-pi-2-b": "raspberrypi-2-model-b",
    "raspberry-pi-3-b": "raspberrypi-3-model-b",
    "raspberry-pi-b": "raspberrypi-model-b",
    "raspberry-pi-foundation-raspberry-pi-4-b": "raspberrypi-4-model-b",
    "sophos-ap100-rev-1": "sophos-ap100",
    "sophos-ap100c-rev-1": "sophos-ap100c",
    "sophos-ap55-rev-1": "sophos-ap55",
    "sophos-ap55c-rev-1": "sophos-ap55c",
    "sophos-red-15w-rev.-1": "sophos-red-15w-rev.1",
    "teltonika-rut230": "teltonika-rut230-v1",
    "tp-link-archer-c2-ac750": "tp-link-archer-c2-v1",
    "tp-link-archer-c20-ac750-v1": "tp-link-archer-c20-v1",
    "tp-link-archer-c20-ac750-v4": "tp-link-archer-c20-v4",
    "tp-link-archer-c20i-ac750-v1": "tp-link-archer-c20i",
    "tp-link-archer-c5-ac1200-v1": "tp-link-archer-c5-v1",
    "tp-link-archer-c6-v2-eu": "tp-link-archer-c6-v2-eu-ru-jp",
    "tp-link-archer-c7-ac1750-v2.0": "tp-link-archer-c7-v2",
    "tp-link-ax23-v1": "tp-link-archer-ax23-v1",
    "tp-link-eap615-wall": "tp-link-eap615-wall-v1",
    "tp-link-td-w8970-v1": "tp-link-td-w8970",
    "tp-link-tl-wdr4300": "tp-link-tl-wdr4300-v1",
    "tp-link-tl-wr2543nd-v1": "tp-link-tl-wr2543n-nd",
    "tp-link-tl-wr810n-v1.1-eu": "tp-link-tl-wr810n-v1",
    "ubiquiti-unifi-6-lr": "ubiquiti-unifi-6-lr-v1",
    "ubiquiti-unifi-apac": "ubiquiti-unifi-ac-mesh",
    "ubiquiti-unifi-apac-lite": "ubiquiti-unifi-ac-lite",
    "ubiquiti-unifi-apac-lr": "ubiquiti-unifi-ac-lr",
    "ubiquiti-unifi-apac-pro": "ubiquiti-unifi-ac-pro",
    "ubiquiti-unifi-outdoorplus": "ubiquiti-unifi-ap-outdoor+",
    "ubiquiti-unifi-uk-ultra": "ubiquiti-unifi-swiss-army-knife-ultra",
    "vocore-vocore2": "vocore2",
    "xiaomi-mi-router-4a-100m": [
        "xiaomi-mi-router-4a-100m-edition",
        "xiaomi-mi-router-4a-100m-international-edition",
        "xiaomi-mi-router-4a-100m-international-edition-v2",
    ],
    "xiaomi-mi-router-4a-gbit": [
        "xiaomi-mi-router-4a-gigabit-edition",
        "xiaomi-mi-router-4a-gigabit-edition-v2",
    ],
    "xiaomi-mi-wifi-range-extender-ac1200-ra75": "xiaomi-mi-ra75",
    "xiaomi-mini-v1": "xiaomi-miwifi-mini",
    "xiaomi-miwifi-3g": "xiaomi-mi-router-3g",
    "xiaomi-miwifi-3g-v2": "xiaomi-mi-router-3g-v2",
    "zbt-wg3526-16m": "zbtlink-zbt-wg3526-16m",
    "zbt-wg3526-32m": "zbtlink-zbt-wg3526-32m",
    "zyxel-nbg6716-a01": "zyxel-nbg6716",
}

entries = toh["entries"]
captions = toh["captions"]
columns = toh["columns"]


def create_caption_dict(columns: list, entries: dict):
    # entries are openwrt toh entries
    result = {}
    for entry in entries:
        result_entry = {}
        for index, column in enumerate(columns):
            result_entry[column] = entry[index]
        device = result_entry["deviceid"].split(":")[1]
        device = device.lower().replace("_", "-").replace(" ", "-").replace("!", "-")
        device = device.replace("open-mesh", "openmesh")
        remap_devices = map_openwrt_to_gluon.get(device, device)
        if isinstance(remap_devices, list):
            for device in remap_devices:
                result[device] = result_entry
        else:
            result[remap_devices] = result_entry
    return result


result = create_caption_dict(columns, entries)

devices = get_devices_from_gluon()
has_gluon = {k: v for k, v in result.items() if k in devices}
# sort dictionary
has_gluon = {k: has_gluon[k] for k in sorted(has_gluon)}

# to check which elements are missing
gluon_missing_from_openwrt = [d for d in devices if d not in result.keys()]

if gluon_missing_from_openwrt:
    print("Following devices are missing", gluon_missing_from_openwrt)

has_lte = {
    k: v for k, v in has_gluon.items() if v["modem"] and v["modem"].lower() == "lte"
}
is_outdoor = {
    k: v for k, v in has_gluon.items() if v["outdoor"] and v["outdoor"].lower() == "yes"
}
has_usb = {
    k: v for k, v in has_gluon.items() if v["usbports"] and v["usbports"] != ["-"]
}
no_wifi24 = {
    k: v for k, v in has_gluon.items() if not v["wlan24ghz"] or v["wlan24ghz"][0] == "-"
}
no_wifi50 = {
    k: v for k, v in has_gluon.items() if not v["wlan50ghz"] or v["wlan50ghz"][0] == "-"
}
atmost_64mb_ram = {
    k: v for k, v in has_gluon.items() if v["rammb"] and int(v["rammb"]) <= 64
}

with open("image-customization-helper.lua", "w") as f:
    usb_devices = "',\n\t'".join([device for device in has_usb])
    lte_devices = "',\n\t'".join([device for device in has_lte])
    outdoor_devices = "',\n\t'".join([device for device in is_outdoor])
    no_wifi24_devices = "',\n\t'".join([device for device in no_wifi24])
    no_wifi50_devices = "',\n\t'".join([device for device in no_wifi50])
    atmost_64mb_ram_devices = "',\n\t'".join([device for device in atmost_64mb_ram])
    lines = f"""#!/usr/bin/lua
has_usb = false
if device(
\t'{usb_devices}'
) then
\thas_usb = true
end

has_lte = false
if device(
\t'{lte_devices}'
) then
\thas_lte = true
end

is_outdoor = false
if device(
\t'{outdoor_devices}'
) then
\tis_outdoor = true
end

no_wifi24 = false
if device(
\t'{no_wifi24_devices}'
) then
\tno_wifi24 = true
end

no_wifi50 = false
if device(
\t'{no_wifi50_devices}'
) then
\tno_wifi50 = true
end

atmost_64mb_ram = false
if device(
\t'{atmost_64mb_ram_devices}'
) then
\tatmost_64mb_ram = true
end
"""
    f.writelines(lines)
