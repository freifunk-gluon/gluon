Adding hardware support
=======================
This page will give a short overview on how to add support
for new hardware to Gluon.

Hardware requirements
---------------------
Having an ath9k, ath10k or mt76 based WLAN adapter is highly recommended,
although other chipsets may also work. VAP (multiple SSID) support
with simultaneous AP + Mesh Point (802.11s) operation is required.

Device checklist
----------------
The description of pull requests adding device support must include the
`device integration checklist
<https://github.com/freifunk-gluon/gluon/wiki/Device-Integration-checklist>`_.
The checklist ensures that core functionality of Gluon is well supported on the
device.

.. _device-class-definition:

Device classes
--------------
All supported hardware is categorized into "device classes". This allows to
adjust the feature set of Gluon to the different hardware's capabilities via
``site.mk`` without having to list individual devices.

There are currently two devices classes defined: "standard" and "tiny". The
"tiny" class contains all devices that do not meet the following requirements:

- At least 7 MiB of usable firmware space
- At least 64 MiB of RAM (128MiB for devices with ath10k radio)

Target configuration
--------------------
Gluon's hardware support is based on OpenWrt's. For each supported target,
a configuration file exists at ``targets/<target>-<subtarget>`` (or just
``target/<target>`` for targets without subtargets) that contains all
Gluon-specific settings for the target. The generic configuration
``targets/generic`` contains settings that affect all targets.

All targets must be listed in ``target/targets.mk``.

The target configuration language is based on Lua, so Lua's syntax for variables
and control structures can be used.

Device definitions
~~~~~~~~~~~~~~~~~~
To configure a device to be built for Gluon, the ``device`` function is used.
In the simplest case, only two arguments are passed, for example:

.. code-block:: lua

  device('tp-link-tl-wdr3600-v1', 'tplink_tl-wdr3600-v1')

