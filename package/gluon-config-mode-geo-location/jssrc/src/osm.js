function findObj(name) {
        list = document.getElementsByClassName("gluon-input-text");
        for(i = 0; i < list.length; i++) {
                item = list.item(i);
                if(item.id.indexOf(name) >= 0) return item;
        }
        return false;
}

function showMap() {
        if ("object" == typeof OpenLayers && false !== findObj("longitude")) {
                document.getElementById("locationPickerMap").style.display = "block";
                var e = new OpenLayers.Projection("EPSG:4326"),
                        a = new OpenLayers.Projection("EPSG:900913"),
                        t = 12,
                        n = new OpenLayers.Layer.Markers("Markers");
                OpenLayers.Control.Click = OpenLayers.Class(OpenLayers.Control, {
                        defaultHandlerOptions: {
                                single: !0,
                                "double": !1,
                                pixelTolerance: 0,
                                stopSingle: !1,
                                stopDouble: !1
                        },
                        initialize: function() {
                                this.handlerOptions = OpenLayers.Util.extend({}, this.defaultHandlerOptions), OpenLayers.Control.prototype.initialize.apply(this, arguments), this.handler = new OpenLayers.Handler.Click(this, {
                                        click: this.trigger
                                }, this.handlerOptions)
                        },
                        trigger: function(t) {
                                var i = osmMap.getLonLatFromPixel(t.xy);
                                oLon = findObj("longitude");
                                oLat = findObj("latitude");
                                lonlat1 = new OpenLayers.LonLat(i.lon, i.lat).transform(a, e),
                                        oLon.value = lonlat1.lon,
                                        oLat.value = lonlat1.lat,
                                        n.clearMarkers(),
                                        n.addMarker(new OpenLayers.Marker(i)),
                                        oLon.className = oLon.className.replace(/ gluon-input-invalid/g, ""),
                                        oLat.className = oLat.className.replace(/ gluon-input-invalid/g, "");
                                        //Anyone knows how to trigger the change event?
                                        //oLon.onChange()
                                        //oLat.onChange()
                        }
                }), osmMap = new OpenLayers.Map("locationPickerMap", {
                        controls: [new OpenLayers.Control.Navigation, new OpenLayers.Control.PanZoomBar, new OpenLayers.Control.MousePosition],
                        maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
                        numZoomLevels: 18,
                        maxResolution: 156543,
                        units: "m",
                        projection: a,
                        displayProjection: e
                });
                var i = new OpenLayers.Layer.OSM("OpenStreetMap");
                osmMap.addLayer(i), osmMap.addLayer(n);
                var o = longitude,
                        r = latitude;
                oLon = findObj("longitude");
                oLat = findObj("latitude");
                "" != oLon.value && (o = oLon.value),
                "" != oLat.value && (r = oLat.value),
                n.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(o, r).transform(e, a)));
                var l = new OpenLayers.LonLat(o, r),
                        d = l.transform(e, a);
                osmMap.setCenter(d, t);
                var s = new OpenLayers.Control.Click;
                osmMap.addControl(s), s.activate()
        } else setTimeout(showMap, 1e3)
}

