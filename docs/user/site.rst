Site
====

The ``site`` consists of the files ``site.conf`` and ``site.mk``.
In the first community based values are defined, which both are processed
during the build process and runtime.
The last is directly included in the make process of Gluon.

Configuration
-------------

The ``site.conf`` is a lua dictionary with the following defined keys.

hostname_prefix
    A string which shall prefix the default hostname of a device.

site_name
    The name of your community.

site_code
    The code of your community. It is good practice to use the TLD of
    your community here.

prefix4
    The IPv4 Subnet of your community mesh network in CIDR notation, e.g.
    ::

       prefix4 = '10.111.111.0/18'

prefix6
    The IPv6 subnet of your community mesh network, e.g.
    ::

       prefix6 = 'fdca::ffee:babe:1::/64'

timezone
    The timezone of your community live in, e.g.
    ::

      -- Europe/Berlin
      timezone = 'CET-1CEST,M3.5.0,M10.5.0/3'

ntp_server
    List of NTP servers available in your community or used by your community, e.g.:
    ::

       ntp_servers = {'1.ntp.services.ffeh','2.tnp.services.ffeh'}

opkg_repo : optional
    Overwrite the default ``opkg`` repository server, e.g.:
    ::

      opkg_repo = 'http://opkg.services.ffeh/attitude_adjustment/12.09/%S/packages'

    The `%S` is a variable, which is replaced with the platform of an device
    during the build process.

regdom
    The wireless regulatory domain responsible for your area, e.g.:
    ::

      regdom = 'DE'

wifi24
    WLAN Configuration of your community in the 2.4Ghz radio. Consisting
    of ``ssid`` of your client network, the ``channel`` your community is using,
    ``htmode``, the adhoc ssid ``mesh_ssid`` used between devices, the adhoc
    bssid ``mesh_bssid`` and the adhoc multicast rate ``mesh_mcast_rate``.
    Optionally ``mesh_vlan`` can be used to setup VLAN on top of the 802.11
    ad-hoc interface. The options ``mesh_disabled`` and ``client_disabled``
    are optional, too. They allow to disable the SSID by default, e.g. for
    preconfigured node. This only affects first configuraton.
    Combined in an dictionary, e.g.:
    ::

       wifi24 = {
         ssid = 'entenhausen.freifunk.net',
         channel = 11,
         htmode = 'HT40-',
         mesh_ssid = 'ff:ff:ff:ee:ba:be',
         mesh_bssid = 'ff:ff:ff:ee:ba:be',
         mesh_mcast_rate = 12000,
       },

wifi5
    Same as `wifi24` but for the 5Ghz radio.

next_node : package
    Configuration of the local node feature of Gluon
    ::

      next_node = {
        ip4 = '10.23.42.1',
        ip6 = 'fdca:ffee:babe:1::1',
        mac = 'ca:ff:ee:ba:be:00'
      }


fastd_mesh_vpn
    Remote server setup for the fastd-based mesh VPN.

    The `enabled` option can be set to true to enable the VPN by default.

    If `configurable` is `false` or unset, the method list will be replaced on updates
    with the list in the site configuration. Setting `configurable` to `true` will allow the user to
    add the method ``null`` to the front of the method list or remove ``null`` from it,
    and make this change survive updates. Settings configurable is necessary for the
    package `gluon-luci-mesh-vpn-fastd`, which adds a UI for this configuration.

    In any case, the ``null`` method should always be the first method in the list
    if it is supported at all. You should only set `configurable` to `true` if the
    configured peers support both the ``null`` method and methods with encryption.
    ::

      fastd_mesh_vpn = {
        methods = {'salsa2012+umac'},
	-- enabled = true,
	-- configurable = true,
        mtu = 1426,
        groups = {
          backbone = {
            limit = 2,
            peers = {
              peer1 = {
                key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                remotes = {'ipv4 "vpn1.entenhausen.freifunk.net" port 10000'},
              },
            }
          }
        }
      }

mesh_on_wan : optional
    Enables the mesh on the WAN port (``true`` or ``false``).

mesh_on_lan : optional
    Enables the mesh on the LAN port (``true`` or ``false``).

autoupdater : package
    Configuration for the autoupdater feature of Gluon.
    ::

      autoupdater = {
        branch = 'experimental',
        branches = {
          stable = {
            name = 'stable',
            mirrors = {
              'http://[fdca:ffee:babe:1::fec1]/firmware/stable/sysupgrade/',
              'http://[fdca:ffee:babe:1::fec2]/firmware/stable/sysupgrade/',
            },
            probability = 0.08,
            good_signatures = 2,
            pubkeys = {
              'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', -- someguy
              'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', -- someother
            }
          }
        }
      }

roles : optional
    Optional role definitions. With this nodes will announce their role inside the mesh.
    In the backend this adds the facility to distinguish between normal, backbone and
    service nodes or even gateways (if they advertise the role, also). It is up to
    the community which roles to define. See the section below as an example.
    ``default`` takes the default role which is set initially. This value should be
    part of ``list``. If you want node owners to change the role via config mode add
    the package ``gluon-luci-node-role`` to ``site.mk``.

    The strings to display in the LuCI interface can be configured per language in the
    ``i18n/en.po``, ``i18n/de.po``, etc. files of the site repository using message IDs like
    ``gluon-luci-node-role:role:node`` and ``gluon-luci-node-role:role:backbone``.
    ::

      roles = {
        default = 'node',
        list = {
          'node',
          'test',
          'backbone',
          'service',
        },
      },

