/*
  Copyright (c) 2022, Maciej Krüger <maciej@xeredo.it>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "respondd-common.h"

#include <libgluonutil.h>

#include <json-c/json.h>

#include <libolsrdhelper.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static json_object * olsr1_get_plugins(void) {
	json_object *resp;

  if (olsr1_get_nodeinfo("plugins", &resp))
    return NULL;

	return json_object_object_get(resp, "plugins");
}

static json_object * olsr1_get_version (void) {
	json_object *resp;

  if (olsr1_get_nodeinfo("version", &resp))
    return NULL;

	return json_object_object_get(json_object_object_get(resp, "version"), "version");
}

static json_object * olsr2_get_version (void) {
	json_object *resp;

	if (olsr2_get_nodeinfo("systeminfo jsonraw version", &resp))
		return NULL;

	return json_object_object_get(json_object_object_get(resp, "version"), "version_text");
}

static json_object * olsr1_get_addresses (void) {
	json_object *resp;

	if (olsr1_get_nodeinfo("interfaces", &resp))
	 	return NULL;

	/*

	interfaces []
		name	"m_uplink"
		configured	true
		hostEmulation	false
		hostEmulationAddress	"0.0.0.0"
		olsrInterface
			-- might be false (and then ipAddress key is missing)
			up	true
			ipv4Address	"10.12.23.234"
			ipv4Netmask	"255.255.0.0"
			ipv4Broadcast	"10.12.255.255"
			mode	"mesh"
			ipv6Address	"::"
			ipv6Multicast	"::"
			-- we need this
			ipAddress	"10.12.23.234"
			..
		InterfaceConfiguration	{…}
		InterfaceConfigurationDefaults	{…}
	*/

	json_object *out = json_object_new_array();

	json_object *intfs = json_object_object_get(resp, "interfaces");

	for (int i = 0; i < json_object_array_length(intfs); i++) {
		struct json_object *el = json_object_array_get_idx(intfs, i);
		struct json_object *olsr = json_object_object_get(el, "olsrInterface");
		struct json_object *ip = json_object_object_get(olsr, "ipAddress"); // might be null (up=false)
		if (ip) {
			json_object_array_add(out, ip);
		}
	}

	return out;
}

static json_object * olsr2_get_addresses (void) {
	/*

	> olsrv2info jsonraw originator
	{"originator": [{
	"originator":"-"},{
	"originator":"fdff:182f:da60:abc:23:ee1a:dec6:d17c"}]}

	if you're wondering "what the fuck": me too, me too

	*/

	json_object *resp;

	if (olsr2_get_nodeinfo("olsrv2info jsonraw originator", &resp))
	 	return NULL;

	json_object *out = json_object_new_array();

	json_object *origs = json_object_object_get(resp, "originator");

	for (int i = 0; i < json_object_array_length(origs); i++) {
		struct json_object *el = json_object_array_get_idx(origs, i);
		if (json_object_get_string(el)[0] != "-"[0]) {
			json_object_array_add(out, el);
		}
	}

	return out;
}

struct json_object * olsr1_get_interfaces (void) {
	json_object *resp;

	if (olsr1_get_nodeinfo("interfaces", &resp))
		return NULL;

	/*

	interfaces []
		name	"m_uplink"
		configured	true
		hostEmulation	false
		hostEmulationAddress	"0.0.0.0"
		olsrInterface
			-- might be false (and then ipAddress key is missing)
			up	true
			ipv4Address	"10.12.23.234"
			ipv4Netmask	"255.255.0.0"
			ipv4Broadcast	"10.12.255.255"
			mode	"mesh"
			ipv6Address	"::"
			ipv6Multicast	"::"
			-- we need this
			ipAddress	"10.12.23.234"
			..
		InterfaceConfiguration	{…}
		InterfaceConfigurationDefaults	{…}
	*/

	json_object *out = json_object_new_object();

	json_object *intfs = json_object_object_get(resp, "interfaces");

	for (int i = 0; i < json_object_array_length(intfs); i++) {
		json_object *el = json_object_array_get_idx(intfs, i);
		json_object *olsr = json_object_object_get(el, "olsrInterface");

		json_object *intf = json_object_new_object();
		json_object_object_add(out,
			json_object_get_string(json_object_object_get(el, "name")),
			intf
		);

		json_object_object_add(intf, "configured", json_object_object_get(el, "configured"));
		json_object_object_add(intf, "up", json_object_object_get(olsr, "up"));
		json_object_object_add(intf, "ipAddress", json_object_object_get(olsr, "ipAddress"));
		json_object_object_add(intf, "mode", json_object_object_get(olsr, "mode"));
	}

