use warnings;


my %config;

sub add_config {
	my ($prefix, $c) = @_;

	foreach my $key (keys $c) {
		my $val = $c->{$key};

		if (ref($val) eq 'HASH') {
			add_config($key . '.', $val);
		}
		elsif (ref($val) eq 'ARRAY') {
			$config{'@' . $prefix . $key . '@'} = join ' ', @{$val};
		}
		unless (ref($val)) {
			$config{'@' . $prefix . $key . '@'} = $val;
		}
	}
}

add_config('', $CONFIG);


my $regex = join '|', map {quotemeta} keys %config;


for (<>) {
	s/($regex)/${config{$1}}/g;
	print;
}
