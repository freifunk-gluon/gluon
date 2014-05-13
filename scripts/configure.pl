#!/usr/bin/perl

use warnings;
use strict;
use POSIX qw(strftime);


sub nightly {
    strftime "%Y%m%d", localtime;
}


our $CONFIG = do $ENV{GLUONDIR} . '/site/site.conf.pl';

my $script = shift @ARGV;
do $script;
