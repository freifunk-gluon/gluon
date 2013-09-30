#!/usr/bin/perl

use warnings;
use strict;


my %config;

sub add_config {
    my ($prefix, $c) = @_;

    foreach my $key (keys $c) {
	my $val = $c->{$key};

	if (ref($val) eq 'HASH') {
	    add_config($key . '.', $val);
	}
	unless (ref($val)) {
	    $config{'@' . $prefix . $key . '@'} = $val;
	}
    }
}

sub read_config {
    my $input = shift;
    my $CONFIG = do $input;
    add_config('', $CONFIG);
}


read_config 'site/site.conf';


my $regex = join '|', map {quotemeta} keys %config;


for (<>) {
    s/($regex)/${config{$1}}/g;
    print;
}
