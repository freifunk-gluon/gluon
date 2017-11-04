gluon-config-mode-site-select
=============================

This Package provides a drop-down list for the config mode, to select the site/region
the node will be placed in. If the selection has changed the upgrade scripts in
`/lib/gluon/upgrade/` are triggered.

extra/sites.conf
----------------

site_select.hidden \: optional
  - `0`, show this site in drop-down list (default)
  - `1`, hide this site within config mode

Example::

{
  {
    site_select: = {
      hidden = 1,
    },
    ...
  },
  ...
},
