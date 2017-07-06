#!/bin/bash

# checks if the site.conf is a valid lua dict

GLUON_SITEDIR="docs/site-example" lua5.1 scripts/site_config.lua

bash -n scripts/*.sh

cp -a docs/site-example site

TARGET=ar71xx-generic
make update GLUON_TARGET=$TARGET
make clean GLUON_TARGET=$TARGET
make GLUON_TARGET=$TARGET
