all: gluon-radv-filterd respondd.so

gluon-radv-filterd: gluon-radv-filterd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Wall -o $@ $^ $(LDLIBS)

respondd.so: respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -D_GNU_SOURCE -o $@ $^ $(LDLIBS) -lgluonutil
