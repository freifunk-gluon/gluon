gluon-wireless-encryption-wpa3
==============================

This package adds support for `WPA3 <https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access#WPA3>`_
configuration on client SSIDs.
Some features of WPA3 are also available for public wireless networks as
`OWE <https://en.wikipedia.org/wiki/Opportunistic_Wireless_Encryption>`_.
Similar security advancements are also independently available for the mesh network
using:doc:`gluon-mesh-wireless-sae`.

It is required for the WPA3 or WPA2/WPA3 mixed-mode setting to be visible in the :doc:`private-wlan <../../features/private-wlan>` feature.
To create an additional OWE ssid for the client radio, it must be configured in :doc:`site.conf <../user/site>`.

For an OWE secured network, the ``owe_ssid`` string has to be set. It sets the
SSID for the opportunistically encrypted wireless network, to which compatible
clients can connect to.
  
To utilize the OWE transition mode, ``owe_transition_mode`` has to be set to true.
When ``owe_transition_mode`` is enabled, the OWE secured SSID will be hidden.
Compatible devices will automatically connect to the OWE secured SSID when selecting
the open SSID.
Note that for the transition mode to work, both ``ssid`` as well as ``owe_ssid``
have to be enabled. Also, some devices with a broken implementation might not be able
to connect with a transition-mode enabled network.

site.conf
---------

wifi24.ap.owe_ssid / wifi5.ap.owe_ssid
    SSID for the OWE client network

wifi24.ap.owe_transition_mode / wifi5.ap.owe_transition_mode
    flag if the transition mode should be enabled - defaults to false
