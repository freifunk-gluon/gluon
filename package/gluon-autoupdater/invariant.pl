my $cfg = $CONFIG->{autoupdater};

print <<'END';
#/bin/sh

uci -q get autoupdater.settings || {
uci -q batch <<EOF
set autoupdater.settings=autoupdater
END

for (qw(enabled branch)) {
  print "set autoupdater.settings.$_=$cfg->{$_}\n";
}

print <<'END';
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

  for (qw(url probability good_signatures)) {
    print "set autoupdater.$name.$_=$branch->{$_}\n";
  }

  for (@{$branch->{pubkeys}}) {
    print "add_list autoupdater.$name.pubkey=$_\n";
  }
}

print <<END;

commit autoupdater
EOF
END
