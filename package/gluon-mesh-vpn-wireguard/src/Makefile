all: respondd.so

CFLAGS += -Wall -Werror-implicit-function-declaration

respondd.so: respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -D_GNU_SOURCE -o $@ $^ $(LDLIBS) -lgluonutil -lubus
