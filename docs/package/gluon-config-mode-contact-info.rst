gluon-config-mode-contact-info
==============================

This package allows the user to provide contact information within config mode to be 
distributed in the mesh. You can define whether the owner contact field is 
obligatory or not in your site.conf.

site.conf
---------

config_mode.owner.obligatory : this whole section is optional
    - ``true`` field is obligatory: gluon-node-info.@owner[0].contact may not be empty
    - ``false`` field is optional: gluon-node-info.@owner[0].contact may be empty
    - defaults to ``false``

# example:

  config_mode = {
    geo_location = {
      show_altitude = true,
    },
    owner = {
      obligatory = true
    },
  },


    