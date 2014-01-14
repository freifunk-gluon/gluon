my $cfg = $CONFIG->{fastd_mesh_vpn};
my $backbone = $cfg->{backbone};

my $add_methods = '';
for (@{$cfg->{methods}}) {
	$add_methods .= "uci add_list fastd.mesh_vpn.method='$_'\n";
}

my $set_peer_limit;
if ($backbone->{limit}) {
	$set_peer_limit = "uci_set fastd mesh_vpn_backbone peer_limit '$backbone->{limit}'\n";
}
else {
	$set_peer_limit = "uci_remove fastd mesh_vpn_backbone peer_limit\n";
}

print <<END;
#/bin/sh

. /lib/functions.sh
. /lib/gluon/functions/sysconfig.sh
. /lib/gluon/functions/users.sh

add_user gluon-fastd 800

uci_add fastd fastd mesh_vpn

uci_remove fastd mesh_vpn config
uci_remove fastd mesh_vpn config_peer_dir

uci_set fastd mesh_vpn user 'gluon-fastd'
uci_set fastd mesh_vpn syslog_level 'verbose'
uci_set fastd mesh_vpn interface 'mesh-vpn'
uci_set fastd mesh_vpn mode 'tap'
uci_set fastd mesh_vpn mtu '$cfg->{mtu}'

uci_remove fastd mesh_vpn method
$add_methods

uci_remove fastd mesh_vpn_backbone
uci_add fastd peer_group mesh_vpn_backbone
uci_set fastd mesh_vpn_backbone enabled '1'
uci_set fastd mesh_vpn_backbone net 'mesh_vpn'
$set_peer_limit
END

foreach my $name (sort keys %{$backbone->{peers}}) {
	my $peer = $backbone->{peers}->{$name};
	print <<EOF;
uci_remove fastd 'mesh_vpn_backbone_peer_$name'
uci_add fastd peer 'mesh_vpn_backbone_peer_$name'
uci_set fastd 'mesh_vpn_backbone_peer_$name' enabled '1'
uci_set fastd 'mesh_vpn_backbone_peer_$name' net 'mesh_vpn'
uci_set fastd 'mesh_vpn_backbone_peer_$name' group 'mesh_vpn_backbone'
uci_set fastd 'mesh_vpn_backbone_peer_$name' key '$peer->{key}'
EOF

	for (@{$peer->{remotes}}) {
		print "uci add_list fastd.mesh_vpn_backbone_peer_$name.remote='$_'\n";
	}
}

print <<'END';

uci_add network interface mesh_vpn
uci_set network mesh_vpn ifname 'mesh-vpn'
uci_set network mesh_vpn proto 'batadv'
uci_set network mesh_vpn mesh 'bat0'
uci_set network mesh_vpn mesh_no_rebroadcast '1'

mainaddr=$(sysconfig primary_mac)
oIFS="$IFS"; IFS=":"; set -- $mainaddr; IFS="$oIFS"
b2mask=0x02
vpnaddr=$(printf "%02x:%s:%s:%02x:%s:%s" $(( 0x$1 | $b2mask )) $2 $3 $(( (0x$4 + 1) % 0x100 )) $5 $6)
uci_set network mesh_vpn macaddr "$vpnaddr"

uci_commit fastd
uci_commit network
END
