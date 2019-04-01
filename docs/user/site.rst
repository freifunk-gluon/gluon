Site configuration
==================

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

domain_seed
    32 bytes of random data, encoded in hexadecimal, used to seed other random
    values specific to the mesh domain. It must be the same for all nodes of one
    mesh, but should be different for firmware that is not supposed to mesh with
    each other.

    The recommended way to generate a value for a new site is:
    ::

        echo $(hexdump -v -n 32 -e '1/1 "%02x"' </dev/urandom)

prefix4 \: optional
    The IPv4 Subnet of your community mesh network in CIDR notation, e.g.
    ::

       prefix4 = '10.111.111.0/18'

    Required if ``next_node.ip4`` is set.

prefix6
    The IPv6 subnet of your community mesh network, e.g.
    ::

       prefix6 = 'fdca::ffee:babe:1::/64'

node_prefix6
    The ipv6 prefix from which the unique IP-addresses for nodes are selected
    in babel-based networks. This may overlap with prefix6. e.g.
    ::

       node_prefix6 = 'fdca::ffee:babe:2::/64'

node_client_prefix6
    The ipv6 prefix from which the client-specific IP-address is calculated that
    is assigned to each node by l3roamd to allow efficient communication when 
    roaming. This is exclusively useful when running a routing mesh protocol
    like babel. e.g.
    ::

       node_client_prefix6 = 'fdca::ffee:babe:3::/64'

timezone
    The timezone of your community live in, e.g.
    ::

      -- Europe/Berlin
      timezone = 'CET-1CEST,M3.5.0,M10.5.0/3'

ntp_servers
    List of NTP servers available in your community or used by your community, e.g.:
    ::

       ntp_servers = {'1.ntp.services.ffac','2.ntp.services.ffac'}

    This NTP servers must be reachable via IPv6 from the nodes. If you don't want to set an IPv6 address
    explicitly, but use a hostname (which is recommended), see also the :ref:`FAQ <faq-dns>`.

opkg \: optional
    ``opkg`` package manager configuration.

    There are two optional fields in the ``opkg`` section:

    - ``openwrt`` overrides the default OpenWrt repository URL. The default URL would
      correspond to ``http://downloads.openwrt.org/snapshots/packages/%A``
      and usually doesn't need to be changed when nodes are expected to have IPv6
      internet connectivity.
    - ``extra`` specifies a table of additional repositories (with arbitrary keys)

    ::

      opkg = {
        openwrt = 'http://opkg.services.ffac/openwrt/snapshots/packages/%A',
        extra = {
          gluon = 'http://opkg.services.ffac/modules/gluon-%GS-%GR/%S',
        },
      }

    There are various patterns which can be used in the URLs:

    - ``%d`` is replaced by the OpenWrt distribution name ("openwrt")
    - ``%v`` is replaced by the OpenWrt version number (e.g. "17.01")
    - ``%S`` is replaced by the target board (e.g. "ar71xx/generic")
    - ``%A`` is replaced by the target architecture (e.g. "mips_24kc")
    - ``%GS`` is replaced by the Gluon site code (as specified in ``site.conf``)
    - ``%GV`` is replaced by the Gluon version
    - ``%GR`` is replaced by the Gluon release (as specified in ``site.mk``)

regdom \: optional
    The wireless regulatory domain responsible for your area, e.g.:
    ::

      regdom = 'DE'

    Setting ``regdom`` is mandatory if ``wifi24`` or ``wifi5`` is defined.

