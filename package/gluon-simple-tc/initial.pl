my $cfg = $CONFIG->{simple_tc};

print <<'END';
#/bin/sh

uci -q batch <<EOF
END

foreach my $name (sort keys %{$cfg}) {
  my $interface = $cfg->{$name};

  print "set gluon-simple-tc.$name=interface\n";

  for (qw(enabled ifname limit_egress limit_ingress)) {
    print "set gluon-simple-tc.$name.$_=$interface->{$_}\n";
  }
}

print <<END;

commit gluon-simple-tc
EOF
END
