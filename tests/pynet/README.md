# pynet

Vendored from https://github.com/freifunk-gluon/gluon-qemu-testlab
(commit 11f3720f807d9609ba1c90eaea78ddbc5d24f608, MIT license, see LICENSE),
which is archived upstream.

pynet boots Gluon x86-64 images in QEMU (KVM), wires them into virtual mesh
topologies and drives them over SSH. The test scripts in `tests/` use it:

```sh
cd tests
pip install -r requirements.txt
GLUON_IMAGE=../output/images/factory/gluon-*-x86-64.img python3 <test>.py
```

Environment variables:

- `GLUON_IMAGE` — path to the firmware image (default: `./image.img`)
- `GLUON_QEMU_BIOS` — firmware for QEMU's `-bios` (e.g. an OVMF path;
    required for `combined-efi` images)
