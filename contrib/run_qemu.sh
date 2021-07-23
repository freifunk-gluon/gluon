#!/bin/sh

# Note: You can exit the qemu instance by first pressing "CTRL + a" then "c".
#       Then you enter the command mode of qemu and can exit by typing "quit".

qemu-system-x86_64 \
    -d 'cpu_reset' \
    -enable-kvm \
    -gdb tcp::1234 \
    -nographic \
    -netdev user,id=wan,hostfwd=tcp::2223-10.0.2.15:22 \
    -device virtio-net-pci,netdev=wan,addr=0x06,id=nic1 \
    -netdev user,id=lan,hostfwd=tcp::6080-192.168.1.1:80,hostfwd=tcp::2222-192.168.1.1:22,net=192.168.1.100/24 \
    -device virtio-net-pci,netdev=lan,addr=0x05,id=nic2 \
    "$@"
