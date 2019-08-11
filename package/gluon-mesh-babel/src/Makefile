all: respondd.so neighbours-babel

CFLAGS += -Wall -g -fPIC -D_GNU_SOURCE

ifeq ($(origin PKG_CONFIG), undefined)
	PKG_CONFIG = pkg-config
	ifeq ($(shell which $(PKG_CONFIG) 2>/dev/null),)
		$(error $(PKG_CONFIG) not found)
	endif
endif

ifeq ($(origin LIBBABEL_CFLAGS) $(origin LIBBABEL_LDLIBS), undefined undefined)
	LIBBABEL_NAME ?= libbabelhelper
	ifeq ($(shell $(PKG_CONFIG) --modversion $(LIBBABEL_NAME) 2>/dev/null),)
		$(error No $(LIBBABEL_NAME) development libraries found!)
	endif
	LIBBABEL_CFLAGS += $(shell $(PKG_CONFIG) --cflags $(LIBBABEL_NAME))
	LIBBABEL_LDLIBS +=  $(shell $(PKG_CONFIG) --libs $(LIBBABEL_NAME))
endif
CFLAGS += $(LIBBABEL_CFLAGS)
LDLIBS += $(LIBBABEL_LDLIBS)

CFLAGS_JSONC = $(shell pkg-config --cflags json-c)
LDFLAGS_JSONC = $(shell pkg-config --libs json-c)


respondd.so: respondd.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(LDLIBS) -shared $(LDFLAGS_JSONC) -o $@ $^ -lgluonutil -lblobmsg_json -lubox -lubus -luci

neighbours-babel: neighbours-babel.c handle_neighbour.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(CFLAGS_JSONC) $(LDFLAGS) $(LDLIBS) $(LDFLAGS_JSONC) -o $@ $^
