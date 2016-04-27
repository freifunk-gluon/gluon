gluon-config-mode-geo-location
==============================

This package enables the user to set latitude, longitude and altitude of their
node within config mode. As the usage of the altitude is not well defined the
corresponding field can be disabled.

site.conf
---------

config_mode.geo_location.show_altitude : optional
    - ``true`` enables the altitude field
    - ``false`` disables the altitude field if altitude has not yet been set
    - defaults to ``true``
