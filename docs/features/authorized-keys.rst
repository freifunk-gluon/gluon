Adding SSH public keys
======================

By using the package ``gluon-authorized-keys`` it is possible to add
SSH public keys to an image to permit root login.

If you select this package, add a list of authorized keys to ``site.conf`` like this:::

  {
    authorized_keys = { 'ssh-rsa AAA.... user1@host',
                        'ssh-rsa AAA.... user2@host' },
    hostname_prefix = ...
    ...

Existing keys in ``/etc/dropbear/authorized_keys`` will be preserved.
