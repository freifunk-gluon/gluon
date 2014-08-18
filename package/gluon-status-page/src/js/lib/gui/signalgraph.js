"use strict"
define(function () {
  return function (canvas, min, max) {
    var i = 0
    var graphWidth
    var last = 0

    var signals = []

    var ctx = canvas.getContext("2d")

    resize()

    window.addEventListener("resize", resize, false)
    window.requestAnimationFrame(step)

    function step(timestamp) {
      var delta = timestamp - last

      if (delta > 40) {
        draw()
        last = timestamp
      }

      window.requestAnimationFrame(step)
    }

    function drawGrid() {
      var gridctx = ctx
      var nLines = Math.floor(canvas.height / 40)
      gridctx.save()
      gridctx.lineWidth = 0.5
      gridctx.strokeStyle = "rgba(0, 0, 0, 0.25)"
      gridctx.fillStyle = "rgba(0, 0, 0, 0.5)"
      gridctx.textAlign = "end"
      gridctx.textBaseline = "bottom"

      gridctx.beginPath()

      for (var i = 0; i < nLines; i++) {
        var y = canvas.height - i * 40
        gridctx.moveTo(0, y - 0.5)
        gridctx.lineTo(canvas.width, y - 0.5)
        var dBm = Math.round(scaleInverse(y, min, max, canvas.height)) + " dBm"

        gridctx.save()
        gridctx.strokeStyle = "rgba(255, 255, 255, 0.9)"
        gridctx.lineWidth = 4
        gridctx.miterLimit = 2
        gridctx.strokeText(dBm, canvas.width - 5, y - 2.5)
        gridctx.fillText(dBm, canvas.width - 5, y - 2.5)
        gridctx.restore()
      }

      gridctx.stroke()

      gridctx.strokeStyle = "rgba(0, 0, 0, 0.83)"
      gridctx.lineWidth = 1.5
      gridctx.strokeRect(0.5, 0.5, canvas.width - 1, canvas.height - 1)

      gridctx.restore()
    }

    function draw() {
      var anyHighlight = signals.some( function (d) { return d.getHighlight() })

      signals.forEach( function (d) {
        d.draw(i, function (v) {
          return scale(v, min, max, canvas.height)
        })
      })

      ctx.clearRect(0, 0, canvas.width, canvas.height)

      ctx.save()

      signals.forEach( function (d) {
        if (anyHighlight)
          ctx.globalAlpha = 0.1

        if (d.getHighlight())
          ctx.globalAlpha = 1

        ctx.drawImage(d.canvas, 0, 0)
      })

      ctx.restore()

      ctx.save()
      ctx.beginPath()
      ctx.strokeStyle = "rgba(255, 180, 0, 0.15)"
      ctx.lineWidth = 5
      ctx.moveTo(i + 2.5, 0)
      ctx.lineTo(i + 2.5, canvas.height)
      ctx.stroke()

      drawGrid()

      i = (i + 1) % graphWidth
    }

    function scaleInverse(n, min, max, height) {
      return (min * n + max * height - max * n) / height
    }

    function scale(n, min, max, height) {
      return (1 - (n - min) / (max - min)) * height
    }

    function resize() {
      var newWidth = canvas.parentNode.clientWidth

      if (newWidth === 0)
        return

      var lastImage = ctx.getImageData(0, 0, newWidth, canvas.height)
      canvas.width = newWidth
      graphWidth = canvas.width
      ctx.putImageData(lastImage, 0, 0)

      signals.forEach( function (d) {
        d.resize(canvas.width, canvas.height)
      })
    }

    this.add = function (d) {
      signals.push(d)
      d.resize(canvas.width, canvas.height)

      return function () {
        signals = signals.filter( function (e) { return e !== d } )
      }
    }

    return this
  }
})
