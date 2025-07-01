gluon-harden-dropbear
=====================

This package reduces the attack surface of dropbear, the SSH server on the router.

If the root account either has no password configured or is locked,
password authorization is disabled in dropbear's settings.

If furthermore no SSH key is authorized to login, the ``dropbear`` service is disabled.

Changing the password or updating authorized keys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Via console
"""""""""""

Upon editing */etc/dropbear/authorized_keys* or changing root's password,
a call to *gluon-reconfigure* as well as a reboot might be needed in order to have dropbear launched conditionally upon boot.

.. code-block:: bash

  passwd
  gluon-reconfigure
  reboot


In setup-mode
"""""""""""""

As *gluon-reconfigure* is run when rebooting from the setup-mode web interface, no further steps are required.
