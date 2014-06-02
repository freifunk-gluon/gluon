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
    The wireless regulatory domain responsible for your area,e.g.:
    ::
      regdom = 'DE'

wifi24
    WLAN Configuration of your community in the 2.4Ghz band. Consisting 
    of ``ssid`` of your client network, the ``channel`` your community is using,
    ``htmode``, the adhoc ssid ``mesh_ssid`` used between devices, the adhoc 
    bssid ``mesh_bssid`` and the adhoc multicast rate ``mesh_mcast_rate``.
    Combined in an dictionary, e.g.:
    :: 
       wifi24 = {
         ssid = 'http://kiel.freifunk.net/',
         channel = 11,
         htmode = 'HT40-',
         mesh_ssid = '02:ca:ff:ee:ba:be',
         mesh_bssid = '02:ca:ff:ee:ba:be',
         mesh_mcast_rate = 12000,
       },

wifi5
    Same as `wifi24` but for the 5Ghz band.

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
          enabled = 0,
          limit_egress = 200,
          limit_ingress = 3000,
        },
      },

config_mode : package
    Configuration Mode text blocks

legacy : package
    Configuration for the legacy upgrade path.
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

Examples
--------


::
    GLUON_SITE_PACKAGES := \
      gluon-alfred \
      gluon-autoupdater \
      gluon-config-mode \
      gluon-ebtables-filter-multicast \
      gluon-ebtables-filter-ra-dhcp \
      gluon-legacy \
      gluon-luci-admin \
      gluon-luci-autoupdater \
      gluon-next-node \
      gluon-mesh-batman-adv \
      gluon-mesh-vpn-fastd \
      gluon-radvd \
      gluon-status-page \
      iwinfo \
      iptables \
      haveged


    DEFAULT_GLUON_RELEASE := 0.4.1+0-exp$(shell date '+%Y%m%d')

    # Allow overriding the release number from the command line
    GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)


