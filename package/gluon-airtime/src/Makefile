ifeq ($(origin CC),default)
CC             = gcc
endif

# standard compliance
CFLAGS         += -std=c99

# warnings
CFLAGS         += -Wall -Wextra -Wformat=2 -Wshadow -Wpointer-arith
CFLAGS         += -pedantic

all: respondd.so

# sudo apt install libnl-3-dev
airtime-test:	airtime-test.c airtime.c airtime.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -fPIC -D_GNU_SOURCE -lnl-tiny -o $@ airtime.c airtime-test.c $(LDLIBS)

respondd.so: respondd.c airtime.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -D_GNU_SOURCE -lnl-tiny -o $@ airtime.c respondd.c $(LDLIBS)

clean:
	rm -rf *.so airtime-test
