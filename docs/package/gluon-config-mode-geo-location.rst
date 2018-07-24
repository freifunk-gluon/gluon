gluon-config-mode-geo-location
==============================

This package allows the user to set latitude, longitude and optionally altitude
to be advertised from within the config mode. There are two types of this
package:

It is possible to include **either** ``gluon-config-mode-geo-location`` **or**
``gluon-config-mode-geo-location-with-map`` in the ``site.mk``.

If you want to use ``gluon-config-mode-geo-location-with-map`` together with
the GLUON_FEATURE ``web-wizard`` then you have to exclude
``gluon-config-mode-geo-location``, i.e.:

    GLUON_SITE_PACKAGES += \
      -gluon-config-mode-geo-location \
      gluon-config-mode-geo-location-with-map

gluon-config-mode-geo-location-with-map
---------------------------------------

This package enhances the config mode by providing users a map that can be used
to pick a position. The map requires an internet connection on the users
computer and will be hidden if there is none.

site.conf
^^^^^^^^^

This option is valid for both ``gluon-config-mode-geo-location`` and
``gluon-config-mode-geo-location-with-map``:

config_mode.geo_location.show_altitude \: optional
  - ``true`` the altitude section in config mode is shown
  - ``false`` the altitude section in config mode is hidden
  - defaults to ``false``

The remaining options are only valid for the
``gluon-config-mode-geo-location-with-map`` package:

config_mode.geo_location.map.lon \: optional
  - represents the default longitude value to use for the center of the map.
  - defaults to ``0.0``

config_mode.geo_location.map.lat \: optional
  - represents the default latitude value to use for the center of the map.
  - defaults to ``0.0``

The map will center to the position defined in **lat** and **lon**, unless a
location was already defined. The new defined location will become the
new center.

config_mode.geo_location.map.zoom \: optional
  - Natural number between ``0-17`` for the zoom level of the map.
  - defaults to ``12``

config_mode.geo_location.map.openlayers_js_url \: optional
  - ``url`` set an URL for OpenStreetMap layers.
  - defaults to ``http://dev.openlayers.org/OpenLayers.js``

Example::

 config_mode = {
   geo_location = {
     map = {
       lon = 52.951947558,
       lat = 7.844238281,
       zoom = 12,
       openlayers_js_url = 'http://osm.ffnw.de/.static/ol/OpenLayers.js',
     },
     show_altitude = true,
   },
 },
