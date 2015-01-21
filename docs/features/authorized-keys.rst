Adding SSH global public keys
=============================

By using the package ``gluon-authorized-keys`` it is possible to add SSH public
keys to an image while compiling to permit root login.

These keys work global on all nodes running the specific build - be careful not
to lose the private keys.

If you select this package, add a list of authorized keys to ``site.conf`` like this::

    {
        authorized_keys = { 'ssh-rsa AAA.... user1@host',
                            'ssh-rsa AAA.... user2@host },
        hostname_prefix = ...
        ...
    }

Existing keys in ``/etc/dropbear/authorized_keys`` will be preserved on update.

.. seealso:: For Information how to add a SSH keys to single nodes see :doc:`/user/authentication`.
