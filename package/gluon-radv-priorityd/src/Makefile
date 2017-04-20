all: gluon-radv-priorityd

LDLIBS += $(shell pkg-config --libs libnetfilter_queue)

gluon-radv-priorityd: gluon-radv-priorityd.c

clean:
	rm gluon-radv-priorityd
