my $cfg = $CONFIG->{fastd_mesh_vpn};
my $backbone = $cfg->{backbone};

my $add_methods = '';
for (@{$cfg->{methods}}) {
	$add_methods .= "add_list fastd.mesh_vpn.method='$_'\n";
}

my $set_peer_limit;
if ($backbone->{limit}) {
	$set_peer_limit = "set fastd.mesh_vpn_backbone.peer_limit='$backbone->{limit}'\n";
}
else {
	$set_peer_limit = "delete fastd.mesh_vpn_backbone.peer_limit\n";
}

print <<END;
#/bin/sh

uci -q batch <<EOF
set fastd.mesh_vpn='fastd'
set fastd.mesh_vpn.syslog_level='verbose'
delete fastd.mesh_vpn.config
delete fastd.mesh_vpn.config_peer_dir

set fastd.mesh_vpn.interface='mesh-vpn'
set fastd.mesh_vpn.mode='tap'
set fastd.mesh_vpn.mtu='$cfg->{mtu}'
delete fastd.mesh_vpn.method
$add_methods
delete fastd.mesh_vpn_backbone
set fastd.mesh_vpn_backbone='peer_group'
set fastd.mesh_vpn_backbone.enabled='1'
set fastd.mesh_vpn_backbone.net='mesh_vpn'
$set_peer_limit
END

foreach my $name (sort keys %{$backbone->{peers}}) {
	my $peer = $backbone->{peers}->{$name};
	print <<EOF;

delete fastd.mesh_vpn_backbone_peer_$name
set fastd.mesh_vpn_backbone_peer_$name='peer'
set fastd.mesh_vpn_backbone_peer_$name.enabled='1'
set fastd.mesh_vpn_backbone_peer_$name.net='mesh_vpn'
set fastd.mesh_vpn_backbone_peer_$name.group='mesh_vpn_backbone'
set fastd.mesh_vpn_backbone_peer_$name.key='$peer->{key}'
EOF

	for (@{$peer->{remotes}}) {
		print "add_list fastd.mesh_vpn_backbone_peer_$name.remote='$_'\n";
	}
}

print <<END;

commit fastd
EOF
END