	return out;
}

struct json_object * olsr2_get_interfaces (void) {
	json_object *resp;

	if (olsr2_get_nodeinfo("nhdpinfo jsonraw interface", &resp))
		return NULL;

	/*

	we're currently just using nhdpinfo, but layer2info might be interesting at some point

	> nhdpinfo jsonraw interface
	{"interface": [{
	"if":"ibss0",
	"if_bindto_v4":"-",
	"if_bindto_v6":"-",
	"if_mac":"b8:69:f4:0d:1a:3c",
	"if_flooding_v4":"false",
	"if_flooding_v6":"false",
	"if_dualstack_mode":"-"},{
	"if":"lo",
	"if_bindto_v4":"-",
	"if_bindto_v6":"fdff:182f:da60:abc:23:ee1a:dec6:d17c",
	"if_mac":"00:00:00:00:00:00",
	"if_flooding_v4":"false",
	"if_flooding_v6":"false",
	"if_dualstack_mode":"-"},{

	> layer2info jsonraw interface
	{"interface": [{
	"if":"ibss0",
	"if_index":14,
	"if_local_addr":"b8:69:f4:0d:1a:3c",
	"if_type":"wireless",
	"if_dlep":"false",
	"if_ident":"",
	"if_ident_addr":"",
	"if_lastseen":0,
	"if_frequency1":"0",
	"if_frequency2":"0",
	"if_bandwidth1":"0",
	"if_bandwidth2":"0",
	"if_noise":"-92",
	"if_ch_active":"40448.827",
	"if_ch_busy":"1015.889",
	"if_ch_rx":"263.867",
	"if_ch_tx":"127.433",
	"if_mtu":"0",
	"if_mcs_by_probing":"true",
	"if_rx_only_unicast":"false",
	"if_tx_only_unicast":"false",
	"if_frequency1_origin":"",
	"if_frequency2_origin":"",
	"if_bandwidth1_origin":"",
	"if_bandwidth2_origin":"",
	"if_noise_origin":"nl80211",
	"if_ch_active_origin":"nl80211",
	"if_ch_busy_origin":"nl80211",
	"if_ch_rx_origin":"nl80211",
	"if_ch_tx_origin":"nl80211",
	"if_mtu_origin":"",
	"if_mcs_by_probing_origin":"nl80211",
	"if_rx_only_unicast_origin":"",
	"if_tx_only_unicast_origin":""},{
	"if":"lo",
	"if_index":1,
	"if_local_addr":"00:00:00:00:00:00",
	"if_type":"wireless",
	"if_dlep":"false",
	"if_ident":"",
	"if_ident_addr":"",
	"if_lastseen":0,
	"if_frequency1":"0",
	"if_frequency2":"0",
	"if_bandwidth1":"0",
	"if_bandwidth2":"0",
	"if_noise":"0",
	"if_ch_active":"0",
	"if_ch_busy":"0",
	"if_ch_rx":"0",
	"if_ch_tx":"0",
	"if_mtu":"0",
	"if_mcs_by_probing":"false",
	"if_rx_only_unicast":"false",
	"if_tx_only_unicast":"false",
	"if_frequency1_origin":"",
	"if_frequency2_origin":"",
	"if_bandwidth1_origin":"",
	"if_bandwidth2_origin":"",
	"if_noise_origin":"",
	"if_ch_active_origin":"",
	"if_ch_busy_origin":"",
	"if_ch_rx_origin":"",
	"if_ch_tx_origin":"",
	"if_mtu_origin":"",
	"if_mcs_by_probing_origin":"",
	"if_rx_only_unicast_origin":"",
	"if_tx_only_unicast_origin":""},{

	*/

	json_object *out = json_object_new_object();

	json_object *intfs = json_object_object_get(resp, "interface");

	for (int i = 0; i < json_object_array_length(intfs); i++) {
		json_object *el = json_object_array_get_idx(intfs, i);

		json_object *intf = json_object_new_object();
		json_object_object_add(out,
			json_object_get_string(json_object_object_get(el, "if")),
			intf
		);

		json_object_object_add(intf, "mac", json_object_object_get(el, "if_mac"));
		json_object_object_add(intf, "v4", json_object_object_get(el, "if_bindto_v4"));
		json_object_object_add(intf, "v6", json_object_object_get(el, "if_bindto_v6"));
	}

	return out;
}

