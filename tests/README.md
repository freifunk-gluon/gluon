# Integration tests

QEMU/KVM-based mesh integration tests: real firmware images booted as
guests, wired into a mesh and driven over SSH.

```sh
pip install -r requirements.txt
sudo ./run.py --image ../output/images/factory/gluon-*-x86-64.img.gz
```

Tests live next to the package they exercise, in a `tests/` directory
holding a `.gluon_tests` marker file, and run when that package is
installed on the image.

Shared code lives here:

- `pynet/` - boots x86-64 images in QEMU and drives them over SSH
- `meshlib.py` - topologies, protocol abstractions, attached clients,
    respondd and firewall helpers
- `run.py` - selects and runs tests

`docs/dev/tests.rst` has the rest: how tests are selected, how to run
them, and the API reference generated from these modules.
