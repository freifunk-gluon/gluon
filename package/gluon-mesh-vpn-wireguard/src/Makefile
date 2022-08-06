all: respondd.so gluon-hex-to-b64

CFLAGS += -Wall -Werror-implicit-function-declaration

gluon-hex-to-b64: gluon-hex-to-b64.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -Wall -o $@ $^ $(LDLIBS) -lubox

respondd.so: respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -D_GNU_SOURCE -o $@ $^ $(LDLIBS) -lgluonutil -lubus
