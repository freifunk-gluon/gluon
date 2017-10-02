"use strict"
define(["lib/helper"], function (Helper) {
  return function (nodeInfo) {
    var el = document.createElement("div")

    update(nodeInfo)

    function dlEntry(dl, dict, key, prettyName, transform) {
      var v = Helper.dictGet(dict, key.split("."))

      if (v === null)
        return

      if (transform) {
        v = transform(v)
      }

      var dt = document.createElement("dt")
      var dd = document.createElement("dd")

      dt.textContent = prettyName
      if (v instanceof Array) {
        var tn = v.map(function (d) { return document.createTextNode(d) })
        tn.forEach(function (node) {
          if (dd.hasChildNodes())
            dd.appendChild(document.createElement("br"))

          dd.appendChild(node)
        })
      } else
        dd.textContent = v

      dl.appendChild(dt)
      dl.appendChild(dd)
    }

    function enabledDisabled(v) {
      if (v) {
        return Helper._("enabled");
      }
      return Helper._("disabled");
    }

    function update(nodeInfo) {
      var list = document.createElement("dl")

      dlEntry(list, nodeInfo, "hostname", Helper._("Node name"))
      dlEntry(list, nodeInfo, "owner.contact", Helper._("Contact"))
      dlEntry(list, nodeInfo, "hardware.model", Helper._("Model"))
      dlEntry(list, nodeInfo, "network.mac", Helper._("Primary MAC"))
      dlEntry(list, nodeInfo, "network.addresses", Helper._("IP Address"))
      dlEntry(list, nodeInfo, "software.firmware.release", Helper._("Firmware"))
      dlEntry(list, nodeInfo, "software.fastd.enabled", Helper._("Mesh VPN"), enabledDisabled)
      dlEntry(list, nodeInfo, "software.autoupdater.enabled", Helper._("Automatic updates"), enabledDisabled)
      dlEntry(list, nodeInfo, "software.autoupdater.branch", Helper._("Branch"))

      el.appendChild(list)
    }

    return { title: document.createTextNode(Helper._("Overview"))
           , render: function (d) { d.appendChild(el) }
           , destroy: function () {}
           }
  }
})
