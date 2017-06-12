gluon-config-mode-contact-info
==============================

This package allows the user to provide contact information within config mode to be
distributed in the mesh. You can define whether the owner contact field is
obligatory or not in your site.conf.

site.conf
---------

config_mode.owner.obligatory \: optional (defaults to false)
  If ``obligatory`` is set to ``true``, the contact info field must be supplied
  and may not be left empty.

Example::

  config_mode = {
    owner = {
      obligatory = true
    }
  }
