SSH Authentication
==================

The methods described here can also be configured via :doc:`/features/configmode`.

Telnet access is only possible when booting into failsafe-mode. How boot into failsafe-mode
is explained in the `openwrt wiki <http://wiki.openwrt.org/de/doc/howto/generic.failsafe>`_.

SSH login will be possible after the start of dropbear, which is regularly performed
when running in normal mode.

Adding a password
-----------------

Setting a password for any user on the Nodes - especially for root - is *not encouraged*.
It comes handy, though, especially when logging in from via a remote machine that
does not have your own SSH private key, e.g. directly from a gateway machine.

Passwords keep certain pitfalls, mostly they are too short or too easy to guess/brutforce
and therefore insecure. If in doubt consider using SSH public keys.

If setting a password via :doc:`/features/configmode` was disabled for security reasons, please:

 * boot into failsafe-mode
 * telnet the node on ``192.168.1.1``
 * when connected::

    $ mount_root
    $ passwd

For users other than root, please perform as you would do with any other Linux machine.

Adding SSH public keys
----------------------

If it is not possible to set a SSH public key via :doc:`/features/configmode`, you can
append your key to ``/etc/dropbear/authorized_keys`` manually using:

    * a (temporary) password
    * the failsafe-mode

.. seealso:: For Information how to add SSH public keys to the images while compiling see :doc:`/features/authorized-keys`