wifi24 \: optional
    WLAN configuration for 2.4 GHz devices.
    ``channel`` must be set to a valid wireless channel for your radio.

    There are currently three interface types available. You may choose to
    configure any subset of them:

    - ``ap`` creates a master interface where clients may connect
    - ``mesh`` creates an 802.11s mesh interface with forwarding disabled
    - ``ibss`` creates an ad-hoc interface

    Each interface may be disabled by setting ``disabled`` to ``true``.
    This will only affect new installations.
    Upgrades will not change the disabled state.

    Additionally it is possible to configure the ``supported_rates`` and ``basic_rate``
    of each radio. Both are optional, by default hostapd/driver dictate the rates.
    If ``supported_rates`` is set, ``basic_rate`` is required, because ``basic_rate``
    has to be a subset of ``supported_rates``. Possible values are: 

    - 6000, 9000, 12000, 18000, 24000, 36000, 48000, 54000 (OFDM)
    - 1000, 5500, 11000 (legacy 802.11b, DSSS)

    The example below disables legacy 802.11b rates (DSSS) for performance reasons.  
    For backwards compatibility in 802.11, this setting only effects 802.11a/b/g rates. 
    I.e in 802.11n 6 MBit/s is announced  all time. In 802.11ac the field is used to 
    derive the length of a packet.

    ``ap`` requires a single parameter, a string, named ``ssid`` which sets the
    interface's ESSID. This is the WiFi the clients connect to.

    ``mesh`` requires a single parameter, a string, named ``id`` which sets the
    mesh id, also visible as an open WiFi in some network managers. Usually you
    don't want users to connect to this mesh-SSID, so use a cryptic id that no
    one will accidentally mistake for the client WiFi.

    ``ibss`` requires two parameters: ``ssid`` (a string) and ``bssid`` (a MAC).
    An optional parameter ``vlan`` (integer) is supported.

    Both ``mesh`` and ``ibss`` accept an optional ``mcast_rate`` (kbit/s) parameter for
    setting the multicast bitrate. Increasing the default value of 1000 to something
    like 12000 is recommended.
    ::

       wifi24 = {
         channel = 11,
         supported_rates = {6000, 9000, 12000, 18000, 24000, 36000, 48000, 54000},
         basic_rate = {6000, 9000, 18000, 36000, 54000},
         ap = {
           ssid = 'alpha-centauri.freifunk.net',
         },
         mesh = {
           id = 'ueH3uXjdp',
           mcast_rate = 12000,
         },
         ibss = {
           ssid = 'ff:ff:ff:ee:ba:be',
           bssid = 'ff:ff:ff:ee:ba:be',
           mcast_rate = 12000,
         },
       },

wifi5 \: optional
    Same as `wifi24` but for the 5Ghz radio.

next_node \: package
    Configuration of the local node feature of Gluon
    ::

      next_node = {
        name = { 'nextnode.location.community.example.org', 'nextnode', 'nn' },
        ip4 = '10.23.42.1',
        ip6 = 'fdca:ffee:babe:1::1',
        mac = '16:41:95:40:f7:dc'
      }

    All values of this section are optional. If the IPv4 or IPv6 address is
    omitted, there will be no IPv4 or IPv6 anycast address. The MAC address
    defaults to ``16:41:95:40:f7:dc``; this value usually doesn't need to be
    changed, but it can be adjusted to match existing deployments that use a
    different value.

    When the nodes' next-node address is used as a DNS resolver by clients
    (by passing it via DHCP or router advertisements), it may be useful to
    allow resolving a next-node hostname without referring to an upstream DNS
    server (e.g. to allow reaching the node using such a hostname via HTTP or SSH
    in isolated mesh segments). This is possible by providing one or more names
    in the ``name`` field.

.. _user-site-mesh:

