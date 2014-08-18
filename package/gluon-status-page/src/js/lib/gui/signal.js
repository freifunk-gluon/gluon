"use strict"
define(function () {
  return function (color) {
    var canvas = document.createElement("canvas")
    var ctx = canvas.getContext("2d")
    var v = null
    var radius = 1.2
    var highlight = false

    function drawPixel(x, y) {
      ctx.beginPath()
      ctx.fillStyle = color
      ctx.arc(x, y, radius, 0, Math.PI * 2, false)
      ctx.closePath()
      ctx.fill()
    }

    this.resize = function (w, h) {
      canvas.width = w
      canvas.height = h
    }

    this.draw = function (x, scale) {
      var y = scale(v)

      ctx.clearRect(x, 0, 5, canvas.height)

      if (y)
        drawPixel(x, y)
    }

    this.canvas = canvas

    this.set = function (d) {
      v = d
    }

    this.setHighlight = function (d) {
      highlight = d
    }

    this.getHighlight = function () {
      return highlight
    }

    return this
  }
})
