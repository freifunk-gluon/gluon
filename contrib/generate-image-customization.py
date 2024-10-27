#!/usr/bin/env python3

import requests
from pathlib import Path

toh = requests.get("https://openwrt.org/toh.json").json()

entries = toh["entries"]
captions = toh["captions"]
columns = toh["columns"]


def get_devices_from_gluon():
    devices = []
    for path in Path("../targets").glob("*"):
        file = path.read_text()
        for line in file.splitlines():
            if line.startswith("device('"):
                devices.append(line.split("('")[1].split("',")[0])
    return devices


def create_caption_dict(columns, entries):
    result = {}
    for entry in entries:
        result_entry = {}
        for index, column in enumerate(columns):
            result_entry[column] = entry[index]
        device = result_entry["deviceid"].split(":")[1]
        device = device.lower().replace("_", "-").replace(" ", "-").replace("!", "-")
        result[device] = result_entry
    return result


result = create_caption_dict(columns, entries)
devices = get_devices_from_gluon()
has_gluon = {k: v for k, v in result.items() if k in devices}

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
atmost_64mb_ram = {k: v for k, v in has_gluon.items() if int(v["rammb"]) <= 64}

with open("image-customization-helper.lua", "w") as f:
    usb_devices = "',\n'".join([device for device in has_usb])
    lte_devices = "',\n'".join([device for device in has_lte])
    outdoor_devices = "',\n'".join([device for device in is_outdoor])
    no_wifi24_devices = "',\n'".join([device for device in no_wifi24])
    no_wifi50_devices = "',\n'".join([device for device in no_wifi50])
    atmost_64mb_ram_devices = "',\n'".join([device for device in atmost_64mb_ram])
    lines = f"""#!/usr/bin/lua
has_usb = false
if device('{usb_devices}') then
    has_usb = true
end

has_lte = false
if device('{lte_devices}') then
    has_lte = true
end

is_outdoor = false
if device('{outdoor_devices}') then
    is_outdoor = true
end

no_wifi24 = false
if device('{no_wifi24_devices}') then
    no_wifi24 = true
end

no_wifi50 = false
if device('{no_wifi50_devices}') then
    no_wifi50 = true
end

atmost_64mb_ram = false
if device('{atmost_64mb_ram_devices}') then
    atmost_64mb_ram = true
end
"""
    f.writelines(lines)
