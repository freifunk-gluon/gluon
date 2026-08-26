"""Protocol- and topology-abstractions for mesh test scenarios.

Topologies come from the helpers below and the routing protocol is
detected on the running nodes, so a scenario runs unchanged on every
protocol the rig knows. Only batman-adv is wired up; another protocol
plugs into the tables and branches below.
"""

import os
import shlex
import subprocess
import sys
import time

from pynet import SLOT, Node, connect

PROTOCOLS = ('batman-adv',)

CONVERGENCE_TIMEOUT = {'batman-adv': 180}

_DETECT = {
    'batman-adv': 'batctl',
}

_proto = None


# --- topologies ---

def pair():
    """Two directly connected nodes."""
    a, b = Node(), Node()
    connect(a, b)
    return a, b


def chain(n):
    """n nodes connected in a line: 1 - 2 - ... - n."""
    nodes = [Node() for _ in range(n)]
    for x, y in zip(nodes, nodes[1:]):
        connect(x, y)
    return nodes


def full_mesh(n):
    """n nodes, every pair directly connected."""
    nodes = [Node() for _ in range(n)]
    for i, x in enumerate(nodes):
        for y in nodes[i + 1:]:
            connect(x, y)
    return nodes


# --- protocol abstractions ---

def proto(node):
    """Routing protocol of the image, detected once on a running node."""
    global _proto
    if _proto is None:
        for name, binary in _DETECT.items():
            status, _ = node.execute('which ' + binary)
            if status == 0:
                _proto = name
                break
        else:
            raise Exception('could not detect mesh routing protocol')
        node.dbg('detected mesh protocol: ' + _proto)
    return _proto


def wait_neighbours(node, count):
    """Wait until the routing protocol on node sees >= count neighbours."""
    cmds = {
        'batman-adv': '[ "$(batctl n -H | grep -c .)" -ge {} ]',
    }
    node.wait_until_succeeds(cmds[proto(node)].format(count))


def node_addr(node):
    """An address of node reachable over the mesh."""
    p = proto(node)
    if p == 'batman-adv':
        return node.hostname  # pynet's /etc/hosts entries
    raise Exception('no node address known for ' + p)


def wait_connected(frm, to):
    """Wait until frm knows to at the routing layer, at any hop count -
    for batman-adv, an originator entry for its mesh address."""
    p = proto(frm)
    timeout = CONVERGENCE_TIMEOUT[p]
    if p == 'batman-adv':
        mac = to.succeed('cat /sys/class/net/primary0/address')
        frm.wait_until_succeeds("batctl o -H | grep -q '{}'".format(mac), timeout)
    else:
        raise Exception('no route check known for ' + p)


def wait_all_connected(nodes):
    """Wait until every node knows every other node."""
    for a in nodes:
        for b in nodes:
            if a is not b:
                wait_connected(a, b)


def ping(frm, to, count=5):
    frm.wait_until_succeeds('ping -c {} {}'.format(count, node_addr(to)),
                            CONVERGENCE_TIMEOUT[proto(frm)])


# --- uplink / internet ---

# Overridable so a disconnected lab can point at a local responder
# instead of a public one.
V4_TARGET = os.environ.get('GLUON_TEST_V4_TARGET', '1.1.1.1')
V6_TARGET = os.environ.get('GLUON_TEST_V6_TARGET', '2606:4700:4700::1111')
DNS_NAME = os.environ.get('GLUON_TEST_DNS_NAME', 'one.one.one.one')


def wait_uplink(node, family=6):
    """Wait until the node's uplink has an address and a default route."""
    if family == 4:
        node.wait_until_succeeds('ip -4 addr show dev br-wan | grep -q "inet "')
        node.wait_until_succeeds(
            'ip -4 route show table all | grep "^default" | grep -q br-wan')
    else:
        # any non-link-local address counts; QEMU's user networking
        # hands out fec0::/64
        node.wait_until_succeeds(
            'ip -6 addr show dev br-wan | grep inet6 | grep -qv fe80')
        # gluon keeps uplink routes in a separate policy table
        node.wait_until_succeeds(
            'ip -6 route show table all | grep "^default" | grep -q br-wan')


