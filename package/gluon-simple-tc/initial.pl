my $cfg = $CONFIG->{simple_tc};

print <<'END';
#/bin/sh

uci -q batch <<EOF
END

while (($name, $interface) = each %{$cfg}) {
  print "set gluon-simple-tc.$name=interface\n";

  for (qw(ifname enabled limit_egress limit_ingress)) {
    print "set gluon-simple-tc.$name.$_=$interface->{$_}\n";
  }
}

print <<END;

commit gluon-simple-tc
EOF
END
