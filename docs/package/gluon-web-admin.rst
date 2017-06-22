gluon-web-admin
===============

This package allows the user to set options like the password for ssh access
within config mode. You can define in your ``site.conf`` whether it should be
possible to access the nodes via ssh with a password or not and what the mimimum
password length must be.

site.conf
---------

config_mode.remote_login.show_password_form \: optional (defaults to ``false``)
  If ``show_password_form`` is set to ``true``, the password section in
  config mode is shown.

config_mode.remote_login.min_password_length \: optional (defaults to ``12``)
  This sets the minimum allowed password length. Set this to ``1`` to
  disable the length check.

If you want to enable the password login you can use this example::

  config_mode = {
    remote_login = {
      show_password_form = true, -- default false
      min_password_length = 12
    }
  }
