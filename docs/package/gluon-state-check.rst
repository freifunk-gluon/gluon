gluon-state-check
=================

This package provides a result cache for the routers state during runtime.

This allows for packages to use recent check results, which might be costly
or are otherwise hard to obtain.

gluon-state-check executes checks in `/lib/gluon/state/check.d/` and provides
a flag file for each check in `/var/gluon/state` depending on the return code
of the check. A flag file is created (or "touched") if the corresponding check
exits cleanly and gets removed otherwise. If the flags are "touched", they
are only accessed, but not modified. In this way, the atime of a flag file
reflects when the last check was performed and the mtime reflects when
when the state was last changed.

This package provides the following checks:
- `has_default_gw6` - check whether the router has a default IPv6-route on br-client.
- `has_ntp_sync` - check whether the last stratum event of busybox ntpd was <16
- `has_lost_ntp_sync` - check whether the last stratum event of busybox was 16

The checks are executed once every minute (by micron.d).
The two NTP checks are hotplug results of ntpd and as a result not available
in the first 11 minutes of uptime.

Lastly this package provides a helper called `gluon-ntp-info`,
which acts as a reference on how to interpret the modification and creation times of
state check files.
