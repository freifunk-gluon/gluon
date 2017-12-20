all: gluon-radv-filterd respondd.so

CPPFLAGS += -D_GNU_SOURCE

gluon-radv-filterd: gluon-radv-filterd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Wall -o $@ $^ $(LDLIBS)

respondd.so: respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -o $@ $^ $(LDLIBS) -lgluonutil