def uplink_routable(node, family=6):
    """True if the uplink has an address usable as source for global
    traffic. Private IPv4 works through the upstream NAT; the deprecated
    fec0::/64 from QEMU's user networking is never picked as a source."""
    if family == 4:
        cmd = 'ip -4 addr show dev br-wan | grep -q "inet "'
    else:
        cmd = 'ip -6 addr show dev br-wan | grep -qE "inet6 [23]"'
    status, _ = node.execute(cmd)
    return status == 0


def reaches_internet(node, family=6, target=None):
    """True if the node can reach the given address off-mesh."""
    target = target or (V4_TARGET if family == 4 else V6_TARGET)
    status, _ = node.execute('ping -{} -c 3 -W 5 {}'.format(family, target))
    return status == 0


def resolves_dns(node, name=None):
    status, _ = node.execute('nslookup {} >/dev/null'.format(name or DNS_NAME))
    return status == 0


def as_mesh_vpn(cmd):
    """Run a command as the gluon-mesh-vpn group, the only one whose DNS
    is redirected to gluon-wan-dnsmasq. The node has no su or setpriv,
    but start-stop-daemon can change the group."""
    program, _, arguments = cmd.partition(' ')
    return ('start-stop-daemon -S -c :gluon-mesh-vpn -x "$(which {})" -- {}'
            .format(program, arguments))


# --- respondd ---

def respondd_dev(node):
    """The device respondd serves the site-local group on:
    /lib/gluon/respondd/client.dev names a uci interface, resolved to a
    device the way gluon-respondd's init does."""
    return node.succeed(
        'ubus call network.interface dump | jsonfilter -e '
        '"@.interface[@.interface=\'$(cat /lib/gluon/respondd/client.dev)\''
        ' && @.up=true].device"').strip()


# gluon-respondd spreads replies over up to 10 s (-t 10);
# gluon-neighbour-info's default 3 s timeout would lose most of them.
RESPONDD_MAXDELAY = 10


def respondd_query(
        dev, request='nodeinfo', count=2, timeout=RESPONDD_MAXDELAY + 5):
    """Command querying the mesh-wide respondd group ff05::2:1001;
    ff02::2:1001 on the mesh devices only reaches direct neighbours."""
    return ('gluon-neighbour-info -d ff05::2:1001 -p 1001 -r {} -i {} -c {}'
            ' -t {}'.format(request, dev, count, timeout))


# --- firewall ---

def send_from(client, scapy_expr):
    """Send a crafted packet from a client's namespace. scapy_expr runs
    with scapy.all imported and IFACE bound to the client's interface,
    under sys.executable: 'python3' may lack scapy under sudo or outside
    a virtualenv."""
    prog = ('from scapy.all import *\nIFACE={!r}\n{}\n'
            .format(client.at.if_client, scapy_expr))
    return client._ns('{} -c {}'.format(
        shlex.quote(sys.executable), shlex.quote(prog)))


