gluon-web-admin
===============

This package allows the user to set options like the password for ssh access
within config mode. You can define in your ``site.conf`` whether it should be
possible to access the nodes via ssh with a password or not and what the minimum
password length must be.

site.conf
---------

config_mode.remote_login.show_password_form \: optional
  - ``true`` the password section in config mode is shown
  - ``false`` the password section in config mode is hidden
  - defaults to ``false``

config_mode.remote_login.min_password_length \: optional
  - sets the minimum allowed password length. Set this to ``1`` to disable the
    length check.
  - defaults to ``12``

Example::

  config_mode = {
    remote_login = {
      show_password_form = true, -- default false
      min_password_length = 12
    }
  }
