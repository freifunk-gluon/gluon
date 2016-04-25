"use strict"
define([ "lib/helper", "lib/gui/signalgraph", "lib/gui/signal"],
function (Helper, SignalGraph, Signal) {

  var graphColors = ["#396AB1", "#DA7C30", "#3E9651", "#CC2529", "#535154", "#6B4C9A", "#922428", "#948B3D"]
  //graphColors = ["#7293CB", "#E1974C", "#84BA5B", "#D35E60", "#808585", "#9067A7", "#AB6857", "#CCC210"];

  var inactiveTime = 200

  function SignalEntry(graph, color, stream) {
    var signal = new Signal(color)
    var remove = graph.add(signal)

    var unsubscribe = stream.onValue(update)

    this.destroy = function () {
      unsubscribe()
      remove()
    }

    this.getSignal = function () {
      return signal
    }

    return this

    function update(d) {
      if ("wifi" in d)
        signal.set(d.wifi.inactive > inactiveTime ? null : d.wifi.signal)
    }
  }

  function TableEntry(parent, nodeInfo, color, stream, mgmtBus, signal) {
    var el = parent.insertRow()

    var tdHostname = el.insertCell()
    var tdTQ = el.insertCell()
    var tdSignal = el.insertCell()
    var tdDistance = el.insertCell()
    var tdInactive = el.insertCell()

    var marker = document.createElement("span")
    marker.textContent = "⬤ "
    marker.style.color = color
    tdHostname.appendChild(marker)

    var hostname = document.createElement("span")
    tdHostname.appendChild(hostname)

    var infoSet = false
    var unsubscribe = stream.onValue(update)

    el.onmouseenter = function () {
      el.classList.add("highlight")
      signal.setHighlight(true)
    }

    el.onmouseleave = function () {
      el.classList.remove("highlight")
      signal.setHighlight(false)
    }

    el.destroy = function () {
      unsubscribe()
      parent.tBodies[0].removeChild(el)
    }

    return el

    function update(d) {
      if ("wifi" in d) {
        var signal = d.wifi.signal
        var inactive = d.wifi.inactive

        el.classList.toggle("inactive", inactive > inactiveTime)

        tdSignal.textContent = signal
        tdInactive.textContent = Math.round(inactive / 1000) + " s"
      }

      if ("batadv" in d)
        tdTQ.textContent = Math.round(d.batadv.tq / 2.55) + " %"
      else
        tdTQ.textContent = "‒"

      if (infoSet)
        return

      if ("nodeInfo" in d) {
          infoSet = true

          var link = document.createElement("a")
          link.textContent = d.nodeInfo.hostname
          link.href = "#"
          link.nodeInfo = d.nodeInfo
          link.onclick = function () {
            mgmtBus.pushEvent("goto", this.nodeInfo)
            return false
          }

          while (hostname.firstChild)
            hostname.removeChild(hostname.firstChild)

          hostname.appendChild(link)

          try {
            var distance = Helper.haversine(nodeInfo.location.latitude, nodeInfo.location.longitude,
                                            d.nodeInfo.location.latitude, d.nodeInfo.location.longitude)

            tdDistance.textContent = Math.round(distance * 1000) + " m"
          } catch (e) {
            tdDistance.textContent = "‒"
          }
      } else
        hostname.textContent = d.id
    }
  }

  function Interface(parent, nodeInfo, iface, stream, mgmtBus) {
    var colors = graphColors.slice(0)

    var el = document.createElement("div")
    el.ifname = iface
    parent.appendChild(el)

    var h = document.createElement("h3")
    h.textContent = iface
    el.appendChild(h)

    var table = document.createElement("table")
    var tr = table.insertRow()
    table.classList.add("datatable")

    var th = document.createElement("th")
    th.textContent = "Knoten"
    tr.appendChild(th)

    th = document.createElement("th")
    th.textContent = "TQ"
    tr.appendChild(th)

    th = document.createElement("th")
    th.textContent = "dBm"
    tr.appendChild(th)

    th = document.createElement("th")
    th.textContent = "Entfernung"
    tr.appendChild(th)

    th = document.createElement("th")
    th.textContent = "Inaktiv"
    tr.appendChild(th)

    el.appendChild(table)

    var wrapper = document.createElement("div")
    wrapper.className = "signalgraph"
    el.appendChild(wrapper)

    var canvas = document.createElement("canvas")
    canvas.className = "signal-history"
    canvas.height = 200
    wrapper.appendChild(canvas)

    var graph = new SignalGraph(canvas, -100, 0, true)

    var stopStream = stream.skipDuplicates(sameKeys).onValue(update)

    var managedNeighbours = {}

    function update(d) {
      var notUpdated = new Set()
      var id

      for (id in managedNeighbours)
        notUpdated.add(id)

      for (id in d) {
        if (!(id in managedNeighbours)) {
          var neighbourStream = stream.map("."  + id).filter( function (d) { return d !== undefined })
          var color = colors.shift()
          var signal = new SignalEntry(graph, color, neighbourStream)
          managedNeighbours[id] = { views: [ signal,
                                             new TableEntry(table, nodeInfo, color, neighbourStream, mgmtBus, signal.getSignal())
                                           ],
                                    color: color
                                  }
        }

        notUpdated.delete(id)
      }

      notUpdated.forEach(function (id) {
        managedNeighbours[id].views.forEach( function (d) { d.destroy() })
        colors.push(managedNeighbours[id].color)
        delete managedNeighbours[id]
      })
    }


    el.destroy = function () {
      stopStream()

      for (var id in managedNeighbours)
        managedNeighbours[id].views.forEach( function (d) { d.destroy() })

      el.removeChild(h)
      el.removeChild(wrapper)
      el.removeChild(table)
    }
  }

  function sameKeys(a, b) {
    a = Object.keys(a).sort()
    b = Object.keys(b).sort()

    return !(a < b || a > b)
  }

  function getter(k) {
    return function(obj) {
      return obj[k]
    }
  }

  return function (nodeInfo, stream, mgmtBus) {
    var stopStream, div

    function render(el) {
      div = document.createElement("div")
      el.appendChild(div)

      stopStream = stream.skipDuplicates(sameKeys).onValue(update)

      function update(d) {
        var have = {}
        var remove = []
        if (div.hasChildNodes()) {
          var children = div.childNodes
          for (var i = 0; i < children.length; i++) {
            var a = children[i]
            if (a.ifname in d)
              have[a.ifname] = true
            else {
              a.destroy()
              remove.push(a)
            }
          }
        }

        remove.forEach(function (d) { div.removeChild(d) })

        for (var k in d) {
          if (!(k in have))
            new Interface(div, nodeInfo, k, stream.map(getter(k)), mgmtBus)
        }
      }
    }

    function destroy() {
      stopStream()

      while (div.firstChild) {
        div.firstChild.destroy()
        div.removeChild(div.firstChild)
      }
    }

    return { title: document.createTextNode("Nachbarknoten")
           , render: render
           , destroy: destroy
           }
  }
})
