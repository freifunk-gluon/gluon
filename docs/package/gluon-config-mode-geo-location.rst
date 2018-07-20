gluon-config-mode-geo-location
==============================

This package allows the user to set latitude, longitude and optionally altitude
within config mode. There are 2 types of this package.

It is possible to include ``gluon-config-mode-geo-location`` or
``gluon-config-mode-geo-location-with-map`` in the ``site.mk``.

gluon-config-mode-geo-location-with-map
---------------------------------------

The package ``gluon-config-mode-geo-location-with-map`` will additionally and a
map where users can pick a position. This map will only shown if the users
computer will have an internet connection.

site.conf
^^^^^^^^^

This option is valid for both typ of package.

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

The above 2 options will usually shown on a factory flashed Router. If a node
is reenter the config mode the maps center will be on the last defined
position.

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
