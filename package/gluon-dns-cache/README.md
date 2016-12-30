##### Hintergrund
Es ist erstrebenswert, die Menge der kleinen Datenpakete vom Router zum 
Supernode zu reduzieren. Dabei hilft es, die DNS-Anfragen der Clients zu 
den Supernodes zu reduzieren. 

<br>

##### Das Packages
Durch dieses Package wird der Cache der Router-dnsmasq-Instanz, welche 
auf Port 53 horcht, konfiguriert. Die Freifunk-Router halten dadurch 
eine Anzahl von *dns.cacheentries* Einträgen im RAM des Routers vor.  
Sollte ein DNS-Record im Cache nicht gefunden werden, wird einer der in 
der Tabelle *dns.servers* angegebenen Server abgefragt. 

Dieses Paket konfiguriert neben dem Cache auch die Namensauflösung für 
die Host-Namen "*nextnode*". Die IP-Adressen werden aus der *site.conf* 
ausgelesen.

#### Konfiguration
Die Konfiguration erfolgt per ***site.conf*** mit folgenden Parametern:
```
dns = {
      cacheentries = 5000,
      servers = { '2a06:8187:fb00:53::53', },
},
```

*  ***cacheentries*** ist die Anzahl der Einträge, die der Cache aufnehmen soll.  
Je Eintrag werden ca 90 Byte RAM benötigt. Der Speicher für alle Einträge wird 
als Block beim Systemstart reserviert.  
* ***servers*** ist eine Namens-Liste von Servern, welche bei Cache-Misses angefragt werden.


---

Siehe auch:  
https://wiki.openwrt.org/doc/uci/dhcp  
http://flux242.blogspot.de/2012/06/dnsmasq-cache-size-tuning.html

