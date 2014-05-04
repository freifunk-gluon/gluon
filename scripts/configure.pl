#!/usr/bin/perl

use warnings;
use strict;
use POSIX qw(strftime);


sub nightly {
    strftime "%Y%m%d", localtime;
}


our $CONFIG = do $ENV{GLUONDIR} . '/site/site.conf';

my $script = shift @ARGV;
do $script;
