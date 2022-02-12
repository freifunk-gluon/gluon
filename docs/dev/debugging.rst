Debugging
=========


.. _dev-debugging-kernel-oops:

Kernel Oops
-----------

Sometimes a running Linux kernel detects an error during runtime that can't
be corrected.
This usually generates a stack trace that points to the location in the code
that caused the oops.

Linux kernels in Gluon (and OpenWrt) are stripped.
That means they do not contain any debug symbols.
On one hand this leads to a smaller binary and faster loading times on the
target.
On the other hand this means that in a case of a stack trace the unwinder
can only print memory locations and no further debugging information.

Gluon stores a compressed kernel with debug symbols for every target
in the directory `output/debug/`.
These kernels should be kept along with the images as long as the images
are in use.
This allows the developer to analyse a stack trace later.

Decoding Stacktraces
....................

The tooling is contained in the kernel source tree in the file
`decode_stacktrace.sh <https://github.com/torvalds/linux/blob/master/scripts/decode_stacktrace.sh>`__.
This file and the needed source tree are available in the directory: ::

  openwrt/build_dir/target-<architecture>/linux-<architecture>/linux-<version>/

.. note::
  Make sure to use a kernel tree that matches the version and patches
  that was used to build the kernel.
  If in doubt just re-build the images for the target.

Some more information on how to use this tool can be found at
`LWN <https://lwn.net/Articles/592724/>`__.

Obtaining Stacktraces
.....................

On many targets stacktraces can be read from the following
location after reboot: ::

  /sys/kernel/debug/crashlog