::

  {
    hostname_prefix = 'freifunk',
    site_name = 'Freifunk Kiel',
    site_code = 'ffki',
    prefix4 = '10.116.128.0/17',
    prefix6 = 'fda1:384a:74de:4242::/64',
    timezone = 'CET-1CEST,M3.5.0,M10.5.0/3', -- Europe/Berlin
    ntp_servers = {'1.ntp.services.ffki'},
    opkg_repo = 'http://opkg.services.ffki/attitude_adjustment/12.09/%S/packages',
    regdom = 'DE',

    wifi24 = {
      ssid = 'http://kiel.freifunk.net/',
      channel = 11,
      htmode = 'HT40-',
      mesh_ssid = '02:ca:ff:ee:ba:be',
      mesh_bssid = '02:ca:ff:ee:ba:be',
      mesh_mcast_rate = 12000,
    },
    wifi5 = {
      ssid = 'http://kiel.freifunk.net/ (5GHz)',
      channel = 44,
      htmode = 'HT40+',
      mesh_ssid = '02:ca:ff:ee:ba:be',
      mesh_bssid = '02:ca:ff:ee:ba:be',
      mesh_mcast_rate = 12000,
    },

    next_node = {
      ip4 = '10.116.254.254',
      ip6 = 'fda1:384a:74de:4242::ffff',

      mac = '36:f4:54:fc:e5:11'
    },

    fastd_mesh_vpn = {
      methods = {'salsa2012+gmac'},
      mtu = 1426,
      backbone = {
        limit = 2,
        peers = {
          ffki_rz = {
            key = '6871220dc77ab508dc45107fd32db8874a40f0ea1ed52985aa798bd603a2ac68',
            remotes = {'ipv4 "freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn1 = {
            key = '65db8bff947e7c02ef7e152e73fb17c39ee9cfea91d047cb7a063ecb1eb7dd88',
            remotes = {'ipv4 "vpn1.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn2 = {
            key = 'fa400de81fc9f53127a4e60980c9756af372161c01ecbc7574fe115cf6434821',
            remotes = {'ipv4 "vpn2.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn3 = {
            key = 'c986eff66227bf0181d07fcaa1624def8895b6ed99e0effd0015d7bd5ef89ea6',
            remotes = {'ipv4 "vpn3.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn4 = {
            key = '647b2af8c795a30b9f55758b1e59d9740e65c06bde6baec2c88136b12e974cb7',
            remotes = {'ipv4 "vpn4.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn5 = {
            key = '0b3dc9457a1966857fe9364b5c836a75fd02bd46388845b5ad104d200a585a99',
            remotes = {'ipv4 "vpn5.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn6 = {
            key = '1b43401ccab790f908f189bf5c1ed0de17f84f683dfd6622d72a8f26fa490e59',
            remotes = {'ipv4 "vpn6.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn7 = {
            key = 'ff4ae2e3a23ed10262b23bbfd316fa6f3be32bf9d2ced6c763b0c7378b97b8ac',
            remotes = {'ipv4 "vpn7.freifunk.in-kiel.de" port 10000'},
          },
          ffki_vpn8 = {
            key = '10e25a530094e278fb877323575b47c79f96e3639a2640ad7096e1aa414dc4ba',
            remotes = {'ipv4 "vpn8.freifunk.in-kiel.de" port 10000'},
          },
        },
      },
    },

    autoupdater = {
      enabled = 1,
      branch = 'experimental',
      branches = {
        stable = {
          name = 'stable',
          mirrors = {
            'http://{fda1:384a:74de:4242::1}/firmware/stable/sysupgrade/',
            'http://{fda1:384a:74de:4242::2}/firmware/stable/sysupgrade/',
          },
          probability = 0.08,
          good_signatures = 2,
          pubkeys = {
            'bbb814470889439c04667748c30aabf25fb800621e67544bee803fd1b342ace3', -- sargon
            '8d16e1b88bcac28b493d6eadbce97bd223a65b3282a533c1f15f4b616b0d732a', -- BenBE
            'ee6ffe0fd4cada0358204c4f62a80d859478e7f12982068d65e48ed0a37a4fea', -- e-chb
          },
        },
        experimental = {
          name = 'experimental',
          mirrors = {
            'http://{fda1:384a:74de:4242::2}/firmware/experimental/sysupgrade/',
            'http://{fda1:384a:74de:4242::1}/firmware/experimental/sysupgrade/',
          },
          probability = 0.1,
          good_signatures = 1,
          pubkeys = {
            'bbb814470889439c04667748c30aabf25fb800621e67544bee803fd1b342ace3', -- sargon
            '8d16e1b88bcac28b493d6eadbce97bd223a65b3282a533c1f15f4b616b0d732a', -- BenBE
            'ee6ffe0fd4cada0358204c4f62a80d859478e7f12982068d65e48ed0a37a4fea', -- e-chb
          },
        },
      },
    },

    simple_tc = {
      mesh_vpn = {
        ifname = 'mesh-vpn',
        enabled = 0,
        limit_egress = 200,
        limit_ingress = 3000,
      },
    },

    config_mode = {
      msg_welcome = [[
  Willkommen zum Einrichtungsassistenten für deinen neuen Kieler
  Freifunk-Knoten. Fülle das folgende Formular deinen Vorstellungen
  entsprechend aus und sende es ab.
  ]],
      msg_pubkey = [[
  Dies ist der öffentliche Schlüssel deines Freifunkknotens. Erst nachdem
  er auf den Servern des Kieler Freifunk-Projektes eingetragen wurde,
  kann sich dein Knoten mit dem Kieler Mesh-VPN verbinden. Bitte
  schicke dazu diesen Schlüssel und den Namen deines Knotens
  (<em><%=hostname%></em>) an
  <a href="mailto:freifunk@in-kiel.de">freifunk@in-kiel.de</a>.
  ]],
      msg_reboot = [[
  <p>
  Dein Knoten startet gerade neu und versucht sich anschließend mit anderen
  Freifunk-Knoten in seiner Nähe zu verbinden. Weitere Informationen zur
  Kieler Freifunk-Community findest du auf
  <a href="http://kiel.freifunk.net/">unserer Webseite</a>.
  </p>
  <p>
  Viel Spaß mit deinem Knoten und der Erkundung von Freifunk!
  </p>
  ]],
    },

    legacy = {
           version_files = {'/etc/.freifunk_version_keep', '/etc/.kff_version_keep'},
           old_files = {'/etc/config/config_mode', '/etc/config/ffki', '/etc/config/freifunk'},

           config_mode_configs = {'config_mode', 'ffki', 'freifunk'},
           fastd_configs = {'ffki_mesh_vpn', 'mesh_vpn'},
           mesh_ifname = 'freifunk',
           tc_configs = {'ffki', 'freifunk'},
           wifi_names = {'wifi_freifunk', 'wifi_freifunk5', 'wifi_mesh', 'wifi_mesh5'},
    },
  }
