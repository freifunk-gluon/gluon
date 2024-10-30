[![Build Gluon](https://github.com/freifunk-gluon/gluon/actions/workflows/build-gluon.yml/badge.svg?branch=main)](https://github.com/freifunk-gluon/gluon/actions/workflows/build-gluon.yml)
[![License](https://img.shields.io/badge/License-BSD%202--Clause-orange.svg)](https://opensource.org/license/bsd-2-clause/)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/freifunk-gluon/gluon?sort=semver)](https://github.com/freifunk-gluon/gluon/releases/latest)

# Gluon

Gluon is a firmware framework to build preconfigured OpenWrt images for public mesh networks.

## Overview

Gluon provides an easy-to-use firmware for a public, decentral WLAN and/or wire based mesh network.
Common network capable devices, like smartphones, laptops or desktop PCs can connect to the mesh network and communicate over it, without the need of passwords for access and without the need of installing special software.
Additionally, internet access and merging mesh clouds can be accomplished over a WAN through VPN connected gateways.

Gluon's features include:

* a decentral mesh network
* easy configuration mode for less techy users
* community-specific technical settings and customizations through a common site.conf and site.mk
* ecdsa signature-based autoupdater
* node status web page
* publication of node information + statistics through respondd
* a variety of preconfigured mesh and VPN protocols:


Supported mesh protocols:

* batman-adv (BATMAN IV fully, BATMAN V partially)
* OLSRv2 (partially)


Supported protocols for node-to-node connections:

* WLAN: 802.11s (with forwarding disabled)
* WAN: VPNs via fastd and Wireguard
* LAN: via VXLAN

## Getting started

We have a huge amount of documentation over at https://gluon.readthedocs.io/.

If you're new to Gluon and ready to get your feet wet, have a look at the
[Getting Started Guide](https://gluon.readthedocs.io/en/latest/user/getting_started.html).

Gluon's developers frequent an IRC chatroom at [#gluon](ircs://irc.hackint.org/#gluon)
on [hackint](https://hackint.org/). There is also a [webchat](https://chat.hackint.org/?join=gluon)
that allows for uncomplicated access from within your browser. This channel is also available as a bridged Matrix Room at [#gluon:hackint.org](https://matrix.to/#/#gluon:hackint.org).

## Issues & Feature requests

Before opening an issue, make sure to check whether any existing issues
(open or closed) match. If you're suggesting a new feature, drop by on IRC or
our mailinglist to discuss it first.

We maintain a [Roadmap](https://github.com/freifunk-gluon/gluon/wiki/Roadmap) for
the future development of Gluon.

## Use a release!

Please refrain from using the `main` branch for anything else but development purposes!
Use the most recent release instead. You can list all releases by running `git tag`
and switch to one by running `git checkout v2023.2.4 && make update`.

If you're using the autoupdater, do not autoupdate nodes with anything but releases.
If you upgrade using random main commits the nodes *might break* eventually.

## Mailinglist

To subscribe to the list, send a message to:

    gluon+subscribe@luebeck.freifunk.net

To remove your address from the list, just send a message to
the address in the `List-Unsubscribe` header of any list
message. If you haven't changed addresses since subscribing,
you can also send a message to:

    gluon+unsubscribe@luebeck.freifunk.net
