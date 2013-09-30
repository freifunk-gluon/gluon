#!/usr/bin/perl

use warnings;
use strict;


our $CONFIG = do $ENV{GLUONDIR} . '/site/site.conf';

my $script = shift @ARGV;
do $script;