mesh
    Configuration of general mesh functionality.

    To avoid inter-mesh links, Gluon can encapsulate the mesh protocol in VXLAN
    for Mesh-on-LAN/WAN. It is recommended to set *mesh.vxlan* to ``true`` to
    enable VXLAN in new setups. Setting it to ``false`` disables this
    encapsulation to allow meshing with other nodes that don't support VXLAN
    (Gluon 2017.1.x and older). In multi-domain setups, *mesh.vxlan* is optional
    and defaults to ``true``.

    Gluon generally segments layer-2 meshes so that each node becomes IGMP/MLD
    querier for its own local clients. This is necessary for reliable multicast
    snooping. The segmentation is realized by preventing IGMP/MLD queries from
    passing through the mesh.

    By default, not only queries are filtered, but also membership report and
    leave packets, as they add to the background noise of the mesh. As a
    consequence, snooping switches outside the mesh that are connected to a
    Gluon node need to be configured to forward all multicast traffic towards
    the mesh; this is usually not a problem, as such setups are unusual. If
    you run a special-purpose mesh that requires membership reports to be
    working, this filtering can be disabled by setting the
    optional *filter_membership_reports* value to ``false``.

    In addition, options specific to the batman-adv routing protocol can be set
    in the *batman_adv* section:

    The optional value *routing_algo* allows to set up ``BATMAN_V`` based meshes. 
    If unset, the routing algorithm will default to ``BATMAN_IV``.

    The optional value *gw_sel_class* sets the gateway selection class, the
    default is ``20`` for B.A.T.M.A.N. IV and ``5000`` kbit/s for B.A.T.M.A.N. V.

    - **B.A.T.M.A.N. IV:** with the value ``20`` the gateway is selected based
      on the link quality (TQ) only; with class ``1`` it is calculated from
      both, the TQ and the announced bandwidth.
    - **B.A.T.M.A.N. V:** with the value ``1500`` the gateway is selected if the
      throughput is at least 1500 kbit/s faster than the throughput of the
      currently selected gateway. 

    For details on determining the threshold, when to switch to a new gateway,
    see `batctl manpage`_, section "gw_mode".
    
    .. _batctl manpage: https://www.open-mesh.org/projects/batman-adv/wiki/Gateways

    ::

      mesh = {
        vxlan = true,
        filter_membership_reports = false,
        batman_adv = {
          routing_algo = 'BATMAN_IV',
          gw_sel_class = 1,
        },
      }


mesh_vpn
    Remote server setup for the mesh VPN.

    The `enabled` option can be set to true to enable the VPN by default. `mtu`
    defines the MTU of the VPN interface, determining a proper MTU value is described
    in the :ref:`FAQ <faq-mtu>`.

    By default the public key of a node's VPN daemon is not added to announced respondd
    data; this prevents malicious ISPs from correlating VPN sessions with specific mesh
    nodes via public respondd data. If this is of no concern in your threat model,
    this behaviour can be disabled (and thus announcing the public key be enabled) by
    setting `pubkey_privacy` to `false`. At the moment, this option only affects fastd.

    The `fastd` section configures settings specific to the *fastd* VPN
    implementation.

    If `configurable` is set to `false` or unset, the method list will be replaced on updates
    with the list from the site configuration. Setting `configurable` to `true` will allow the user to
    add the method ``null`` to the beginning of the method list or remove ``null`` from it,
    and make this change survive updates. Setting `configurable` is necessary for the
    package `gluon-web-mesh-vpn-fastd`, which adds a UI for this configuration.

    In any case, the ``null`` method should always be the first method in the list
    if it is supported at all. You should only set `configurable` to `true` if the
    configured peers support both the ``null`` method and methods with encryption.

    You can set syslog_level from verbose (default) to warn to reduce syslog output.

    The `tunneldigger` section is used to define the *tunneldigger* broker list.

    **Note:** It doesn't make sense to include both `fastd` and `tunneldigger`
    sections in the same configuration file, as only one of the packages *gluon-mesh-vpn-fastd*
    and *gluon-mesh-vpn-tunneldigger* should be installed with the current
    implementation.

    **Note:** It may be interesting to include the package *gluon-iptables-clamp-mss-to-pmtu*
    in the build when using *gluon-mesh-babel* to work around icmp blackholes on the internet.

    ::

      mesh_vpn = {
        -- enabled = true,
        mtu = 1312,
        -- pubkey_privacy = true,

        fastd = {
          methods = {'salsa2012+umac'},
          -- configurable = true,
          -- syslog_level = 'warn',
          groups = {
            backbone = {
              -- Limit number of connected peers from this group
              limit = 1,
              peers = {
                peer1 = {
                  key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                  -- Having multiple domains prevents SPOF in freifunk.net
                  remotes = {
                    'ipv4 "vpn1.alpha-centauri.freifunk.net" port 10000',
                    'ipv4 "vpn1.alpha-centauri-freifunk.de" port 10000',
                  },
                },
                peer2 = {
                  key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                  -- You can also omit the ipv4 to allow both connection via ipv4 and ipv6
                  remotes = {'"vpn2.alpha-centauri.freifunk.net" port 10000'},
                },
                peer3 = {
                  key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
                  -- In addition to domains you can also add ip addresses, which provides
                  -- resilience in case of dns outages
                  remotes = {
                    '"vpn3.alpha-centauri.freifunk.net" port 10000',
                    '[2001:db8::3:1]:10000',
                    '192.0.2.3:10000',
                  },
                },
              },
              -- Optional: nested peer groups
              -- groups = {
              --   lowend_backbone = {
              --     limit = 1,
              --     peers = ...
              --   },
              -- },
            },
            -- Optional: additional peer groups, possibly with other limits
            -- peertopeer = {
            --   limit = 10,
            --   peers = { ... },
            -- },
          },
        },

        tunneldigger = {
          brokers = {'vpn1.alpha-centauri.freifunk.net'}
        },

        bandwidth_limit = {
          -- The bandwidth limit can be enabled by default here.
          enabled = false,

          -- Default upload limit (kbit/s).
          egress = 200,

          -- Default download limit (kbit/s).
          ingress = 3000,
        },
      }

