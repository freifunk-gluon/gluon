my $cfg = $CONFIG->{autoupdater};

my $branch = $ENV{GLUON_BRANCH} || $cfg->{branch};
my $enabled = $ENV{GLUON_BRANCH} ? 1 : 0;

print <<END;
#/bin/sh

uci -q get autoupdater.settings || {
uci -q batch <<EOF
set autoupdater.settings=autoupdater
set autoupdater.settings.branch=$branch
set autoupdater.settings.enabled=$enabled
EOF
}

uci -q batch <<EOF
END

foreach my $name (sort keys $cfg->{branches}) {
  my $branch = $cfg->{branches}->{$name};

  print <<END;

delete autoupdater.$name
set autoupdater.$name=branch
END

  for (qw(name probability good_signatures)) {
    print "set autoupdater.$name.$_=$branch->{$_}\n";
  }

  for (@{$branch->{mirrors}}) {
    print "add_list autoupdater.$name.mirror=$_\n";
  }

  for (@{$branch->{pubkeys}}) {
    print "add_list autoupdater.$name.pubkey=$_\n";
  }
}

print <<END;

commit autoupdater
EOF
END
