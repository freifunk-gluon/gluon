# Integration tests

QEMU/KVM-based mesh integration tests, driven by the vendored
[pynet](pynet/README.md) module.

Tests live next to the package they exercise, in a `tests/` directory
holding a `.gluon_tests` marker file:

```
package/gluon-core/tests/.gluon_tests
package/gluon-core/tests/connect_two.py
package/gluon-respondd/tests/test_respondd.py
...
```

Both gluon's own `package/` tree and every checked-out feed under
`packages/` are scanned, so a package feed a site pulls in through
`GLUON_SITE_FEEDS` can ship tests the same way. The marker is what
distinguishes them from the unrelated `tests/` directories some
upstream packages ship.

A test runs when its own package is installed on the image. If it needs
more than that, it says so in a header:

```python
# requires: gluon-mesh-batman-adv
```

`run.py` reads the installed package list from `<image>.packages` next
to the image, and boots one node to produce it when that file is missing
or older than the image. The image therefore decides which tests apply -
no protocol flags to keep in sync. `--all` skips the probe and runs
everything.

Shared code lives here:

- `pynet/` - boots x86-64 images in QEMU and drives them over SSH
- `meshlib.py` - topology helpers (`pair()`, `chain(n)`, `full_mesh(n)`),
    protocol abstractions (`wait_neighbours()`, `wait_connected()`,
    `ping()`) that auto-detect the routing protocol on the running
    image, attached clients (`attach_client()`, `Client`), respondd and
    firewall helpers
- `run.py` - selects and runs tests, two at a time by default (`-j`)

Usage:

```sh
pip install -r requirements.txt
sudo ./run.py --image ../output/images/factory/gluon-*-x86-64.img.gz
sudo ./run.py connect_two firewall_packets   # named tests only
```

`--image` takes a `.img` or a `.img.gz`; a gzipped image is unpacked next
to the archive and reused until the archive changes - so a rebuild is only
needed when the packages or site config actually change.

Root is needed for the tests that attach clients (network namespaces and
taps); `tcpdump` and `scapy` are needed for the firewall packet test.

Each test gets `tests/run/<test>/` with its output in `test.log` and the
node consoles under `logs/`.

Images are built per site config, which selects the routing protocol;
`../contrib/ci/minimal-site` builds a batman-adv one.
