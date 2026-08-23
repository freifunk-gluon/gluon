# pynet

Vendored from https://github.com/freifunk-gluon/gluon-qemu-testlab
(commit 11f3720f807d9609ba1c90eaea78ddbc5d24f608, MIT license, see LICENSE),
which is archived upstream.

pynet boots Gluon x86-64 images in QEMU (KVM), wires them into virtual mesh
topologies and drives them over SSH. The test scripts in `tests/` use it. The
copy here is unmodified, so it still boots `./image.img` and needs `asyncssh`
from `../requirements.txt`.
