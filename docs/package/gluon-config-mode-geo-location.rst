gluon-config-mode-geo-location
==============================

This package allows the user to set latitude, longitude and optionally altitude
to be advertised from within the config mode. There are two types of this
package:

It is possible to include ``gluon-config-mode-geo-location`` or
``gluon-config-mode-geo-location-with-map`` in the ``site.mk``.

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

All following options are only valid for the package
``gluon-config-mode-geo-location-with-map``.

config_mode.geo_location.map_lon \: optional
  - represents the default longitude center of the location picker map.
  - defaults to ``0.0``

config_mode.geo_location.map_lat \: optional
  - represents the default latitude center of the location picker map.
  - defaults to ``0.0``

The map will center to the position defined in map_lat and map_lon, unless a
+location was already defined. The new defined location will become the
new center.

config_mode.geo_location.olurl \: optional
  - ``url`` set an url for OpenStreetMap layers.
  - defaults to ``http://dev.openlayers.org/OpenLayers.js``

Example::

  config_mode = {
            geo_location = {
                    map_lon = 52.951947558,
                    map_lat = 7.844238281,
                    olurl = 'http://osm.ffnw.de/.static/ol/OpenLayers.js',
                    show_altitude = true,
            },
  },
