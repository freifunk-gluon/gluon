"use strict"
define([ "bacon"
       , "lib/helper"
       , "lib/streams"
       ], function(Bacon, Helper, Streams) {

  return function (mgmtBus, nodesBus, ip) {
    function nodeQuerier() {
      var asked = {}
      var timeout = 6000

      return function (ifname) {
        var now = new Date().getTime()

        if (ifname in asked && now - asked[ifname] < timeout)
          return Bacon.never()

        asked[ifname] = now
        return Streams.nodeInfo(ip, ifname).map(function (d) {
          return { "ifname": ifname
                 , "nodeInfo": d
                 }
        })
      }
    }

    var querierAsk = new Bacon.Bus()
    var querier = querierAsk.flatMap(nodeQuerier())
    querier.map(".nodeInfo").onValue(mgmtBus, "pushEvent", "nodeinfo")

    function wrapIfname(ifname, d) {
      return [ifname, d]
    }

    function extractIfname(d) {
      var r = {}

      for (var station in d) {
        var ifname = d[station].ifname
        delete d[station].ifname

        if (!(ifname in r))
          r[ifname] = {}

        r[ifname][station] = d[station]
      }

      return r
    }

    function stationsStream(ifname) {
      return new Streams.Stations(ip, ifname).map(wrapIfname, ifname)
    }

    function magic(interfaces) {
      var ifnames = Object.keys(interfaces)
      ifnames.forEach(querierAsk.push)

      var wifiStream = Bacon.fromArray(ifnames)
                            .flatMap(stationsStream)
                            .scan({}, function (a, b) {
                              a[b[0]] = b[1]
                              return a
                            })

      var batadvStream = new Streams.Batadv(ip).toProperty({})

      return Bacon.combineWith(combine, wifiStream
                                      , batadvStream.map(extractIfname)
                                      , nodesBus.map(".macs")
                                      )
    }

    function combine(wifi, batadv, macs) {
      var interfaces = combineWithIfnames(wifi, batadv)

      for (var ifname in interfaces) {
        var stations = interfaces[ifname]
        for (var station in stations) {
          stations[station].id = station

          if (station in macs)
            stations[station].nodeInfo = macs[station]
          else
            querierAsk.push(ifname)
        }
      }

      return interfaces
    }

    function combineWithIfnames(wifi, batadv) {
      var ifnames = Object.keys(wifi).concat(Object.keys(batadv))

      // remove duplicates
      ifnames.filter(function(e, i) {
        return ifnames.indexOf(e) === i
      })

      var out = {}

      ifnames.forEach(function (ifname) {
        out[ifname] = combineWifiBatadv(wifi[ifname], batadv[ifname])
      })

      return out
    }

    function combineWifiBatadv(wifi, batadv) {
      var station
      var out = {}

      for (station in batadv) {
        if (!(station in out))
          out[station] = {}

        out[station].batadv = batadv[station]
      }

      for (station in wifi) {
        if (!(station in out))
          out[station] = {}

        out[station].wifi = wifi[station]
      }

      return out
    }

    return Helper.request(ip, "interfaces").flatMap(magic)
  }
})