mesh_on_wan \: optional
    Enables the mesh on the WAN port (``true`` or ``false``).
    ::

       mesh_on_wan = true,

mesh_on_lan \: optional
    Enables the mesh on the LAN port (``true`` or ``false``).
    ::

        mesh_on_lan = true,

poe_passthrough \: optional
    Enable PoE passthrough by default on hardware with such a feature.

autoupdater \: package
    Configuration for the autoupdater feature of Gluon.

    The mirrors are checked in random order until the manifest could be downloaded
    successfully or all mirrors have been tried.
    ::

      autoupdater = {
        branch = 'stable',
        branches = {
          stable = {
            name = 'stable',
            mirrors = {
              'http://[fdca:ffee:babe:1::fec1]/firmware/stable/sysupgrade/',
              'http://autoupdate.alpha-centauri.freifunk.net/firmware/stable/sysupgrade/',
            },
            -- Number of good signatures required
            good_signatures = 2,
            pubkeys = {
              'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', -- someguy
              'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', -- someother
            }
          }
        }
      }

    All configured mirrors must be reachable from the nodes via IPv6. If you don't want to set an IPv6 address
    explicitly, but use a hostname (which is recommended), see also the :ref:`FAQ <faq-dns>`.

.. _user-site-config_mode:

config_mode \: optional
    Additional configuration for the configuration web interface. All values are
    optional.

    When no hostname is specified, a default hostname based on the *hostname_prefix*
    and the node's primary MAC address is assigned. Manually setting a hostname
    can be enforced by setting *hostname.optional* to *false*.

    To not prefill the hostname-field in config-mode with the default hostname,
    set *hostname.prefill* to *false*.

    By default, no altitude field is shown by the *gluon-config-mode-geo-location*
    package. Set *geo_location.show_altitude* to *true* if you want the altitude
    field to be visible.

    The *geo_location.osm* section is only relevant when the *gluon-config-mode-geo-location-osm*
    package is used. The *center.lon* and *center.lat* values are mandatory in this case and
    define the default center of the map when no position has been picked yet. The *zoom* level
    defaults to 12 in this case. *openlayers_url* allows to override the base URL of the
    *build/ol.js* and *css/ol.css* files (the default is
    ``https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v5.2.0``).

    The remote login page only shows SSH key configuration by default. A
    password form can be displayed by setting *remote_login.show_password_form*
    to true; in this case, *remote_login.min_password_length* defines the
    minimum password length.
    ::

        config_mode = {
          hostname = {
            optional = false,
            prefill = true,
          },
          geo_location = {
            show_altitude = true,
            osm = {
              center = {
                lat = 52.951947558,
                lon = 8.744238281,
              },
              zoom = 13,
              -- openlayers_url = 'http://ffac.example.org/openlayer',
            },
          },
          remote_login = {
            show_password_form = true,
            min_password_length = 10,
          },
        },


