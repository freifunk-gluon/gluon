gluon-site-generate
===================

This package generates the needed `site.json` directly on the node after firmware
upgrade has been performed. This can be used, to support different sites/regions
within one firmware image. The default `site.json` will be replaced by
`extra/template.conf` which is partially replaced by values defined in
`extra/sites.conf` and `extra/groups.conf`.

One can generate the `site.conf` before build with: `GLUON_SITEDIR=$PATH ./scripts/gen-site-conf.lua`

This does not belong to the `site.mk`.

extra/sites.conf
----------------

Array of possible sites, containing site specific configuration different to the
original site.conf and group specific config. Same configuration as in the site.conf
can be done here.

site_select.group \: optional
  specify a group out of `extra/groups.conf` the site belongs to

Example::

{
  {
    site_name = 'Freifunk Alpha Centauri - North',
    site_code = 'ffxx_north',
    subst = {
      ['%%ID'] = 1,
      ['%%CD'] = 'north',
    },
    site_select = {
      group = 'ffxx_23',
    },
  },
  ...
}


extra/groups.conf
-----------------

Array of groups, containing group specific configuration different to the original
site.conf. Same configuration as in the site.conf can be done here.

Example::

{
  ffac_23 = {
    subst = {
      ['%%V4'] = '10.xxx.0.0/21',
      ['%%V6'] = 'fdxx:xxxx:xxxx::/64',
      ...
    },
  },
  ...
}


extra/default.conf
------------------

An array, containing the default configuration, to create site.conf out of template.conf before build.

Example::

subst = {
  ['%%SN'] = 'Freifunk Alpha Centauri - Legacy',
  ['%%SC'] = 'ffxx',
  ['%%SS'] = 'a-centauri.freifunk.net/legacy',
  ...
}

