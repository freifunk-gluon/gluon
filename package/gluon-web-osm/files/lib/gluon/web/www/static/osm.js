function findObj(e){for(list=document.getElementsByClassName("gluon-input-text"),i=0;i<list.length;i++)if(item=list.item(i),0<=item.id.indexOf(e))return item;return!1}function showMap(){if("object"==typeof OpenLayers&&!1!==findObj("longitude")){document.getElementById("locationPickerMap").style.display="block";var a=new OpenLayers.Projection("EPSG:4326"),o=new OpenLayers.Projection("EPSG:900913"),e=zoom,t=new OpenLayers.Layer.Markers("Markers");OpenLayers.Control.Click=OpenLayers.Class(OpenLayers.Control,{defaultHandlerOptions:{single:!0,double:!1,pixelTolerance:0,stopSingle:!1,stopDouble:!1},initialize:function(){this.handlerOptions=OpenLayers.Util.extend({},this.defaultHandlerOptions),OpenLayers.Control.prototype.initialize.apply(this,arguments),this.handler=new OpenLayers.Handler.Click(this,{click:this.trigger},this.handlerOptions)},trigger:function(e){var n=osmMap.getLonLatFromPixel(e.xy);oLon=findObj("longitude"),oLat=findObj("latitude"),lonlat1=new OpenLayers.LonLat(n.lon,n.lat).transform(o,a),oLon.value=lonlat1.lon,oLat.value=lonlat1.lat,t.clearMarkers(),t.addMarker(new OpenLayers.Marker(n)),oLon.className=oLon.className.replace(/ gluon-input-invalid/g,""),oLat.className=oLat.className.replace(/ gluon-input-invalid/g,"")}}),osmMap=new OpenLayers.Map("locationPickerMap",{controls:[new OpenLayers.Control.Navigation,new OpenLayers.Control.PanZoomBar,new OpenLayers.Control.MousePosition],maxExtent:new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34),numZoomLevels:18,maxResolution:156543,units:"m",projection:o,displayProjection:a});var n=new OpenLayers.Layer.OSM("OpenStreetMap");osmMap.addLayer(n),osmMap.addLayer(t);var r=longitude,i=latitude;oLon=findObj("longitude"),oLat=findObj("latitude"),""!=oLon.value&&(r=oLon.value),""!=oLat.value&&(i=oLat.value),t.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(r,i).transform(a,o)));var l=new OpenLayers.LonLat(r,i).transform(a,o);osmMap.setCenter(l,e);var s=new OpenLayers.Control.Click;osmMap.addControl(s),s.activate()}else setTimeout(showMap,1e3)}