The first argument is the device name in Gluon, which is part of the output
image filename, and must correspond to the model string looked up by the
autoupdater. The second argument is the corresponding device profile name in
OpenWrt, as found in ``openwrt/target/linux/<target>/image/*``.

A table of additional settings can be passed as a third argument:

.. code-block:: lua

  device('ubiquiti-edgerouter-x', 'ubnt_edgerouter-x', {
    factory = false,
    packages = {'-hostapd-mini'},
    manifest_aliases = {
      'ubnt-erx',
    },
  })

The supported additional settings are described in the following sections.

Suffixes and extensions
~~~~~~~~~~~~~~~~~~~~~~~
For many targets, OpenWrt generates images with the suffixes
``-squashfs-factory.bin`` and ``-squashfs-sysupgrade.bin``. For devices with
different image names, is it possible to override the suffixes and extensions
using the settings ``factory``, ``factory_ext``, ``sysupgrade`` and
``sysupgrade_ext``, for example:

.. code-block:: lua

  {
    factory = '-squashfs-combined',
    factory_ext = '.img.gz',
    sysupgrade = '-squashfs-combined',
    sysupgrade_ext = '.img.gz',
  }

Only settings that differ from the defaults need to be passed. ``factory`` and
``sysupgrade`` can be set to ``false`` when no such images exist.

For some device types, there are multiple factory images with different
extensions. ``factory_ext`` can be set to a table of strings to account for this
case:

.. code-block:: lua

  {
    factory_ext = {'.img.gz', '.vmdk', '.vdi'},
  }

TODO: Extra images

Aliases and manifest aliases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Sometimes multiple devices exist that use the same OpenWrt images. To make it
easier to find these images, the ``aliases`` setting can be used to define
additional device names. Gluon will create symlinks for these names in the
image output directory.

.. code-block:: lua

  device('aruba-ap-303', 'aruba_ap-303', {
    factory = false,
    aliases = {'aruba-instant-on-ap11'},
  })

The aliased name will also be added to the autoupdater manifest, allowing upgrade
images to be found under the different name on targets that perform model name
detection at runtime.

It is also possible to add alternative names to the autoupdater manifest without
creating a symlink by using ``manifest_aliases`` instead of ``aliases``, which
should be done when the alternative name does not refer to a separate device.
This is particularly useful to allow the autoupdater to work when the model name
changed between Gluon versions.

Package lists
~~~~~~~~~~~~~
Gluon generates lists of packages that are installed in all images based on a
default list and the features and packages specified in the site configuration.

In addition, OpenWrt defines additional per-device package lists. These lists
may be modified in Gluon's device definitions, for example to include additional
drivers and firmware, or to remove unneeded software. Packages to remove are
prefixed with a ``-`` character.

For many ath10k-based devices, this is used to replace the "CT" variant of
ath10k with the mainline-based version:

.. code-block:: lua

  local ATH10K_PACKAGES_QCA9880 = {
    'kmod-ath10k',
    '-kmod-ath10k-ct',
    '-kmod-ath10k-ct-smallbuffers',
    'ath10k-firmware-qca988x',
    '-ath10k-firmware-qca988x-ct',
  }
  device('openmesh-a40', 'openmesh_a40', {
    packages = ATH10K_PACKAGES_QCA9880,
    factory = false,
  })

This example also shows how to define a local variable, allowing the package
list to be reused for multiple devices.

Device flags
~~~~~~~~~~~~

The settings ``class``, ``deprecated`` or ``broken`` should be set according to
the device support status. The default values are as follows:

.. code-block:: lua

  {
    class = 'standard',
    deprecated = false,
    broken = false,
  }

- Device classes are described in :ref:`device-class-definition`
- Broken devices are untested or do not meet our requirements as given by the
  device checklist
- Deprecated devices are slated for removal in a future Gluon version due to
  hardware constraints

Global settings
~~~~~~~~~~~~~~~
There is a number of directives that can be used outside of a ``device()``
definition:

- ``include('filename')``: Include another file with global settings
- ``config(key, value)``: Set a config symbol in OpenWrt's ``.config``. Value
  may be a string, number, boolean, or nil. Booleans and nil are used for
  tristate symbols, where nil sets the symbol to ``m``.
- ``try_config(key, value)``: Like ``config()``, but do not fail if setting
  the symbol is not possible (usually because its dependencies are not met)
- ``packages { 'package1', '-package2', ... }``: Define a list of packages to
  add or remove for all devices of a target. Package lists passed to multiple
  calls of ``packages`` will be aggregated.
- ``defaults { key = value, ... }``: Set default values for any of the
  additional settings that can be passed to ``device()``.

Helper functions
~~~~~~~~~~~~~~~~
The following helpers can be used in the target configuration:

- ``env.KEY`` allows to access environment variables
- ``istrue(value)`` returns true if the passed string is a positive number
  (often used with ``env``, for example ``if istrue(env.GLUON_DEBUG) then ...``)

Hardware support in packages
----------------------------
In addition to the target configuration files, some device-specific changes may
be required in packages.

gluon-core
~~~~~~~~~~
- ``/lib/gluon/upgrade/010-primary-mac``: Override primary MAC address selection

  Usually, the primary (label) MAC address is defined in OpenWrt's Device Trees.
  For devices or targets where this is not the case, it is possible to specify
  what interface to take the primary MAC address from in ``010-primary-mac``.

- ``/lib/gluon/upgrade/020-interfaces``: Override LAN/WAN interface assignment

  On PoE-powered devices, the PoE input port should be "WAN".

- ``/usr/lib/lua/gluon/platform.lua``: Contains a list of outdoor devices

gluon-setup-mode
~~~~~~~~~~~~~~~~
- ``/lib/gluon/upgrade/320-setup-ifname``: Contains a list of devices that use
  the WAN port for the config mode

  On PoE-powered devices, the PoE input port should be used for the config
  mode. This is handled correctly by default for outdoor devices listed in
  ``platform.lua``.

libplatforminfo
~~~~~~~~~~~~~~~
When adding support for a new target to Gluon, it may be necessary to adjust
libplatforminfo to define how autoupdater image names are derived from the
model name.
