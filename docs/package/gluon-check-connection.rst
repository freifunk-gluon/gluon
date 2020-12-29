gluon-check-connection
======================

This package adds a script that checks if at least one connection to IPv6 hosts
defined as *target groups* is working using the ping command. 
The script is called once every minute by ``micrond``.
For example one can define a group of *local* targets to check if a connection
to hosts in the mesh network is possible (e.g. time or update servers) and 
*global* targets for checking if a connection to the global internet is possible.
Currently only IPv6 addresses are supported.
This is e.g. used by the *gluon-scheduled-domain-switch* package

site.conf
---------

Target groups can be pre-defined in the domain config.

::

    check_connection = {
        targets = {
	    targets_local = {
                'fe80::dead:c0de:1',
                'fe80::bad:c0de:1',
                'fe80::dead:c0de:2',
                'fe80::bad:c0de:2',
            },
            targets_global = {
                '2620:0:ccc::2', -- OpenDNS
                '2001:4860:4860::8888', -- Google DNS
                '2600::1', -- Sprint DNS
                '2620:0:ccd::2', -- OpenDNS
                '2001:4860:4860::8844', -- Google DNS
                '2600::2', -- Sprint DNS
            },
	},
    },


Defining target groups in the site.conf will overwrite existing ones with the same
name when performing a *sysupgrade* or by triggering *gluon-reconfigure*.

Configuration via UCI
---------------------

Packages can use gluon-check-connection to be triggered after connection checks.
For this they can define the following *script* attributes:

script : an entry for defining the ping target
    enabled : 
        - a boolean defining whether the target will be considered
    interval :
        - the interval to execute the trigger script (in minutes - defaults to 1)
    command :
        - the command to execute
    groups :
        - the target groups array on which the ping test will be performed on
    onchange :
        - if set true the command is only being executed on a state change or always otherwise
    trigger :
        - on which the command is being executed (``offline``, ``online`` or unset for both)


*target* groups can be defined with the following attributes:

target : an entry for defining the IPv6 adress to ping
    hosts :
        - array containing the IPv6 addresses to perform the ping test on

