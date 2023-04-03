/*
	Build using:

	uglifyjs javascript/gluon-web-osm.js -o javascript/gluon-web-osm.min.js -c -m
*/

'use strict';

function initOSM(options, ready) {
	var markerSvg = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="30" height="45">'
		+ '<path d="M2,15A13,13,0,0,1,28,13Q28,28,15,45Q2,28,2,15" fill="#48b" stroke="#369" stroke-width="1.5" />'
		+ '<circle cx="15" cy="15" r="6" fill="#fff" />'
		+ '</svg>';

	var style = document.createElement('link');
	style.rel = 'stylesheet';
	style.type = 'text/css';
	style.href = options.openlayers_url + '/css/ol.css';
	document.head.appendChild(style);

	var script = document.createElement('script');
	var done = false;
	script.onload = script.onreadystatechange = function() {
		if (done)
			return;
		if (this.readyState && this.readyState !== "loaded" && this.readyState !== "complete")
			return;

		done = true;


		var markerImg = new Image();
		markerImg.onload = function() {
			var markerStyle = new ol.style.Style({
				image: new ol.style.Icon({
					img: markerImg,
					imgSize: [30, 45],
					anchor: [0.5, 1]
				})
			});

			var marker = new ol.Feature();
			marker.setStyle(markerStyle);

			var source;
			if (options.tile_layer && options.tile_layer.type === 'XYZ') {
				source = new ol.source.XYZ({
					url: options.tile_layer.url,
					attributions: options.tile_layer.attributions,
				});
			} else {
				source = new ol.source.OSM();
			}

			ready(function(elMap, pos, zoom, set, onUpdate) {
				var map = new ol.Map({
					target: elMap,
					layers: [
						new ol.layer.Tile({
							source: source
						}),
						new ol.layer.Vector({
							source: new ol.source.Vector({
								features: [marker]
							})
						})
					],
					view: new ol.View({
						center: ol.proj.fromLonLat(pos),
						zoom: zoom,
					})
				});

				var refresh = function(coord) {
					marker.setGeometry(new ol.geom.Point(coord));
				}

				map.addEventListener('click', function(e) {
					refresh(e.coordinate);
					onUpdate(ol.proj.toLonLat(e.coordinate));
				});

				if (set)
					refresh(ol.proj.fromLonLat(pos));

				return map;
			});
		}

		markerImg.src = 'data:image/svg+xml,' + escape(markerSvg);
	};
	script.src = options.openlayers_url + '/build/ol.js';
	document.head.appendChild(script);
}