/* static struct json_object * get_mesh(void) {
	struct json_object *ret = json_object_new_object();
	struct json_object *bat0_interfaces = json_object_new_object();
	json_object_object_add(bat0_interfaces, "interfaces", get_mesh_subifs("bat0"));
	json_object_object_add(ret, "bat0", bat0_interfaces);
	return ret;
} */

struct json_object * real_respondd_provider_nodeinfo(void) {
	struct olsr_info *info;

	struct json_object *ret = json_object_new_object();

	if (oi(&info))
		return ret;

	/* struct json_object *network = json_object_new_object();
	json_object_object_add(network, "addresses", get_addresses());
	json_object_object_add(network, "mesh", get_mesh());
	json_object_object_add(ret, "network", network); */

	/*

	TODO: get interfaces and return in following schema

	{
		interfaces: {
			$intf_name: {
				olsr1: {
					configured,
					up: intf.olsrInterface.up,
				}
				olsr2: {

				}
			}
		}
	}

	*/

	struct json_object *network = json_object_new_object();

	struct json_object *n_addresses = json_object_new_array();

	json_object_object_add(network, "addresses", n_addresses);

	struct json_object *n_interfaces = json_object_new_object();

	json_object_object_add(network, "interfaces", n_interfaces);

	json_object_object_add(ret, "network", network);

	struct json_object *software = json_object_new_object();

	if (info->olsr1.enabled) {
		struct json_object *software_olsr1 = json_object_new_object();

		json_object_object_add(software_olsr1, "running", json_object_new_boolean(info->olsr1.running));

		if (info->olsr1.running) {
			struct json_object *version = olsr1_get_version();
			if (version)
				json_object_object_add(software_olsr1, "version", version);

			struct json_object *plugins = olsr1_get_plugins();
			if (plugins)
				json_object_object_add(software_olsr1, "plugins", plugins);

			struct json_object *addresses = olsr1_get_addresses();
			if (addresses) {
				json_object_object_add(software_olsr1, "addresses", addresses);

				for (int i = 0; i < json_object_array_length(addresses); i++)
					json_object_array_add(n_addresses, json_object_array_get_idx(addresses, i));
			}

			struct json_object *interfaces = olsr1_get_interfaces();
			if (interfaces) {
				json_object_object_add(software_olsr1, "interfaces", interfaces);

				struct json_object_iterator it = json_object_iter_begin(interfaces);
			  struct json_object_iterator itEnd = json_object_iter_end(interfaces);

			  while (!json_object_iter_equal(&it, &itEnd)) {
					const char * name = json_object_iter_peek_name(&it);
					json_object *append_key = json_object_object_get(n_interfaces, name);

					if (!append_key) {
						append_key = json_object_new_object();
						json_object_object_add(n_interfaces, name, append_key);
					}

					json_object_object_add(append_key, "olsr1",
						json_object_object_get(interfaces, name));
		      json_object_iter_next(&it);
			  }
			}
		}

		json_object_object_add(software, "olsr1", software_olsr1);
	}

	if (info->olsr2.enabled) {
		struct json_object *software_olsr2 = json_object_new_object();

		json_object_object_add(software_olsr2, "running", json_object_new_boolean(info->olsr2.running));

		if (info->olsr2.running) {
			struct json_object *version = olsr2_get_version();
			if (version)
				json_object_object_add(software_olsr2, "version", version);

			struct json_object *addresses = olsr2_get_addresses();
			if (addresses) {
				json_object_object_add(software_olsr2, "addresses", addresses);

				for (int i = 0; i < json_object_array_length(addresses); i++)
					json_object_array_add(n_addresses, json_object_array_get_idx(addresses, i));
			}

			struct json_object *interfaces = olsr2_get_interfaces();
			if (interfaces) {
				json_object_object_add(software_olsr2, "interfaces", interfaces);

				struct json_object_iterator it = json_object_iter_begin(interfaces);
			  struct json_object_iterator itEnd = json_object_iter_end(interfaces);

			  while (!json_object_iter_equal(&it, &itEnd)) {
					const char * name = json_object_iter_peek_name(&it);
					json_object *append_key = json_object_object_get(n_interfaces, name);

					if (!append_key) {
						append_key = json_object_new_object();
						json_object_object_add(n_interfaces, name, append_key);
					}

					json_object_object_add(append_key, "olsr2",
						json_object_object_get(interfaces, name));
		      json_object_iter_next(&it);
			  }
			}
		}

		json_object_object_add(software, "olsr2", software_olsr2);
	}

	json_object_object_add(ret, "software", software);

	return ret;
}

make_safe_fnc(respondd_provider_nodeinfo, real_respondd_provider_nodeinfo)