roles \: optional
    Optional role definitions. Nodes will announce their role inside the mesh.
    This will allow in the backend to distinguish between normal, backbone and
    service nodes or even gateways (if they advertise that role). It is up to
    the community which roles to define. See the section below as an example.
    ``default`` takes the default role which is set initially. This value should be
    part of ``list``. If you want node owners to change the role via config mode add
    the package ``gluon-web-node-role`` to ``site.mk``.

    The strings to display in the web interface are configured per language in the
    ``i18n/en.po``, ``i18n/de.po``, etc. files of the site repository using message IDs like
    ``gluon-web-node-role:role:node`` and ``gluon-web-node-role:role:backbone``.
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

setup_mode \: package
    Allows skipping setup mode (config mode) at first boot when attribute
    ``skip`` is set to ``true``. This is optional and may be left out.
    ::

      setup_mode = {
        skip = true,
      },

Build configuration
-------------------

The ``site.mk`` is a Makefile which defines various values
involved in the build process of Gluon.

GLUON_FEATURES
    Defines a list of features to include. The feature list is used to generate
    the default package set.

GLUON_SITE_PACKAGES
    Defines a list of packages which should be installed in addition to the
    default package set. It is also possible to remove packages from the
    default set by prepending a minus sign to the package name.

GLUON_RELEASE
    The current release version Gluon should use.

GLUON_PRIORITY
    The default priority for the generated manifests (see the autoupdater documentation
    for more information).

GLUON_REGION
    Region code to build into images where necessary. Valid values are the empty string,
    ``us`` and ``eu``.

GLUON_LANGS
    List of languages (as two-letter-codes) to be included in the web interface. Should always contain
    ``en``.

