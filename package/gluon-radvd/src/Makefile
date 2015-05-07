all: gluon-radvd

gluon-radvd: gluon-radvd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Wall -o $@ $^ $(LDLIBS) -lrt