simple_tc : package
    Uplink traffic control, ingress and egress values are specified in kbit/s.
    ::

      simple_tc = {
        mesh_vpn = {
          ifname = 'mesh-vpn',
          enabled = false,
          limit_egress = 200,
          limit_ingress = 3000,
        },
      },

setup_mode : package
    Allows skipping setup mode (config mode) at first boot when attribute
    ``skip`` is set to ``true``. This is optional and may be left out.
    ::

      setup_mode = {
        skip = true,
      },

legacy : package
    Configuration for the legacy upgrade path.
    This is only required in communities upgrading from Lübeck's LFF-0.3.x.
    ::

      legacy = {
             version_files = {'/etc/.freifunk_version_keep', '/etc/.eff_version_keep'},
             old_files = {'/etc/config/config_mode', '/etc/config/ffeh', '/etc/config/freifunk'},
             config_mode_configs = {'config_mode', 'ffeh', 'freifunk'},
             fastd_configs = {'ffeh_mesh_vpn', 'mesh_vpn'},
             mesh_ifname = 'freifunk',
             tc_configs = {'ffki', 'freifunk'},
             wifi_names = {'wifi_freifunk', 'wifi_freifunk5', 'wifi_mesh', 'wifi_mesh5'},
      }

Packages
--------

The ``site.mk`` is a Makefile which should define constants
involved in the build process of Gluon.

GLUON_SITE_PACKAGES
    Defines a list of packages which should installed additional
    to the ``gluon_core`` package.

GLUON_RELEASE
    The current release version Gluon should use.

GLUON_PRIORITY
    The default priority for the generated manifests (see the autoupdater documentation
    for more information).

GLUON_LANGS
    List of languages (as two-letter-codes) to include for the web interface. Should always contain
    ``en``.

.. _site-config-mode-texts:

Config mode texts
-----------------

The community-defined texts in the config mode are configured in PO files in the ``i18n`` subdirectory
of the site configuration. The message IDs currently defined are:

gluon-config-mode:welcome
    Welcome text on the top of the config wizard page.

gluon-config-mode:pubkey
    Information about the public VPN key on the reboot page.

gluon-config-mode:reboot
    General information about the reboot page.

There is a POT file in the site example directory which can be used to create templates
for the language files. The command ``msginit -l en -i ../../docs/site-example/i18n/gluon-site.pot``
can be used from the ``i18n`` directory to create an initial PO file called ``en.po`` if the ``gettext``
utilities are installed.

Examples
--------

site.mk
^^^^^^^

.. literalinclude:: ../site-example/site.mk
  :language: makefile

site.conf
^^^^^^^^^

.. literalinclude:: ../site-example/site.conf
  :language: lua

i18n/en.po
^^^^^^^^^^

.. literalinclude:: ../site-example/i18n/en.po
  :language: po

i18n/de.po
^^^^^^^^^^

.. literalinclude:: ../site-example/i18n/de.po
  :language: po

modules
^^^^^^^

.. literalinclude:: ../site-example/modules
  :language: makefile

site-repos in the wild
^^^^^^^^^^^^^^^^^^^^^^

This is a non-exhaustive list of site-repos from various communities:

* `site-ffbs <https://github.com/ffbs/site-ffbs>`_ (Braunschweig)
* `site-ffhb <https://github.com/FreifunkBremen/gluon-site-ffhb>`_ (Bremen)
* `site-ffda <https://github.com/freifunk-darmstadt/site-ffda>`_ (Darmstadt)
* `site-ffgoe <https://github.com/freifunk-goettingen/site-ffgoe>`_ (Göttingen)
* `site-ffhh <https://github.com/freifunkhamburg/site-ffhh>`_ (Hamburg)
* `site-ffhgw <https://github.com/lorenzo-greifswald/site-ffhgw>`_ (Greifswald)
* `site-ffhl <https://github.com/freifunk-luebeck/site-ffhl>`_ (Lübeck)
* `site-ffmd <https://github.com/FreifunkMD/site-ffmd>`_ (Magdeburg)
* `site-ffmwu <https://github.com/freifunk-mwu/site-ffmwu>`_ (Mainz, Wiesbaden & Umgebung)
* `site-ffmyk <https://github.com/FreifunkMYK/site-ffmyk>`_ (Mayen-Koblenz)
* `site-ffm <https://github.com/freifunkMUC/site-ffm>`_ (München)
* `site-ffms <https://github.com/FreiFunkMuenster/site-ffms>`_ (Münster)
* `site-ffnw <https://git.freifunk-ol.de/root/siteconf.git>`_ (Nordwest)
* `site-ffpb <https://git.c3pb.de/freifunk-pb/site-ffpb>`_ (Paderborn)
* `site-ffka <https://github.com/ffka/site-ffka>`_ (Karlsruhe)
* `site-ffrl <https://github.com/ffrl/sites-ffrl>`_ (Rheinland)
* `site-ffrg <https://github.com/ffruhr/site-ffruhr>`_ (Ruhrgebiet)
* `site-ffs <https://github.com/freifunk-stuttgart/site-ffs>`_ (Stuttgart)
* `site-fftr <https://github.com/freifunktrier/site-fftr>`_ (Trier)