GLUON_WLAN_MESH
  Setting this to ``11s`` or ``ibss`` will enable generation of matching images for devices which don't
  support both meshing modes, either at all (e.g. ralink and mediatek don't support AP+IBSS) or in the
  same firmware (ath10k-based 5GHz). Defaults to ``11s``.

.. _user-site-feature-flags:

Feature flags
^^^^^^^^^^^^^

With the addition of more and more features that interact in complex ways, it
has become necessary to split certain packages into multiple parts, so it is
possible to install just what is needed for a specific use case. One example
is the package *gluon-status-page-mesh-batman-adv*: There are batman-adv-specific
status page components; they should only be installed when both batman-adv and
the status page are enabled, making the addition of a specific package for this
combination necessary.

With the ongoing modularization, e.g. for the purpose of supporting new
routing protocols, specifying all such split packages in *site.mk* would
soon become very cumbersome: In the future, further components like
respondd support or languages might be split off as separate packages,
leading to entangled package names like *gluon-mesh-vpn-fastd-respondd* or
*gluon-status-page-mesh-batman-adv-i18n-de*.

For this reason, we have introduced *feature flags*, which can be specified
in the *GLUON_FEATURES* variable. These flags allow to specify a set of features
on a higher level than individual package names.

Most Gluon packages can simply be specified as feature flags by removing the ``gluon-``
prefix: The feature flag corresponding to the package *gluon-mesh-batman-adv-15* is
*mesh-batman-adv-15*.

The file ``package/features`` in the Gluon repository (or
``features`` in site feeds) can specify additional rules for deriving package lists
from feature flags, e.g. specifying both *status-page* and either *mesh-batman-adv-14*
or *mesh-batman-adv-15* will automatically select the additional package
*gluon-status-page-mesh-batman-adv*. In the future, selecting the flags
*mesh-vpn-fastd* and *respondd* might automatically enable the additional
package *gluon-mesh-vpn-fastd-respondd*, and enabling *status-page* and
*mesh-batman-adv-15* (or *-14*) with ``de`` in *GLUON_LANGS* could
add the package *gluon-status-page-mesh-batman-adv-i18n-de*.

In short, it is not necessary anymore to list all the individual packages that are
relevant for a firmware; instead, the package list is derived from a list of feature
flags using a flexible ruleset defined in the Gluon repo or site package feeds.
To some extent, it will even allow us to further modularize existing Gluon packages,
without necessitating changes to existing site configurations.

It is still possible to override such automatic rules using *GLUON_SITE_PACKAGES*
(e.g., ``-gluon-status-page-mesh-batman-adv`` to remove the automatically added
package *gluon-status-page-mesh-batman-adv*).

For convenience, there are two feature flags that do not directly correspond to a Gluon
package:

* web-wizard

  Includes the *gluon-config-mode-...* base packages (hostname, geolocation and contact info),
  as well as the *gluon-config-mode-autoupdater* (when *autoupdater* is in *GLUON_FEATURES*),
  and *gluon-config-mode-mesh-vpn* (when *mesh-vpn-fastd* or *mesh-vpn-tunneldigger* are in
  *GLUON_FEATURES*)

* web-advanced

  Includes the *gluon-web-...* base packages (admin, network, WiFi config),
  as well as the *gluon-web-autoupdater* (when *autoupdater* is in *GLUON_FEATURES*)

We recommend to use *GLUON_SITE_PACKAGES* for non-Gluon OpenWrt packages only and
completely rely on *GLUON_FEATURES* for Gluon packages, as it is shown in the
example *site.mk*.

.. _site-config-mode-texts:

Config mode texts
-----------------

The community-defined texts in the config mode are configured in PO files in the ``i18n`` subdirectory
of the site configuration. The message IDs currently defined are:

gluon-config-mode:welcome
    Welcome text on the top of the config wizard page.

gluon-config-mode:pubkey
    Information about the public VPN key on the reboot page.

gluon-config-mode:novpn
    Information shown on the reboot page, if the mesh VPN was not selected.

gluon-config-mode:contact-help
    Description for the usage of the ``contact`` field

gluon-config-mode:contact-note
    Note shown (in small font) below the ``contact`` field

gluon-config-mode:hostname-help
    Description for the usage of the ``hostname`` field

gluon-config-mode:geo-location-help
    Description for the usage of the longitude/latitude fields (and altitude, if shown)

gluon-config-mode:altitude-label
    Label for the ``altitude`` field

gluon-config-mode:reboot
    General information shown on the reboot page.

There is a POT file in the site example directory which can be used to create templates
for the language files. The command ``msginit -l en -i ../../docs/site-example/i18n/gluon-site.pot``
can be used from the ``i18n`` directory to create an initial PO file called ``en.po`` if the ``gettext``
utilities are installed.

.. note::

   An empty ``msgstr``, as is the default after running ``msginit``, leads to
   the ``msgid`` being printed as-is. It does *not* hide the whole text, as
   might be expected.

   Depending on the context, you might be able to use comments like
   ``<!-- empty -->`` as translations to effectively hide the text.

Site modules
------------

The file ``modules`` in the site repository is completely optional and can be used
to supply additional package feeds from which packages are built. The git repositories
specified here are retrieved in addition to the default feeds when ``make update``
is called.

This file's format is very similar to the toplevel ``modules`` file of the Gluon
tree, with the important different that the list of feeds must be assigned to
the variable ``GLUON_SITE_FEEDS``. Multiple feed names must be separated by spaces,
for example::

    GLUON_SITE_FEEDS='foo bar'

The feed names may only contain alphanumerical characters, underscores and slashes.
For each of the feeds, the following variables are used to specify how to update
the feed:

PACKAGES_${feed}_REPO
    The URL of the git repository to clone (usually ``git://`` or ``http(s)://``)

PACKAGES_${feed}_COMMIT
    The commit ID of the repository to use

PACKAGES_${feed}_BRANCH
    Optional: The branch of the repository the given commit ID can be found in.
    Defaults to the default branch of the repository (usually ``master``)

These variables are always all uppercase, so for an entry ``foo`` in GLUON_SITE_FEEDS,
the corresponding configuration variables would be ``PACKAGES_FOO_REPO``,
``PACKAGES_FOO_COMMIT`` and ``PACKAGES_FOO_BRANCH``. Slashes in feed names are
replaced by underscores to get valid shell variable identifiers.


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

A non-exhaustive list of site-repos from various communities can be found on the
wiki: https://github.com/freifunk-gluon/gluon/wiki/Site-Configurations
