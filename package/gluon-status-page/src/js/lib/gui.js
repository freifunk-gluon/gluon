"use strict"
define([ "lib/gui/nodeinfo"
       , "lib/gui/statistics"
       , "lib/gui/neighbours"
       , "lib/gui/menu"
       , "lib/streams"
       , "lib/neighbourstream"
       ], function ( NodeInfo
                   , Statistics
                   , Neighbours
                   , Menu
                   , Streams
                   , NeighbourStream
                   ) {

  function VerticalSplit(parent) {
    var el = document.createElement("div")
    el.className = "vertical-split"
    parent.appendChild(el)

    el.push = function (child) {
      var header = document.createElement("h2")
      header.appendChild(child.title)

      var div = document.createElement("div")
      div.className = "frame"
      div.node = child
      div.appendChild(header)

      el.appendChild(div)

      child.render(div)

      return function () {
        div.node.destroy()
        el.removeChild(div)
      }
    }

    el.clear = function () {
      while (el.firstChild) {
        el.firstChild.node.destroy()
        el.removeChild(el.firstChild)
      }
    }

    return el
  }

  var h1

  return function (mgmtBus, nodesBus) {
    function setTitle(node, state) {
      var title = node ? node.hostname : "(not connected)"

      document.title = title
      h1.textContent = title

      var icon = document.createElement("i")
      icon.className = "icon-down-dir"

      h1.appendChild(icon)

      switch (state) {
        case "connect":
          stateIcon.className = "icon-arrows-cw animate-spin"
          break
        case "fail":
          stateIcon.className = "icon-attention"
          break
        default:
          stateIcon.className = ""
          break
      }
    }

    var nodes = []

    function nodeMenu() {
      var myNodes = nodes.slice()

      myNodes.sort(function (a, b) {
        a = a.hostname
        b = b.hostname
        return (a < b) ? -1 : (a > b)
      })

      var menu = myNodes.map(function (d) {
        return [d.hostname, function () {
          mgmtBus.pushEvent("goto", d)
        }]
      })

      new Menu(menu).apply(this)
    }

    var header = document.createElement("header")
    h1 = document.createElement("h1")
    header.appendChild(h1)

    h1.onclick = nodeMenu

    var icons = document.createElement("p")
    icons.className = "icons"
    header.appendChild(icons)

    var stateIcon = document.createElement("i")
    icons.appendChild(stateIcon)

    document.body.appendChild(header)

    var container = document.createElement("div")
    container.className = "container"

    document.body.appendChild(container)

    setTitle()

    var content = new VerticalSplit(container)

    function nodeChanged(nodeInfo) {
      setTitle(nodeInfo, "connect")

      content.clear()
      content.push(new NodeInfo(nodeInfo))
    }

    function nodeNotArrived(nodeInfo) {
      setTitle(nodeInfo, "fail")
    }

    function nodeArrived(nodeInfo, ip) {
      setTitle(nodeInfo)

      var neighbourStream = new NeighbourStream(mgmtBus, nodesBus, ip)
      var statisticsStream = new Streams.Statistics(ip)

      content.push(new Statistics(statisticsStream))
      content.push(new Neighbours(nodeInfo, neighbourStream, mgmtBus))
    }

    function newNodes(d) {
      nodes = []
      for (var nodeId in d)
        nodes.push(d[nodeId])
    }

    mgmtBus.onEvent({ "goto": nodeChanged
                    , "arrived": nodeArrived
                    , "gotoFailed": nodeNotArrived
                    })

    nodesBus.map(".nodes").onValue(newNodes)

    return this
  }
})
