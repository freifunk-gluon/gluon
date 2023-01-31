CC:=gcc
CFLAGS:=
LDFLAGS:=

all: wait-network-request send-network-request

wait-network-request:
	$(CC) $(CFLAGS) $(LDFLAGS) -o wait-network-request wait-network-request.c

send-network-request:
	$(CC) $(CFLAGS) $(LDFLAGS) -o send-network-request send-network-request.c

clean:
	rm -rf send-network-request wait-network-request

.PHONY: clean all
