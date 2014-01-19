my $cfg = $CONFIG->{simple_tc};

print "#/bin/sh\n\n";

foreach my $name (sort keys %{$cfg}) {
  my $interface = $cfg->{$name};

  print "uci -q get gluon-simple-tc.$name >/dev/null || uci -q batch <<EOF\n";
  print "set gluon-simple-tc.$name=interface\n";

  for (qw(enabled ifname limit_egress limit_ingress)) {
    print "set gluon-simple-tc.$name.$_=$interface->{$_}\n";
  }

  print "EOF\n\n";
}

print "uci commit gluon-simple-tc\n";
