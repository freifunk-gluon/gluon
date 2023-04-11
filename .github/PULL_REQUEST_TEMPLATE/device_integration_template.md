<!--
All pull requests should target master. A backport can be made afterwards and is welcomed (as long as it is easy to realize). Next is not a valid target.

Please name your PR like "$TARGET: add $DEVICE_NAME".
For example, to add ZyXEL NWA55AXE name the PR:
`ramips-mt7621: add support for ZyXEL NWA55AXE`

Next fill out the following device integration checklist and make notes if something unexpected happens

You can use the "Preview" tab to check how your issue is going to look
before you actually send it in.

Thank you for taking the time to integrate a new device into the Gluon project.

-->
- [ ] Must be flashable from vendor firmware
  - [ ] Web interface
  - [ ] TFTP
  - [ ] Other: <specify>
- [ ] Must support upgrade mechanism
  - [ ] Must have working sysupgrade
    - [ ] Must keep/forget configuration (`sysupgrade [-n]`, `firstboot`)
  - [ ] Gluon profile name matches autoupdater image name
        (`lua -e 'print(require("platform_info").get_image_name())'`)
- [ ] Reset/WPS/... button must return device into config mode
- [ ] Primary MAC address should match address on device label (or packaging)
      (https://gluon.readthedocs.io/en/latest/dev/hardware.html#hardware-support-in-packages)
  - When re-adding a device that was supported by an earlier version of Gluon, a
    factory reset must be performed before checking the primary MAC address, as
    the setting from the old version is not reset otherwise.
- Wired network
  - [ ] should support all network ports on the device
  - [ ] must have correct port assignment (WAN/LAN)
    - if there are multiple ports but no WAN port:
      - the PoE input should be WAN, all other ports LAN
      - otherwise the first port should be delcared as WAN, all other ports LAN
- Wireless network (if applicable)
  - [ ] Association with AP must be possible on all radios
  - [ ] Association with 802.11s mesh must work on all radios 
  - [ ] AP+mesh mode must work in parallel on all radios
- LED mapping
  - Power/system LED
    - [ ] Lit while the device is on
    - [ ] Should display config mode blink sequence 
          (https://gluon.readthedocs.io/en/latest/features/configmode.html)
  - Radio LEDs
    - [ ] Should map to their respective radio
    - [ ] Should show activity
  - Switch port LEDs
    - [ ] Should map to their respective port (or switch, if only one led present) 
    - [ ] Should show link state and activity
- Outdoor devices only:
  - [ ] Added board name to `is_outdoor_device` function in `package/gluon-core/luasrc/usr/lib/lua/gluon/platform.lua`
- Cellular devices only:
  - [ ] Added board name to `is_cellular_device` function in `package/gluon-core/luasrc/usr/lib/lua/gluon/platform.lua`
  - [ ] Added board name with modem setup function `setup_ncm_qmi` to `package/gluon-core/luasrc/lib/gluon/upgrade/250-cellular`
- Docs:
  - [ ] Added Device to `docs/user/supported_devices.rst`
