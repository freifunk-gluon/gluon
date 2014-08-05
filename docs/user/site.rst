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
    Combined in an dictionary, e.g.:
    ::

       wifi24 = {
         ssid = 'http://kiel.freifunk.net/',
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
        mac = 'ca:ff:ee:ba:be'
      }


fastd_mesh_vpn
    Remote server setup for vpn.
    ::

      fastd_mesh_vpn = {
        methods = {'salsa2012+gmac'},
        mtu = 1426,
        backbone = {
          limit = 2,
          peers = {
            ffki_rz = {
              key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
              remotes = {'ipv4 "vpn1.entenhausen.freifunk.net" port 10000'},
            },
          }
        }
      }

mesh_on_wan : optional
    Enables the mesh on the WAN port (``true`` or ``false``).

autoupdater : package
    Configuration for the autoupdater feature of Gluon.
    ::

      autoupdater = {
        enabled = 1,
        branch = 'experimental',
        branches = {
          stable = {
            name = 'stable',
            mirrors = {
              'http://{fdca:ffee:babe:1::fec1}/firmware/stable/sysupgrade/',
              'http://{fdca:ffee:babe:1::fec2}/firmware/stable/sysupgrade/',
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

simple_tc : package
    Uplink traffic control
    ::

      simple_tc = {
        mesh_vpn = {
          ifname = 'mesh-vpn',
          enabled = false,
          limit_egress = 200,
          limit_ingress = 3000,
        },
      },

config_mode : package
    Configuration Mode text blocks

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

modules
^^^^^^^

.. literalinclude:: ../site-example/modules
  :language: makefile

site-repos in the wild
^^^^^^^^^^^^^^^^^^^^^^

This is a non-exhaustive list of site-repos from various communities:

* `site-ffhb <https://github.com/FreifunkBremen/gluon-site-ffhb>`_ (Bremen)
* `site-ffhh <https://github.com/freifunkhamburg/site-ffhh>`_ (Hamburg)
* `site-ffhgw <https://github.com/lorenzo-greifswald/site-ffhgw>`_ (Greifswald)
* `site-ffhl <https://github.com/freifunk-gluon/site-ffhl>`_ (Lübeck)
* `site-ffmd <https://github.com/FreifunkMD/site-ffmd>`_ (Magdeburg)
* `site-ffmz <https://github.com/Freifunk-Mainz/site-ffmz>`_ (Mainz & Wiesbaden)
* `site-ffm <https://github.com/freifunkMUC/site-ffm>`_ (München)
* `siteconf-ffol <https://ticket.freifunk-ol.de/projects/siteconf-ffol/repository>`_ (Oldenburg)
* `site-ffpb <https://git.c3pb.de/freifunk-pb/site-ffpb>`_ (Paderborn)
* `site-ffka <https://github.com/ffka/site-ffka>`_ (Karlsruhe)
