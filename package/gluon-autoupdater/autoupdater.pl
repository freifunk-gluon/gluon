my $cfg = $CONFIG->{autoupdater};

print <<'END';
#/bin/sh

uci -q batch <<EOF
delete autoupdater.default
set autoupdater.default=autoupdater
END

for (qw(enabled branch url probability good_signatures)) {
  print 'set autoupdater.default.' . $_ . '=' . $cfg->{$_} . "\n";
}

for (@{$cfg->{pubkeys}}) {
  print 'add_list autoupdater.default.pubkey=' . $_ . "\n";
}

print <<END;

commit autoupdater
EOF
END
