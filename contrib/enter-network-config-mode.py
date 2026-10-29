#!/usr/bin/env python3

"""Send the request activating network-triggered Config Mode on a Gluon node.

The request is sent repeatedly until the script is stopped, so the node can
be power-cycled while it is running. See docs/features/configmode.rst.

On Linux, only the Python standard library is required. On other systems,
such as macOS, BSD or Windows, Scapy (https://scapy.net) is used to send the
request. Sending raw Ethernet frames requires root or administrator
privileges.
"""

import argparse
import sys
import time

# Keep in sync with package/gluon-network-setup-mode/src/gluon-remote-setup-mode.h
DESTINATION = bytes([0x01, 0x80, 0xC2, 0x00, 0x00, 0x0E])
SOURCE = bytes([0xDA, 0xEC, 0xE5, 0x8F, 0x60, 0x14])
ETHERTYPE = bytes([0x23, 0x42])
COMMAND = b"SETUP\0"
INTERVAL = 0.1  # seconds

# Not all drivers pad frames to the minimum Ethernet frame length
MIN_FRAME_LENGTH = 60


def build_frame():
    frame = DESTINATION + SOURCE + ETHERTYPE + COMMAND
    return frame.ljust(MIN_FRAME_LENGTH, b"\0")


def linux_sender(interface):
    import socket

    sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
    sock.bind((interface, 0))
    return sock.send


def scapy_sender(interface):
    try:
        from scapy.all import Raw, conf
    except ImportError:
        sys.exit("Error: Scapy is required on this system, install it with 'pip install scapy'")

    try:
        sock = conf.L2socket(iface=interface)
    except OSError:
        raise
    except Exception as e:
        # Scapy reports errors like a missing interface with its own exceptions
        raise OSError(str(e)) from e

    return lambda frame: sock.send(Raw(frame))


def main():
    parser = argparse.ArgumentParser(
        description="Activate network-triggered Config Mode on a directly attached Gluon node."
    )
    parser.add_argument("interface", help="network interface connected to the node")
    args = parser.parse_args()

    try:
        if sys.platform.startswith("linux"):
            send = linux_sender(args.interface)
        else:
            send = scapy_sender(args.interface)
    except PermissionError:
        sys.exit("Error: sending raw Ethernet frames requires root or administrator privileges")
    except OSError as e:
        sys.exit(f"Error opening interface {args.interface}: {e}")

    frame = build_frame()
    print(f"Sending setup-mode request on {args.interface}, power-cycle the node now (Ctrl-C to stop)", flush=True)

    last_error = None
    try:
        while True:
            # Keep sending on errors, e.g. while the link is down as the node
            # is power-cycled, but only report changes of the error
            try:
                send(frame)
                last_error = None
            except OSError as e:
                if str(e) != last_error:
                    print(f"Error sending packet, retrying: {e}", file=sys.stderr, flush=True)
                last_error = str(e)
            time.sleep(INTERVAL)
    except KeyboardInterrupt:
        print()


if __name__ == "__main__":
    main()