def capture_while(client, pcap_filter, action, seconds=4):
    """Capture on a client's interface while action() runs, and return
    the number of matching packets that arrived."""
    pcap = '/tmp/{}.pcap'.format(client.netns)
    subprocess.run('rm -f ' + pcap, shell=True, check=False)
    tcpdump = subprocess.Popen(
        ['ip', 'netns', 'exec', client.netns, 'tcpdump', '-p', '-U',
            '-i', client.at.if_client, '-w', pcap, pcap_filter],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        time.sleep(1.5)  # let tcpdump attach before anything is sent
        action()
        time.sleep(seconds)
    finally:
        tcpdump.terminate()
        tcpdump.wait()

    out = subprocess.run(
        ['tcpdump', '-nn', '-r', pcap], capture_output=True, text=True,
        check=False).stdout
    return len([line for line in out.splitlines() if line.strip()])


def mesh_dev(node):
    """The device a client frame crosses into the mesh: bat0 on
    batman-adv, otherwise the mesh interfaces themselves."""
    _, out = node.execute(
        'for d in bat0 $(gluon-list-mesh-interfaces); do'
        ' [ -e /sys/class/net/$d ] && echo $d && break; done')
    dev = out.strip()
    if not dev:
        raise Exception('node has no mesh-facing device')
    return dev


def mesh_tx(node, dev=None):
    """Frames the client bridge handed to the mesh-facing device:
    tx_packets plus tx_dropped, since batman-adv drops multicast nobody
    joined, which says nothing about the firewall. Together they move
    for exactly the frames the bridge firewall let out."""
    _, out = node.execute(
        'cd /sys/class/net/{}/statistics && cat tx_packets tx_dropped'
        .format(dev or mesh_dev(node)))
    return sum(int(v) for v in out.split())


def flood_multicast(node):
    """Disable multicast snooping on br-client: otherwise frames to a
    group nothing has joined are dropped before the firewall sees them,
    which looks exactly like a firewall drop."""
    node.succeed('echo 0 > /sys/class/net/br-client/bridge/multicast_snooping')


def dump_firewall(node):
    """The ebtables tables plus fw3's ip6tables rules, also written to
    the node log."""
    # ebtables-tiny is installed under either name
    parts = []
    for label, cmd in (
        ('ebtables-filter',
            'ebtables -t filter -L 2>/dev/null'
            ' || ebtables-tiny -t filter -L 2>/dev/null'),
        ('ebtables-nat',
            'ebtables -t nat -L 2>/dev/null'
            ' || ebtables-tiny -t nat -L 2>/dev/null'),
        ('ip6tables', 'ip6tables -L -n 2>/dev/null'),
    ):
        _, out = node.execute(cmd)
        if out.strip():
            parts.append('### {}\n{}'.format(label, out))
    dump = '\n'.join(parts)
    node.dbg('firewall dump:\n' + dump)
    return dump


# --- attached clients ---

def attach_client(node):
    """Give node a host tap on its client interface, so a Client can
    attach to it. Must be called before start(); requires root."""
    if os.geteuid() != 0:
        raise Exception('client taps require running the scenario as root')
    node.client_tap = True


class Client:
    """A simulated client in its own network namespace.

    Takes the client taps of the given nodes; move_to(node) brings the
    client (one MAC, one SLAAC address) up behind that node, like a
    device roaming through the mesh.
    """

    _count = 0

    def __init__(self, *nodes):
        Client._count += 1
        # Carries the slot like the client tap; the cleanup below would
        # otherwise delete a parallel run's namespace.
        self.netns = 'testclient%d_%d' % (SLOT, Client._count)
        self.mac = '02:00:00:00:%02x:01' % Client._count
        self.at = None

        self._host('ip netns del ' + self.netns, check=False)
        self._host('ip netns add ' + self.netns)
        self._ns('ip link set lo up')
        for node in nodes:
            self._host('ip link set {} netns {}'.format(node.if_client, self.netns))

    def _host(self, cmd, check=True):
        res = subprocess.run(
            cmd, shell=True, capture_output=True, text=True)
        if check and res.returncode != 0:
            # CalledProcessError hides captured stderr; include it
            raise Exception('host command failed: {}\n{}{}'.format(
                cmd, res.stdout, res.stderr))
        return res.stdout

    def _ns(self, cmd, check=True):
        return self._host('ip netns exec {} {}'.format(self.netns, cmd), check=check)

    def move_to(self, node):
        if self.at is not None:
            self._ns('ip -6 addr flush dev ' + self.at.if_client)
            self._ns('ip link set {} down'.format(self.at.if_client))

        tap = node.if_client
        self._ns('ip link set {} address {} down'.format(tap, self.mac))
        self._ns('ip link set {} up'.format(tap))
        self.at = node

    def wait_addr(self, timeout=60):
        """Wait for the SLAAC address on the current node's tap."""
        for _ in range(timeout):
            out = self._ns('ip -6 addr show dev {} scope global'.format(self.at.if_client))
            for line in out.split('\n'):
                line = line.strip()
                if line.startswith('inet6 ') and 'tentative' not in line:
                    return line.split()[1].split('/')[0]
            time.sleep(1)
        raise Exception('client got no SLAAC address on ' + self.at.hostname)

    def succeed(self, cmd):
        return self._ns(cmd)
