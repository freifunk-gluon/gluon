"use strict"
define([ "bacon" ], function (Bacon) {
  function get(url) {
    return Bacon.fromBinder(function(sink) {
      var req = new XMLHttpRequest()
      req.open("GET", url)

      req.onload = function() {
        if (req.status === 200)
          sink(new Bacon.Next(req.response))
        else
          sink(new Bacon.Error(req.statusText))
        sink(new Bacon.End())
      }

      req.onerror = function() {
        sink(new Bacon.Error("network error"))
        sink(new Bacon.End())
      }

      req.send()

      return function () {}
    })
  }

  function getJSON(url) {
    return get(url).map(JSON.parse)
  }

  function buildUrl(ip, object, param) {
    var url = "http://[" + ip + "]/cgi-bin/" + object
    if (param) url += "?" + param

    return url
  }

  function request(ip, object, param) {
    return getJSON(buildUrl(ip, object, param))
  }

  function dictGet(dict, key) {
    var k = key.shift()

    if (!(k in dict))
      return null

    if (key.length === 0)
      return dict[k]

    return dictGet(dict[k], key)
  }

  function localizeNumber(d) {
    var sep = ','
    return d.replace('.', sep)
  }

  function formatNumberFixed(d, digits) {
    return localizeNumber(d.toFixed(digits))
  }

  function formatNumber(d, digits) {
    digits--

    for (var v = d; v >= 10 && digits > 0; v /= 10)
      digits--

    // avoid toPrecision as it might produce strings in exponential notation
    return formatNumberFixed(d, digits)
  }

  function haversine() {
    var radians = Array.prototype.map.call(arguments, function(deg) { return deg / 180.0 * Math.PI })
    var lat1 = radians[0], lon1 = radians[1], lat2 = radians[2], lon2 = radians[3]
    var R = 6372.8 // km
    var dLat = lat2 - lat1
    var dLon = lon2 - lon1
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2)
    var c = 2 * Math.asin(Math.sqrt(a))
    return R * c
  }

  function _(s) {
    var i, lang, langs, dict = {
      "de": {
        "Node": "Knoten",
        "Distance": "Entfernung",
        "Inactive": "Inaktiv",
        "Node name": "Knotenname",
        "Contact": "Kontakt",
        "Model": "Modell",
        "Primary MAC": "Primäre MAC",
        "IP Address": "IP-Adresse",
        "Automatic updates": "Automatische Updates",
        "Overview": "Übersicht",
        "used": "belegt",
        "Uptime": "Laufzeit",
        "Load average": "Systemlast",
        "Transmitted": "Gesendet",
        "Received": "Empfangen",
        "Forwarded": "Weitergeleitet",
        "Day": "Tag",
        "Days": "Tage",
        "connected": "verbunden",
        "not connected": "nicht verbunden",
        "Packets/s": "Pakete/s",
        "Statistic": "Statistik",
        "Neighbors": "Nachbarknoten"
      },
      "ru": {
        "Node": "Узел",
        "Distance": "Дальность",
        "Inactive": "Не активен",
        "Node name": "Имя узла",
        "Contact": "Контакт",
        "Model": "Модель",
        "Primary MAC": "Основной MAC",
        "IP Address": "IP Адрес",
        "Automatic updates": "Автоматические обновления",
        "Overview": "Обзор",
        "used": "используется",
        "Uptime": "Время работы",
        "Load average": "Загрузка системы",
        "Gateway": "Шлюз",
        "Clients": "Клиенты",
        "Transmitted": "Передано",
        "Received": "Получено",
        "Forwarded": "Переправленно",
        "Day": "День",
        "Days": "Дней",
        "connected": "подключено",
        "not connected": "не подключено",
        "Packets/s": "Пакетов/c",
        "Statistic": "Статистика",
        "Traffic": "Трафик",
        "Neighbors": "Соседи",
        "Firmware": "Прошивка",
        "Branch": "Ветка"
      }
    }
    if (navigator.languages)
      langs = navigator.languages
    else if (navigator.language)
      langs = [navigator.language]
    else
      langs = []
    for (i=0; i<langs.length; i++) {
      lang = langs[i].split('-')[0]
      if (lang == "en")
        return s
      else if (lang in dict && s in dict[lang])
        return dict[lang][s]
    }
    return s
  }

  return { buildUrl: buildUrl
         , request: request
         , getJSON: getJSON
         , dictGet: dictGet
         , formatNumber: formatNumber
         , formatNumberFixed: formatNumberFixed
         , haversine: haversine
         , _: _
         }
})
