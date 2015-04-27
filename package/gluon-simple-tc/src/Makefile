all: gluon-simple-tc

gluon-simple-tc: gluon-simple-tc.c
	$(CC) -Iinclude $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Wall -o $@ $^ $(LDLIBS) -lnl-tiny
