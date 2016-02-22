CFLAGS += -std=c99 -D_BSD_SOURCE

CFLAGS_JSONC = $(shell pkg-config --cflags json-c)
LDFLAGS_JSONC = $(shell pkg-config --libs json-c)

all: neighbours-batadv stations respondd.so

neighbours-batadv: neighbours-batadv.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CFLAGS_JSONC) $(LDFLAGS) $(LDFLAGS_JSONC) -Wall -o $@ $^ $(LDLIBS)

stations: stations.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CFLAGS_JSONC) $(LDFLAGS) $(LDFLAGS_JSONC) -Wall -o $@ $^ $(LDLIBS) -liwinfo

respondd.so: respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -o $@ $^ $(LDLIBS)
