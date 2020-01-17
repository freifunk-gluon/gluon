all: respondd.so

CFLAGS += -Wall

SOURCES = respondd.c respondd-nodeinfo.c respondd-statistics.c respondd-neighbours.c

respondd.so: $(SOURCES) respondd-common.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -shared -fPIC -fvisibility=hidden -D_GNU_SOURCE -o $@ $(SOURCES) $(LDLIBS) -lgluonutil -lplatforminfo -luci -liwinfo
