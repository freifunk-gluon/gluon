"use strict"
require([ "bacon"
        , "lib/helper"
        , "lib/streams"
        , "lib/gui"
        ], function(Bacon, Helper, Streams, GUI) {

  var mgmtBus = new Bacon.Bus()

  mgmtBus.pushEvent = function (key, a) {
    var v = [key].concat(a)
    return this.push(v)
  }

  mgmtBus.onEvent = function (events) {
    return this.onValue(function (e) {
      var d = e.slice() // shallow copy so calling shift doesn't change it
      var ev = d.shift()
      if (ev in events)
        events[ev].apply(this, d)
    })
  }

  var nodesBusIn = new Bacon.Bus()

  var nodesBus = nodesBusIn.scan({ "nodes": {}
                                 , "macs": {}
                                 }, scanNodeInfo)

  new GUI(mgmtBus, nodesBus)

  mgmtBus.onEvent({ "goto": gotoNode
                  , "nodeinfo": function (d) { nodesBusIn.push(d) }
                  })

  function tryIp(ip) {
    return Helper.request(ip, "nodeinfo").map(function () { return ip })
  }

  var gotoEpoch = 0

  function onEpoch(epoch, f) {
    return function (d) {
      if (epoch === gotoEpoch)
        return f(d)
    }
  }

  function gotoNode(nodeInfo) {
    gotoEpoch++

    var addresses = nodeInfo.network.addresses.filter(function (d) { return !/^fe80:/.test(d) })
    var race = Bacon.fromArray(addresses).flatMap(tryIp).withStateMachine([], function (acc, ev) {
      if (ev.isError())
        return [acc.concat(ev.error), []]
      else if (ev.isEnd() && acc.length > 0)
        return [undefined, [new Bacon.Error(acc), ev]]
      else if (ev.hasValue())
        return [[], [ev, new Bacon.End()]]
    })

    race.onValue(onEpoch(gotoEpoch, function (d) {
          mgmtBus.pushEvent("arrived", [nodeInfo, d])
        }))

    race.onError(onEpoch(gotoEpoch, function () {
          mgmtBus.pushEvent("gotoFailed", nodeInfo)
        }))
  }

  function scanNodeInfo(a, nodeInfo) {
    a.nodes[nodeInfo.node_id] = nodeInfo

    var mesh = Helper.dictGet(nodeInfo, ["network", "mesh"])

    if (mesh)
      for (var m in mesh)
        for (var ifname in mesh[m].interfaces)
          mesh[m].interfaces[ifname].forEach( function (d) {
            a.macs[d] = nodeInfo
          })

    return a
  }

  var lsavailable = false
  try {
    localStorage.setItem("t", "t")
    localStorage.removeItem("t")
    lsavailable = true
  } catch(e) {
    lsavailable = false
  }


  if ( lsavailable && localStorage.nodes)
    JSON.parse(localStorage.nodes).forEach(nodesBusIn.push)

  nodesBus.map(".nodes").onValue(function (nodes) {
    var out = []

    for (var k in nodes)
      out.push(nodes[k])

    if (lsavailable)
      localStorage.nodes = JSON.stringify(out)
  })

  var bootstrap = Helper.getJSON(bootstrapUrl)

  bootstrap.onError(function () {
    console.log("FIXME bootstrapping failed")
  })

  bootstrap.onValue(function (d) {
    mgmtBus.pushEvent("nodeinfo", d)
    mgmtBus.pushEvent("goto", d)
  })
})
