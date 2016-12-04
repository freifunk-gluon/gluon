ifeq ($(origin CC),default)
CC             = gcc
endif

# standard compliance
CFLAGS         += -std=c99

# warnings
CFLAGS         += -Wall -Wextra -Wformat=2 -Wshadow -Wpointer-arith
CFLAGS         += -pedantic

all: respondd.so

%.c: %.h

# sudo apt install libnl-3-dev
airtime-test: airtime.c ifaces.c airtime-test.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -fPIC -D_GNU_SOURCE -lnl-tiny -o $@ $^ $(LDLIBS)

respondd.so: airtime.c ifaces.c respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -D_GNU_SOURCE -lnl-tiny -o $@ $^ $(LDLIBS)

clean:
	rm -rf *.so airtime-test
